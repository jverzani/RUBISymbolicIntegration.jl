## This is basically the frontend.jl file from SymbolicIntegration

# The functions a symbolic type must provide are in `interface.jl`

# does the expression have an unevaluated integral?
contains_int(expr) = contains_op(:∫, expr)


function integrate(f, dx) # apply_rules
    problem = make_integral(f, dx)
    return repeated_prewalk(problem)
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

            # TODO Can this be a bad idea sometimes?
            simplified_expr = _simplify(expr, expand=true)
            if simplified_expr !== expr
                (new_expr,success) = apply_rules(simplified_expr)
                if !success
                    return new_expr
                end
            end
            return new_expr
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
    for (j, rule) in enumerate(RULES)
        out, success = apply_single_rule(rule, problem, j)
        if success
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
    σs = _eachmatch(rule.lhs, problem)
    for σ ∈ σs
        out = try
            rule.f(σ)
        catch err
            if VERBOSE
                println("----- error rule $j ($(IDENTIFIERS[j])) ----")
                @show problem rule σ err
            end
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
