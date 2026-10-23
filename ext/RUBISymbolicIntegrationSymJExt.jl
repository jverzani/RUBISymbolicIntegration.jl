module RUBISymbolicIntegrationSymJExt

## --------- SymJ -------------
# These definitions get SymJ working with the integration
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
    Gamma,
    LogGamma,
    appell_f1,
    Expint, Expinti,
    Erf, Erfi,
    Elliptic_e, Elliptic_f, Elliptic_pi,
    Sinint, Cosint,
    FresnelIntegrals_fresnels, FresnelIntegrals_fresnelc,
    coshintegral, sinhintegral,
    CannotIntegrate, Unintegrable

using TermInterface
import SymJ
import SymJ: Sym, SymFunction

const SymType = Sym # for dispatch

contains_int(expr::SymType) = contains_op(SymFunction(:∫), expr)
make_integral(f::SymType, dx::SymType) = SymFunction(:∫)(f, dx)
make_integral(f::Number, dx::SymType) = SymFunction(:∫)(f, dx)

function contains_var(expr, var::SymType)
    isa(expr, SymType) && SymJ.issymbol(var) && return SymJ.has(expr, var)
    return false
end

_substitute(x::SymType, d::AbstractDict; kwargs...) = SymJ.subs(x, d)
_substitute(x::SymType, kvs::Pair...; kwargs...) = SymJ.subs(x, kvs...)
# with `expand = true` (as the frontend asks when no rule applies), multiply
# out, e.g. (x - a)*(b - x) to a quadratic that a rule matches
_simplify(x::SymType, args...; expand = false, kwargs...) = expand ? SymJ.expand(x) : x
_expand(x::SymType) = SymJ.expand(x)
_derivative(f, dx::SymType) = diff(f, dx)

# predicates
is_constant(x::SymType) = isempty(SymJ.free_symbols(x))
is_symbolic(x::SymType) = !is_constant(x)
is_symbol(x::SymType) = SymJ.issymbol(x)
_iszero(x::SymType) = iszero(x)

# a number as a Julia number; anything else, `π` included, stays a `Sym`
unwrap_const(x::SymType) = SymJ.isnumber(x) ? SymJ._jlnum(x.num) : x
unwrap(x::SymType) = unwrap_const(x)
Base.Complex(x::SymType) = x # for powers

ext_isinteger(u::SymType) = SymJ.isnumber(u) && isinteger(u.num)
ext_iseven(u::SymType) = ext_isinteger(u) && iseven(unwrap_const(u))
ext_isodd(u::SymType) = ext_isinteger(u) && isodd(unwrap_const(u))
ext_den(u::SymType) = SymJ.numer_denom(u)[2]
ext_num(u::SymType) = SymJ.numer_denom(u)[1]
ext_coeff(u::SymType, x::Number, n) = 0
function ext_coeff(u::SymType, x::SymType, n)
    try
        p = SymJ.Poly(u, x)
        for (c, e) in zip(SymJ.coefficients(p), SymJ.exponent_vectors(p))
            only(e) == n && return Sym(c)
        end
        return 0
    catch
        return 0
    end
end

# Special Functions. Where SpecialFunctions.jl has the function, SymJ's
# extension for it builds the term, so the term evaluates to a number.
import SpecialFunctions as SF
Gamma(x::SymType) = SF.gamma(x)
Gamma(a::SymType, x) = SF.gamma(a, x)        # upper incomplete Γ(a, x)
Gamma(a::Number, x::SymType) = SF.gamma(a, x)
LogGamma(x::SymType) = SF.loggamma(x)
Expint(n, x::SymType) = SF.expint(n, x)
Expinti(x::SymType) = SF.expinti(x)
Erf(x::SymType, args...) = SF.erf(x, args...)
Erfi(x::SymType) = SF.erfi(x)
Sinint(x::SymType) = SF.sinint(x)
Cosint(x::SymType) = SF.cosint(x)

# Liₙ(z) is `PolyLog.reli(n, z)` and ₂F₁(a, b; c; z) is HypergeometricFunctions.jl's
# `_₂F₁(a, b, c, z)`, defined for a symbolic argument by SymJ's own extensions

# The rest are unevaluated
appell_f1(a, b, c, d, e, z::SymType) =
    SymFunction(:appell_f1)(a, b, c, d, e, z)

Elliptic_e(x::SymType, args...) = SymFunction(:Elliptic_e)(x, args...)
Elliptic_f(x::SymType, args...) = SymFunction(:Elliptic_f)(x, args...)
Elliptic_pi(x::SymType, args...) = SymFunction(:Elliptic_pi)(x, args...)

FresnelIntegrals_fresnels(x::SymType) = SymFunction(:Fresnels)(x)
FresnelIntegrals_fresnelc(x::SymType) = SymFunction(:Fresnelc)(x)

coshintegral(x::SymType) = SymFunction(:coshintegral)(x)
sinhintegral(x::SymType) = SymFunction(:sinhintegral)(x)

CannotIntegrate(x::SymType, args...) = SymFunction(:CannotIntegrate)(x, args...)
Unintegrable(x::SymType, args...) = SymFunction(:Unintegrable)(x, args...)

end
