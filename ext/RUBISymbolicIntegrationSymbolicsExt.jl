module RUBISymbolicIntegrationSymbolicsExt
using TermInterface
## Notes
#=

=#

# These definitions get SybmolicUtils working
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
    CannotIntegrate, Unintegrable,
    poly_coefficients, poly_degree,
    issum, monomial,
    _substitute_after_int


import Symbolics
import Symbolics: @variables, Num
const S = Symbolics
import Symbolics.SymbolicUtils: BasicSymbolic, @syms


SymType =  BasicSymbolic# for dispatch
SymType′ = Union{BasicSymbolic, Symbolics.Num}
SymNumber = identity

Base.gcd(x::SymType′, y::SymType′) = gcd(unwrap_const(x), unwrap_const(y))

@syms var1 var2 ∫(var1,var2)

contains_int(expr::SymType′) = contains_op(∫, expr)
make_integral(f::Symbolics.Num, dx::Symbolics.Num) = ∫(f.val, dx.val)
make_integral(f::BasicSymbolic, dx::BasicSymbolic) = ∫(f, dx)


function contains_var(expr, var)
    expr = unwrap(expr)
    var = unwrap(var)
    expr === var && return true

    if iscall(expr)
        for arg in arguments(expr)
            if contains_var(arg, var)
                return true
            end
        end
    end
    return false
end

_substitute(x::SymType, args...;kwargs...) =
    Symbolics.substitute(x, Dict(args...))

_simplify(x::SymType, args...; kwargs...) = S.simplify(x; kwargs...)
_expand(x::SymType) = S.expand(x)
_derivative(f,dx::SymType) = begin
    S.derivative(f, dx)
end

# predicates
is_constant(x::SymType′) = !isa(Symbolics.unwrap_const(x), BasicSymbolic)
is_symbolic(x::SymType′) = !is_constant(x)
is_symbol(x::SymType′) = S.issym(x)
_iszero(x::SymType′) = S._iszero(x)


unwrap_const(x::SymType′) = S.unwrap_const(x)
unwrap(x::SymType′) = S.unwrap(x)
Base.Complex(x::SymType) = x # for powers

function ext_isinteger(u::SymType)
    v = unwrap_const(u)
    isa(v, Number) && return isa(v, Integer) #isinteger(v)
    return false
end
ext_even(u::SymType) = iseven(unwrap_const(u))
ext_isodd(u::SymType) = isodd(unwrap_const(u))
function ext_numden(x::SymType)
    if is_operation(/)(x)
        arguments(x)
    else
        x, one(x)
    end
end
ext_den(u::SymType) = ext_numden(u)[2]
ext_num(u::SymType) = ext_numden(u)[1]
ext_coeff(u::Symbolics.Num, x::Number, n) = 0
ext_coeff(u::BasicSymbolic, x::Number, n) = 0
ext_coeff(u::Symbolics.Num, x::Symbolics.Num, n) = ext_coeff(u.val, x.val, n)
function ext_coeff(u::BasicSymbolic, x::BasicSymbolic, n)
    try
        Symbolics.coeff(u,x^n)
    catch err
        return 0
    end
end


eq_expr(a::SymType,  p::Symbol) = Symbol(a) == p

function poly_coefficients(p, x::SymType′)
    deg = poly_degree(p, x)
    deg===nothing && throw("first argument is not a polynomial")
    p = Symbolics.expand(p)
    coeffs = Symbolics.Num[]
    for i in 0:deg
        push!(coeffs, Symbolics.coeff(p, x^i))
    end
    return coeffs
end

poly_degree(u::Real, x::SymType′) = 0
poly_degree(u::Symbolics.Num, x::Symbolics.Num) =
            poly_degree(Symbolics.unwrap(u), Symbolics.unwrap(x))
function poly_degree(u::BasicSymbolic, x::BasicSymbolic)
    u = Symbolics.expand(u)

    if issum(u)
        max_degree = 0
        for term in arguments(u)
            degree = monomial(term, x)
            if degree === nothing
                return false
            elseif degree > max_degree
                max_degree = degree
            end
        end
        # no monomial returned nothing, so its a polynomial
        return max_degree
    else
        out = monomial(u,x)
        return monomial(u, x)
    end
end


# Rule modifications
# Rule 1678L "3_1_3_18" has mistake. ~u should be (?) 1/(~d + ~e* x^2)

USE_GAMMA = false

#=
Proper way:
using Elliptic
@register_symbolic Elliptic.F(phi, m) # incomplete first kind
@register_symbolic Elliptic.E(phi, m) # incomplete second kind
@register_symbolic Elliptic.E(m) false # complete second kind
@register_symbolic Elliptic.Pi(nu, phi, m) # incomplete third kind

# changing name bc the . does no good in translation script
elliptic_f(phi, m) = Elliptic.F(phi, m)
elliptic_e(m) = Elliptic.E(m)
elliptic_e(phi, m) = Elliptic.E(phi, m)
elliptic_pi(nu, phi, m) = Elliptic.Pi(nu, phi, m)
elliptic_pi(nu, m) = Elliptic.Pi(nu, π/2, m)

using HypergeometricFunctions
"""
Calculates the 2F1 Hypergeometric function using the HypergeometricFunctions.jl package,
but also wraps the inputs in Complex numbers. so:
hypergeometric2f1(a, b, c, z) = HypergeometricFunctions._₂F₁(Complex(a), Complex(b), Complex(c), Complex(z))
"""
hypergeometric2f1(a, b, c, z) = HypergeometricFunctions._₂F₁(Complex(a), Complex(b), Complex(c), Complex(z))
@register_symbolic hypergeometric2f1(a, b, c, z)

"""
Calculates the pFq Hypergeometric function using the HypergeometricFunctions.jl package,
but also wraps the inputs in Complex numbers. so:
hypergeometricpFq(a, b, z) = HypergeometricFunctions.pFq(a, b, Complex(z))
"""
hypergeometricpFq(a, b, z) = HypergeometricFunctions.pFq(a, b, Complex(z))
@register_symbolic hypergeometricpFq(a::Vector, b::Vector, z)

appell_f1(a, b, c, d, e, z) = println("AppellF1 function is not implemented yet")
@register_symbolic appell_f1(a, b, c, d, e, z)

using PolyLog
@register_symbolic PolyLog.reli(n, z)

using FresnelIntegrals
@register_symbolic FresnelIntegrals.fresnelc(z)
@register_symbolic FresnelIntegrals.fresnels(z)

sinhintegral(x::Any) = println("hyperbolic sine integral Shi(z) function (https://en.wikipedia.org/wiki/Trigonometric_integral#Hyperbolic_sine_integral) is not implemented yet")
@register_symbolic sinhintegral(x)
coshintegral(x::Any) = println("hyperbolic cosine integral Chi(z) function (https://en.wikipedia.org/wiki/Trigonometric_integral#Hyperbolic_cosine_integral) is not implemented yet")
@register_symbolic coshintegral(x)
=#
# Special Functions
Gamma(x::SymType′, args...; kwargs...) =
    last(@syms x Gamma(x))(x)

LogGamma(x::SymType′, args...; kwargs...) =
    last(@syms x LogGamma(x))(x)

# HyperGeometric Functions (?)
appell_f1(args...; kwargs...) =
    last(@syms x appell_f1(x))(x)

hypergeometric2f1(a,b,c,d::SymType′) =
    last(@syms x hypergeometric2f1(x))(x)

# SymbolicUtils.expinti
Expinti(x::SymType′, args...; kwargs...) =
    last(@syms x Expintid1(x))(x)


# SymbolicUtils.erf[i[
Erf(x::SymType′, args...; kwargs...) =
    last(@syms x Erf(x))(x)
Erfi(x::SymType′, args...; kwargs...) =
    last(@syms x Erfi(x))(x)


Elliptic_e(x::SymType′, args...; kwargs...) =
    last(@syms x Elliptic_e(x))(x)
Elliptic_f(x::SymType′, y, args...; kwargs...) =
    last(@syms x Elliptic_f(x,x))(x,y)
Elliptic_pi(x::SymType′, args...; kwargs...) =
    last(@syms x Elliptic_pi(x))(x)

Sinint(x::SymType′, args...; kwargs...) =
    last(@syms x Sinint(x))(x)
Cosint(x::SymType′, args...; kwargs...) =
    last(@syms x Cosint(x))(x)

FresnelIntegrals_fresnels(x::SymType′, args...; kwargs...) =
    last(@syms x Fresnels(x))(x)
FresnelIntegrals_fresnelsc(x::SymType′, args...; kwargs...) =
    last(@syms x Fresnelsc(x))(x)


# PolyLog.reli
PolyLog_reli(a, x::SymType′, args...;kwargs...) =
    last(@syms x y PolyLog_reli(x,y))(a, x)

coshintegral(x::SymType′, args...;kwargs...) =
    last(@syms x coshintegral(x))(x)
sinhintegral(x::SymType′, args...;kwargs...) =
    last(@syms x sinhintegral(x))(x)

CannotIntegrate(x::SymType′, args...; kwargs...) =
    last(@syms x CannotIntegrate(x))(x)
Unintegrable(x::SymType′, args...; kwargs...) =
    last(@syms x Unintegrable(x))(x)


end
