module RUBISymbolicIntegrationSymEngineExt

## Notes
#=

=#

## --------- SymEngine -------------
# These definitions get SymEngine working
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
import SymEngine
import SymEngine: Basic, SymFunction

Base.gcd(x::Real, y::Basic) = gcd(Basic(x), y)


SymType = Basic # for dispatch
SymNumber = Basic

contains_int(expr::SymType) = contains_op(SymFunction(:∫), expr)
make_integral(f::SymType, dx::SymType) = SymFunction(:∫)(f, dx)



function contains_var(expr, var::SymType)
    isa(expr, SymType) && SymEngine.is_symbol(var) && return SymEngine.has_symbol(expr, var)
    return false
end

_substitute(x::SymType, args...;kwargs...) = SymEngine.subs(x, args...; kwargs...)
_simplify(x::SymType, args...; kwargs...) =  SymEngine.expand(x)
_expand(x) = x
function _expand(x::SymType)
        SymEngine.expand(x)
end
_derivative(f,dx::SymType) = SymEngine.diff(f, dx)

# predicates
is_constant(x::SymType) = SymEngine.is_constant(x)
is_symbolic(x::SymType) = isa(x, SymType)
is_symbol(x::SymType) = SymEngine.is_symbol(x)
_iszero(x::SymType) = iszero(x)


unwrap_const(x::SymType) = SymEngine.unwrap_const(x)
unwrap(x::SymType) = SymEngine.unwrap_const(x)
Base.Complex(x::SymType) = x # for powers

ext_isinteger(u::SymType) = isinteger(u)
ext_even(u::SymType) = iseven(u)
ext_isodd(u::SymType) = isodd(u)
ext_den(u::SymType) = denominator(u)
ext_num(u::SymType) = numerator(u)
ext_coeff(u::SymType, x::Number, n) = 0
function ext_coeff(u::SymType, x::SymType, n)
    try
        SymEngine.coeff(u,x,n)
    catch err
        println("error", err)
        return 0
    end
end

eq_expr(a::SymType,  p::Symbol) = Symbol(a) == p


USE_GAMMA = false

# Special Functions
Gamma(x::SymType, args...; kwargs...) =
    SymFunction("Gamma")(x, args...; kwargs...)
LogGamma(x::SymType, args...; kwargs...) =
    SymFunction("Gamma")(x, args...; kwargs...)

# HyperGeometric Functions (?)
appell_f1(x::SymType, args...; kwargs...) =
    SymFunction("appell_f1")(x, args...; kwargs...) # ?signature

hypergeometric2f1(a,b,c,d::SymType) =
    SymFunction("hypergeometric2f1")(a,b,c,d)


# SymbolicUtils.expinti
Expint(x::SymType, args...; kwargs...) =
    SymFunction("Expint")(x, args...; kwargs...)
Expinti(x::SymType, args...; kwargs...) =
    SymFunction("Expinti")(x, args...; kwargs...)

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
