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
    Gamma,
    LogGamma,
    appell_f1,
    hypergeometric2f1,
    Expint, Expinti,
    Erf, Erfi,
    Elliptic_e, Elliptic_f, Elliptic_pi,
    Sinint, Cosint,
    FresnelIntegrals_fresnels, FresnelIntegrals_fresnelc,
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


function contains_var(expr, var::SymType′)
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
# Special functions. Where SpecialFunctions.jl has the function, the term is
# built with it, so it evaluates and (mostly) differentiates; the others are
# registered, so the term keeps its arguments but stays unevaluated.
import SpecialFunctions as SF

Gamma(x::SymType′) = SF.gamma(x)
Symbolics.@register_symbolic Gamma(a, x)          # upper incomplete Γ(a, x)
LogGamma(x::SymType′) = SF.loggamma(x)
Expinti(x::SymType′) = SF.expinti(x)
Expint(n, x::SymType′) = SF.expint(n, x)
Erf(x::SymType′) = SF.erf(x)
Erfi(x::SymType′) = SF.erfi(x)
Sinint(x::SymType′) = SF.sinint(x)
Cosint(x::SymType′) = SF.cosint(x)

Symbolics.@register_symbolic hypergeometric2f1(a, b, c, z)
Symbolics.@register_symbolic appell_f1(a, b1, b2, c, x, y)
# one arity per function: registering a second redefines a method, which
# precompilation does not allow. These are the incomplete integrals.
Symbolics.@register_symbolic Elliptic_e(phi, m)
Symbolics.@register_symbolic Elliptic_f(phi, m)
Symbolics.@register_symbolic Elliptic_pi(n, phi, m)
Symbolics.@register_symbolic FresnelIntegrals_fresnels(z)
Symbolics.@register_symbolic FresnelIntegrals_fresnelc(z)
Symbolics.@register_symbolic coshintegral(z)
Symbolics.@register_symbolic sinhintegral(z)
Symbolics.@register_symbolic CannotIntegrate(u, x)
Symbolics.@register_symbolic Unintegrable(u, x)

# Liₙ(z), PolyLog.jl's `reli(n, z)`, registered so that a term folds to a
# number on substitution (`substitute(ex, d; fold=Val(true))`) and can be
# differentiated. (This belongs in a Symbolics extension for PolyLog.)
import PolyLog
Symbolics.@register_symbolic PolyLog.reli(n, z)
@static if isdefined(Symbolics, Symbol("@register_derivative"))
    # d/dz Liₙ(z) = Liₙ₋₁(z) / z
    Symbolics.@register_derivative PolyLog.reli(n, z) 2 PolyLog.reli(n - 1, z) / z
end

end
