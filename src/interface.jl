## ---- Interface for a symbolic type -----
#
# The functions here are those the frontend and the rules need from the
# underlying symbolic type. Each has methods only for Julia expressions
# (`Expr`, with `Symbol` and number leaves); an extension adds methods for
# its own type and only for its own type. Values matched by a rule are
# unwrapped to Julia numbers (`unwrap_const`), so several functions also
# have a `Number` method.
#
# Functions which need only TermInterface (`iscall`, `operation`,
# `arguments`, `maketerm`) are generic and are not part of this list, e.g.
# `contains_op`, `contains_int`, `anyQ`, `node_count`.
#
# An extension for a symbolic type `T` defines, for `x::T`:
#
# * `make_integral(f, dx)`: the unevaluated integral, a term with operation
#   named `∫` and arguments `f` and `dx`. Rules match `∫(...)` by that name.
# * `unwrap_const(x)` (CommutativePatternMatching's): a numeric term as a
#   Julia number, so a `2` in a pattern equals a `2` in the subject.
# * `contains_var(expr, x)`: does `expr` contain the variable `x`?
# * `_simplify(x; kwargs...)`, `_expand(x)`, `_substitute(x, d)` (`d` a
#   `Dict` or pairs), `_derivative(f, x)`
# * `is_constant(x)`, `is_symbolic(x)`, `is_symbol(x)`, `_iszero(x)`,
#   `unwrap(x)`
# * the special functions below, which build an unevaluated call
#
# Optional, when the generic code in `rules-utility-functions.jl` and
# `polynomial-defns.jl` is not right for the type: `ext_isinteger`,
# `ext_iseven`, `ext_isodd`, `ext_den`, `ext_num`, `ext_coeff`,
# `poly_coefficients`, `poly_degree`, `issum`, `monomial`.
#
# A Julia expression can not be integrated: a rule's right-hand side does
# arithmetic on the matched values, which is not defined for `Expr`.

const ExprLike = Union{Expr, Symbol}

# unevaluated integral
make_integral(f::Union{ExprLike, Number}, dx::Symbol) = Expr(:call, :∫, f, dx)
∫(f, dx) = make_integral(f, dx)

# does `expr` contain the variable `var`?
contains_var(expr::Union{ExprLike, Number}, var::Symbol) =
    expr === var || (iscall(expr) && any(a -> contains_var(a, var), arguments(expr)))

# simplification; none for an expression
_simplify(x::Union{ExprLike, Number}, args...; kwargs...) = x
_simpler(args...; kwargs...) = _simplify(args...; kwargs...)
_expand(x::Union{ExprLike, Number}) = x

# substitute for subterms, `_substitute(ex, Dict(x => 2))` or `_substitute(ex, x => 2)`
# (Not `x::Number` with pairs: SymEngine's `Basic <: Number` would be ambiguous)
_substitute(x::Number, args...) = x
_substitute(x::ExprLike, kvs::Pair...) = _substitute(x, Dict(kvs...))
_substitute(x::ExprLike, d::AbstractDict) = _substitute_expr(x, d)
function _substitute_expr(x, d)
    haskey(d, x) && return d[x]
    iscall(x) || return x
    Expr(:call, operation(x), (_substitute_expr(a, d) for a ∈ arguments(x))...)
end

_derivative(f::Union{ExprLike, Number}, dx::Symbol) =
    throw(ArgumentError("`_derivative` is not implemented for a Julia expression"))

# predicates
is_constant(x::Number) = true
is_constant(x::Symbol) = isa(unwrap_const(x), Number) # e.g. :π
is_constant(x::Expr) = iscall(x) && all(is_constant, arguments(x))

is_symbolic(x::Number) = false
is_symbolic(x::ExprLike) = !is_constant(x)

is_symbol(x::Union{Expr, Number}) = false
is_symbol(x::Symbol) = !is_constant(x)

_iszero(x::Number) = iszero(x)
_iszero(x::ExprLike) = false

unwrap(x::Union{ExprLike, Number}) = x

# special functions, as unevaluated calls. Each dispatches on the argument
# which is symbolic in the rules, as the extensions do
for F ∈ (:Gamma, :LogGamma, :Expinti, :Erf, :Erfi,
         :Elliptic_e, :Elliptic_f, :Elliptic_pi, :Sinint, :Cosint,
         :FresnelIntegrals_fresnels, :FresnelIntegrals_fresnelc,
         :coshintegral, :sinhintegral, :CannotIntegrate, :Unintegrable)
    @eval $F(x::ExprLike, args...) = Expr(:call, $(QuoteNode(F)), x, args...)
end
Expint(n, z::ExprLike) = Expr(:call, :Expint, n, z)
hypergeometric2f1(a, b, c, z::ExprLike) = Expr(:call, :hypergeometric2f1, a, b, c, z)
appell_f1(a, b, c, d, e, z::ExprLike) = Expr(:call, :appell_f1, a, b, c, d, e, z)

# The polylogarithm Liₙ(z) (Mathematica's PolyLog[n, z]) is PolyLog.jl's
# `reli(n, z)`, which evaluates numbers. A symbolic package adds a method
# for its type (SimpleExpressions has a PolyLog extension; the SymEngine and
# Symbolics extensions here add one). There is no method for an `Expr`, as
# that would be type piracy.
