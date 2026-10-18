## This is basically the frontend.jl file from SymbolicIntegration

# The functions a symbolic type must provide are in `interface.jl`

# does the expression have an unevaluated integral?
contains_int(expr) = contains_op(:∫, expr)


"""
    integrate(f, x; verbose=false)

Integrate `f` with respect to `x` by applying the RUBI rules. The result
contains an unevaluated `∫` when no rule applies.

With `verbose=true`, each rule is printed as it is applied, with the
integral it matched and what it rewrote it to; integrals that a rule
integrates in turn are shown inside its step. The identifier, such as `1_1_1_1_2`,
names the rule's section in RUBI: here, 1.1.1.1 `(a+b x)^m`.
"""
function integrate(f, dx; verbose::Bool=VERBOSE[]) # apply_rules
    # a rule may call `integrate` on a subproblem, which then inherits `verbose`
    old = VERBOSE[]
    VERBOSE[] = verbose
    try
        problem = make_integral(f, dx)
        return repeated_prewalk(problem)
    finally
        VERBOSE[] = old
    end
end

# where `verbose` steps go. While a rule's right-hand side runs, this is a
# buffer, so the steps of the integrals it does in turn print inside its own
# step, and are dropped if the rule does not apply after all. `nothing` is
# the current `stdout` (not the one at precompile time)
const STEP_IO = Ref{Union{IO,Nothing}}(nothing)
step_io() = something(STEP_IO[], stdout)

# print one step of `integrate(f, x; verbose=true)`; `inner` holds the steps
# taken while the rule's right-hand side ran
function print_step(io::IO, j, problem, out, inner)
    id = IDENTIFIERS[j]
    printstyled(io, "┌ rule ", id, " on "; bold=true)
    printstyled(io, string(problem), "\n"; color=:light_red)
    # `pretty_print_rule` gives "lhs => if", the conditions, then the result;
    # show it as lhs, "if" and the conditions, then "=> result"
    lines = split(pretty_print_rule(RULES[j], id), '\n')
    if length(lines) > 2 && endswith(rstrip(lines[1]), "=> if")
        lhs = rstrip(chopsuffix(rstrip(lines[1]), "=> if"))
        lines = [lhs; "  if"; lines[2:end-1]; "  => " * strip(lines[end])]
    end
    for line in lines
        println(io, "│   ", line)
    end
    for line in eachline(IOBuffer(inner))
        println(io, "│ ", line)
    end
    printstyled(io, "└ gives "; bold=true)
    printstyled(io, string(out), "\n"; color=:light_blue)
end

function repeated_prewalk(expr, n=50)
    !iscall(expr) && return expr # termination condition
    n < 0 && return expr
    new_expr = expr
    if Symbol(operation(expr)) == :∫
        (new_expr,success) = apply_rules(expr)
        if success
            # cannot directly return new_expr because even if a rule
            # is applied the result could still contain integrals
            !contains_int(new_expr) && return new_expr #_simplify(new_expr)
            return repeated_prewalk(new_expr, n-1)

        else
            # No rule applies: try the integral simplified (with expand=true),
            # then fully expanded. Which form a rule matches depends on the
            # type: e.g. -a*b + (a + b)*x - x^2 or 1//2 + x//2 + x^2//2.
            for alt in (_simplify(expr, expand=true), _expand(expr))
                isequal(alt, expr) && continue
                VERBOSE[] && println(step_io(), "no rule for ", expr, "; trying ", alt)
                (new_expr, success) = apply_rules(alt)
                success || continue
                !contains_int(new_expr) && return new_expr
                return repeated_prewalk(new_expr, n-1)
            end
            VERBOSE[] && println(step_io(), "no rule for ", expr)
            return expr
        end
    end

    expr = maketerm(
        typeof(expr),
        operation(expr),
        map(Base.Fix2(repeated_prewalk, n-1), arguments(expr)),
        nothing
    )

    return expr
end


function apply_rules(problem)
    VERBOSE[] && return apply_rules_verbose(problem)
    for (j, rule) in enumerate(RULES)
        out, success = apply_single_rule(rule, problem, j)
        success && return (out, true)
    end
    return (problem, false)
end

function apply_rules_verbose(problem)
    old = STEP_IO[]
    io = step_io()
    for (j, rule) in enumerate(RULES)
        buf = IOBuffer()
        STEP_IO[] = IOContext(buf, :color => get(io, :color, false))
        out, success = try
            apply_single_rule(rule, problem, j)
        finally
            STEP_IO[] = old
        end
        if success
            print_step(io, j, problem, out, String(take!(buf)))
            return (out, true)
        end
    end
    return (problem, false)
end


# a rule signals an undefined result (e.g. ⨸ by 0) with NaN. Not every
# symbolic type is a `Number`, so check only numeric values
_isnan(x) = (u = unwrap_const(x); isa(u, Number) && isnan(u))

# check problem against rule = RULES[j]
#
# Every match is tried, not just the first: a rule's right-hand side returns
# `nothing` when its conditions on the match fail, and another match may
# satisfy them.
function apply_single_rule(rule::Rule, problem, j)
    seen = Any[problem]
    σs = _ceachmatch(rule.lhs, problem)
    for σ ∈ σs
        out = try
            rule.f(σ)
        catch err
            # a guard erroring on a match it was not meant for is routine;
            # see these with JULIA_DEBUG=RUBISymbolicIntegration
            @debug "error in rule $j ($(IDENTIFIERS[j]))" problem σ err
            nothing
        end
        out === nothing && continue
        anyQ(out, _isnan) && continue
        # `isequal`, as `==` need not return a Bool for a symbolic type
        any(isequal(out), seen) && break # oddly using continue doesn't work apostol[151]
        push!(seen, out)
        if !isequal(out, problem)
            return (out, true)
        end
    end
    return (problem, false)
end
