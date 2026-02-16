module RUBISymbolicIntegrationSimpleExpressionsExt
## Notes
#=

=#

## --------- SymEngine -------------
# These definitions get SimpleExpressions working
# with the integration
import RUBISymbolicIntegration:
    contains_op, contains_int, make_integral,
    contains_var,
    _substitute,
    _simplify,
    _expand,
    _derivative,
    _iszero,
    is_constant,
    is_symbolic,
    is_symbol,
    unwrap_const,
    unwrap,
    ext_isinteger,
    ext_iseven, ext_isodd,
    ext_den, ext_num,
    ext_coeff,
    eq_expr,
    Gamma,
    LogGamma,
    appell_f1,
    hypergeometric2f1,
    Expinti,
    Erf, Erfi,
    Elliptic_e, Elliptic_f, Elliptic_pi,
    Sinint, Cosint,
    FresnelIntegrals_fresnels, FresnelIntegrals_fresnelsc,
    PolyLog_reli,
    coshintegral, sinhintegral,
    CannotIntegrate, Unintegrable

using TermInterface

import SimpleExpressions
import SimpleExpressions: SymbolicExpression, SymbolicFunction, SymbolicNumber, AbstractSymbolic
const S = SimpleExpressions

SymType = AbstractSymbolic # for dispatch
SymNumber = SymbolicNumber
SymFunction = SymbolicFunction

contains_int(expr::AbstractSymbolic) = contains_op(SymFunction(:∫), expr)
make_integral(f::AbstractSymbolic, dx::AbstractSymbolic) = SymFunction(:∫)(f, dx)



function contains_var(expr, var::AbstractSymbolic)
    isa(expr, AbstractSymbolic) && S.isvariable(var) && return contains(expr, var)
    return false
end

_substitute(x::SymType, args::AbstractDict;kwargs...) =
    SimpleExpressions.replace(x,args...)
_substitute(x::SymType, args::Pair...;kwargs...) = begin
    for kv ∈ args
        x = SimpleExpressions.replace(x, kv)
    end
    x
end
_simplify(x::SymType, args...; kwargs...) = SimpleExpressions.combine(x)
_expand(x::SymType) = x
_derivative(f,dx::SymType) = begin
    diff(f, dx)
end

# predicates
is_constant(x::SymType) = S.isconstant(x) # isempty(free_symbols(x))
is_symbolic(x::SymType) = !is_constant(x)
is_symbol(x::SymType) = S.isvariable(x)
_iszero(x::SymType) = iszero(x)


unwrap_const(x::SymType) = S.isconstant(x) ? x() : x
unwrap(x::SymType) = unwrap_const(x)
Base.Complex(x::SymType) = x # for powers

ext_isinteger(u::SymType) = isinteger(u)
ext_even(u::SymType) = iseven(u)
ext_isodd(u::SymType) = isodd(u)
function ext_numden(x::SymType)
    if is_operation(/)(x)
        arguments(x)
    else
        x, one(x)
    end
end
ext_den(u::SymType) = ext_numden(u)[2]
ext_num(u::SymType) = ext_numden(u)[1]
ext_coeff(u::SymType, x::Number, n) = 0
function ext_coeff(u::SymType, x::SymType, n)
    u = S.coefficients(u,x)
    isnothing(u) && return zero(x)
    1 + n <= length(u) ? u[1 + n] : 0
end


eq_expr(a::SymType,  p::Symbol) = Symbol(a) == p


# Rule modifications
# Rule 1678L "3_1_3_18" has mistake. ~u should be (?) 1/(~d + ~e* x^2)

USE_GAMMA = false

# Special Functions
Gamma(x::SymType, args...; kwargs...) =
    SymFunction("Gamma")(x, args...; kwargs...)
LogGamma(x::SymType, args...; kwargs...) =
    SymFunction("Gamma")(x, args...; kwargs...)

# HyperGeometric Functions (?)
appell_f1(args...; kwargs...) =
    SymFunction("appell_f1")(args...; kwargs...) # ?signature

hypergeometric2f1(a,b,c,d::SymType) =
    SymFunction("hypergeometric2f1")(a,b,c,d)


# SymbolicUtils.expinti
Expinti(x::SymType, args...; kwargs...) =
    SymFunction("Expini")(x, args...; kwargs...)

# SymbolicUtils.erf[i[
Erf(x::SymType, args...; kwargs...) =
    SymFunction("Erf")(x, args...; kwargs...)
Erfi(x::SymType, args...; kwargs...) =
    SymFunction("Erfi")(x, args...; kwargs...)


Elliptic_e(x::SymType, args...; kwargs...) =
    SymFunction("Ellipic_e")(x, args...; kwargs...)
Elliptic_f(x::SymType, args...; kwargs...) =
    SymFunction("Ellipic_f")(x, args...; kwargs...)
Elliptic_pi(x::SymType, args...; kwargs...) =
    SymFunction("Ellipic_pi")(x, args...; kwargs...)

Sinint(x::SymType, args...; kwargs...) =
    SymFunction("Sinint")(x, args...; kwargs...)
Cosint(x::SymType, args...; kwargs...) =
    SymFunction("Cosint")(x, args...; kwargs...)

FresnelIntegrals_fresnels(x::SymType, args...; kwargs...) =
    SymFunction("Fresnels")(x, args...; kwargs...)
FresnelIntegrals_fresnelsc(x::SymType, args...; kwargs...) =
    SymFunction("Fresnelsc")(x, args...; kwargs...)


# PolyLog.reli
PolyLog_reli(a, x::SymType, args...;kwargs...) =
    SymFunction("PolyLog_reli")(a, x, args...; kwargs...)

coshintegral(x::SymType, args...;kwargs...) =
    SymFunction("coshintegral")(x, args...; kwargs...)
sinhintegral(x::SymType, args...;kwargs...) =
    SymFunction("singintegral")(x, args...; kwargs...)


CannotIntegrate(x::SymType, args...; kwargs...) =
    SymFunction("CannotIntegrate")(x, args...; kwargs...)
Unintegrable(x::SymType, args...; kwargs...) =
    SymFunction("Unintegrableb")(x, args...; kwargs...)


end
