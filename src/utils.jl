# utils for rule2a
# A substitution is a collection of pairs 𝑋 -> 𝐺
const MatchDict = Base.ImmutableDict{Symbol, Any}
FAIL_DICT = MatchDict(:_fail,0)
∅ = ()

match_dict() = MatchDict()

function match_dict(kvs::Pair...)
    σ = MatchDict()
    match_dict(σ, kvs...)
end

function match_dict(σ::MatchDict, kvs::Pair...)
    for (k,v) ∈ kvs
        v = isa(v,Number) ? unwrap_const(v) : v
        if haskey(σ, k)
            σ[k] != v && return FAIL_DICT #error("repeated key with different value: $k => $v ($(σ[k]))")
        else
            σ = MatchDict(σ, k, v)
        end
    end
    σ
end

#  σ △ σ′ (\bigtriangleup) for every x in the intersection of the domains has same value
function iscompatible(σ::MatchDict, σ′::MatchDict)
    isempty(σ) && return true
    isempty(σ′) && return true
    for k in keys(σ)
        if haskey(σ′, k) # intersect(keys(σ), keys(σ′)) allocates
            isequal(σ[k], σ′[k]) || return false
        end
    end
    return true
end

# σ ⊔ σ′ (\sqcup) is union of two compatible matches
function merge_match(σ::MatchDict, σ′::MatchDict)
    # assume compatible
    for (k,v) ∈ σ′
        σ = match_dict(σ, k => v)
    end
    σ
end
merge_match(σ::Tuple, σ′::MatchDict) = σ′

function union_merge(θ, σ′)
    (merge_match(σ, σ′) for σ ∈ θ if iscompatible(σ, σ′))
end

## utils
_isone(x) = isequal(x, 1)


## Expression related methods

# need to compare x and p when p is from an expression
# trick -- SymEngine.Basic <: Number
eq_expr(a, p::Number) = isequal(a,p)
eq_expr(a::Number, p::Symbol) = false
eq_expr(a, p::Symbol) = isequal(Symbol(a),p)


# create a term for a pattern (pterm) or a subject (sterm)
# the latter might involve a symbolic type
function pterm(op::Union{Expr,Symbol}, args; elide=true)
    if elide && length(args) == 1 && op ∈(:+, :*, :^, :/)
        return only(args)
    else
        Expr(:call, op, args...)
    end
end

# subject term
function sterm(T, op, args)
    _isexpr = T ∈ (Expr, Symbol, Real)
    if _isexpr
        !isa(op, Symbol) && (op = nameof(op))
    elseif !_isexpr
        isa(op, Symbol) && (op = eval(op))
    end
    _isexpr ? pterm(op, args) : op(args...)
end

# invert an expr to regularize a/b --> a*b^{-1}
function _invert_expr(pat)
    if isa(pat, Integer)
        return pterm(:^, (pat, -1.0))
    elseif is_operation(:(//))(pat)
        u,v = arguments(pat)
        u′ = isa(u, Number) ? -u : pterm(*, (u,-1))
        return pterm(:(//), (u′, v))
    else
        return pterm(:^, (pat, -1))
    end
end


_groupby(pred, t) = (t = filter(pred,t), f=filter(!pred, t))


# ----- predicates
_is_rational(x) = isa(unwrap_const(x), Rational)


# can override, say with :Symbol
iscommutative(op) = op ∈ (:+, :*, +, *)
isassociative(op) = op ∈ (:+, :*, +, *)

isassociative(::typeof(+)) = true
isassociative(::typeof(*)) = true

iscommutative(::typeof(+)) = true
iscommutative(::typeof(*)) = true



# check for wildcard variables
is_𝑋(x::Any) = false
has_𝑋(x::Any) = false
is_slot(x::Any) = false
is_defslot(x::Any) = false
is_segment(x::Any) = false
is_plus(x::Any) = false
is_op(x::Any) = false

const defslot_op_map = Dict(:+ => 0, :* => 1, :^ => 1, :/ => 1)

# Expr
is_𝑋(x::Expr) = (iscall(x) && first(x.args) === :(~))  ||
    (isexpr(x) && is_𝑋(first(x.args)))

function has_𝑋(x::Expr)
    is_𝑋(x) && return true
    !iscall(x) && return false
    is_𝑋(operation(x)) && return true
    any(has_𝑋, arguments(x))
end

function is_slot(x::Expr)
    is_𝑋(x) || return false
    _, x = x.args
    iscall(x) && return false
    return true
end

function is_defslot(x::Expr)

    is_𝑋(x) || return false
    _, arg = x.args
    is_operation(:(!))(arg) && return true


    return false
end

is_slot_or_defslot(x) = is_slot(x) || is_defslot(x)

function is_segment(x::Expr)
    is_𝑋(x) || return false # first is ~
    h,x = x.args
    is_𝑋(h) && return false # an op
    is_𝑋(x) || return false # second is ~
    _,x = x.args
    is_𝑋(x) && return false
    return true
end

# ~~~x (1 or more)
function is_plus(x::Expr)
    is_𝑋(x) || return false
    _,x = x.args
    is_𝑋(x) || return false
    _,x = x.args
    is_𝑋(x) || return false
    return true
end

# (~G)(~x)
function is_op(x::Expr)
    is_𝑋(x) && iscall(x) && is_𝑋(operation(x))
end

# return symbol holding variable name
varname(x::Symbol) = x
function varname(x::Expr)
    if x.args[1] ∈ (:~, :!)
        varname(x.args[2])
    else
        varname(x.args[1])
    end
end

# return wildcard matches
# RENAME?
_free_symbols(::Any) = Expr[]
function _free_symbols(x::Expr)
    is_𝑋(x) && return [varname(x)]
    iscall(x) || return Expr[]
    unique(vcat(_free_symbols.(arguments(x))...))
end


# return bool, var (symbol name), pred
has_predicate(x::Symbol) = false
function has_predicate(x::Expr)
    if x.args[1] ∈ (:~, :!)
        has_predicate(x.args[2])
    else
        length(x.args) == 2 && x.head==:(::)
    end
end

# return symbol of function
get_predicate(x::Symbol) = :nothing
function get_predicate(x::Expr)
    if x.args[1] ∈ (:~, :!)
        get_predicate(x.args[2])
    else
        x.args[2]
    end
end


## Matching
# copy of  CallableExpressions.expression_map_matched(pred, mapping, u)
# if argument, `a`, matches via `is_match` replace with `f(a)`
function map_matched(ex, is_match, f)
    if !iscall(ex)
        return is_match(ex) ? f(ex) : ex
    else
        is_match(ex) && return f(ex)
        iscall(ex) || return ex
        children = map_matched.(arguments(ex), is_match, f)
        return sterm(typeof(first(children)), operation(ex), children)
    end
end

# if expression operation, `op`, matches via `is_match` replace with `f(op)`
function map_matched_head(ex, is_match, f)
    !iscall(ex) && return ex
    op = operation(ex)
    is_match(op) && (op = f(op))
    args′ = map_matched_head.(arguments(ex), is_match, f)
    T = typeof(first(args′))
    if T <: Expr || T <: Symbol || T <: Number
        return pterm(Symbol(op), args′)
    else
        return sterm(T, op, args′)
    end
end


### ---- match, eachmatch, replace

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
function _rewrite(σ::MatchDict, rhs::Expr)
    if !iscall(rhs)
        if isexpr(rhs)
            args = [_rewrite(σ, a) for a ∈ children(rhs)]
            return Expr(head(rhs), args...)
        else
            return rhs
        end
    end

    if iscall(rhs) && is_𝑋(operation(rhs))
        args = [_rewrite(σ, a) for a ∈  arguments(rhs)]
        op = Symbol(σ[varname(operation(rhs))])
        return  pterm(op, args; elide=false)
    end

    if is_𝑋(rhs)
        var = varname(rhs)
        if haskey(σ, var)
            return σ[var]
        else
            @show σ
            error("No match found for variable $(var)") #it should never happen
        end
    end

    # otherwise call recursively on arguments and then reconstruct expression
    args = [_rewrite(σ, a) for a ∈  arguments(rhs)]
    op = operation(rhs)
    if op == :^
        a,b = args
        return :(^($a, $b))
    end
    return pterm(op, args; elide=false)
end

_rewrite(matches::MatchDict, rhs::Symbol) = rhs::Symbol
_rewrite(matches::MatchDict, rhs::Real) = rhs::Real
_rewrite(matches::MatchDict, rhs::String) = rhs::String
_rewrite(matches::MatchDict, rhs::LineNumberNode) = nothing::Nothing
_rewrite(matches::MatchDict, rhs::QuoteNode) = rhs::QuoteNode

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
    @show :replace_arguments, ex, u,v
    iscall(ex) || return (ex == u ? v : ex)

    σ = _match(u, ex, M) # sigma is nothing, (), or a substitution

    if !isnothing(σ)
        σ == () && return v # no substitution
        return _rewrite(σ, v, M)
    end

    # peel off
    op, args = Symbol(operation(ex)), arguments(ex)
    args′ = _replace_arguments.(args, (u,), (v,), (M,))
    return pterm(op, args′)

end
