## This is basically the frontend.jl file from SymbolicIntegration


# contains_op(∫, expr) is the same as checking if the integral has been completely solved

contains_int(expr) = "define me" #contains_op(∫, expr)
make_integral() = "Define me"


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
            #@show :rp, success, contains_int(new_expr), new_expr

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


# check problem against rule = RULES[j]
function apply_single_rule(rule, problem, j)
    seen = Any[problem]
    σs = _eachmatch(first(rule), problem)
    for σ ∈ σs
        ex = _rewrite(σ, last(rule))
        out = try
            eval(ex)
        catch err
            println("----- error rule $j ----")
            @show problem
            @show rule[1]
            @show σ
            @show rule[2]
            @show ex
            @show err
            nothing
        end
        out === nothing && continue
        #@show out ∈ seen, out, seen
        anyQ(out, isnan) && continue
        #@show out ∈ seen, σ, out
        out ∈ seen && break # oddly using continue doesn't work apostol[151]
        push!(seen, out)
        if !isequal(out, problem)
            #@show :rule_match, j, problem
            return (out, true)
        end
    end
    return (problem, false)
end
