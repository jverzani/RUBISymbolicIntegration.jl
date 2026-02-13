### ---- match, eachmatch, rewrite, replace

function _match(pat::Union{Symbol, Expr}, sub)
    σs = _eachmatch(pat, sub)
    σ = iterate(σs)
    isnothing(σ) && return nothing
    first(σ)
end


# return iterator of each possible match
function _eachmatch(pat::Union{Symbol, Expr}, sub)
    check_expr_r(sub, pat, [MatchDict()])
end


# replace variables in rhs with values looked upin σ
# return an Expr (or Symbol or literal number)
function rewrite(σ::MatchDict, rhs::Expr)
    if !iscall(rhs)
        if isexpr(rhs)
            args = [rewrite(σ, a) for a ∈ children(rhs)]
            return Expr(head(rhs), args...)
        else
            return rhs
        end
    end

    if is_𝑋(rhs)
        var = varname(rhs)
        if haskey(σ, var)
            return as_symbol_or_literal(σ[var]) # unwrap_const
        else
            error("No match found for variable $(var)") #it should never happen
        end
    end

    # otherwise call recursively on arguments and then reconstruct expression
    args = [rewrite(σ, a) for a ∈  arguments(rhs)]
    return pterm(operation(rhs), args; elide=false)
end

rewrite(matches::MatchDict, rhs::Symbol) = rhs::Symbol
rewrite(matches::MatchDict, rhs::Real) = rhs::Real
rewrite(matches::MatchDict, rhs::String) = rhs::String
rewrite(matches::MatchDict, rhs::LineNumberNode) = nothing::Nothing
rewrite(matches::MatchDict, rhs::QuoteNode) = rhs::QuoteNode

function _replace(ex, uv::Pair)
    u,v = uv

    # Expr
    isa(u, Expr) && return _replace_arguments(ex, u, v)

    # is u function replace head
    isa(u, Function) && return map_matched_head(ex, ==(Symbol(u)), _ -> v)

    # is u variable, replace exact
    return map_matched(ex, ==(u), _ -> v)
end


# return Expression
function _replace_arguments(ex, u, v)
    iscall(ex) || return (ex == u ? v : ex)

    σ = _match(u, ex, M) # sigma is nothing, (), or a substitution

    if !isnothing(σ)
        σ == () && return v # no substitution
        return rewrite(σ, v, M)
    end

    # peel off
    op, args = Symbol(operation(ex)), arguments(ex)
    args′ = _replace_arguments.(args, (u,), (v,), (M,))
    return pterm(op, args′)

end
