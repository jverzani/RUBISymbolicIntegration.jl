using Test
using SymEngine
import RUBISymbolicIntegration:
    integrate,⨸,contains_int,
    Expinti,
    PolyLog_reli,
    Gamma,
    Elliptic_e,
    Elliptic_f,
    Elliptic_pi,
    Erf,
    Erfi,
    Sinint,
    Cosint,
    hypergeometric2f1,
    CannotIntegrate,
    Unintegrable

@vars ∫() w x y z t d n m a b c h k l p q r s alpha epsilon e mc A B H K b1 c1
I = IM

# file format (integrand, result, integration variable, mystery value)

# this custom division function is added to produce
# - rationals if called with integers
# - floats if called with floats
# it's a infix operator with the same precedence of /
#=
function ⨸(x::Union{Rational, Integer}, y::Union{Rational, Integer})
    iszero(y) && return nothing
    res = x // y
    #SymbolicIntegration.ext_isinteger(res) ? Int(res) : res
end
⨸(x, y) = iszero(y) ? nothing : x / y
=#
# Each tuple is (integrand, result, integration variable, mystery value)
apostol = [
# ::Package::

# ::Title::
# Tom M. Apostol - Calculus, Volume I, Second Edition (1967)


# ::Section::Closed::
# Section 5.8 Exercises (p. 216-217)


# ::Subsection::Closed::
# Exercises 1 - 10


(sqrt(2*x + 1), (1⨸3)*(1 + 2*x)^(3⨸2), x, 1),
(x*sqrt(1 + 3*x), (-(2⨸27))*(1 + 3*x)^(3⨸2) + (2⨸45)*(1 + 3*x)^(5⨸2), x, 2),
(x^2*sqrt(x + 1), (2⨸3)*(1 + x)^(3⨸2) - (4⨸5)*(1 + x)^(5⨸2) + (2⨸7)*(1 + x)^(7⨸2), x, 2),
(x/sqrt(2 - 3*x), (-(4⨸9))*sqrt(2 - 3*x) + (2⨸27)*(2 - 3*x)^(3⨸2), x, 2),
((x + 1)/(x^2 + 2*x + 2)^3, -(1/(4*(2 + 2*x + x^2)^2)), x, 1),
(sin(x)^3, -cos(x) + cos(x)^3/3, x, 2),
(z*(z - 1)^(1⨸3), (3⨸4)*(-1 + z)^(4⨸3) + (3⨸7)*(-1 + z)^(7⨸3), z, 2),
(cos(x)/sin(x)^3, (-(1⨸2))*csc(x)^2, x, 2),
(cos(2*x)*sqrt(4 - sin(2*x)), (-(1⨸3))*(4 - sin(2*x))^(3⨸2), x, 2),
(sin(x)/(3 + cos(x))^2, 1/(3 + cos(x)), x, 2),


# ::Subsection::Closed::
# Exercises 11 - 20


(sin(x)/sqrt(cos(x)^3), (2*cos(x))/sqrt(cos(x)^3), x, 3),
(sin(sqrt(x + 1))/sqrt(x + 1), -2*cos(sqrt(1 + x)), x, 3),
(x^(n - 1)*sin(x^n), -(cos(x^n)/n), x, 2),
(x^5/sqrt(1 - x^6), (-(1⨸3))*sqrt(1 - x^6), x, 1),
(t*(1 + t)^(1⨸4), (-(4⨸5))*(1 + t)^(5⨸4) + (4⨸9)*(1 + t)^(9⨸4), t, 2),
((x^2 + 1)^(-3⨸2), x/sqrt(1 + x^2), x, 1),
(x^2*(8*x^3 + 27)^(2⨸3), (1⨸40)*(27 + 8*x^3)^(5⨸3), x, 1),
((sin(x) + cos(x))/(sin(x) - cos(x))^(1⨸3), (3⨸2)*(-cos(x) + sin(x))^(2⨸3), x, 1),
(x/sqrt(1 + x^2 + (1 + x^2)^(3⨸2)), (2*sqrt((1 + x^2)*(1 + sqrt(1 + x^2))))/sqrt(1 + x^2), x, 3),
(x/(sqrt(1 + x^2)*sqrt(1 + sqrt(1 + x^2))), 2*sqrt(1 + sqrt(1 + x^2)), x, 1),
((x^2 + 1 - 2*x)^(1⨸5)/(1 - x), (-(5⨸2))*(1 - 2*x + x^2)^(1⨸5), x, 2),


# ::Section::Closed::
# Section 5.10 Exercises (p. 220-222)


# ::Subsection::Closed::
# Exercises 1 - 6


(x*sin(x), (-x)*cos(x) + sin(x), x, 2),
(x^2*sin(x), 2*cos(x) - x^2*cos(x) + 2*x*sin(x), x, 3),
(x^3*cos(x), -6*cos(x) + 3*x^2*cos(x) - 6*x*sin(x) + x^3*sin(x), x, 4),
(x^3*sin(x), 6*x*cos(x) - x^3*cos(x) - 6*sin(x) + 3*x^2*sin(x), x, 4),
(sin(x)*cos(x), sin(x)^2/2, x, 2),
(x*sin(x)*cos(x), -(x/4) + (1⨸4)*cos(x)*sin(x) + (1⨸2)*x*sin(x)^2, x, 3),


# ::Subsection::Closed::
# Exercises 7 - 10


(sin(x)^2, x/2 - (1⨸2)*cos(x)*sin(x), x, 2),
(sin(x)^3, -cos(x) + cos(x)^3⨸3, x, 2),
(sin(x)^4, (3*x)/8 - (3⨸8)*cos(x)*sin(x) - (1⨸4)*cos(x)*sin(x)^3, x, 3),
(sin(x)^5, -cos(x) + (2*cos(x)^3)/3 - cos(x)^5⨸5, x, 2),
(sin(x)^6, (5*x)/16 - (5⨸16)*cos(x)*sin(x) - (5⨸24)*cos(x)*sin(x)^3 - (1⨸6)*cos(x)*sin(x)^5, x, 4),


# ::Subsection::Closed::
# Exercise 11


(x*sin(x)^2, x^2⨸4 - (1⨸2)*x*cos(x)*sin(x) + sin(x)^2⨸4, x, 2),
(x*sin(x)^3, (-(2⨸3))*x*cos(x) + (2*sin(x))/3 - (1⨸3)*x*cos(x)*sin(x)^2 + sin(x)^3⨸9, x, 3),
(x^2*sin(x)^2, -(x/4) + x^3⨸6 + (1⨸4)*cos(x)*sin(x) - (1⨸2)*x^2*cos(x)*sin(x) + (1⨸2)*x*sin(x)^2, x, 4),


# ::Subsection::Closed::
# Exercise 13


(cos(x)^2, x/2 + (1⨸2)*cos(x)*sin(x), x, 2),
(cos(x)^3, sin(x) - sin(x)^3⨸3, x, 2),
(cos(x)^4, (3*x)/8 + (3⨸8)*cos(x)*sin(x) + (1⨸4)*cos(x)^3*sin(x), x, 3),


# ::Subsection::Closed::
# Exercises 15 - 17


((a^2 - x^2)^(5⨸2), (5⨸16)*a^4*x*sqrt(a^2 - x^2) + (5⨸24)*a^2*x*(a^2 - x^2)^(3⨸2) + (1⨸6)*x*(a^2 - x^2)^(5⨸2) + (5⨸16)*a^6*atan(x/sqrt(a^2 - x^2)), x, 5),
(x^5/sqrt(5 + x^2), 25*sqrt(5 + x^2) - (10⨸3)*(5 + x^2)^(3⨸2) + (1⨸5)*(5 + x^2)^(5⨸2), x, 3),
(t^3/(4 + t^3)^(1⨸2), (2⨸5)*t*sqrt(4 + t^3) - (8*2^(2⨸3)*sqrt(2 + sqrt(3))*(2^(2⨸3) + t)*sqrt((2*2^(1⨸3) - 2^(2⨸3)*t + t^2)/(2^(2⨸3)*(1 + sqrt(3)) + t)^2)*Elliptic_f(asin((2^(2⨸3)*(1 - sqrt(3)) + t)/(2^(2⨸3)*(1 + sqrt(3)) + t)), -7 - 4*sqrt(3)))/(5*3^(1⨸4)*sqrt((2^(2⨸3) + t)/(2^(2⨸3)*(1 + sqrt(3)) + t)^2)*sqrt(4 + t^3)), t, 2),


# ::Subsection::Closed::
# Exercises 18 - 19


(tan(x)^2, -x + tan(x), x, 2),
(tan(x)^4, x - tan(x) + tan(x)^3⨸3, x, 3),
(cot(x)^2, -x - cot(x), x, 2),
(cot(x)^4, x + cot(x) - cot(x)^3⨸3, x, 3),


# ::Section::Closed::
# Section 5.11 Miscellaneous review exercises (p. 222-225)


# ::Subsection::Closed::
# Exercises 11 - 20


((2 + 3*x)*sin(5*x), (-(1⨸5))*(2 + 3*x)*cos(5*x) + (3⨸25)*sin(5*x), x, 2),
(x*sqrt(1 + x^2), (1⨸3)*(1 + x^2)^(3⨸2), x, 1),
(x*(x^2 - 1)^9, (1⨸20)*(1 - x^2)^10, x, 1),
((2*x + 3)/(6*x + 7)^3, -((3 + 2*x)^2/(8*(7 + 6*x)^2)), x, 1),
(x^4*(1 + x^5)^5, (1⨸30)*(1 + x^5)^6, x, 1),
(x^4*(1 - x)^20, (-(1⨸21))*(1 - x)^21 + (2⨸11)*(1 - x)^22 - (6⨸23)*(1 - x)^23 + (1⨸6)*(1 - x)^24 - (1⨸25)*(1 - x)^25, x, 2),
(sin(1/x)/x^2, cos(1/x), x, 2),
(sin((x - 1)^(1⨸4)), 24*(-1 + x)^(1⨸4)*cos((-1 + x)^(1⨸4)) - 4*(-1 + x)^(3⨸4)*cos((-1 + x)^(1⨸4)) - 24*sin((-1 + x)^(1⨸4)) + 12*sqrt(-1 + x)*sin((-1 + x)^(1⨸4)), x, 5),
(x*sin(x^2)*cos(x^2), (1⨸4)*sin(x^2)^2, x, 1),
(sqrt(1 + 3*cos(x)^2)*sin(2*x), (-(2⨸9))*(4 - 3*sin(x)^2)^(3⨸2), x, 3),


# ::Section::Closed::
# Section 6.9 Exercises (p. 236-238)


# ::Subsection::Closed::
# Exercises 16 - 21


(1/(2 + 3*x), (1⨸3)*log(2 + 3*x), x, 1),
(log(x)^2, 2*x - 2*x*log(x) + x*log(x)^2, x, 2),
(x*log(x), -(x^2⨸4) + (1⨸2)*x^2*log(x), x, 1),
(x*log(x)^2, x^2⨸4 - (1⨸2)*x^2*log(x) + (1⨸2)*x^2*log(x)^2, x, 2),
(1/(1 + t), log(1 + t), t, 1),
(cot(x), log(sin(x)), x, 1),


# ::Subsection::Closed::
# Exercises 22 - 27


(x^n*log(a*x), -(x^(1 + n)/(1 + n)^2) + (x^(1 + n)*log(a*x))/(1 + n), x, 1),
(x^2*log(x)^2, (2*x^3)/27 - (2⨸9)*x^3*log(x) + (1⨸3)*x^3*log(x)^2, x, 2),
(1/(x*log(x)), log(log(x)), x, 2),
(log(1 - t)/(1 - t), (-(1⨸2))*log(1 - t)^2, t, 2),
(log(x)/(x*sqrt(1 + log(x))), -2*sqrt(1 + log(x)) + (2⨸3)*(1 + log(x))^(3⨸2), x, 3),
(x^3*log(x)^3, -((3*x^4)/128) + (3⨸32)*x^4*log(x) - (3⨸16)*x^4*log(x)^2 + (1⨸4)*x^4*log(x)^3, x, 3),


# ::Section::Closed::
# Section 6.16 Differentiation and integration formulas involving exponentials (p. 245-248)


# ::Subsection::Closed::
# Example 1


(x^2*ℯ^(x^3), ℯ^x^3⨸3, x, 1),


# ::Subsection::Closed::
# Example 2


(2^sqrt(x)/sqrt(x), 2^(1 + sqrt(x))/log(2), x, 1),


# ::Subsection::Closed::
# Example 3


(cos(x)*ℯ^(2*sin(x)), (1⨸2)*ℯ^(2*sin(x)), x, 2),


# ::Subsection::Closed::
# Example 4


(ℯ^x*sin(x), (-(1⨸2))*ℯ^x*cos(x) + (1⨸2)*ℯ^x*sin(x), x, 1),
(ℯ^x*cos(x), (1⨸2)*ℯ^x*cos(x) + (1⨸2)*ℯ^x*sin(x), x, 1),


# ::Subsection::Closed::
# Example 5


(1/(1 + ℯ^x), x - log(1 + ℯ^x), x, 4),


# ::Section::Closed::
# Section 6.17 Exercises (p. 248-250)


# ::Subsection::Closed::
# Exercises 13 - 18


(x*ℯ^x, -ℯ^x + ℯ^x*x, x, 2),
(x*ℯ^(-x), -ℯ^(-x) - x/ℯ^x, x, 2),
(x^2*ℯ^x, 2*ℯ^x - 2*ℯ^x*x + ℯ^x*x^2, x, 3),
(x^2*ℯ^(-2*x), -(1⨸4)/ℯ^(2*x) - ((1⨸2)*x)/ℯ^(2*x) - ((1⨸2)*x^2)/ℯ^(2*x), x, 3),
(ℯ^sqrt(x), -2*ℯ^sqrt(x) + 2*ℯ^sqrt(x)*sqrt(x), x, 3),
(x^3*ℯ^(-x^2), -(1/(ℯ^x^2*2)) - ((1⨸2)*x^2)/ℯ^x^2, x, 2),


# ::Subsection::Closed::
# Exercise 20


(ℯ^(a*x)*cos(b*x), (a*ℯ^(a*x)*cos(b*x))/(a^2 + b^2) + (b*ℯ^(a*x)*sin(b*x))/(a^2 + b^2), x, 1),
(ℯ^(a*x)*sin(b*x), -((b*ℯ^(a*x)*cos(b*x))/(a^2 + b^2)) + (a*ℯ^(a*x)*sin(b*x))/(a^2 + b^2), x, 1),


# ::Section::Closed::
# Section 6.22 Exercises (p. 256-258)


# ::Subsection::Closed::
# Exercises 6 - 10


(acot(x), x*acot(x) + (1⨸2)*log(1 + x^2), x, 2),
(asec(x), x*asec(x) - atanh(sqrt(1 - 1/x^2)), x, 4),
(acsc(x), x*acsc(x) + atanh(sqrt(1 - 1/x^2)), x, 4),
(asin(x)^2, -2*x + 2*sqrt(1 - x^2)*asin(x) + x*asin(x)^2, x, 3),
(asin(x)/x^2, -(asin(x)/x) - atanh(sqrt(1 - x^2)), x, 4),


# ::Subsection::Closed::
# Exercises 29 - 37


(1/sqrt(a^2 - x^2), atan(x/sqrt(a^2 - x^2)), x, 2),
(1/sqrt(1 - 2*x - x^2), asin((1 + x)/sqrt(2)), x, 2),
(1/(a^2 + x^2), atan(x/a)/a, x, 1),
(1/(a + b*x^2), atan((sqrt(b)*x)/sqrt(a))/(sqrt(a)*sqrt(b)), x, 1),
(1/(x^2 - x + 2), -((2*atan((1 - 2*x)/sqrt(7)))/sqrt(7)), x, 2),
(x*atan(x), -(x/2) + atan(x)/2 + (1⨸2)*x^2*atan(x), x, 3),
(x^2*acos(x), (-(1⨸3))*sqrt(1 - x^2) + (1⨸9)*(1 - x^2)^(3⨸2) + (1⨸3)*x^3*acos(x), x, 4),
(x*atan(x)^2, (-x)*atan(x) + atan(x)^2⨸2 + (1⨸2)*x^2*atan(x)^2 + (1⨸2)*log(1 + x^2), x, 5),
(atan(sqrt(x)), -sqrt(x) + atan(sqrt(x)) + x*atan(sqrt(x)), x, 4),


# ::Subsection::Closed::
# Exercises 38 - 47


(atan(sqrt(x))/(sqrt(x)*(1 + x)), atan(sqrt(x))^2, x, 1),
(sqrt(1 - x^2), (1⨸2)*x*sqrt(1 - x^2) + asin(x)/2, x, 2),
(x*ℯ^atan(x)/(1 + x^2)^(3⨸2), -((ℯ^atan(x)*(1 - x))/(2*sqrt(1 + x^2))), x, 1),
(ℯ^atan(x)/(1 + x^2)^(3⨸2), (ℯ^atan(x)*(1 + x))/(2*sqrt(1 + x^2)), x, 1),
(x^2/(1 + x^2)^2, -(x/(2*(1 + x^2))) + atan(x)/2, x, 2),
(ℯ^x/(1 + ℯ^(2*x)), atan(ℯ^x), x, 2),
(acot(ℯ^x)/ℯ^x, -x - acot(ℯ^x)/ℯ^x + (1⨸2)*log(1 + ℯ^(2*x)), x, 5),
(((a + x)/(a - x))^(1⨸2), -((a - x)*sqrt((a + x)/(a - x))) + 2*a*atan(sqrt((a + x)/(a - x))), x, 3),
(sqrt((x - a)*(b - x)), (-(1⨸4))*(a + b - 2*x)*sqrt((-a)*b + (a + b)*x - x^2) - (1⨸8)*(a - b)^2*atan((a + b - 2*x)/(2*sqrt((-a)*b + (a + b)*x - x^2))), x, 4),
(1/sqrt((x - a)*(b - x)), -atan((a + b - 2*x)/(2*sqrt((-a)*b + (a + b)*x - x^2))), x, 3),


# ::Section::Closed::
# Section 6.23 Integration by partial fractions (p. 258-264)


# ::Subsection::Closed::
# Example 1


((5*x + 3)/(x^2 + 2*x - 3), 2*log(1 - x) + 3*log(3 + x), x, 3),


# ::Subsection::Closed::
# Example 2


((2*x + 5)/(x^2 + 2*x - 3), (7⨸4)*log(1 - x) + (1⨸4)*log(3 + x), x, 3),
((x^3 + 3*x)/(x^2 - 2*x - 3), 2*x + x^2⨸2 + 9*log(3 - x) + log(1 + x), x, 6),


# ::Subsection::Closed::
# Example 3


((2*x^2 + 5*x - 1)/(x^3 + x^2 - 2*x), 2*log(1 - x) + log(x)/2 - (1⨸2)*log(2 + x), x, 3),


# ::Subsection::Closed::
# Example 4


((x^2 + 2*x + 3)/((x - 1)*(x + 1)^2), 1/(1 + x) + (3⨸2)*log(1 - x) - (1⨸2)*log(1 + x), x, 2),


# ::Subsection::Closed::
# Example 5


((3*x^2 + 2*x - 2)/(x^3 - 1), (4*atan((1 + 2*x)/sqrt(3)))/sqrt(3) + log(1 - x^3), x, 5),


# ::Subsection::Closed::
# Example 6


((x^4 - x^3 + 2*x^2 - x + 2)/((x - 1)*(x^2 + 2)^2), 1/(2*(2 + x^2)) - atan(x/sqrt(2))/(3*sqrt(2)) + (1⨸3)*log(1 - x) + (1⨸3)*log(2 + x^2), x, 6),


# ::Section::Closed::
# Section 6.24 Integrals which can be transformed into integrals of rational functions (p. 264-266)


# ::Subsection::Closed::
# Example 1


(1/(sin(x) + cos(x)), -(atanh((cos(x) - sin(x))/sqrt(2))/sqrt(2)), x, 2),


# ::Subsection::Closed::
# Example 2


(x/(4 - x^2 + sqrt(4 - x^2)), -log(1 + sqrt(4 - x^2)), x, 3),


# ::Section::Closed::
# Section 6.25 Exercises (p. 267-268)


# ::Subsection::Closed::
# Exercises 1 - 10


((2*x + 3)/((x - 2)*(x + 5)), log(2 - x) + log(5 + x), x, 2),
(x/((x + 1)*(x + 2)*(x + 3)), (-(1⨸2))*log(1 + x) + 2*log(2 + x) - (3⨸2)*log(3 + x), x, 2),
(x/(x^3 - 3*x + 2), 1/(3*(1 - x)) + (2⨸9)*log(1 - x) - (2⨸9)*log(2 + x), x, 2),
((x^4 + 2*x - 6)/(x^3 + x^2 - 2*x), -x + x^2⨸2 - log(1 - x) + 3*log(x) + log(2 + x), x, 3),
((8*x^3 + 7)/((x + 1)*(2*x + 1)^3), -(3/(1 + 2*x)^2) + 3/(1 + 2*x) + log(1 + x), x, 2),
((4*x^2 + x + 1)/(x^3 - 1), 2*log(1 - x) + log(1 + x + x^2), x, 3),
(x^4/(x^4 + 5*x^2 + 4), x - (8⨸3)*atan(x/2) + atan(x)/3, x, 4),
((x + 2)/(x^2 + x), 2*log(x) - log(1 + x), x, 2),
(1/(x*(x^2 + 1)^2), 1/(2*(1 + x^2)) + log(x) - (1⨸2)*log(1 + x^2), x, 3),
(1/((x + 1)*(x + 2)^2*(x + 3)^3), 1/(2 + x) + 1/(4*(3 + x)^2) + 5/(4*(3 + x)) + (1⨸8)*log(1 + x) + 2*log(2 + x) - (17⨸8)*log(3 + x), x, 2),


# ::Subsection::Closed::
# Exercises 11 - 20


(x/(x + 1)^2, 1/(1 + x) + log(1 + x), x, 2),
(1/(x^3 - x), -log(x) + (1⨸2)*log(1 - x^2), x, 5),
(x^2/(x^2 + x - 6), x + (4⨸5)*log(2 - x) - (9⨸5)*log(3 + x), x, 4),
((x + 2)/(x^2 - 4*x + 4), 4/(2 - x) + log(2 - x), x, 3),
(1/((x^2 - 4*x + 4)*(x^2 - 4*x + 5)), 1/(2 - x) + atan(2 - x), x, 4),
((x - 3)/(x^3 + 3*x^2 + 2*x), -((3*log(x))/2) + 4*log(1 + x) - (5⨸2)*log(2 + x), x, 3),
(1/(x^2 - 1)^2, x/(2*(1 - x^2)) + atanh(x)/2, x, 2),
((x + 1)/(x^3 - 1), (2⨸3)*log(1 - x) - (1⨸3)*log(1 + x + x^2), x, 3),
((x^4 + 1)/(x*(x^2 + 1)^2), 1/(1 + x^2) + log(x), x, 3),
(1/(x^4 - 2*x^3), 1/(4*x^2) + 1/(4*x) + (1⨸8)*log(2 - x) - log(x)/8, x, 3),


# ::Subsection::Closed::
# Exercises 21 - 30


((1 - x^3)/(x*(x^2 + 1)), -x + atan(x) + log(x) - log(1 + x^2)/2, x, 5),
(1/(x^4 - 1), -(atan(x)/2) - atanh(x)/2, x, 3),
(1/(x^4 + 1), -(atan(1 - sqrt(2)*x)/(2*sqrt(2))) + atan(1 + sqrt(2)*x)/(2*sqrt(2)) - log(1 - sqrt(2)*x + x^2)/(4*sqrt(2)) + log(1 + sqrt(2)*x + x^2)/(4*sqrt(2)), x, 9),
(x^2/(x^2 + 2*x + 2)^2, -((x*(2 + x))/(2*(2 + 2*x + x^2))) + atan(1 + x), x, 3),
((4*x^5 - 1)/(x^5 + x + 1)^2, -(x/(1 + x + x^5)), x, 1),
(1/(2*sin(x) - cos(x) + 5), x/(2*sqrt(5)) + atan((2*cos(x) + sin(x))/(5 + 2*sqrt(5) - cos(x) + 2*sin(x)))/sqrt(5), x, 3),
(1/(1 + a*cos(x)), (2*atan((sqrt(1 - a)*tan(x/2))/sqrt(1 + a)))/sqrt(1 - a^2), x, 2),
(1/(1 + 2*cos(x)), -(log(sqrt(3)*cos(x/2) - sin(x/2))/sqrt(3)) + log(sqrt(3)*cos(x/2) + sin(x/2))/sqrt(3), x, 2),
(1/(1 + 1⨸2*cos(x)), (2*x)/sqrt(3) - (4*atan(sin(x)/(2 + sqrt(3) + cos(x))))/sqrt(3), x, 1),
(sin(x)^2/(1 + sin(x)^2), x - x/sqrt(2) - atan((cos(x)*sin(x))/(1 + sqrt(2) + sin(x)^2))/sqrt(2), x, 3),
(1/(a^2*sin(x)^2 + b^2*cos(x)^2), atan((a*tan(x))/b)/(a*b), x, 2),


# ::Subsection::Closed::
# Exercises 31 - 40


(1/(a*sin(x) + b*cos(x))^2, sin(x)/(b*(b*cos(x) + a*sin(x))), x, 1),
(sin(x)/(1 + sin(x) + cos(x)), x/2 - (1⨸2)*log(1 + cos(x) + sin(x)) - (1⨸2)*log(1 + tan(x/2)), x, 3),
(sqrt(3 - x^2), (1⨸2)*x*sqrt(3 - x^2) + (3⨸2)*asin(x/sqrt(3)), x, 2),
(x/sqrt(3 - x^2), -sqrt(3 - x^2), x, 1),
(sqrt(3 - x^2)/x, sqrt(3 - x^2) - sqrt(3)*atanh(sqrt(3 - x^2)/sqrt(3)), x, 4),
(sqrt(x^2 + x)/x, sqrt(x + x^2) + atanh(x/sqrt(x + x^2)), x, 3),
(sqrt(x^2 + 5), (1⨸2)*x*sqrt(5 + x^2) + (5⨸2)*asinh(x/sqrt(5)), x, 2),
(x/sqrt(x^2 + x + 1), sqrt(1 + x + x^2) - (1⨸2)*asinh((1 + 2*x)/sqrt(3)), x, 3),
(1/sqrt(x^2 + x), 2*atanh(x/sqrt(x + x^2)), x, 2),
(sqrt(2 - x - x^2)/x^2, -(sqrt(2 - x - x^2)/x) + asin((1⨸3)*(-1 - 2*x)) + atanh((4 - x)/(2*sqrt(2)*sqrt(2 - x - x^2)))/(2*sqrt(2)), x, 6),


# ::Section::Closed::
# Section 6.26 Miscellaneous review exercises (p. 268-271)


# ::Subsection::Closed::
# Exercise 1


(log(t)/(t + 1), log(t)*log(1 + t) + PolyLog_reli(2., -t), t, 2),


# ::Subsection::Closed::
# Exercise 4


(log(ℯ^cos(x)), (-x)*cos(x) + x*log(ℯ^cos(x)) + sin(x), x, 3),


# ::Subsection::Closed::
# Exercise 6


(ℯ^t/t, Expinti(t), t, 1),
(ℯ^(a*t)/t, Expinti(a*t), t, 1),
(ℯ^t/t^2, -(ℯ^t/t) + Expinti(t), t, 2),
(ℯ^(1/t), ℯ^(1/t)*t - Expinti(1/t), t, 2),


# ::Subsection::Closed::
# Exercise 12


(1/(ℯ^t*(t - a - 1)), ℯ^(-1 - a)*Expinti(1 + a - t), t, 1),
(t*(ℯ^t^2/(t^2 + 1)), Expinti(1 + t^2)/(2*ℯ), t, 2),
(ℯ^t/(t + 1)^2, -(ℯ^t/(1 + t)) + Expinti(1 + t)/ℯ, t, 2),
(ℯ^t*log(1 + t), -(Expinti(1 + t)/ℯ) + ℯ^t*log(1 + t), t, 2),


# ::Subsection::Closed::
# Exercise 25


(t/ℯ^t, -ℯ^(-t) - t/ℯ^t, t, 2),
(t^2/ℯ^t, -2/ℯ^t - (2*t)/ℯ^t - t^2/ℯ^t, t, 3),
(t^3/ℯ^t, -6/ℯ^t - (6*t)/ℯ^t - (3*t^2)/ℯ^t - t^3/ℯ^t, t, 4),


# ::Subsection::Closed::
# Exercise 26


((c*sin(x) + d*cos(x))/(a*sin(x) + b*cos(x)), ((a*c + b*d)*x)/(a^2 + b^2) - ((c*b - a*d)*log(b*cos(x) + a*sin(x)))/(a^2 + b^2), x, 1),


# ::Subsection::Closed::
# Exercise 28


(1/log(t), Expinti(log(t)), t, 1),
(1/log(t)^2, -(t/log(t)) + Expinti(log(t)), t, 2),
(1/log(t)^(n + 1), ((-Gamma(-n, -log(t)))*(-log(t))^n)/log(t)^n, t, 2),
(ℯ^(2*t)/(t - 1), ℯ^2*Expinti(-2*(1 - t)), t, 1),
(ℯ^(2*x)/(x^2 - 3*x + 2), ℯ^4*Expinti(-4 + 2*x) - ℯ^2*Expinti(-2 + 2*x), x, 4),


# ::Subsection::Closed::
# Exercise 30


(1/(1 + t^3)^(1⨸2), (2*sqrt(2 + sqrt(3))*(1 + t)*sqrt((1 - t + t^2)/(1 + sqrt(3) + t)^2)*Elliptic_f(asin((1 - sqrt(3) + t)/(1 + sqrt(3) + t)), -7 - 4*sqrt(3)))/(3^(1⨸4)*sqrt((1 + t)/(1 + sqrt(3) + t)^2)*sqrt(1 + t^3)), t, 1),




]
# Total integrals translated: 175

bondarenko = [
# ::Package::

# ::Title::
# Vladimir Bondarenko Integration Problems


# ::Section::Closed::
# 9 June 2010


(1/(sqrt(2) + sin(z) + cos(z)), -((1 - sqrt(2)*sin(z))/(cos(z) - sin(z))), z, 1),


(1/(sqrt(1 + x) + sqrt(1 - x))^2, -(1/(2*x)) + sqrt(1 - x^2)/(2*x) + asin(x)/2, x, 4),


(1/(1 + cos(x))^2, sin(x)/(3*(1 + cos(x))^2) + sin(x)/(3*(1 + cos(x))), x, 2),
##XXX-XXX(sin(x)/sqrt(1 + x), sqrt(2*π)*cos(1)*FresnelIntegrals.fresnels(sqrt(2/π)*sqrt(1 + x)) - sqrt(2*π)*FresnelIntegrals.fresnelc(sqrt(2/π)*sqrt(1 + x))*sin(1), x, 5),
(1/(cos(x) + sin(x))^6, -((cos(x) - sin(x))/(10*(cos(x) + sin(x))^5)) - (cos(x) - sin(x))/(15*(cos(x) + sin(x))^3) + (2*sin(x))/(15*(cos(x) + sin(x))), x, 3),


(log(x^4 + 1/x^4), -4*x - sqrt(2 + sqrt(2))*atan((sqrt(2 - sqrt(2)) - 2*x)/sqrt(2 + sqrt(2))) - sqrt(2 - sqrt(2))*atan((sqrt(2 + sqrt(2)) - 2*x)/sqrt(2 - sqrt(2))) + sqrt(2 + sqrt(2))*atan((sqrt(2 - sqrt(2)) + 2*x)/sqrt(2 + sqrt(2))) + sqrt(2 - sqrt(2))*atan((sqrt(2 + sqrt(2)) + 2*x)/sqrt(2 - sqrt(2))) - (1//2)*sqrt(2 - sqrt(2))*log(1 - sqrt(2 - sqrt(2))*x + x^2) + (1//2)*sqrt(2 - sqrt(2))*log(1 + sqrt(2 - sqrt(2))*x + x^2) - (1//2)*sqrt(2 + sqrt(2))*log(1 - sqrt(2 + sqrt(2))*x + x^2) + (1//2)*sqrt(2 + sqrt(2))*log(1 + sqrt(2 + sqrt(2))*x + x^2) + x*log(1/x^4 + x^4), x, 22),
(log(1 + x)/(x*sqrt(1 + sqrt(1 + x))), -8*atanh(sqrt(1 + sqrt(1 + x))) - (2*log(1 + x))/sqrt(1 + sqrt(1 + x)) - sqrt(2)*atanh(sqrt(1 + sqrt(1 + x))/sqrt(2))*log(1 + x) + 2*sqrt(2)*atanh(1/sqrt(2))*log(1 - sqrt(1 + sqrt(1 + x))) - 2*sqrt(2)*atanh(1/sqrt(2))*log(1 + sqrt(1 + sqrt(1 + x))) + sqrt(2)*PolyLog_reli(2., -((sqrt(2)*(1 - sqrt(1 + sqrt(1 + x))))/(2 - sqrt(2)))) - sqrt(2)*PolyLog_reli(2., (sqrt(2)*(1 - sqrt(1 + sqrt(1 + x))))/(2 + sqrt(2))) - sqrt(2)*PolyLog_reli(2., -((sqrt(2)*(1 + sqrt(1 + sqrt(1 + x))))/(2 - sqrt(2)))) + sqrt(2)*PolyLog_reli(2., (sqrt(2)*(1 + sqrt(1 + sqrt(1 + x))))/(2 + sqrt(2))), x, -1),
(log(1 + x)/x*sqrt(1 + sqrt(1 + x)), -16*sqrt(1 + sqrt(1 + x)) + 16*atanh(sqrt(1 + sqrt(1 + x))) + 4*sqrt(1 + sqrt(1 + x))*log(1 + x) - 2*sqrt(2)*atanh(sqrt(1 + sqrt(1 + x))/sqrt(2))*log(1 + x) + 4*sqrt(2)*atanh(1/sqrt(2))*log(1 - sqrt(1 + sqrt(1 + x))) - 4*sqrt(2)*atanh(1/sqrt(2))*log(1 + sqrt(1 + sqrt(1 + x))) + 2*sqrt(2)*PolyLog_reli(2., -((sqrt(2)*(1 - sqrt(1 + sqrt(1 + x))))/(2 - sqrt(2)))) - 2*sqrt(2)*PolyLog_reli(2., (sqrt(2)*(1 - sqrt(1 + sqrt(1 + x))))/(2 + sqrt(2))) - 2*sqrt(2)*PolyLog_reli(2., -((sqrt(2)*(1 + sqrt(1 + sqrt(1 + x))))/(2 - sqrt(2)))) + 2*sqrt(2)*PolyLog_reli(2., (sqrt(2)*(1 + sqrt(1 + sqrt(1 + x))))/(2 + sqrt(2))), x, -1),


# ::Section::Closed::
# 4 July 2010


(1/(1 + sqrt(x + sqrt(1 + x^2))), -(1/(2*(x + sqrt(1 + x^2)))) + 1/sqrt(x + sqrt(1 + x^2)) + sqrt(x + sqrt(1 + x^2)) + (1//2)*log(x + sqrt(1 + x^2)) - 2*log(1 + sqrt(x + sqrt(1 + x^2))), x, 4),
(sqrt(1 + x)/(x + sqrt(1 + sqrt(1 + x))), 2*sqrt(1 + x) + (8*atanh((1 + 2*sqrt(1 + sqrt(1 + x)))/sqrt(5)))/sqrt(5), x, 6),
(1/(x - sqrt(1 + sqrt(1 + x))), (2//5)*(5 + sqrt(5))*log(1 - sqrt(5) - 2*sqrt(1 + sqrt(1 + x))) + (2//5)*(5 - sqrt(5))*log(1 + sqrt(5) - 2*sqrt(1 + sqrt(1 + x))), x, 5),
(x/(x + sqrt(1 - sqrt(1 + x))), 2*sqrt(1 + x) - 4*sqrt(1 - sqrt(1 + x)) + (1 - sqrt(1 + x))^2 + (8*atanh((1 + 2*sqrt(1 - sqrt(1 + x)))/sqrt(5)))/sqrt(5), x, 6),
(sqrt(sqrt(1 + x) + x)/((1 + x^2)*sqrt(1 + x)), -((I*atan((2 + sqrt(1 - I) - (1 - 2*sqrt(1 - I))*sqrt(1 + x))/(2*sqrt(I + sqrt(1 - I))*sqrt(x + sqrt(1 + x)))))/(2*sqrt((1 - I)/(I + sqrt(1 - I))))) + (I*atan((2 + sqrt(1 + I) - (1 - 2*sqrt(1 + I))*sqrt(1 + x))/(2*sqrt(-I + sqrt(1 + I))*sqrt(x + sqrt(1 + x)))))/(2*sqrt(-((1 + I)/(I - sqrt(1 + I))))) + (I*atanh((2 - sqrt(1 - I) - (1 + 2*sqrt(1 - I))*sqrt(1 + x))/(2*sqrt(-I + sqrt(1 - I))*sqrt(x + sqrt(1 + x)))))/(2*sqrt(-((1 - I)/(I - sqrt(1 - I))))) - (I*atanh((2 - sqrt(1 + I) - (1 + 2*sqrt(1 + I))*sqrt(1 + x))/(2*sqrt(I + sqrt(1 + I))*sqrt(x + sqrt(1 + x)))))/(2*sqrt((1 + I)/(I + sqrt(1 + I)))), x, 20),
(sqrt(x + sqrt(1 + x))/(1 + x^2), (1//2)*I*sqrt(I + sqrt(1 - I))*atan((2 + sqrt(1 - I) - (1 - 2*sqrt(1 - I))*sqrt(1 + x))/(2*sqrt(I + sqrt(1 - I))*sqrt(x + sqrt(1 + x)))) - (1//2)*I*sqrt(-I + sqrt(1 + I))*atan((2 + sqrt(1 + I) - (1 - 2*sqrt(1 + I))*sqrt(1 + x))/(2*sqrt(-I + sqrt(1 + I))*sqrt(x + sqrt(1 + x)))) + (1//2)*I*sqrt(-I + sqrt(1 - I))*atanh((2 - sqrt(1 - I) - (1 + 2*sqrt(1 - I))*sqrt(1 + x))/(2*sqrt(-I + sqrt(1 - I))*sqrt(x + sqrt(1 + x)))) - (1//2)*I*sqrt(I + sqrt(1 + I))*atanh((2 - sqrt(1 + I) - (1 + 2*sqrt(1 + I))*sqrt(1 + x))/(2*sqrt(I + sqrt(1 + I))*sqrt(x + sqrt(1 + x)))), x, 22),
(sqrt(1 + sqrt(x) + sqrt(1 + 2*sqrt(x) + 2*x)), (2*sqrt(1 + sqrt(x) + sqrt(1 + 2*sqrt(x) + 2*x))*(2 + sqrt(x) + 6*x^(3//2) - (2 - sqrt(x))*sqrt(1 + 2*sqrt(x) + 2*x)))/(15*sqrt(x)), x, 2),
(sqrt(sqrt(2) + sqrt(x) + sqrt(2 + sqrt(8)*sqrt(x) + 2*x)), (1/(15*sqrt(x)))*(2*sqrt(2)*sqrt(sqrt(2) + sqrt(x) + sqrt(2)*sqrt(1 + sqrt(2)*sqrt(x) + x))*(4 + sqrt(2)*sqrt(x) + 3*sqrt(2)*x^(3//2) - sqrt(2)*(2*sqrt(2) - sqrt(x))*sqrt(1 + sqrt(2)*sqrt(x) + x))), x, 3),
(sqrt(x + sqrt(1 + x))/x^2, -(sqrt(x + sqrt(1 + x))/x) - (1//4)*atan((3 + sqrt(1 + x))/(2*sqrt(x + sqrt(1 + x)))) + (3//4)*atanh((1 - 3*sqrt(1 + x))/(2*sqrt(x + sqrt(1 + x)))), x, 7),
(sqrt(1/x + sqrt(1 + 1/x)), sqrt(sqrt(1 + 1/x) + 1/x)*x + (1//4)*atan((3 + sqrt(1 + 1/x))/(2*sqrt(sqrt(1 + 1/x) + 1/x))) - (3//4)*atanh((1 - 3*sqrt(1 + 1/x))/(2*sqrt(sqrt(1 + 1/x) + 1/x))), x, 7),


(sqrt(1 + exp(-x))/(exp(x) - exp(-x)), (-sqrt(2))*atanh(sqrt(1 + ℯ^(-x))/sqrt(2)), x, 6),
(sqrt(1 + exp(-x))/sinh(x), -2*sqrt(2)*atanh(sqrt(1 + ℯ^(-x))/sqrt(2)), x, 7),


(1/(cos(x) + cos(3*x))^5, (-(523//256))*atanh(sin(x)) + (1483*atanh(sqrt(2)*sin(x)))/(512*sqrt(2)) + sin(x)/(32*(1 - 2*sin(x)^2)^4) - (17*sin(x))/(192*(1 - 2*sin(x)^2)^3) + (203*sin(x))/(768*(1 - 2*sin(x)^2)^2) - (437*sin(x))/(512*(1 - 2*sin(x)^2)) - (43//256)*sec(x)*tan(x) - (1//128)*sec(x)^3*tan(x), x, -45),
(1/(cos(x) + sin(x) + 1)^2, -log(1 + tan(x/2)) - (cos(x) - sin(x))/(1 + cos(x) + sin(x)), x, 3),


(sqrt(1 + tanh(4*x)), atanh(sqrt(1 + tanh(4*x))/sqrt(2))/(2*sqrt(2)), x, 2),
(tanh(x)/sqrt(exp(2*x) + exp(x)), (2*sqrt(ℯ^x + ℯ^(2*x)))/ℯ^x - atan((I - (1 - 2*I)*ℯ^x)/(2*sqrt(1 + I)*sqrt(ℯ^x + ℯ^(2*x))))/sqrt(1 + I) + atan((I + (1 + 2*I)*ℯ^x)/(2*sqrt(1 - I)*sqrt(ℯ^x + ℯ^(2*x))))/sqrt(1 - I), x, -11),
# {Sqrt[Sinh[2*x]/Cosh[x]], x, 5, (2*I*Sqrt[2]*EllipticE[Pi/4 - (I*x)/2, 2]*Sqrt[Sinh[x]])/Sqrt[I*Sinh[x]], (2*I*EllipticE[Pi/4 - (I*x)/2, 2]*Sqrt[Sech[x]*Sinh[2*x]])/Sqrt[I*Sinh[x]]}


(log(x^2 + sqrt(1 - x^2)), -2*x - asin(x) + sqrt((1//2)*(1 + sqrt(5)))*atan(sqrt(2/(1 + sqrt(5)))*x) + sqrt((1//2)*(1 + sqrt(5)))*atan((sqrt((1//2)*(1 + sqrt(5)))*x)/sqrt(1 - x^2)) + sqrt((1//2)*(-1 + sqrt(5)))*atanh(sqrt(2/(-1 + sqrt(5)))*x) - sqrt((1//2)*(-1 + sqrt(5)))*atanh((sqrt((1//2)*(-1 + sqrt(5)))*x)/sqrt(1 - x^2)) + x*log(x^2 + sqrt(1 - x^2)), x, -31),
(log(1 + exp(x))/(1 + exp(2*x)), (-(1//2))*log((1//2 - I/2)*(I - ℯ^x))*log(1 + ℯ^x) - (1//2)*log((-(1//2) - I/2)*(I + ℯ^x))*log(1 + ℯ^x) - PolyLog_reli(2., -ℯ^x) - (1//2)*PolyLog_reli(2., (1//2 - I/2)*(1 + ℯ^x)) - (1//2)*PolyLog_reli(2., (1//2 + I/2)*(1 + ℯ^x)), x, 12),
(log(1 + cosh(x)^2)^2*cosh(x), -8*sqrt(2)*atan(sinh(x)/sqrt(2)) + 4*I*sqrt(2)*atan(sinh(x)/sqrt(2))^2 + 8*sqrt(2)*atan(sinh(x)/sqrt(2))*log((2*sqrt(2))/(sqrt(2) + I*sinh(x))) + 4*sqrt(2)*atan(sinh(x)/sqrt(2))*log(2 + sinh(x)^2) + 4*I*sqrt(2)*PolyLog_reli(2., 1 - (2*sqrt(2))/(sqrt(2) + I*sinh(x))) + 8*sinh(x) - 4*log(2 + sinh(x)^2)*sinh(x) + log(2 + sinh(x)^2)^2*sinh(x), x, 13),
(log(sinh(x) + cosh(x)^2)^2*cosh(x), -4*sqrt(3)*atan((1 + 2*sinh(x))/sqrt(3)) - (1//2)*(1 - I*sqrt(3))*log(1 - I*sqrt(3) + 2*sinh(x))^2 - (1 + I*sqrt(3))*log((I*(1 - I*sqrt(3) + 2*sinh(x)))/(2*sqrt(3)))*log(1 + I*sqrt(3) + 2*sinh(x)) - (1//2)*(1 + I*sqrt(3))*log(1 + I*sqrt(3) + 2*sinh(x))^2 - (1 - I*sqrt(3))*log(1 - I*sqrt(3) + 2*sinh(x))*log(-((I*(1 + I*sqrt(3) + 2*sinh(x)))/(2*sqrt(3)))) - 2*log(1 + sinh(x) + sinh(x)^2) + (1 - I*sqrt(3))*log(1 - I*sqrt(3) + 2*sinh(x))*log(1 + sinh(x) + sinh(x)^2) + (1 + I*sqrt(3))*log(1 + I*sqrt(3) + 2*sinh(x))*log(1 + sinh(x) + sinh(x)^2) - (1 + I*sqrt(3))*PolyLog_reli(2., -((I - sqrt(3) + 2*I*sinh(x))/(2*sqrt(3)))) - (1 - I*sqrt(3))*PolyLog_reli(2., (I + sqrt(3) + 2*I*sinh(x))/(2*sqrt(3))) + 8*sinh(x) - 4*log(1 + sinh(x) + sinh(x)^2)*sinh(x) + log(1 + sinh(x) + sinh(x)^2)^2*sinh(x), x, 28),
(log(x + sqrt(1 + x))/(1 + x^2), (1//2)*I*log(sqrt(1 - I) - sqrt(1 + x))*log(x + sqrt(1 + x)) - (1//2)*I*log(sqrt(1 + I) - sqrt(1 + x))*log(x + sqrt(1 + x)) + (1//2)*I*log(sqrt(1 - I) + sqrt(1 + x))*log(x + sqrt(1 + x)) - (1//2)*I*log(sqrt(1 + I) + sqrt(1 + x))*log(x + sqrt(1 + x)) - (1//2)*I*log(sqrt(1 - I) + sqrt(1 + x))*log((1 - sqrt(5) + 2*sqrt(1 + x))/(1 - 2*sqrt(1 - I) - sqrt(5))) - (1//2)*I*log(sqrt(1 - I) - sqrt(1 + x))*log((1 - sqrt(5) + 2*sqrt(1 + x))/(1 + 2*sqrt(1 - I) - sqrt(5))) + (1//2)*I*log(sqrt(1 + I) + sqrt(1 + x))*log((1 - sqrt(5) + 2*sqrt(1 + x))/(1 - 2*sqrt(1 + I) - sqrt(5))) + (1//2)*I*log(sqrt(1 + I) - sqrt(1 + x))*log((1 - sqrt(5) + 2*sqrt(1 + x))/(1 + 2*sqrt(1 + I) - sqrt(5))) - (1//2)*I*log(sqrt(1 - I) + sqrt(1 + x))*log((1 + sqrt(5) + 2*sqrt(1 + x))/(1 - 2*sqrt(1 - I) + sqrt(5))) - (1//2)*I*log(sqrt(1 - I) - sqrt(1 + x))*log((1 + sqrt(5) + 2*sqrt(1 + x))/(1 + 2*sqrt(1 - I) + sqrt(5))) + (1//2)*I*log(sqrt(1 + I) + sqrt(1 + x))*log((1 + sqrt(5) + 2*sqrt(1 + x))/(1 - 2*sqrt(1 + I) + sqrt(5))) + (1//2)*I*log(sqrt(1 + I) - sqrt(1 + x))*log((1 + sqrt(5) + 2*sqrt(1 + x))/(1 + 2*sqrt(1 + I) + sqrt(5))) - (1//2)*I*PolyLog_reli(2., (2*(sqrt(1 - I) - sqrt(1 + x)))/(1 + 2*sqrt(1 - I) - sqrt(5))) - (1//2)*I*PolyLog_reli(2., (2*(sqrt(1 - I) - sqrt(1 + x)))/(1 + 2*sqrt(1 - I) + sqrt(5))) + (1//2)*I*PolyLog_reli(2., (2*(sqrt(1 + I) - sqrt(1 + x)))/(1 + 2*sqrt(1 + I) - sqrt(5))) + (1//2)*I*PolyLog_reli(2., (2*(sqrt(1 + I) - sqrt(1 + x)))/(1 + 2*sqrt(1 + I) + sqrt(5))) - (1//2)*I*PolyLog_reli(2., -((2*(sqrt(1 - I) + sqrt(1 + x)))/(1 - 2*sqrt(1 - I) - sqrt(5)))) - (1//2)*I*PolyLog_reli(2., -((2*(sqrt(1 - I) + sqrt(1 + x)))/(1 - 2*sqrt(1 - I) + sqrt(5)))) + (1//2)*I*PolyLog_reli(2., -((2*(sqrt(1 + I) + sqrt(1 + x)))/(1 - 2*sqrt(1 + I) - sqrt(5)))) + (1//2)*I*PolyLog_reli(2., -((2*(sqrt(1 + I) + sqrt(1 + x)))/(1 - 2*sqrt(1 + I) + sqrt(5)))), x, 44),
(log(x + sqrt(1 + x))^2/(1 + x)^2, log(1 + x) + (2*log(x + sqrt(1 + x)))/sqrt(1 + x) - 6*log(sqrt(1 + x))*log(x + sqrt(1 + x)) - log(x + sqrt(1 + x))^2/(1 + x) - (1 + sqrt(5))*log(1 - sqrt(5) + 2*sqrt(1 + x)) + 6*log((1//2)*(-1 + sqrt(5)))*log(1 - sqrt(5) + 2*sqrt(1 + x)) + (3 + sqrt(5))*log(x + sqrt(1 + x))*log(1 - sqrt(5) + 2*sqrt(1 + x)) - (1//2)*(3 + sqrt(5))*log(1 - sqrt(5) + 2*sqrt(1 + x))^2 - (1 - sqrt(5))*log(1 + sqrt(5) + 2*sqrt(1 + x)) + (3 - sqrt(5))*log(x + sqrt(1 + x))*log(1 + sqrt(5) + 2*sqrt(1 + x)) - (3 - sqrt(5))*log(-((1 - sqrt(5) + 2*sqrt(1 + x))/(2*sqrt(5))))*log(1 + sqrt(5) + 2*sqrt(1 + x)) - (1//2)*(3 - sqrt(5))*log(1 + sqrt(5) + 2*sqrt(1 + x))^2 - (3 + sqrt(5))*log(1 - sqrt(5) + 2*sqrt(1 + x))*log((1 + sqrt(5) + 2*sqrt(1 + x))/(2*sqrt(5))) + 6*log(sqrt(1 + x))*log(1 + (2*sqrt(1 + x))/(1 + sqrt(5))) + 6*PolyLog_reli(2., -((2*sqrt(1 + x))/(1 + sqrt(5)))) - (3 + sqrt(5))*PolyLog_reli(2., -((1 - sqrt(5) + 2*sqrt(1 + x))/(2*sqrt(5)))) - (3 - sqrt(5))*PolyLog_reli(2., (1 + sqrt(5) + 2*sqrt(1 + x))/(2*sqrt(5))) - 6*PolyLog_reli(2., 1 + (2*sqrt(1 + x))/(1 - sqrt(5))), x, 35),
(log(x + sqrt(1 + x))/x, log(-1 + sqrt(1 + x))*log(x + sqrt(1 + x)) + log(1 + sqrt(1 + x))*log(x + sqrt(1 + x)) - log(-1 + sqrt(1 + x))*log((1 - sqrt(5) + 2*sqrt(1 + x))/(3 - sqrt(5))) - log(1 + sqrt(1 + x))*log(-((1 - sqrt(5) + 2*sqrt(1 + x))/(1 + sqrt(5)))) - log(1 + sqrt(1 + x))*log(-((1 + sqrt(5) + 2*sqrt(1 + x))/(1 - sqrt(5)))) - log(-1 + sqrt(1 + x))*log((1 + sqrt(5) + 2*sqrt(1 + x))/(3 + sqrt(5))) - PolyLog_reli(2., (2*(1 - sqrt(1 + x)))/(3 - sqrt(5))) - PolyLog_reli(2., (2*(1 - sqrt(1 + x)))/(3 + sqrt(5))) - PolyLog_reli(2., (2*(1 + sqrt(1 + x)))/(1 - sqrt(5))) - PolyLog_reli(2., (2*(1 + sqrt(1 + x)))/(1 + sqrt(5))), x, 21),


(atan(2*tan(x)), x*atan(2*tan(x)) + (1//2)*I*x*log(1 - 3*ℯ^(2*I*x)) - (1//2)*I*x*log(1 - (1//3)*ℯ^(2*I*x)) - (1//4)*PolyLog_reli(2., (1//3)*ℯ^(2*I*x)) + (1//4)*PolyLog_reli(2., 3*ℯ^(2*I*x)), x, 7),
(atan(x)*log(x)/x, (1//2)*I*log(x)*PolyLog_reli(2., (-I)*x) - (1//2)*I*log(x)*PolyLog_reli(2., I*x) - (1//2)*I*PolyLog_reli(3., (-I)*x) + (1//2)*I*PolyLog_reli(3., I*x), x, 5),


# Note: Mathematica is unable to differentiate result back to integrand!
(atan(x)^2*sqrt(1 + x^2), asinh(x) - sqrt(1 + x^2)*atan(x) + (1//2)*x*sqrt(1 + x^2)*atan(x)^2 - I*atan(ℯ^(I*atan(x)))*atan(x)^2 + I*atan(x)*PolyLog_reli(2., (-I)*ℯ^(I*atan(x))) - I*atan(x)*PolyLog_reli(2., I*ℯ^(I*atan(x))) - PolyLog_reli(3., (-I)*ℯ^(I*atan(x))) + PolyLog_reli(3., I*ℯ^(I*atan(x))), x, 10),
]

bronstein = [
# ::Package::

# ::Title::
# Manuel Bronstein - Symbolic Integration Tutorial (1998)


# ::Section::Closed::
# 2  Algebraic Functions


((2*x^8 + 1)*(sqrt(x^8 + 1)/(x^17 + 2*x^9 + x)), -(1/(4*sqrt(1 + x^8))) - (1//4)*atanh(sqrt(1 + x^8)), x, 6),
(1/(1 + x^2), atan(x), x, 1),
(sqrt(x^8 + 1)/(x*(x^8 + 1)), (-(1//4))*atanh(sqrt(1 + x^8)), x, 3),
(x/sqrt(1 - x^3), (2*sqrt(1 - x^3))/(1 + sqrt(3) - x) - (3^(1//4)*sqrt(2 - sqrt(3))*(1 - x)*sqrt((1 + x + x^2)/(1 + sqrt(3) - x)^2)*Elliptic_e(asin((1 - sqrt(3) - x)/(1 + sqrt(3) - x)), -7 - 4*sqrt(3)))/(sqrt((1 - x)/(1 + sqrt(3) - x)^2)*sqrt(1 - x^3)) + (2*sqrt(2)*(1 - x)*sqrt((1 + x + x^2)/(1 + sqrt(3) - x)^2)*Elliptic_f(asin((1 - sqrt(3) - x)/(1 + sqrt(3) - x)), -7 - 4*sqrt(3)))/(3^(1//4)*sqrt((1 - x)/(1 + sqrt(3) - x)^2)*sqrt(1 - x^3)), x, 3),
(1/(x*sqrt(1 - x^3)), (-(2//3))*atanh(sqrt(1 - x^3)), x, 3),
(x/sqrt(x^4 + 10*x^2 - 96*x - 71), (1//8)*log(10001 + 3124*x^2 - 1408*x^3 + 54*x^4 - 128*x^5 + 20*x^6 + x^8 + sqrt(-71 - 96*x + 10*x^2 + x^4)*(781 - 528*x + 27*x^2 - 80*x^3 + 15*x^4 + x^6)), x, 1),


# ::Section::Closed::
# 3  Elementary Functions


((x - tan(x))/tan(x)^2, -(x^2//2) - x*cot(x), x, 6),
(1 + x*tan(x) + tan(x)^2, (I*x^2)/2 - x*log(1 + ℯ^(2*I*x)) + (1//2)*I*PolyLog_reli(2., -ℯ^(2*I*x)) + tan(x), x, 7),
(sin(x)/x, Sinint(x), x, 1),
((3*(x + ℯ^x)^(1//3) + (2*x^2 + 3*x)*ℯ^x + 5*x^2)/(x*(x + ℯ^x)^(1//3)), 3*x*(ℯ^x + x)^(2//3) + 3*log(x), x, 8),


(1/x + (1 + 1/x)/(x + log(x))^(3//2), log(x) - 2/sqrt(x + log(x)), x, 2),
((log(x)^2 + 2*x*log(x) + x^2 + (x + 1)*sqrt(x + log(x)))/(x*log(x)^2 + 2*x^2*log(x) + x^3), log(x) - 2/sqrt(x + log(x)), x, -3),

((2*log(x)^2 - log(x) - x^2)/(log(x)^3 - x^2*log(x)), (-(1//2))*log(x - log(x)) + (1//2)*log(x + log(x)) + Expinti(log(x)), x, 6),
# {Log[1 + E^x]^(1/3)/(1 + Log[1 + E^x]), x, 0, CannotIntegrate[Log[1 + E^x]^(1/3)/(1 + Log[1 + E^x]), x]}
# {((x^2 + 2*x + 1)*Sqrt[x + Log[x]] + (3*x + 1)*Log[x] + 3*x^2 + x)/((x*Log[x] + x^2)*Sqrt[x + Log[x]] + x^2*Log[x] + x^3), x, 0, 2*Sqrt[x + Log[x]] + 2*Log[x + Sqrt[x + Log[x]]]}


# ::Title::
# Manuel Bronstein - Symbolic Integration I; Transcendental FunctionsTutorial (2005)


# ::Section::Closed::
# 2.8  Rioboo's Algorithm for Real Rational Functions


((x^4 - 3*x^2 + 6)/(x^6 - 5*x^4 + 5*x^2 + 4), -atan(sqrt(3) - 2*x) + atan(sqrt(3) + 2*x) + atan((1//2)*x*(1 - 3*x^2 + x^4)), x, 1),
]

charlwood = [
# ::Package::

# ::Title::
# Kevin Charlwood - Integration on Computer Algebra Systems (2008)


# ::Subsection::Closed::
# Problem #1


# {ArcSin[x]*Log[x], x, 8, -2*Sqrt[1 - x^2] + ArcTanh[Sqrt[1 - x^2]] - x*ArcSin[x]*(1 - Log[x]) + Sqrt[1 - x^2]*Log[x], -2*Sqrt[1 - x^2] - x*ArcSin[x] + ArcTanh[Sqrt[1 - x^2]] + Sqrt[1 - x^2]*Log[x] + x*ArcSin[x]*Log[x]}


# ::Subsection::Closed::
# Problem #2


(x*asin(x)/sqrt(1 - x^2), x - sqrt(1 - x^2)*asin(x), x, 2),


# ::Subsection::Closed::
# Problem #3


(asin(sqrt(x + 1) - sqrt(x)), ((sqrt(x) + 3*sqrt(1 + x))*sqrt(-x + sqrt(x)*sqrt(1 + x)))/(4*sqrt(2)) - (3//8 + x)*asin(sqrt(x) - sqrt(1 + x)), x, -3),


# ::Subsection::Closed::
# Problem #4


(log(1 + x*sqrt(1 + x^2)), -2*x + sqrt(2*(1 + sqrt(5)))*atan(sqrt(-2 + sqrt(5))*(x + sqrt(1 + x^2))) - sqrt(2*(-1 + sqrt(5)))*atanh(sqrt(2 + sqrt(5))*(x + sqrt(1 + x^2))) + x*log(1 + x*sqrt(1 + x^2)), x, -32),


# ::Subsection::Closed::
# Problem #5


(cos(x)^2/sqrt(cos(x)^4 + cos(x)^2 + 1), x/3 + (1//3)*atan((cos(x)*(1 + cos(x)^2)*sin(x))/(1 + cos(x)^2*sqrt(1 + cos(x)^2 + cos(x)^4))), x, -5),


# ::Subsection::Closed::
# Problem #6


(tan(x)*sqrt(1 + tan(x)^4), (-(1//2))*asinh(tan(x)^2) - atanh((1 - tan(x)^2)/(sqrt(2)*sqrt(1 + tan(x)^4)))/sqrt(2) + (1//2)*sqrt(1 + tan(x)^4), x, 7),


# ::Subsection::Closed::
# Problem #7


(tan(x)/sqrt(1 + sec(x)^3), (-(2//3))*atanh(sqrt(1 + sec(x)^3)), x, 4),


# ::Subsection::Closed::
# Problem #8


(sqrt(tan(x)^2 + 2*tan(x) + 2), asinh(1 + tan(x)) - sqrt((1//2)*(1 + sqrt(5)))*atan((2*sqrt(5) - (5 + sqrt(5))*tan(x))/(sqrt(10*(1 + sqrt(5)))*sqrt(2 + 2*tan(x) + tan(x)^2))) - sqrt((1//2)*(-1 + sqrt(5)))*atanh((2*sqrt(5) + (5 - sqrt(5))*tan(x))/(sqrt(10*(-1 + sqrt(5)))*sqrt(2 + 2*tan(x) + tan(x)^2))), x, 9),


# ::Subsection::Closed::
# Problem #9


(sin(x)*atan(sqrt(sec(x) - 1)), (1//2)*atan(sqrt(-1 + sec(x))) - atan(sqrt(-1 + sec(x)))*cos(x) + (1//2)*cos(x)*sqrt(-1 + sec(x)), x, 7),


# ::Subsection::Closed::
# Problem #10


# {x^3*E^ArcSin[x]/Sqrt[1 - x^2], x, 5, (1/10)*E^ArcSin[x]*(3*x + x^3 - 3*Sqrt[1 - x^2] - 3*x^2*Sqrt[1 - x^2]), (3/10)*E^ArcSin[x]*x + (1/10)*E^ArcSin[x]*x^3 - (3/10)*E^ArcSin[x]*Sqrt[1 - x^2] - (3/10)*E^ArcSin[x]*x^2*Sqrt[1 - x^2]}


# ::Subsection::Closed::
# Problem #11


((x*log(1 + x^2)*log(x + sqrt(1 + x^2)))/sqrt(1 + x^2), 4*x - 2*atan(x) - x*log(1 + x^2) - 2*sqrt(1 + x^2)*log(x + sqrt(1 + x^2)) + sqrt(1 + x^2)*log(1 + x^2)*log(x + sqrt(1 + x^2)), x, 7),


# ::Subsection::Closed::
# Problem #12


(atan(x + sqrt(1 - x^2)), -(asin(x)/2) + (1//4)*sqrt(3)*atan((-1 + sqrt(3)*x)/sqrt(1 - x^2)) + (1//4)*sqrt(3)*atan((1 + sqrt(3)*x)/sqrt(1 - x^2)) - (1//4)*sqrt(3)*atan((-1 + 2*x^2)/sqrt(3)) + x*atan(x + sqrt(1 - x^2)) - (1//4)*atanh(x*sqrt(1 - x^2)) - (1//8)*log(1 - x^2 + x^4), x, -40),


# ::Subsection::Closed::
# Problem #13


(x*atan(x + sqrt(1 - x^2))/sqrt(1 - x^2), -(asin(x)/2) + (1//4)*sqrt(3)*atan((-1 + sqrt(3)*x)/sqrt(1 - x^2)) + (1//4)*sqrt(3)*atan((1 + sqrt(3)*x)/sqrt(1 - x^2)) - (1//4)*sqrt(3)*atan((-1 + 2*x^2)/sqrt(3)) - sqrt(1 - x^2)*atan(x + sqrt(1 - x^2)) + (1//4)*atanh(x*sqrt(1 - x^2)) + (1//8)*log(1 - x^2 + x^4), x, -32),


# ::Subsection::Closed::
# Problem #14


# {ArcSin[x]/(1 + Sqrt[1 - x^2]), x, 9, -((x*ArcSin[x])/(1 + Sqrt[1 - x^2])) + ArcSin[x]^2/2 - Log[1 + Sqrt[1 - x^2]], -(ArcSin[x]/x) + (Sqrt[1 - x^2]*ArcSin[x])/x + ArcSin[x]^2/2 - ArcTanh[Sqrt[1 - x^2]] - Log[x]}


# ::Subsection::Closed::
# Problem #15


(log(x + sqrt(1 + x^2))/(1 - x^2)^(3//2), (-(1//2))*asin(x^2) + (x*log(x + sqrt(1 + x^2)))/sqrt(1 - x^2), x, 3),


# ::Subsection::Closed::
# Problem #16


(asin(x)/(1 + x^2)^(3//2), (x*asin(x))/sqrt(1 + x^2) - asin(x^2)/2, x, 3),


# ::Subsection::Closed::
# Problem #17


(log(x + sqrt(x^2 - 1))/(1 + x^2)^(3//2), (-(1//2))*acosh(x^2) + (x*log(x + sqrt(-1 + x^2)))/sqrt(1 + x^2), x, 3),


# ::Subsection::Closed::
# Problem #18


(log(x)/(x^2*sqrt(x^2 - 1)), sqrt(-1 + x^2)/x - atanh(x/sqrt(-1 + x^2)) + (sqrt(-1 + x^2)*log(x))/x, x, 4),


# ::Subsection::Closed::
# Problem #19


(sqrt(1 + x^3)/x, (2*sqrt(1 + x^3))/3 - (2//3)*atanh(sqrt(1 + x^3)), x, 4),


# ::Subsection::Closed::
# Problem #20


(x*log(x + sqrt(x^2 - 1))/sqrt(x^2 - 1), -x + sqrt(-1 + x^2)*log(x + sqrt(-1 + x^2)), x, 2),


# ::Subsection::Closed::
# Problem #21


(x^3*(asin(x)/sqrt(1 - x^4)), (1//4)*x*sqrt(1 + x^2) - (1//2)*sqrt(1 - x^4)*asin(x) + asinh(x)/4, x, 5),


# ::Subsection::Closed::
# Problem #22


# {x^3*(ArcSec[x]/Sqrt[x^4 - 1]), x, 7, -(Sqrt[-1 + x^4]/(2*Sqrt[1 - 1/x^2]*x)) + (1/2)*Sqrt[-1 + x^4]*ArcSec[x] + (1/2)*ArcTanh[(Sqrt[1 - 1/x^2]*x)/Sqrt[-1 + x^4]], -(Sqrt[-1 + x^4]/(2*Sqrt[1 - 1/x^2]*x)) + (1/2)*Sqrt[-1 + x^4]*ArcSec[x] + (Sqrt[1 - x^2]*ArcTan[Sqrt[-1 + x^4]/Sqrt[1 - x^2]])/(2*Sqrt[1 - 1/x^2]*x)}


# ::Subsection::Closed::
# Problem #23


(x*atan(x)*log(x + sqrt(1 + x^2))/sqrt(1 + x^2), (-x)*atan(x) + (1//2)*log(1 + x^2) + sqrt(1 + x^2)*atan(x)*log(x + sqrt(1 + x^2)) - (1//2)*log(x + sqrt(1 + x^2))^2, x, 4),


# ::Subsection::Closed::
# Problem #24


(x*log(1 + sqrt(1 - x^2))/sqrt(1 - x^2), sqrt(1 - x^2) - log(1 + sqrt(1 - x^2)) - sqrt(1 - x^2)*log(1 + sqrt(1 - x^2)), x, 5),


# ::Subsection::Closed::
# Problem #25


(x*log(x + sqrt(1 + x^2))/sqrt(1 + x^2), -x + sqrt(1 + x^2)*log(x + sqrt(1 + x^2)), x, 2),


# ::Subsection::Closed::
# Problem #26


(x*log(x + sqrt(1 - x^2))/sqrt(1 - x^2), sqrt(1 - x^2) + atanh(sqrt(2)*x)/sqrt(2) - atanh(sqrt(2)*sqrt(1 - x^2))/sqrt(2) - sqrt(1 - x^2)*log(x + sqrt(1 - x^2)), x, 18),


# ::Subsection::Closed::
# Problem #27


(log(x)/(x^2*sqrt(1 - x^2)), -(sqrt(1 - x^2)/x) - asin(x) - (sqrt(1 - x^2)*log(x))/x, x, 3),


# ::Subsection::Closed::
# Problem #28


(x*atan(x)/sqrt(1 + x^2), -asinh(x) + sqrt(1 + x^2)*atan(x), x, 2),


# ::Subsection::Closed::
# Problem #29


(atan(x)/(x^2*sqrt(1 - x^2)), -((sqrt(1 - x^2)*atan(x))/x) - atanh(sqrt(1 - x^2)) + sqrt(2)*atanh(sqrt(1 - x^2)/sqrt(2)), x, 7),


# ::Subsection::Closed::
# Problem #30


(x*atan(x)/sqrt(1 - x^2), -asin(x) - sqrt(1 - x^2)*atan(x) + sqrt(2)*atan((sqrt(2)*x)/sqrt(1 - x^2)), x, 5),


# ::Subsection::Closed::
# Problem #31


(atan(x)/(x^2*sqrt(1 + x^2)), -((sqrt(1 + x^2)*atan(x))/x) - atanh(sqrt(1 + x^2)), x, 4),


# ::Subsection::Closed::
# Problem #32


(asin(x)/(x^2*sqrt(1 - x^2)), -((sqrt(1 - x^2)*asin(x))/x) + log(x), x, 2),


# ::Subsection::Closed::
# Problem #33


(x*log(x)/sqrt(x^2 - 1), -sqrt(-1 + x^2) + atan(sqrt(-1 + x^2)) + sqrt(-1 + x^2)*log(x), x, 5),


# ::Subsection::Closed::
# Problem #34


(log(x)/(x^2*sqrt(1 + x^2)), -(sqrt(1 + x^2)/x) + asinh(x) - (sqrt(1 + x^2)*log(x))/x, x, 3),


# ::Subsection::Closed::
# Problem #35


(x*asec(x)/sqrt(x^2 - 1), sqrt(-1 + x^2)*asec(x) - (x*log(x))/sqrt(x^2), x, 2),


# ::Subsection::Closed::
# Problem #36


(x*log(x)/sqrt(1 + x^2), -sqrt(1 + x^2) + atanh(sqrt(1 + x^2)) + sqrt(1 + x^2)*log(x), x, 5),


# ::Subsection::Closed::
# Problem #37


(sin(x)/(1 + sin(x)^2), -(atanh(cos(x)/sqrt(2))/sqrt(2)), x, 2),


# ::Subsection::Closed::
# Problem #38


((1 + x^2)/((1 - x^2)*sqrt(1 + x^4)), (1/sqrt(2))*atanh(sqrt(2)*(x/sqrt(1 + x^4))), x, 2),


# ::Subsection::Closed::
# Problem #39


((1 - x^2)/((1 + x^2)*sqrt(1 + x^4)), atan((sqrt(2)*x)/sqrt(1 + x^4))/sqrt(2), x, 2),


# ::Subsection::Closed::
# Problem #40


(log(sin(x))/(1 + sin(x)), -x - atanh(cos(x)) - (cos(x)*log(sin(x)))/(1 + sin(x)), x, 4),


# ::Subsection::Closed::
# Problem #41


(log(sin(x))*sqrt(1 + sin(x)), (4*cos(x))/sqrt(1 + sin(x)) - (2*cos(x)*log(sin(x)))/sqrt(1 + sin(x)) - 4*atanh(cos(x)/sqrt(1 + sin(x))), x, 6),


# ::Subsection::Closed::
# Problem #42


(sec(x)/sqrt(sec(x)^4 - 1), -(atanh((cos(x)*cot(x)*sqrt(sec(x)^4 - 1))/sqrt(2))/sqrt(2)), x, -5),


# ::Subsection::Closed::
# Problem #43


(tan(x)/sqrt(1 + tan(x)^4), -(atanh((1 - tan(x)^2)/(sqrt(2)*sqrt(1 + tan(x)^4)))/(2*sqrt(2))), x, 4),


# ::Subsection::Closed::
# Problem #44


# {Sin[x]/Sqrt[1 - Sin[x]^6], x, 4, ArcTanh[(Sqrt[3]*Cos[x]*(1 + Sin[x]^2))/(2*Sqrt[1 - Sin[x]^6])]/(2*Sqrt[3]), ArcTanh[(Cos[x]*(6 - 3*Cos[x]^2))/(2*Sqrt[3]*Sqrt[3*Cos[x]^2 - 3*Cos[x]^4 + Cos[x]^6])]/(2*Sqrt[3])}


# ::Subsection::Closed::
# Problem #45


(sqrt(sqrt(sec(x) + 1) - sqrt(sec(x) - 1)), sqrt(2)*(sqrt(-1 + sqrt(2))*atan((sqrt(-2 + 2*sqrt(2))*(-sqrt(2) - sqrt(-1 + sec(x)) + sqrt(1 + sec(x))))/(2*sqrt(-sqrt(-1 + sec(x)) + sqrt(1 + sec(x))))) - sqrt(1 + sqrt(2))*atan((sqrt(2 + 2*sqrt(2))*(-sqrt(2) - sqrt(-1 + sec(x)) + sqrt(1 + sec(x))))/(2*sqrt(-sqrt(-1 + sec(x)) + sqrt(1 + sec(x))))) - sqrt(1 + sqrt(2))*atanh((sqrt(-2 + 2*sqrt(2))*sqrt(-sqrt(-1 + sec(x)) + sqrt(1 + sec(x))))/(sqrt(2) - sqrt(-1 + sec(x)) + sqrt(1 + sec(x)))) + sqrt(-1 + sqrt(2))*atanh((sqrt(2 + 2*sqrt(2))*sqrt(-sqrt(-1 + sec(x)) + sqrt(1 + sec(x))))/(sqrt(2) - sqrt(-1 + sec(x)) + sqrt(1 + sec(x)))))*cot(x)*sqrt(-1 + sec(x))*sqrt(1 + sec(x)), x, -1),


# ::Subsection::Closed::
# Problem #46


(x*log(x^2 + 1)*atan(x)^2, 3*x*atan(x) - (3*atan(x)^2)/2 - (1//2)*x^2*atan(x)^2 - (3//2)*log(1 + x^2) - x*atan(x)*log(1 + x^2) + (1//2)*(1 + x^2)*atan(x)^2*log(1 + x^2) + (1//4)*log(1 + x^2)^2, x, 13),


# ::Subsection::Closed::
# Problem #47


(atan(x*sqrt(1 + x^2)), x*atan(x*sqrt(1 + x^2)) + (1//2)*atan(sqrt(3) - 2*sqrt(1 + x^2)) - (1//2)*atan(sqrt(3) + 2*sqrt(1 + x^2)) - (1//4)*sqrt(3)*log(2 + x^2 - sqrt(3)*sqrt(1 + x^2)) + (1//4)*sqrt(3)*log(2 + x^2 + sqrt(3)*sqrt(1 + x^2)), x, 12),


# ::Subsection::Closed::
# Problem #48


# {ArcTan[Sqrt[x + 1] - Sqrt[x]], x, 6, Sqrt[x]/2 + (1 + x)*ArcTan[Sqrt[1 + x] - Sqrt[x]], Sqrt[x]/2 + (Pi*x)/4 - ArcTan[Sqrt[x]]/2 - (1/2)*x*ArcTan[Sqrt[x]]}


# ::Subsection::Closed::
# Problem #49


(asin(x/sqrt(1 - x^2)), x*asin(x/sqrt(1 - x^2)) + atan(sqrt(1 - 2*x^2)), x, 4),


# ::Subsection::Closed::
# Problem #50


# {ArcTan[x*Sqrt[1 - x^2]], x, 6, x*ArcTan[x*Sqrt[1 - x^2]] - Sqrt[(1/2)*(1 + Sqrt[5])]*ArcTan[Sqrt[(1/2)*(1 + Sqrt[5])]*Sqrt[1 - x^2]] + Sqrt[(1/2)*(-1 + Sqrt[5])]*ArcTanh[Sqrt[(1/2)*(-1 + Sqrt[5])]*Sqrt[1 - x^2]], (-Sqrt[2/(-1 + Sqrt[5])])*ArcTan[Sqrt[2/(-1 + Sqrt[5])]*Sqrt[1 - x^2]] + x*ArcTan[x*Sqrt[1 - x^2]] + Sqrt[2/(1 + Sqrt[5])]*ArcTanh[Sqrt[2/(1 + Sqrt[5])]*Sqrt[1 - x^2]]}
]

hearn = [
# ::Package::

# ::Title::
# Anthony Hearn - Reduce Integration Test Package


# ::Section::Closed::
# Polynomial and rational function examples


(1 + x + x^2, x + x^2//2 + x^3//3, x, 1),
(x^2*(2*x^2 + x)^2, x^5//5 + (2*x^6)/3 + (4*x^7)/7, x, 3),
(x*(x^2 + 2*x + 1), x^2//2 + (2*x^3)/3 + x^4//4, x, 2),
(1/x, log(x), x, 1),
((x + 1)^3/(x - 1)^4, 8/(3*(1 - x)^3) - 6/(1 - x)^2 + 6/(1 - x) + log(1 - x), x, 2),
(1/(x*(x - 1)*(x + 1)^2), -(1/(2*(1 + x))) + (1//4)*log(1 - x) - log(x) + (3//4)*log(1 + x), x, 2),
((a*x + b)/((x - p)*(x - q)), ((b + a*p)*log(p - x))/(p - q) - ((b + a*q)*log(q - x))/(p - q), x, 2),
(1/(a*x^2 + b*x + c), -((2*atanh((b + 2*a*x)/sqrt(b^2 - 4*a*c)))/sqrt(b^2 - 4*a*c)), x, 2),
((a*x + b)/(1 + x^2), b*atan(x) + (1//2)*a*log(1 + x^2), x, 3),
(1/(x^2 - 2*x + 3), -(atan((1 - x)/sqrt(2))/sqrt(2)), x, 2),


# ::Section::Closed::
# Rational function examples from Hardy, Pure Mathematics, p 253 et seq.


(1/((x-1)*(x^2+1))^2, 1/(4*(1 - x)) - 1/(4*(1 + x^2)) + atan(x)/4 - (1//2)*log(1 - x) + (1//4)*log(1 + x^2), x, 6),
(x/((x-a)*(x-b)*(x-c)), (a*log(a - x))/((a - b)*(a - c)) - (b*log(b - x))/((a - b)*(b - c)) + (c*log(c - x))/((a - c)*(b - c)), x, 2),
(x/((x^2+a^2)*(x^2+b^2)), -(log(a^2 + x^2)/(2*(a^2 - b^2))) + log(b^2 + x^2)/(2*(a^2 - b^2)), x, 4),
(x^2/((x^2+a^2)*(x^2+b^2)), (a*atan(x/a))/(a^2 - b^2) - (b*atan(x/b))/(a^2 - b^2), x, 3),
(x/((x-1)*(x^2+1)), atan(x)/2 + (1//2)*log(1 - x) - (1//4)*log(1 + x^2), x, 5),
(x/(1+x^3), -(atan((1 - 2*x)/sqrt(3))/sqrt(3)) - (1//3)*log(1 + x) + (1//6)*log(1 - x + x^2), x, 6),
(x^3/((x-1)^2*(x^3+1)), 1/(2*(1 - x)) + (3//4)*log(1 - x) - (1//12)*log(1 + x) - (1//3)*log(1 - x + x^2), x, 3),
(1/(1+x^4), -(atan(1 - sqrt(2)*x)/(2*sqrt(2))) + atan(1 + sqrt(2)*x)/(2*sqrt(2)) - log(1 - sqrt(2)*x + x^2)/(4*sqrt(2)) + log(1 + sqrt(2)*x + x^2)/(4*sqrt(2)), x, 9),
(x^2/(1+x^4), -(atan(1 - sqrt(2)*x)/(2*sqrt(2))) + atan(1 + sqrt(2)*x)/(2*sqrt(2)) + log(1 - sqrt(2)*x + x^2)/(4*sqrt(2)) - log(1 + sqrt(2)*x + x^2)/(4*sqrt(2)), x, 9),
(1/(1+x^2+x^4), -(atan((1 - 2*x)/sqrt(3))/(2*sqrt(3))) + atan((1 + 2*x)/sqrt(3))/(2*sqrt(3)) - (1//4)*log(1 - x + x^2) + (1//4)*log(1 + x + x^2), x, 9),


# ::Section::Closed::
# Examples involving a+b*x


((a+b*x)^p, (a + b*x)^(1 + p)/(b*(1 + p)), x, 1),
(x*(a+b*x)^p, -((a*(a + b*x)^(1 + p))/(b^2*(1 + p))) + (a + b*x)^(2 + p)/(b^2*(2 + p)), x, 2),
(x^2*(a+b*x)^p, (a^2*(a + b*x)^(1 + p))/(b^3*(1 + p)) - (2*a*(a + b*x)^(2 + p))/(b^3*(2 + p)) + (a + b*x)^(3 + p)/(b^3*(3 + p)), x, 2),
(1/(a+b*x), log(a + b*x)/b, x, 1),
(1/(a+b*x)^2, -(1/(b*(a + b*x))), x, 1),
(x/(a+b*x), x/b - (a*log(a + b*x))/b^2, x, 2),
(x^2/(a+b*x), -((a*x)/b^2) + x^2/(2*b) + (a^2*log(a + b*x))/b^3, x, 2),
(1/(x*(a+b*x)), log(x)/a - log(a + b*x)/a, x, 3),
(1/(x^2*(a+b*x)), -(1/(a*x)) - (b*log(x))/a^2 + (b*log(a + b*x))/a^2, x, 2),
(1/(x*(a+b*x))^2, -(1/(a^2*x)) - b/(a^2*(a + b*x)) - (2*b*log(x))/a^3 + (2*b*log(a + b*x))/a^3, x, 2),
(1/(c^2+x^2), atan(x/c)/c, x, 1),
(1/(c^2-x^2), atanh(x/c)/c, x, 1),


# ::Section::Closed::
# More complicated rational function examples


# Mostly examples contributed by David M. Dahm, who also developed the code to integrate them.

(1/(2*x^3-1), -(atan((1 + 2*2^(1//3)*x)/sqrt(3))/(2^(1//3)*sqrt(3))) + log(1 - 2^(1//3)*x)/(3*2^(1//3)) - log(1 + 2^(1//3)*x + 2^(2//3)*x^2)/(6*2^(1//3)), x, 6),
(1/(x^3-2), -(atan((1 + 2^(2//3)*x)/sqrt(3))/(2^(2//3)*sqrt(3))) + log(2^(1//3) - x)/(3*2^(2//3)) - log(2^(2//3) + 2^(1//3)*x + x^2)/(6*2^(2//3)), x, 6),
(1/(a*x^3-b), -(atan((b^(1//3) + 2*a^(1//3)*x)/(sqrt(3)*b^(1//3)))/(sqrt(3)*a^(1//3)*b^(2//3))) + log(b^(1//3) - a^(1//3)*x)/(3*a^(1//3)*b^(2//3)) - log(b^(2//3) + a^(1//3)*b^(1//3)*x + a^(2//3)*x^2)/(6*a^(1//3)*b^(2//3)), x, 6),
(1/(x^4-2), -(atan(x/2^(1//4))/(2*2^(3//4))) - atanh(x/2^(1//4))/(2*2^(3//4)), x, 3),
(1/(5*x^4-1), -(atan(5^(1//4)*x)/(2*5^(1//4))) - atanh(5^(1//4)*x)/(2*5^(1//4)), x, 3),
# {1/(3*x^4+7), x, 9, If[$VersionNumber<9, -(ArcTan[1 - (3/7)^(1/4)*Sqrt[2]*x]/(2*Sqrt[2]*3^(1/4)*7^(3/4))) + ArcTan[1 + (3/7)^(1/4)*Sqrt[2]*x]/(2*Sqrt[2]*3^(1/4)*7^(3/4)) - Log[Sqrt[21] - Sqrt[2]*3^(3/4)*7^(1/4)*x + 3*x^2]/(4*Sqrt[2]*3^(1/4)*7^(3/4)) + Log[Sqrt[21] + Sqrt[2]*3^(3/4)*7^(1/4)*x + 3*x^2]/(4*Sqrt[2]*3^(1/4)*7^(3/4)), -(ArcTan[1 - (3/7)^(1/4)*Sqrt[2]*x]/(2*Sqrt[2]*3^(1/4)*7^(3/4))) + ArcTan[1 + (3/7)^(1/4)*Sqrt[2]*x]/(2*Sqrt[2]*3^(1/4)*7^(3/4)) - Log[Sqrt[21] - Sqrt[2]*3^(3/4)*7^(1/4)*x + 3*x^2]/(4*Sqrt[2]*3^(1/4)*7^(3/4)) + Log[Sqrt[21] + Sqrt[2]*3^(3/4)*7^(1/4)*x + 3*x^2]/(4*Sqrt[2]*3^(1/4)*7^(3/4))]}
(1/(x^4+3*x^2-1), (-sqrt(2/(13*(3 + sqrt(13)))))*atan(sqrt(2/(3 + sqrt(13)))*x) - sqrt((1//26)*(3 + sqrt(13)))*atanh(sqrt(2/(-3 + sqrt(13)))*x), x, 3),
(1/(x^4-3*x^2-1), (-sqrt((1//26)*(3 + sqrt(13))))*atan(sqrt(2/(-3 + sqrt(13)))*x) - sqrt(2/(13*(3 + sqrt(13))))*atanh(sqrt(2/(3 + sqrt(13)))*x), x, 3),
(1/(x^4-3*x^2+1), (-sqrt(2/(5*(3 + sqrt(5)))))*atanh(sqrt(2/(3 + sqrt(5)))*x) + sqrt((1//10)*(3 + sqrt(5)))*atanh(sqrt((1//2)*(3 + sqrt(5)))*x), x, 3),
(1/(x^4-4*x^2+1), atanh(x/sqrt(2 - sqrt(3)))/(2*sqrt(3*(2 - sqrt(3)))) - atanh(x/sqrt(2 + sqrt(3)))/(2*sqrt(3*(2 + sqrt(3)))), x, 3),
(1/(x^4+4*x^2+1), atan(x/sqrt(2 - sqrt(3)))/(2*sqrt(3*(2 - sqrt(3)))) - atan(x/sqrt(2 + sqrt(3)))/(2*sqrt(3*(2 + sqrt(3)))), x, 3),
(1/(x^4+x^2+2), (-(1//2))*sqrt((1//14)*(-1 + 2*sqrt(2)))*atan((sqrt(-1 + 2*sqrt(2)) - 2*x)/sqrt(1 + 2*sqrt(2))) + (1//2)*sqrt((1//14)*(-1 + 2*sqrt(2)))*atan((sqrt(-1 + 2*sqrt(2)) + 2*x)/sqrt(1 + 2*sqrt(2))) - log(sqrt(2) - sqrt(-1 + 2*sqrt(2))*x + x^2)/(4*sqrt(2*(-1 + 2*sqrt(2)))) + log(sqrt(2) + sqrt(-1 + 2*sqrt(2))*x + x^2)/(4*sqrt(2*(-1 + 2*sqrt(2)))), x, 9),
(1/(x^4-x^2+2), (-(1//2))*sqrt((1//14)*(1 + 2*sqrt(2)))*atan((sqrt(1 + 2*sqrt(2)) - 2*x)/sqrt(-1 + 2*sqrt(2))) + (1//2)*sqrt((1//14)*(1 + 2*sqrt(2)))*atan((sqrt(1 + 2*sqrt(2)) + 2*x)/sqrt(-1 + 2*sqrt(2))) - log(sqrt(2) - sqrt(1 + 2*sqrt(2))*x + x^2)/(4*sqrt(2*(1 + 2*sqrt(2)))) + log(sqrt(2) + sqrt(1 + 2*sqrt(2))*x + x^2)/(4*sqrt(2*(1 + 2*sqrt(2)))), x, 9),
(1/(x^6-1), atan((1 - 2*x)/sqrt(3))/(2*sqrt(3)) - atan((1 + 2*x)/sqrt(3))/(2*sqrt(3)) - atanh(x)/3 + (1//12)*log(1 - x + x^2) - (1//12)*log(1 + x + x^2), x, 10),
(1/(x^6-2), atan(1/sqrt(3) - (2^(5//6)*x)/sqrt(3))/(2*2^(5//6)*sqrt(3)) - atan(1/sqrt(3) + (2^(5//6)*x)/sqrt(3))/(2*2^(5//6)*sqrt(3)) - atanh(x/2^(1//6))/(3*2^(5//6)) + log(2^(1//3) - 2^(1//6)*x + x^2)/(12*2^(5//6)) - log(2^(1//3) + 2^(1//6)*x + x^2)/(12*2^(5//6)), x, 10),
(1/(x^6+2), atan(x/2^(1//6))/(3*2^(5//6)) - atan(sqrt(3) - 2^(5//6)*x)/(6*2^(5//6)) + atan(sqrt(3) + 2^(5//6)*x)/(6*2^(5//6)) - log(2^(1//3) - 2^(1//6)*sqrt(3)*x + x^2)/(4*2^(5//6)*sqrt(3)) + log(2^(1//3) + 2^(1//6)*sqrt(3)*x + x^2)/(4*2^(5//6)*sqrt(3)), x, 10),
(1/(x^8+1), -(atan((sqrt(2 - sqrt(2)) - 2*x)/sqrt(2 + sqrt(2)))/(4*sqrt(2*(2 - sqrt(2))))) - atan((sqrt(2 + sqrt(2)) - 2*x)/sqrt(2 - sqrt(2)))/(4*sqrt(2*(2 + sqrt(2)))) + atan((sqrt(2 - sqrt(2)) + 2*x)/sqrt(2 + sqrt(2)))/(4*sqrt(2*(2 - sqrt(2)))) + atan((sqrt(2 + sqrt(2)) + 2*x)/sqrt(2 - sqrt(2)))/(4*sqrt(2*(2 + sqrt(2)))) - (1//16)*sqrt(2 - sqrt(2))*log(1 - sqrt(2 - sqrt(2))*x + x^2) + (1//16)*sqrt(2 - sqrt(2))*log(1 + sqrt(2 - sqrt(2))*x + x^2) - (1//16)*sqrt(2 + sqrt(2))*log(1 - sqrt(2 + sqrt(2))*x + x^2) + (1//16)*sqrt(2 + sqrt(2))*log(1 + sqrt(2 + sqrt(2))*x + x^2), x, 19),
(1/(x^8-1), -(atan(x)/4) + atan(1 - sqrt(2)*x)/(4*sqrt(2)) - atan(1 + sqrt(2)*x)/(4*sqrt(2)) - atanh(x)/4 + log(1 - sqrt(2)*x + x^2)/(8*sqrt(2)) - log(1 + sqrt(2)*x + x^2)/(8*sqrt(2)), x, 13),
(1/(x^8-x^4+1), -(atan((sqrt(2 - sqrt(3)) - 2*x)/sqrt(2 + sqrt(3)))/(2*sqrt(6))) - atan((sqrt(2 + sqrt(3)) - 2*x)/sqrt(2 - sqrt(3)))/(2*sqrt(6)) + atan((sqrt(2 - sqrt(3)) + 2*x)/sqrt(2 + sqrt(3)))/(2*sqrt(6)) + atan((sqrt(2 + sqrt(3)) + 2*x)/sqrt(2 - sqrt(3)))/(2*sqrt(6)) - log(1 - sqrt(2 - sqrt(3))*x + x^2)/(4*sqrt(6)) + log(1 + sqrt(2 - sqrt(3))*x + x^2)/(4*sqrt(6)) - log(1 - sqrt(2 + sqrt(3))*x + x^2)/(4*sqrt(6)) + log(1 + sqrt(2 + sqrt(3))*x + x^2)/(4*sqrt(6)), x, 19),
(x^7/(x^12+1), -(atan((1 - 2*x^4)/sqrt(3))/(4*sqrt(3))) - (1//12)*log(1 + x^4) + (1//24)*log(1 - x^4 + x^8), x, 7),


# ::Section::Closed::
# Examples involving logarithms


(log(x), -x + x*log(x), x, 1),
(x*log(x), -(x^2//4) + (1//2)*x^2*log(x), x, 1),
(x^2*log(x), -(x^3//9) + (1//3)*x^3*log(x), x, 1),
(x^p*log(x), -(x^(1 + p)/(1 + p)^2) + (x^(1 + p)*log(x))/(1 + p), x, 1),
((log(x))^2, 2*x - 2*x*log(x) + x*log(x)^2, x, 2),
(x^9*log(x)^11, -((6237*x^10)/156250000) + (6237*x^10*log(x))/15625000 - (6237*x^10*log(x)^2)/3125000 + (2079*x^10*log(x)^3)/312500 - (2079*x^10*log(x)^4)/125000 + (2079*x^10*log(x)^5)/62500 - (693*x^10*log(x)^6)/12500 + (99*x^10*log(x)^7)/1250 - (99*x^10*log(x)^8)/1000 + (11//100)*x^10*log(x)^9 - (11//100)*x^10*log(x)^10 + (1//10)*x^10*log(x)^11, x, 11),
(log(x)^2/x, log(x)^3//3, x, 2),
(1/log(x), Expinti(log(x)), x, 1),
(1/log(x+1), Expinti(log(1 + x)), x, 2),
(1/(x*log(x)), log(log(x)), x, 2),
(1/(x*log(x))^2, -Expinti(-log(x)) - 1/(x*log(x)), x, 3),
((log(x))^p/x, log(x)^(1 + p)/(1 + p), x, 2),
(log(x)*(a*x+b), (-b)*x - (a*x^2)/4 + b*x*log(x) + (1//2)*a*x^2*log(x), x, 2),
((a*x+b)^2*log(x), (-b^2)*x - (1//2)*a*b*x^2 - (a^2*x^3)/9 - (b^3*log(x))/(3*a) + ((b + a*x)^3*log(x))/(3*a), x, 4),
(log(x)/(a*x+b)^2, (x*log(x))/(b*(b + a*x)) - log(b + a*x)/(a*b), x, 2),
(x*log(a*x+b), (b*x)/(2*a) - x^2//4 - (b^2*log(b + a*x))/(2*a^2) + (1//2)*x^2*log(b + a*x), x, 3),
(x^2*log(a*x+b), -((b^2*x)/(3*a^2)) + (b*x^2)/(6*a) - x^3//9 + (b^3*log(b + a*x))/(3*a^3) + (1//3)*x^3*log(b + a*x), x, 3),
(log(x^2+a^2), -2*x + 2*a*atan(x/a) + x*log(a^2 + x^2), x, 3),
(x*log(x^2+a^2), -(x^2//2) + (1//2)*(a^2 + x^2)*log(a^2 + x^2), x, 3),
(x^2*log(x^2+a^2), (2*a^2*x)/3 - (2*x^3)/9 - (2//3)*a^3*atan(x/a) + (1//3)*x^3*log(a^2 + x^2), x, 4),
(x^4*log(x^2+a^2), -((2*a^4*x)/5) + (2*a^2*x^3)/15 - (2*x^5)/25 + (2//5)*a^5*atan(x/a) + (1//5)*x^5*log(a^2 + x^2), x, 4),
(log(x^2-a^2), -2*x + 2*a*atanh(x/a) + x*log(-a^2 + x^2), x, 3),
(log(log(log(log(x)))), CannotIntegrate(log(log(log(log(x)))), x), x, 0),


# ::Section::Closed::
# Examples involving circular functions


(sin(x), -cos(x), x, 1),
(cos(x), sin(x), x, 1),
(tan(x), -log(cos(x)), x, 1),
(1/tan(x), log(sin(x)), x, 1),
(1/(1+tan(x))^2, (1//2)*log(cos(x) + sin(x)) - 1/(2*(1 + tan(x))), x, 2),
(1/cos(x), atanh(sin(x)), x, 1),
(1/sin(x), -atanh(cos(x)), x, 1),
(sin(x)^2, x/2 - (1//2)*cos(x)*sin(x), x, 2),
(x^3*sin(x^2), (-(1//2))*x^2*cos(x^2) + sin(x^2)/2, x, 3),
(sin(x)^3, -cos(x) + cos(x)^3//3, x, 2),
(sin(x)^p, (cos(x)*hypergeometric2f1(1//2, (1 + p)/2, (3 + p)/2, sin(x)^2)*sin(x)^(1 + p))/((1 + p)*sqrt(cos(x)^2)), x, 1),
((sin(x)^2+1)^2*cos(x), sin(x) + (2*sin(x)^3)/3 + sin(x)^5//5, x, 3),
(cos(x)^2, x/2 + (1//2)*cos(x)*sin(x), x, 2),
(cos(x)^3, sin(x) - sin(x)^3//3, x, 2),
(1/cos(x)^2, tan(x), x, 2),
(sin(x)*sin(2*x), sin(x)/2 - (1//6)*sin(3*x), x, 1),
(x*sin(x), (-x)*cos(x) + sin(x), x, 2),
(x^2*sin(x), 2*cos(x) - x^2*cos(x) + 2*x*sin(x), x, 3),
(x*sin(x)^2, x^2//4 - (1//2)*x*cos(x)*sin(x) + sin(x)^2//4, x, 2),
(x^2*sin(x)^2, -(x/4) + x^3//6 + (1//4)*cos(x)*sin(x) - (1//2)*x^2*cos(x)*sin(x) + (1//2)*x*sin(x)^2, x, 4),
(x*sin(x)^3, (-(2//3))*x*cos(x) + (2*sin(x))/3 - (1//3)*x*cos(x)*sin(x)^2 + sin(x)^3//9, x, 3),
(x*cos(x), cos(x) + x*sin(x), x, 2),
(x^2*cos(x), 2*x*cos(x) - 2*sin(x) + x^2*sin(x), x, 3),
(x*cos(x)^2, x^2//4 + cos(x)^2//4 + (1//2)*x*cos(x)*sin(x), x, 2),
(x^2*cos(x)^2, -(x/4) + x^3//6 + (1//2)*x*cos(x)^2 - (1//4)*cos(x)*sin(x) + (1//2)*x^2*cos(x)*sin(x), x, 4),
(x*cos(x)^3, (2*cos(x))/3 + cos(x)^3//9 + (2//3)*x*sin(x) + (1//3)*x*cos(x)^2*sin(x), x, 3),
(sin(x)/x, Sinint(x), x, 1),
(cos(x)/x, Cosint(x), x, 1),
(sin(x)/x^2, Cosint(x) - sin(x)/x, x, 2),
(sin(x)^2/x, (-(1//2))*Cosint(2*x) + log(x)/2, x, 3),
(tan(x)^3, log(cos(x)) + tan(x)^2//2, x, 2),


(sin(a+b*x), -(cos(a + b*x)/b), x, 1),
(cos(a+b*x), sin(a + b*x)/b, x, 1),
(tan(a+b*x), -(log(cos(a + b*x))/b), x, 1),
(1/tan(a+b*x), log(sin(a + b*x))/b, x, 1),
(1/sin(a+b*x), -(atanh(cos(a + b*x))/b), x, 1),
(1/cos(a+b*x), atanh(sin(a + b*x))/b, x, 1),
(sin(a+b*x)^2, x/2 - (cos(a + b*x)*sin(a + b*x))/(2*b), x, 2),
(sin(a+b*x)^3, -(cos(a + b*x)/b) + cos(a + b*x)^3/(3*b), x, 2),
(cos(a+b*x)^2, x/2 + (cos(a + b*x)*sin(a + b*x))/(2*b), x, 2),
(cos(a+b*x)^3, sin(a + b*x)/b - sin(a + b*x)^3/(3*b), x, 2),
(1/cos(a+b*x)^2, tan(a + b*x)/b, x, 2),


(1/(1+cos(x)), sin(x)/(1 + cos(x)), x, 1),
(1/(1-cos(x)), -(sin(x)/(1 - cos(x))), x, 1),
(1/(1+sin(x)), -(cos(x)/(1 + sin(x))), x, 1),
(1/(1-sin(x)), cos(x)/(1 - sin(x)), x, 1),
(1/(a+b*sin(x)), (2*atan((b + a*tan(x/2))/sqrt(a^2 - b^2)))/sqrt(a^2 - b^2), x, 3),
(1/(a+b*sin(x)+cos(x)), -((2*atanh((b - (1 - a)*tan(x/2))/sqrt(1 - a^2 + b^2)))/sqrt(1 - a^2 + b^2)), x, 3),
(x^2*sin(a+b*x)^2, -(x/(4*b^2)) + x^3//6 + (cos(a + b*x)*sin(a + b*x))/(4*b^3) - (x^2*cos(a + b*x)*sin(a + b*x))/(2*b) + (x*sin(a + b*x)^2)/(2*b^2), x, 4),
(cos(x)*cos(2*x), sin(x)/2 + (1//6)*sin(3*x), x, 1),
(x^2*cos(a+b*x)^2, -(x/(4*b^2)) + x^3//6 + (x*cos(a + b*x)^2)/(2*b^2) - (cos(a + b*x)*sin(a + b*x))/(4*b^3) + (x^2*cos(a + b*x)*sin(a + b*x))/(2*b), x, 4),
(1/tan(x)^3, (-(1//2))*cot(x)^2 - log(sin(x)), x, 2),
(x^3*tan(x)^4, -(x^2//2) + (4*I*x^3)/3 + x^4//4 - 4*x^2*log(1 + ℯ^(2*I*x)) + log(cos(x)) + 4*I*x*PolyLog_reli(2, -ℯ^(2*I*x)) - 2*PolyLog_reli(3, -ℯ^(2*I*x)) + x*tan(x) - x^3*tan(x) - (1//2)*x^2*tan(x)^2 + (1//3)*x^3*tan(x)^3, x, 17),
(x^3*tan(x)^6, (19*x^2)/20 - (23*I*x^3)/15 - x^4//4 + (23//5)*x^2*log(1 + ℯ^(2*I*x)) - 2*log(cos(x)) - (23//5)*I*x*PolyLog_reli(2, -ℯ^(2*I*x)) + (23//10)*PolyLog_reli(3, -ℯ^(2*I*x)) - (19//10)*x*tan(x) + x^3*tan(x) - tan(x)^2//20 + (4//5)*x^2*tan(x)^2 + (1//10)*x*tan(x)^3 - (1//3)*x^3*tan(x)^3 - (3//20)*x^2*tan(x)^4 + (1//5)*x^3*tan(x)^5, x, 34),
(x*tan(x)^2, -(x^2//2) + log(cos(x)) + x*tan(x), x, 3),
(sin(2*x)*cos(3*x), cos(x)/2 - (1//10)*cos(5*x), x, 1),
(sin(x)^2*cos(x)^2, x/8 + (1//8)*cos(x)*sin(x) - (1//4)*cos(x)^3*sin(x), x, 3),
(1/(sin(x)^2*cos(x)^2), -cot(x) + tan(x), x, 3),


(d^x*sin(x), -((d^x*cos(x))/(1 + log(d)^2)) + (d^x*log(d)*sin(x))/(1 + log(d)^2), x, 1),
(d^x*cos(x), (d^x*cos(x)*log(d))/(1 + log(d)^2) + (d^x*sin(x))/(1 + log(d)^2), x, 1),
(x*d^x*sin(x), (2*d^x*cos(x)*log(d))/(1 + log(d)^2)^2 - (d^x*x*cos(x))/(1 + log(d)^2) + (d^x*sin(x))/(1 + log(d)^2)^2 - (d^x*log(d)^2*sin(x))/(1 + log(d)^2)^2 + (d^x*x*log(d)*sin(x))/(1 + log(d)^2), x, 4),
(x*d^x*cos(x), (d^x*cos(x))/(1 + log(d)^2)^2 - (d^x*cos(x)*log(d)^2)/(1 + log(d)^2)^2 + (d^x*x*cos(x)*log(d))/(1 + log(d)^2) - (2*d^x*log(d)*sin(x))/(1 + log(d)^2)^2 + (d^x*x*sin(x))/(1 + log(d)^2), x, 4),
(x^2*d^x*sin(x), (2*d^x*cos(x))/(1 + log(d)^2)^3 - (6*d^x*cos(x)*log(d)^2)/(1 + log(d)^2)^3 + (4*d^x*x*cos(x)*log(d))/(1 + log(d)^2)^2 - (d^x*x^2*cos(x))/(1 + log(d)^2) - (6*d^x*log(d)*sin(x))/(1 + log(d)^2)^3 + (2*d^x*log(d)^3*sin(x))/(1 + log(d)^2)^3 + (2*d^x*x*sin(x))/(1 + log(d)^2)^2 - (2*d^x*x*log(d)^2*sin(x))/(1 + log(d)^2)^2 + (d^x*x^2*log(d)*sin(x))/(1 + log(d)^2), x, 11),
(x^2*d^x*cos(x), -((6*d^x*cos(x)*log(d))/(1 + log(d)^2)^3) + (2*d^x*cos(x)*log(d)^3)/(1 + log(d)^2)^3 + (2*d^x*x*cos(x))/(1 + log(d)^2)^2 - (2*d^x*x*cos(x)*log(d)^2)/(1 + log(d)^2)^2 + (d^x*x^2*cos(x)*log(d))/(1 + log(d)^2) - (2*d^x*sin(x))/(1 + log(d)^2)^3 + (6*d^x*log(d)^2*sin(x))/(1 + log(d)^2)^3 - (4*d^x*x*log(d)*sin(x))/(1 + log(d)^2)^2 + (d^x*x^2*sin(x))/(1 + log(d)^2), x, 11),
(x^3*d^x*sin(x), -((24*d^x*cos(x)*log(d))/(1 + log(d)^2)^4) + (24*d^x*cos(x)*log(d)^3)/(1 + log(d)^2)^4 + (6*d^x*x*cos(x))/(1 + log(d)^2)^3 - (18*d^x*x*cos(x)*log(d)^2)/(1 + log(d)^2)^3 + (6*d^x*x^2*cos(x)*log(d))/(1 + log(d)^2)^2 - (d^x*x^3*cos(x))/(1 + log(d)^2) - (6*d^x*sin(x))/(1 + log(d)^2)^4 + (36*d^x*log(d)^2*sin(x))/(1 + log(d)^2)^4 - (6*d^x*log(d)^4*sin(x))/(1 + log(d)^2)^4 - (18*d^x*x*log(d)*sin(x))/(1 + log(d)^2)^3 + (6*d^x*x*log(d)^3*sin(x))/(1 + log(d)^2)^3 + (3*d^x*x^2*sin(x))/(1 + log(d)^2)^2 - (3*d^x*x^2*log(d)^2*sin(x))/(1 + log(d)^2)^2 + (d^x*x^3*log(d)*sin(x))/(1 + log(d)^2), x, 25),
(x^3*d^x*cos(x), -((6*d^x*cos(x))/(1 + log(d)^2)^4) + (36*d^x*cos(x)*log(d)^2)/(1 + log(d)^2)^4 - (6*d^x*cos(x)*log(d)^4)/(1 + log(d)^2)^4 - (18*d^x*x*cos(x)*log(d))/(1 + log(d)^2)^3 + (6*d^x*x*cos(x)*log(d)^3)/(1 + log(d)^2)^3 + (3*d^x*x^2*cos(x))/(1 + log(d)^2)^2 - (3*d^x*x^2*cos(x)*log(d)^2)/(1 + log(d)^2)^2 + (d^x*x^3*cos(x)*log(d))/(1 + log(d)^2) + (24*d^x*log(d)*sin(x))/(1 + log(d)^2)^4 - (24*d^x*log(d)^3*sin(x))/(1 + log(d)^2)^4 - (6*d^x*x*sin(x))/(1 + log(d)^2)^3 + (18*d^x*x*log(d)^2*sin(x))/(1 + log(d)^2)^3 - (6*d^x*x^2*log(d)*sin(x))/(1 + log(d)^2)^2 + (d^x*x^3*sin(x))/(1 + log(d)^2), x, 25),


(sin(x)*sin(2*x)*sin(3*x), (-(1//8))*cos(2*x) - (1//16)*cos(4*x) + (1//24)*cos(6*x), x, 5),
(cos(x)*cos(2*x)*cos(3*x), x/4 + (1//8)*sin(2*x) + (1//16)*sin(4*x) + (1//24)*sin(6*x), x, 5),
(sin(k*x)^3*x^2, (14*cos(k*x))/(9*k^3) - (2*x^2*cos(k*x))/(3*k) - (2*cos(k*x)^3)/(27*k^3) + (4*x*sin(k*x))/(3*k^2) - (x^2*cos(k*x)*sin(k*x)^2)/(3*k) + (2*x*sin(k*x)^3)/(9*k^2), x, 6),
(x*cos(k/sin(x))*cos(x)/sin(x)^2, CannotIntegrate(x*cos(k*csc(x))*cot(x)*csc(x), x), x, 0),


# Mixed angles and half angles.
(cos(x)/(sin(x)*tan(x/2)), -x - cot(x/2), x, 4),
(sin(a*x)/(b+c*sin(a*x))^2, -((2*c*atan((c + b*tan((a*x)/2))/sqrt(b^2 - c^2)))/(a*(b^2 - c^2)^(3//2))) - (b*cos(a*x))/(a*(b^2 - c^2)*(b + c*sin(a*x))), x, 5),


# ::Section::Closed::
# Examples involving trig functions of logarithms


(sin(log(x)), (-(1//2))*x*cos(log(x)) + (1//2)*x*sin(log(x)), x, 1),
(cos(log(x)), (1//2)*x*cos(log(x)) + (1//2)*x*sin(log(x)), x, 1),


# ::Section::Closed::
# Examples involving exponentials


(ℯ^x, ℯ^x, x, 1),
(a^x, a^x/log(a), x, 1),
(ℯ^(a*x), ℯ^(a*x)/a, x, 1),
(ℯ^(a*x)/x, Expinti(a*x), x, 1),
(1/(a+b*ℯ^(m*x)), x/a - log(a + b*ℯ^(m*x))/(a*m), x, 4),
(ℯ^(2*x)/(1+ℯ^x), ℯ^x - log(1 + ℯ^x), x, 3),
(ℯ^(2*x)*ℯ^(a*x), ℯ^((2 + a)*x)/(2 + a), x, 2),
(1/(a*ℯ^(m*x)+b*ℯ^(-m*x)), atan((sqrt(a)*ℯ^(m*x))/sqrt(b))/(sqrt(a)*sqrt(b)*m), x, 2),
(x*ℯ^(a*x), -(ℯ^(a*x)/a^2) + (ℯ^(a*x)*x)/a, x, 2),
(x^20*ℯ^x, 2432902008176640000*ℯ^x - 2432902008176640000*ℯ^x*x + 1216451004088320000*ℯ^x*x^2 - 405483668029440000*ℯ^x*x^3 + 101370917007360000*ℯ^x*x^4 - 20274183401472000*ℯ^x*x^5 + 3379030566912000*ℯ^x*x^6 - 482718652416000*ℯ^x*x^7 + 60339831552000*ℯ^x*x^8 - 6704425728000*ℯ^x*x^9 + 670442572800*ℯ^x*x^10 - 60949324800*ℯ^x*x^11 + 5079110400*ℯ^x*x^12 - 390700800*ℯ^x*x^13 + 27907200*ℯ^x*x^14 - 1860480*ℯ^x*x^15 + 116280*ℯ^x*x^16 - 6840*ℯ^x*x^17 + 380*ℯ^x*x^18 - 20*ℯ^x*x^19 + ℯ^x*x^20, x, 21),
(a^x/b^x, a^x/(b^x*(log(a) - log(b))), x, 2),
(a^x*b^x, (a^x*b^x)/(log(a) + log(b)), x, 2),
(a^x/x^2, -(a^x/x) + Expinti(x*log(a))*log(a), x, 2),
(x*a^x/(1+b*x)^2, a^x/(b^2*(1 + b*x)) + Expinti(((1 + b*x)*log(a))/b)/(a^b^(-1)*b^2) - (Expinti(((1 + b*x)*log(a))/b)*log(a))/(a^b^(-1)*b^3), x, 5),
(x*ℯ^(a*x)/(1+a*x)^2, ℯ^(a*x)/(a^2*(1 + a*x)), x, 1),
(x*k^(x^2), k^x^2/(2*log(k)), x, 1),
(ℯ^(x^2), (1//2)*sqrt(π)*Erfi(x), x, 1),
(x*ℯ^(x^2), ℯ^x^2//2, x, 1),
((x+1)*ℯ^(1/x)/x^4, -ℯ^(1/x) - ℯ^(1/x)/x^2 + ℯ^(1/x)/x, x, 7),
((2*x^3+x)*(ℯ^(x^2))^2*ℯ^(1-x*ℯ^(x^2))/(1-x*ℯ^(x^2))^2, -(ℯ^(1 - ℯ^x^2*x)/(-1 + ℯ^x^2*x)), x, -3),
(ℯ^(ℯ^(ℯ^(ℯ^x))), CannotIntegrate(ℯ^ℯ^ℯ^ℯ^x, x), x, 1),


# Examples involving exponentials and logarithms.
(ℯ^x*log(x), -Expinti(x) + ℯ^x*log(x), x, 2),
(x*ℯ^x*log(x), -ℯ^x + Expinti(x) - ℯ^x*log(x) + ℯ^x*x*log(x), x, 5),
(ℯ^(2*x)*log(ℯ^x), -(ℯ^(2*x)/4) + (1//2)*ℯ^(2*x)*log(ℯ^x), x, 3),


# ::Section::Closed::
# Examples involving square roots


(sqrt(2)*x^2 + 2*x, x^2 + (sqrt(2)*x^3)/3, x, 1),
(log(x)/sqrt(a*x+b), -((4*sqrt(b + a*x))/a) + (4*sqrt(b)*atanh(sqrt(b + a*x)/sqrt(b)))/a + (2*sqrt(b + a*x)*log(x))/a, x, 4),
(sqrt(a+b*x)*sqrt(c+d*x), ((b*c - a*d)*sqrt(a + b*x)*sqrt(c + d*x))/(4*b*d) + ((a + b*x)^(3//2)*sqrt(c + d*x))/(2*b) - ((b*c - a*d)^2*atanh((sqrt(d)*sqrt(a + b*x))/(sqrt(b)*sqrt(c + d*x))))/(4*b^(3//2)*d^(3//2)), x, 5),
(sqrt(a+b*x), (2*(a + b*x)^(3//2))/(3*b), x, 1),
(x*sqrt(a+b*x), -((2*a*(a + b*x)^(3//2))/(3*b^2)) + (2*(a + b*x)^(5//2))/(5*b^2), x, 2),
(x^2*sqrt(a+b*x), (2*a^2*(a + b*x)^(3//2))/(3*b^3) - (4*a*(a + b*x)^(5//2))/(5*b^3) + (2*(a + b*x)^(7//2))/(7*b^3), x, 2),
(sqrt(a+b*x)/x, 2*sqrt(a + b*x) - 2*sqrt(a)*atanh(sqrt(a + b*x)/sqrt(a)), x, 3),
(sqrt(a+b*x)/x^2, -(sqrt(a + b*x)/x) - (b*atanh(sqrt(a + b*x)/sqrt(a)))/sqrt(a), x, 3),
(1/sqrt(a+b*x), (2*sqrt(a + b*x))/b, x, 1),
(x/sqrt(a+b*x), -((2*a*sqrt(a + b*x))/b^2) + (2*(a + b*x)^(3//2))/(3*b^2), x, 2),
(x^2/sqrt(a+b*x), (2*a^2*sqrt(a + b*x))/b^3 - (4*a*(a + b*x)^(3//2))/(3*b^3) + (2*(a + b*x)^(5//2))/(5*b^3), x, 2),
(1/(x*sqrt(a+b*x)), -((2*atanh(sqrt(a + b*x)/sqrt(a)))/sqrt(a)), x, 2),
(1/(x^2*sqrt(a+b*x)), -(sqrt(a + b*x)/(a*x)) + (b*atanh(sqrt(a + b*x)/sqrt(a)))/a^(3//2), x, 3),
(sqrt(a+b*x)^p, (2*(a + b*x)^((2 + p)/2))/(b*(2 + p)), x, 1),
(x*sqrt(a+b*x)^p, -((2*a*(a + b*x)^((2 + p)/2))/(b^2*(2 + p))) + (2*(a + b*x)^((4 + p)/2))/(b^2*(4 + p)), x, 2),
(atan((-sqrt(2)+2*x)/sqrt(2)), atan(1 - sqrt(2)*x)/sqrt(2) - x*atan(1 - sqrt(2)*x) - log(1 - sqrt(2)*x + x^2)/(2*sqrt(2)), x, 6),
(1/sqrt(x^2-1), atanh(x/sqrt(-1 + x^2)), x, 2),
(sqrt(x+1)*sqrt(x), (1//4)*sqrt(x)*sqrt(1 + x) + (1//2)*x^(3//2)*sqrt(1 + x) - asinh(sqrt(x))/4, x, 4),


(sin(sqrt(x)), -2*sqrt(x)*cos(sqrt(x)) + 2*sin(sqrt(x)), x, 3),
(x*sqrt(1 - x^2)^(-9//4), 4/(1 - x^2)^(1//8), x, 1),
(x/sqrt(1 - x^4), asin(x^2)/2, x, 2),
(1/(x*sqrt(1 + x^4)), (-(1//2))*atanh(sqrt(1 + x^4)), x, 3),
(x/sqrt(1 + x^2 + x^4), (1//2)*asinh((1 + 2*x^2)/sqrt(3)), x, 3),
(1/(x*sqrt(x^2 - 1 - x^4)), (-(1//2))*atan((2 - x^2)/(2*sqrt(-1 + x^2 - x^4))), x, 3),


# Examples generated by differentiating various functions.
((1 + x)/((1 - x)^2*sqrt(1 + x^2)), sqrt(1 + x^2)/(1 - x), x, 1),
(1/sqrt(1 + x^2), asinh(x), x, 1),
((sqrt(x)*sqrt(1 + x) + sqrt(x)*sqrt(2 + x) + sqrt(1 + x)*sqrt(2 + x))/(2*sqrt(x)*sqrt(1 + x)*sqrt(2 + x)), sqrt(x) + sqrt(1 + x) + sqrt(2 + x), x, 3),
((-2*sqrt(1 + x^3) + 5*x^4*sqrt(1 + x^3) - 3*x^2*sqrt(1 - 2*x + x^5))/(2*sqrt(1 + x^3)*sqrt(1 - 2*x + x^5)), -sqrt(1 + x^3) + sqrt(1 - 2*x + x^5), x, 5),


# ::Section::Closed::
# Examples from James Davenport's thesis


(1/sqrt(x^2-1)+10/sqrt(x^2-4), 10*atanh(x/sqrt(-4 + x^2)) + atanh(x/sqrt(-1 + x^2)), x, 5),
(sqrt(x+sqrt(x^2+a^2))/x, 2*sqrt(x + sqrt(a^2 + x^2)) - 2*sqrt(a)*atan(sqrt(x + sqrt(a^2 + x^2))/sqrt(a)) - 2*sqrt(a)*atanh(sqrt(x + sqrt(a^2 + x^2))/sqrt(a)), x, 6),


# Another such example from James Davenport's thesis (p. 146).
# It contains a point of order 3, which is found by use of Mazur's
# bound on the torsion of elliptic curves over the rationals;
((3*x^2)/(2*(1 + x^3 + sqrt(1 + x^3))), log(1 + sqrt(1 + x^3)), x, 4),


# ::Section::Closed::
# Examples quoted by Joel Moses


(1/sqrt(2*h*r^2-alpha^2), atanh((sqrt(2)*sqrt(h)*r)/sqrt(-alpha^2 + 2*h*r^2))/(sqrt(2)*sqrt(h)), r, 2),
(1/(r*sqrt(2*h*r^2-alpha^2-epsilon^2)), atan(sqrt(-alpha^2 - epsilon^2 + 2*h*r^2)/sqrt(alpha^2 + epsilon^2))/sqrt(alpha^2 + epsilon^2), r, 3),
(1/(r*sqrt(2*h*r^2-alpha^2-2*k*r)), -(atan((alpha^2 + k*r)/(alpha*sqrt(-alpha^2 - 2*k*r + 2*h*r^2)))/alpha), r, 2),
(1/(r*sqrt(2*h*r^2-alpha^2-epsilon^2-2*k*r)), -(atan((alpha^2 + epsilon^2 + k*r)/(sqrt(alpha^2 + epsilon^2)*sqrt(-alpha^2 - epsilon^2 - 2*k*r + 2*h*r^2)))/sqrt(alpha^2 + epsilon^2)), r, 2),
(r/sqrt(2*e*r^2-alpha^2), sqrt(-alpha^2 + 2*e*r^2)/(2*e), r, 1),
(r/sqrt(2*e*r^2-alpha^2-epsilon^2), sqrt(-alpha^2 - epsilon^2 + 2*e*r^2)/(2*e), r, 1),
(r/sqrt(2*e*r^2-alpha^2-2*k*r^4), -(atan((e - 2*k*r^2)/(sqrt(2)*sqrt(k)*sqrt(-alpha^2 + 2*e*r^2 - 2*k*r^4)))/(2*sqrt(2)*sqrt(k))), r, 3),
(r/sqrt(2*e*r^2-alpha^2-2*k*r), sqrt(-alpha^2 - 2*k*r + 2*e*r^2)/(2*e) - (k*atanh((k - 2*e*r)/(sqrt(2)*sqrt(e)*sqrt(-alpha^2 - 2*k*r + 2*e*r^2))))/(2*sqrt(2)*e^(3//2)), r, 3),
(1/(r*sqrt(2*h*r^2-alpha^2-2*k*r^4)), -(atan((alpha^2 - h*r^2)/(alpha*sqrt(-alpha^2 + 2*h*r^2 - 2*k*r^4)))/(2*alpha)), r, 3),
(1/(r*sqrt(2*h*r^2-alpha^2-epsilon^2-2*k*r^4)), -(atan((alpha^2 + epsilon^2 - h*r^2)/(sqrt(alpha^2 + epsilon^2)*sqrt(-alpha^2 - epsilon^2 + 2*h*r^2 - 2*k*r^4)))/(2*sqrt(alpha^2 + epsilon^2))), r, 3),


# ::Section::Closed::
# Examples from Novosibirsk


# Many of these integrals used to require Steve Harrington's code to evaluate.
# They originated in Novosibirsk as examples of using Analytik.
# There are still a few examples that could be evaluated using better heuristics.

 (a*sin(3*x+5)^2*cos(3*x+5), (1//9)*a*sin(5 + 3*x)^3, x, 3),
(log(x^2)/x^3, -(1/(2*x^2)) - log(x^2)/(2*x^2), x, 1),
(x*sin(x+a), (-x)*cos(a + x) + sin(a + x), x, 2),
((log(x)*(1-x)-1)/(ℯ^x*log(x)^2), x/(ℯ^x*log(x)), x, 1),
(x^3/(a*x^2+b), x^2/(2*a) - (b*log(b + a*x^2))/(2*a^2), x, 3),
(x^(1//2)*(x+1)^(-7//2), (2*x^(3//2))/(5*(1 + x)^(5//2)) + (4*x^(3//2))/(15*(1 + x)^(3//2)), x, 2),
(x^(-1)*(x+1)^(-1), log(x) - log(1 + x), x, 3),
(x^(-1//2)*(2*x-1)^(-1), (-sqrt(2))*atanh(sqrt(2)*sqrt(x)), x, 2),
((x^2+1)*x^(1//2), (2*x^(3//2))/3 + (2*x^(7//2))/7, x, 2),
(x^(-1)*(x-a)^(1//3), 3*(-a + x)^(1//3) + sqrt(3)*a^(1//3)*atan((a^(1//3) - 2*(-a + x)^(1//3))/(sqrt(3)*a^(1//3))) + (1//2)*a^(1//3)*log(x) - (3//2)*a^(1//3)*log(a^(1//3) + (-a + x)^(1//3)), x, 5),
(x*sinh(x), x*cosh(x) - sinh(x), x, 2),
(x*cosh(x), -cosh(x) + x*sinh(x), x, 2),
(sinh(2*x)/cosh(2*x), (1//2)*log(cosh(2*x)), x, 1),
((I*epsilon*sinh(x)-1)/(epsilon*I*cosh(x)+I*a-x), log(a + I*x + epsilon*cosh(x)), x, 1),
(sin(2*x+3)*cos(x)^2, (-(1//4))*cos(3 + 2*x) - (1//16)*cos(3 + 4*x) + (1//4)*x*sin(3), x, 4),
(x*atan(x), -(x/2) + atan(x)/2 + (1//2)*x^2*atan(x), x, 3),
(x*acot(x), x/2 + (1//2)*x^2*acot(x) - atan(x)/2, x, 3),
(x*log(x^2+a), -(x^2//2) + (1//2)*(a + x^2)*log(a + x^2), x, 3),
(sin(x+a)*cos(x), (-(1//4))*cos(a + 2*x) + (1//2)*x*sin(a), x, 3),
(cos(x+a)*sin(x), (-(1//4))*cos(a + 2*x) - (1//2)*x*sin(a), x, 3),
((1+sin(x))^(1//2), -((2*cos(x))/sqrt(1 + sin(x))), x, 1),
((1-sin(x))^(1//2), (2*cos(x))/sqrt(1 - sin(x)), x, 1),
((1+cos(x))^(1//2), (2*sin(x))/sqrt(1 + cos(x)), x, 1),
((1-cos(x))^(1//2), -((2*sin(x))/sqrt(1 - cos(x))), x, 1),
(1/(x^(1//2)-(x-1)^(1//2)), (2//3)*(-1 + x)^(3//2) + (2*x^(3//2))/3, x, 3),
(1/(1-(x+1)^(1//2)), -2*sqrt(1 + x) - 2*log(1 - sqrt(1 + x)), x, 4),
(x/(x^4+36)^(1//2), (1//2)*asinh(x^2//6), x, 2),
(1/(x^(1//3)+x^(1//2)), 6*x^(1//6) - 3*x^(1//3) + 2*sqrt(x) - 6*log(1 + x^(1//6)), x, 4),
(log(2+3*x^2), -2*x + 2*sqrt(2//3)*atan(sqrt(3//2)*x) + x*log(2 + 3*x^2), x, 3),
(cot(x), log(sin(x)), x, 1),
(cot(x)^4, x + cot(x) - cot(x)^3//3, x, 3),
(tanh(x), log(cosh(x)), x, 1),
(coth(x), log(sinh(x)), x, 1),
(b^x, b^x/log(b), x, 1),
((x^4+x^(-4)+2)^(1//2), -((x*sqrt(2 + 1/x^4 + x^4))/(1 + x^4)) + (x^5*sqrt(2 + 1/x^4 + x^4))/(3*(1 + x^4)), x, 4),
((2*x+1)/(3*x+2), (2*x)/3 - (1//9)*log(2 + 3*x), x, 2),
(x*log(x+(x^2+1)^(1//2)), (-(1//4))*x*sqrt(1 + x^2) + asinh(x)/4 + (1//2)*x^2*log(x + sqrt(1 + x^2)), x, 3),
(x*(ℯ^x*sin(x)+1)^2, -((3*ℯ^(2*x))/32) + (1//8)*ℯ^(2*x)*x + x^2//2 + ℯ^x*cos(x) - ℯ^x*x*cos(x) - (1//32)*ℯ^(2*x)*cos(2*x) + ℯ^x*x*sin(x) + (1//16)*ℯ^(2*x)*cos(x)*sin(x) - (1//4)*ℯ^(2*x)*x*cos(x)*sin(x) - (1//16)*ℯ^(2*x)*sin(x)^2 + (1//4)*ℯ^(2*x)*x*sin(x)^2 + (1//32)*ℯ^(2*x)*sin(2*x), x, 14),
(x*ℯ^x*cos(x), (1//2)*ℯ^x*x*cos(x) - (1//2)*ℯ^x*sin(x) + (1//2)*ℯ^x*x*sin(x), x, 4),


# ::Section::Closed::
# Examples from Herbert Stoyan


(1/(x-3)^4, 1/(3*(3 - x)^3), x, 1),
(x/(x^3-1), atan((1 + 2*x)/sqrt(3))/sqrt(3) + (1//3)*log(1 - x) - (1//6)*log(1 + x + x^2), x, 6),
(x/(x^4-1), (-(1//2))*atanh(x^2), x, 2),
##XXX (log(x)*(x^3+1)/(x^4+2), (1//8)*(2 + I*(-2.0)^(1//4))*log(x)*log(1 - ((1 + I)*x)/2^(3//4)) + (1//16)*(4 + (1 - I)*2^(3//4))*log(x)*log(1 + ((1 + I)*x)/2^(3//4)) + (1//8)*(2 + (-2.0)^(1//4))*log(x)*log(1 - ((-1)^(3//4)*x)/2^(1//4)) + (1//8)*(2 - (-2.0)^(1//4))*log(x)*log(1 + ((-1)^(3//4)*x)/2^(1//4)) + (1//16)*(4 + (1 - I)*2^(3//4))*PolyLog_reli(2, -(((1 + I)*x)/2^(3//4))) + (1//8)*(2 + I*(-2.0)^(1//4))*PolyLog_reli(2, ((1 + I)*x)/2^(3//4)) + (1//8)*(2 - (-2.0)^(1//4))*PolyLog_reli(2, -(((-1)^(3//4)*x)/2^(1//4))) + (1//8)*(2 + (-2.0)^(1//4))*PolyLog_reli(2, ((-1)^(3//4)*x)/2^(1//4)), x, 10),
(log(x)+log(x+1)+log(x+2), -3*x + x*log(x) + (1 + x)*log(1 + x) + (2 + x)*log(2 + x), x, 6),
(1/(x^3+5), -(atan((5^(1//3) - 2*x)/(sqrt(3)*5^(1//3)))/(sqrt(3)*5^(2//3))) + log(5^(1//3) + x)/(3*5^(2//3)) - log(5^(2//3) - 5^(1//3)*x + x^2)/(6*5^(2//3)), x, 6),
(1/sqrt(1+x^2), asinh(x), x, 1),
(sqrt(x^2+3), (1//2)*x*sqrt(3 + x^2) + (3//2)*asinh(x/sqrt(3)), x, 2),
(x/(x+1)^2, 1/(1 + x) + log(1 + x), x, 2),


# ::Section::Closed::
# Examples from Moses' SIN program


(asin(x), sqrt(1 - x^2) + x*asin(x), x, 2),
(x^2*asin(x), sqrt(1 - x^2)/3 - (1//9)*(1 - x^2)^(3//2) + (1//3)*x^3*asin(x), x, 4),
(sec(x)^2/(1+sec(x)^2-3*tan(x)), -log(cos(x) - sin(x)) + log(2*cos(x) - sin(x)), x, 4),
(1/sec(x)^2, x/2 + (1//2)*cos(x)*sin(x), x, 2),
((5*x^2-3*x-2)/(x^2*(x-2)), -(1/x) + 3*log(2 - x) + 2*log(x), x, 2),
(1/(4*x^2+9)^(1//2), (1//2)*asinh((2*x)/3), x, 1),
((x^2+4)^(-1//2), asinh(x/2), x, 1),
(1/(9*x^2-12*x+10), -(atan((2 - 3*x)/sqrt(6))/(3*sqrt(6))), x, 2),
(1/(x^8-2*x^7+2*x^6-2*x^5+x^4), 1/(2*(1 - x)) - 1/(3*x^3) - 1/x^2 - 2/x - (5//2)*log(1 - x) + 2*log(x) + (1//4)*log(1 + x^2), x, 3),
((a*x^3+b*x^2+c*x+d)/((x+1)*x*(x-3)), a*x + (1//12)*(27*a + 9*b + 3*c + d)*log(3 - x) - (1//3)*d*log(x) - (1//4)*(a - b + c - d)*log(1 + x), x, 2),
(1/(2-log(x^2+1))^5, Unintegrable(1/(2 - log(1 + x^2))^5, x), x, 0),


# ::Section::Closed::
# Miscellaneous examples


# The next integral appeared in Risch's 1968 paper.

(2*x*ℯ^(x^2)*log(x)+ℯ^(x^2)/x+(log(x)-2)/(log(x)^2+x)^2+((2/x)*log(x)+(1/x)+1)/(log(x)^2+x), ℯ^x^2*log(x) - log(x)/(x + log(x)^2) + log(x + log(x)^2), x, 9),


# The following integral would not evaluate in REDUCE 3.3.

(exp(x*z+x/2)*sin(π*z)^4*x^4, (24*ℯ^(x/2 + x*z)*π^4*x^3)/(64*π^4 + 20*π^2*x^2 + x^4) - (24*ℯ^(x/2 + x*z)*π^3*x^4*cos(π*z)*sin(π*z))/(64*π^4 + 20*π^2*x^2 + x^4) + (12*ℯ^(x/2 + x*z)*π^2*x^5*sin(π*z)^2)/(64*π^4 + 20*π^2*x^2 + x^4) - (4*ℯ^(x/2 + x*z)*π*x^4*cos(π*z)*sin(π*z)^3)/(16*π^2 + x^2) + (ℯ^(x/2 + x*z)*x^5*sin(π*z)^4)/(16*π^2 + x^2), z, 4),


# Examples involving the error function.

(Erf(x), 1/(ℯ^x^2*sqrt(π)) + x*Erf(x), x, 1),
(Erf(x+a), 1/(ℯ^(a + x)^2*sqrt(π)) + (a + x)*Erf(a + x), x, 1),


# Some interesting integrals of algebraic functions;
# The Chebyshev integral.

((2*x^6+4*x^5+7*x^4-3*x^3-x*x-8*x-8)/((2*x^2-1)^2*sqrt(x^4+4*x^3+2*x^2+1)), ((1 + 2*x)*sqrt(1 + 2*x^2 + 4*x^3 + x^4))/(2*(-1 + 2*x^2)) - atanh((x*(2 + x)*(7 - x + 27*x^2 + 33*x^3))/((2 + 37*x^2 + 31*x^3)*sqrt(1 + 2*x^2 + 4*x^3 + x^4))), x, -10),


# This integral came from Dr. G.S. Joyce of Imperial College London.

((1+2*y)*sqrt(1-5*y-5*y^2)/(y*(1+y)*(2+y)*sqrt(1-y-y^2)), (-(1//4))*atanh(((1 - 3*y)*sqrt(1 - 5*y - 5*y^2))/((1 - 5*y)*sqrt(1 - y - y^2))) - (1//2)*atanh(((4 + 3*y)*sqrt(1 - 5*y - 5*y^2))/((6 + 5*y)*sqrt(1 - y - y^2))) + (9//4)*atanh(((11 + 7*y)*sqrt(1 - 5*y - 5*y^2))/(3*(7 + 5*y)*sqrt(1 - y - y^2))), y, -2),


# This one has a simple result.

(x*(sqrt(x^2-1)*x^2-4*sqrt(x^2-1)+sqrt(x^2-4)*x^2-sqrt(x^2-4))/((1+sqrt(x^2-4)+sqrt(x^2-1))*(x^4-5*x^2+4)), log(1 + sqrt(-4 + x^2) + sqrt(-1 + x^2)), x, 1),


# This used to reveal bugs in the integrator which have been fixed.

##XXX(sqrt(-4*sqrt(2) + 9)*x - sqrt(x^4 + 2*x^2 + 4*x + 1)*sqrt(2), (1//2)*sqrt(9 - 4*sqrt(2))*x^2 - sqrt(2)*((-(1//3))*sqrt(1 + 4*x + 2*x^2 + x^4) + (1//3)*(1 + x)*sqrt(1 + 4*x + 2*x^2 + x^4) + (4*I*(-13 + 3*sqrt(33))^(1//3)*sqrt(1 + 4*x + 2*x^2 + x^4))/(4*2^(2//3)*(-I + sqrt(3)) - 2*I*(-13 + 3*sqrt(33))^(1//3) + 2^(1//3)*(I + sqrt(3))*(-13 + 3*sqrt(33))^(2//3) + 6*I*(-13 + 3*sqrt(33))^(1//3)*x) - (8*2^(2//3)*sqrt(3/(-13 + 3*sqrt(33) + 4*(-26 + 6*sqrt(33))^(1//3)))*sqrt((I*(-19899 + 3445*sqrt(33) + (-26 + 6*sqrt(33))^(2//3)*(-2574 + 466*sqrt(33)) + (-26 + 6*sqrt(33))^(1//3)*(-19899 + 3445*sqrt(33)) + (59697 - 10335*sqrt(33))*x))/((-39 - 13*I*sqrt(3) + 9*I*sqrt(11) + 9*sqrt(33) + 4*I*(3*I + sqrt(3))*(-26 + 6*sqrt(33))^(1//3))*(26 - 6*sqrt(33) + (-13 + 13*I*sqrt(3) - 9*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + (-4 - 4*I*sqrt(3))*(-26 + 6*sqrt(33))^(2//3) + 6*(-13 + 3*sqrt(33))*x)))*sqrt(1 + 4*x + 2*x^2 + x^4)*Elliptic_e(asin(sqrt(26 - 6*sqrt(33) + (-13 - 13*I*sqrt(3) + 9*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + 4*I*(I + sqrt(3))*(-26 + 6*sqrt(33))^(2//3) + 6*(-13 + 3*sqrt(33))*x)/(sqrt((39 + 13*I*sqrt(3) - 9*I*sqrt(11) - 9*sqrt(33) + 4*(3 - I*sqrt(3))*(-26 + 6*sqrt(33))^(1//3))/(39 - 13*I*sqrt(3) + 9*I*sqrt(11) - 9*sqrt(33) + 4*(3 + I*sqrt(3))*(-26 + 6*sqrt(33))^(1//3)))*sqrt(26 - 6*sqrt(33) + (-13 + 13*I*sqrt(3) - 9*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + (-4 - 4*I*sqrt(3))*(-26 + 6*sqrt(33))^(2//3) + 6*(-13 + 3*sqrt(33))*x))), (4*(21 + 7*I*sqrt(3) - 3*I*sqrt(11) - 3*sqrt(33)) + (3 - I*sqrt(3) - 3*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3))/(4*(21 - 7*I*sqrt(3) + 3*I*sqrt(11) - 3*sqrt(33)) + (3 + I*sqrt(3) + 3*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3))))/((4*2^(2//3) - (-13 + 3*sqrt(33))^(1//3) - 2^(1//3)*(-13 + 3*sqrt(33))^(2//3) + 3*(-13 + 3*sqrt(33))^(1//3)*x)*sqrt((I*(1 + x))/((104 - 24*sqrt(33) + (-13 - 13*I*sqrt(3) + 9*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + 4*I*(I + sqrt(3))*(-26 + 6*sqrt(33))^(2//3))*(26 - 6*sqrt(33) + (-13 + 13*I*sqrt(3) - 9*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + (-4 - 4*I*sqrt(3))*(-26 + 6*sqrt(33))^(2//3) + 6*(-13 + 3*sqrt(33))*x)))*sqrt(26 - 6*sqrt(33) + (-13 + 13*I*sqrt(3) - 9*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + (-4 - 4*I*sqrt(3))*(-26 + 6*sqrt(33))^(2//3) + 6*(-13 + 3*sqrt(33))*x)*sqrt(26 - 6*sqrt(33) + (-13 - 13*I*sqrt(3) + 9*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + 4*I*(I + sqrt(3))*(-26 + 6*sqrt(33))^(2//3) + 6*(-13 + 3*sqrt(33))*x)) + ((2^(1//3)*(13 - 13*I*sqrt(3) + 9*I*sqrt(11) - 3*sqrt(33)) + 4*2^(2//3)*(1 + I*sqrt(3))*(-13 + 3*sqrt(33))^(1//3) + 20*(-13 + 3*sqrt(33))^(2//3))*(4*2^(2//3)*(I + sqrt(3)) + 8*I*(-13 + 3*sqrt(33))^(1//3) + 2^(1//3)*(-I + sqrt(3))*(-13 + 3*sqrt(33))^(2//3))*sqrt((52 - 12*sqrt(33) - 2^(1//3)*(-13 + 3*sqrt(33))^(4//3) + 4*(-26 + 6*sqrt(33))^(2//3))/(-13 + 3*sqrt(33) + 4*(-26 + 6*sqrt(33))^(1//3)))*sqrt((1/(1 + x))*(-8*I*(-13 + 3*sqrt(33)) + (-43*I - 13*sqrt(3) + 9*sqrt(11) + 5*I*sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + (2*I + 4*sqrt(3) - 2*I*sqrt(33))*(-26 + 6*sqrt(33))^(2//3) + (8*I*(-13 + 3*sqrt(33)) + (13*I - 13*sqrt(3) + 9*sqrt(11) - 3*I*sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + 4*(I + sqrt(3))*(-26 + 6*sqrt(33))^(2//3))*x))*sqrt(1 + 4*x + 2*x^2 + x^4)*Elliptic_f(asin((sqrt(52 - 12*sqrt(33) - 2^(1//3)*(-13 + 3*sqrt(33))^(4//3) + 4*(-26 + 6*sqrt(33))^(2//3))*sqrt(26 - 6*sqrt(33) + (-13 - 13*I*sqrt(3) + 9*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + 4*I*(I + sqrt(3))*(-26 + 6*sqrt(33))^(2//3) + 6*(-13 + 3*sqrt(33))*x))/(2^(1//6)*sqrt(3)*(-13 + 3*sqrt(33))^(2//3)*sqrt(39 + 13*I*sqrt(3) - 9*I*sqrt(11) - 9*sqrt(33) + 4*(3 - I*sqrt(3))*(-26 + 6*sqrt(33))^(1//3))*sqrt(1 + x))), (4*(21*I - 7*sqrt(3) + 3*sqrt(11) - 3*I*sqrt(33)) + (3*I + sqrt(3) + 3*sqrt(11) + 3*I*sqrt(33))*(-26 + 6*sqrt(33))^(1//3))/(-56*sqrt(3) + 24*sqrt(11) + 2*(sqrt(3) + 3*sqrt(11))*(-26 + 6*sqrt(33))^(1//3))))/(3*2^(2//3)*3^(3//4)*(-13 + 3*sqrt(33))^(1//3)*sqrt(39 + 13*I*sqrt(3) - 9*I*sqrt(11) - 9*sqrt(33) + 4*(3 - I*sqrt(3))*(-26 + 6*sqrt(33))^(1//3))*sqrt(1 + x)*(4*2^(2//3)*(-I + sqrt(3)) - 2*I*(-13 + 3*sqrt(33))^(1//3) + 2^(1//3)*(I + sqrt(3))*(-13 + 3*sqrt(33))^(2//3) + 6*I*(-13 + 3*sqrt(33))^(1//3)*x)*sqrt(26 - 6*sqrt(33) + (-13 - 13*I*sqrt(3) + 9*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + 4*I*(I + sqrt(3))*(-26 + 6*sqrt(33))^(2//3) + 6*(-13 + 3*sqrt(33))*x)*sqrt((8*(-13 + 3*sqrt(33)) - (5 - 3*I*sqrt(3) + 3*I*sqrt(11) + sqrt(33))*(-26 + 6*sqrt(33))^(2//3) + (-26 + 6*sqrt(33))^(1//3)*(-41 + 15*I*sqrt(3) - 3*I*sqrt(11) + 7*sqrt(33)) + (104 - 24*sqrt(33) + (-13 - 13*I*sqrt(3) + 9*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + 4*I*(I + sqrt(3))*(-26 + 6*sqrt(33))^(2//3))*x)/((-39 - 13*I*sqrt(3) + 9*I*sqrt(11) + 9*sqrt(33) + 4*I*(3*I + sqrt(3))*(-26 + 6*sqrt(33))^(1//3))*(1 + x)))) + ((4*2^(2//3) + 2*(-13 + 3*sqrt(33))^(1//3) - 2^(1//3)*(-13 + 3*sqrt(33))^(2//3))*(4*2^(2//3)*(I + sqrt(3)) - 4*I*(-13 + 3*sqrt(33))^(1//3) + 2^(1//3)*(-I + sqrt(3))*(-13 + 3*sqrt(33))^(2//3))*(4*2^(2//3)*(-I + sqrt(3)) + 4*I*(-13 + 3*sqrt(33))^(1//3) + 2^(1//3)*(I + sqrt(3))*(-13 + 3*sqrt(33))^(2//3))*sqrt((-39 + 13*I*sqrt(3) - 9*I*sqrt(11) + 9*sqrt(33) - 4*I*(-3*I + sqrt(3))*(-26 + 6*sqrt(33))^(1//3))/(104 - 24*sqrt(33) + (-13 + 13*I*sqrt(3) - 9*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + (-4 - 4*I*sqrt(3))*(-26 + 6*sqrt(33))^(2//3)))*sqrt(1 + x)*sqrt((104 - 24*sqrt(33) + 2*(1 + 14*I*sqrt(3) - 6*I*sqrt(11) + sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + (-7 - I*sqrt(3) - 3*I*sqrt(11) + sqrt(33))*(-26 + 6*sqrt(33))^(2//3) + 2*(-52 + 12*sqrt(33) + 2^(1//3)*(-13 + 3*sqrt(33))^(4//3) - 4*(-26 + 6*sqrt(33))^(2//3))*x)/((-39 + 13*I*sqrt(3) - 9*I*sqrt(11) + 9*sqrt(33) - 4*I*(-3*I + sqrt(3))*(-26 + 6*sqrt(33))^(1//3))*(1 + x)))*sqrt((104 - 24*sqrt(33) + 2*(1 - 14*I*sqrt(3) + 6*I*sqrt(11) + sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + (-7 + I*sqrt(3) + 3*I*sqrt(11) + sqrt(33))*(-26 + 6*sqrt(33))^(2//3) + 2*(-52 + 12*sqrt(33) + 2^(1//3)*(-13 + 3*sqrt(33))^(4//3) - 4*(-26 + 6*sqrt(33))^(2//3))*x)/((-39 - 13*I*sqrt(3) + 9*I*sqrt(11) + 9*sqrt(33) + 4*I*(3*I + sqrt(3))*(-26 + 6*sqrt(33))^(1//3))*(1 + x)))*sqrt(1 + 4*x + 2*x^2 + x^4)*Elliptic_pi((2^(1//3)*(4*2^(1//3)*(-3*I + sqrt(3)) + (3*I + sqrt(3))*(-13 + 3*sqrt(33))^(2//3)))/(4*2^(2//3)*(-I + sqrt(3)) - 8*I*(-13 + 3*sqrt(33))^(1//3) + 2^(1//3)*(I + sqrt(3))*(-13 + 3*sqrt(33))^(2//3)), asin(sqrt(13 - 3*sqrt(33) - 2^(1//3)*(-13 + 3*sqrt(33))^(4//3) + 4*(-26 + 6*sqrt(33))^(2//3) + (-39 + 9*sqrt(33))*x)/(2^(1//6)*sqrt(3)*(-13 + 3*sqrt(33))^(2//3)*sqrt((-39 + 13*I*sqrt(3) - 9*I*sqrt(11) + 9*sqrt(33) - 4*I*(-3*I + sqrt(3))*(-26 + 6*sqrt(33))^(1//3))/(104 - 24*sqrt(33) + (-13 + 13*I*sqrt(3) - 9*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3) + (-4 - 4*I*sqrt(3))*(-26 + 6*sqrt(33))^(2//3)))*sqrt(1 + x))), (4*(21 - 7*I*sqrt(3) + 3*I*sqrt(11) - 3*sqrt(33)) + (3 + I*sqrt(3) + 3*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3))/(4*(21 + 7*I*sqrt(3) - 3*I*sqrt(11) - 3*sqrt(33)) + (3 - I*sqrt(3) - 3*I*sqrt(11) + 3*sqrt(33))*(-26 + 6*sqrt(33))^(1//3))))/(2^(1//6)*sqrt(3)*(4*2^(2//3)*(I + sqrt(3)) + 2*I*(-13 + 3*sqrt(33))^(1//3) + 2^(1//3)*(-I + sqrt(3))*(-13 + 3*sqrt(33))^(2//3) - 6*I*(-13 + 3*sqrt(33))^(1//3)*x)*(4*2^(2//3)*(-I + sqrt(3)) - 2*I*(-13 + 3*sqrt(33))^(1//3) + 2^(1//3)*(I + sqrt(3))*(-13 + 3*sqrt(33))^(2//3) + 6*I*(-13 + 3*sqrt(33))^(1//3)*x)*sqrt(13 - 3*sqrt(33) - 2^(1//3)*(-13 + 3*sqrt(33))^(4//3) + 4*(-26 + 6*sqrt(33))^(2//3) + (-39 + 9*sqrt(33))*x))), x, -1),


# It is interesting to see how much of this one can be done;

((12*log(x/mc^2)*x^2*π^2*mc^3*(-8*x-12*mc^2+3*mc) + π^2*(12*x^4*mc+3*x^4+176*x^3*mc^3-24*x^3*mc^2 - 144*x^2*mc^5-48*x*mc^7+24*x*mc^6+4*mc^9-3*mc^8))/(384*ℯ^(x/y)*x^2), ((3 - 4*mc)*mc^8*π^2)/(ℯ^(x/y)*(384*x)) + ((3//8)*mc^5*π^2*y)/ℯ^(x/y) + ((1//48)*(3 - 22*mc)*mc^2*π^2*x*y)/ℯ^(x/y) - ((1//128)*(1 + 4*mc)*π^2*x^2*y)/ℯ^(x/y) + ((1//48)*(3 - 22*mc)*mc^2*π^2*y^2)/ℯ^(x/y) + ((1//4)*mc^3*π^2*y^2)/ℯ^(x/y) - ((1//64)*(1 + 4*mc)*π^2*x*y^2)/ℯ^(x/y) - ((1//64)*(1 + 4*mc)*π^2*y^3)/ℯ^(x/y) + (1//16)*(1 - 2*mc)*mc^6*π^2*Expinti(-(x/y)) + ((3 - 4*mc)*mc^8*π^2*Expinti(-(x/y)))/(384*y) + (1//32)*mc^3*π^2*(3*mc - 12*mc^2 - 8*y)*y*Expinti(-(x/y)) - ((1//32)*mc^3*π^2*(3*(1 - 4*mc)*mc - 8*x)*y*log(x/mc^2))/ℯ^(x/y) + ((1//4)*mc^3*π^2*y^2*log(x/mc^2))/ℯ^(x/y), x, 20),


# The following integrals reveal deficiencies in the current integrator;

(sin(2*x)/cos(x), -2*cos(x), x, 2),

# This example, which appeared in Tobey's thesis, needs factorization
# over algebraic fields. It currently gives an ugly answer and so has
# been suppressed;

((7*x^13+10*x^8+4*x^7-7*x^6-4*x^3-4*x^2+3*x+3)/(x^14-2*x^8-2*x^7-2*x^4-4*x^3-x^2+2*x+1), (1//2)*((1 + sqrt(2))*log(1 + x + sqrt(2)*x + sqrt(2)*x^2 - x^7) - (-1 + sqrt(2))*log(-1 + (-1 + sqrt(2))*x + sqrt(2)*x^2 + x^7)), x, -5),
]

hebisch = [
# ::Package::

# ::Title::
# Waldek Hebisch - email May 2013


# ::Subsection::
# Problem #1


((x^6 - x^5 + x^4 - x^3 + 1)*exp(x), 871*ℯ^x - 870*ℯ^x*x + 435*ℯ^x*x^2 - 145*ℯ^x*x^3 + 36*ℯ^x*x^4 - 7*ℯ^x*x^5 + ℯ^x*x^6, x, 25),


# ::Subsection::
# Problem #2


((2 - x^2)*exp(x/(x^2 + 2))/(x^3 + 2*x), Expinti(x/(2 + x^2)), x, -5),


((2 + 2*x + 3*x^2 - x^3 + 2*x^4)*exp(x/(2 + x^2))/(x^3 + 2*x), ℯ^(x/(2 + x^2))*(2 + x^2) + Expinti(x/(2 + x^2)), x, -5),


# ::Subsection::
# Problem #3


((exp(x) + 1)*(exp(exp(x) + x)/(exp(x) + x)), Expinti(ℯ^x + x), x, 2),


# ::Subsection::
# Problem #4


((x^3 - x^2 - 3*x + 1)*(exp(1/(x^2 - 1))/(x^3 - x^2 - x + 1)), ℯ^(1/(-1 + x^2))*(1 + x), x, -6),


# ::Subsection::
# Problem #5


((log(x)^2 - 1)*exp(1 + 1/log(x))/log(x)^2, x*ℯ^(1 + 1/log(x)), x, 1),


(((x + 1)*log(x)^2  - 1)*exp(x + 1/log(x))/log(x)^2, ℯ^(x + 1/log(x))*x, x, -2),
]

jeffrey =  [
# ::Package::

# ::Title::
# David Jeffrey - Rectifying Transformations for Trig Integration (1997)


# ::Subsection::Closed::
# Problem (1.2)


(3/(5 - 4*cos(x)), x + 2*atan(sin(x)/(2 - cos(x))), x, 2),


# ::Subsection::Closed::
# Problem (1.4)


((cos(x) + 2*sin(x) + 1)/(cos(x)^2 - 2*sin(x)*cos(x) + 2*sin(x) + 3), -atan((2*cos(x) - sin(x))/(2 + sin(x))), x, -43),


# ::Subsection::Closed::
# Problem (1.5)


((2 + 5*sin(x) + cos(x))/(4*cos(x) + sin(x)*cos(x) - 2*sin(x) - 2*sin(x)^2), -log(1 - 3*cos(x) + sin(x)) + log(3 + cos(x) + sin(x)), x, -25),


# ::Subsection::Closed::
# Problem (3.3)


((7*cos(x) + 2*sin(x) + 3)/(3*cos(x)^2 - sin(x)*cos(x) + 4*cos(x) - 5*sin(x) + 1), -log(1 + cos(x) - 2*sin(x)) + log(3 + cos(x) + sin(x)), x, -32),


# ::Subsection::Closed::
# Problem


((5*cos(x)^2 + 4*cos(x) - 1)/(4*cos(x)^3 - 3*cos(x)^2 - 4*cos(x) - 1), x - 2*atan(sin(x)/(3 + cos(x))) - 2*atan((3*sin(x) + 7*cos(x)*sin(x))/(1 + 2*cos(x) + 5*cos(x)^2)), x, -2),


# ::Subsection::Closed::
# Problem


((7*cos(x)^2 + 2*cos(x) - 5)/(4*cos(x)^3 - 9*cos(x)^2 + 2*cos(x) - 1), x - 2*atan((2*cos(x)*sin(x))/(1 - cos(x) + 2*cos(x)^2)), x, -2),


# ::Subsection::Closed::
# Problem (3.4)


(3/(5 + 4*sin(x)), x + 2*atan(cos(x)/(2 + sin(x))), x, 2),


# ::Subsection::Closed::
# Problem (3.6)


(2/(1 + cos(x)^2), sqrt(2)*x - sqrt(2)*atan((cos(x)*sin(x))/(1 + sqrt(2) + cos(x)^2)), x, 3),


# ::Subsection::Closed::
# Problem (3.8)


(1/(p + q*cos(x) + r*sin(x)), (2*atan((r + (p - q)*tan(x/2))/sqrt(p^2 - q^2 - r^2)))/sqrt(p^2 - q^2 - r^2), x, 3),
]

moses = [
# ::Package::

# ::Title::
# Joel Moses - Symbolic Integration Ph.D. Thesis (1967)


# ::Section::Closed::
# Chapter 2 - How SIN differs from SAINT


(cot(x)^4, x + cot(x) - cot(x)^3//3, x, 3),
(1/(x^4*(1 + x^2)), -(1/(3*x^3)) + 1/x + atan(x), x, 3),
((x^2 + x)/sqrt(x), (2*x^(3//2))/3 + (2*x^(5//2))/5, x, 2),
(cos(x), sin(x), x, 1),
(x*ℯ^x^2, ℯ^x^2//2, x, 1),
(tan(x)*sec(x)^2, sec(x)^2//2, x, 2),
(x*sqrt(1 + x^2), (1//3)*(1 + x^2)^(3//2), x, 1),
(sin(x)*ℯ^x, (-(1//2))*ℯ^x*cos(x) + (1//2)*ℯ^x*sin(x), x, 1),


# ::Section::Closed::
# Chapter 3 - SCHATCHEN - A Matching Program for Algebraic Expressions


(csc(x)^2*(cos(x)/sin(x)^2), (-(1//3))*csc(x)^3, x, 2),


# ::Section::Closed::
# Chapter 4 - The First Stage of Sin


(sin(ℯ^x), Sinint(ℯ^x), x, 2),
(sin(y)/y, Sinint(y), y, 1),


(sin(x) + ℯ^x, ℯ^x - cos(x), x, 3),
(ℯ^x^2 + 2*x^2*ℯ^x^2, ℯ^x^2*x, x, 4),
((x + ℯ^x)^2, -2*ℯ^x + ℯ^(2*x)/2 + 2*ℯ^x*x + x^3//3, x, 5),
(x^2 + 2*ℯ^x + ℯ^(2*x), 2*ℯ^x + ℯ^(2*x)/2 + x^3//3, x, 3),


(sin(x)*cos(x), sin(x)^2//2, x, 2),
(x*ℯ^x^2, ℯ^x^2//2, x, 1),
(x*sqrt(1 + x^2), (1//3)*(1 + x^2)^(3//2), x, 1),
(ℯ^x/(1 + ℯ^x), log(1 + ℯ^x), x, 2),
(x^(3//2), (2*x^(5//2))/5, x, 1),
(cos(2*x + 3), (1//2)*sin(3 + 2*x), x, 1),
(2*y*z*ℯ^(2*x), ℯ^(2*x)*y*z, x, 2),
(cos(ℯ^x)^2*sin(ℯ^x)*ℯ^x, (-(1//3))*cos(ℯ^x)^3, x, 3),


# ::Section::Closed::
# Chapter 4 - The Second Stage of Sin


(x*sqrt(x + 1), (-(2//3))*(1 + x)^(3//2) + (2//5)*(1 + x)^(5//2), x, 2),
(1/(x^4 - 1), -(atan(x)/2) - atanh(x)/2, x, 3),


# ::Subsection::Closed::
# Method 1)  Elementary function of exponentials


(ℯ^x/(2 + 3*ℯ^(2*x)), atan(sqrt(3//2)*ℯ^x)/sqrt(6), x, 2),
(ℯ^(2*x)/(A + B*ℯ^(4*x)), atan((sqrt(B)*ℯ^(2*x))/sqrt(A))/(2*sqrt(A)*sqrt(B)), x, 2),
(ℯ^(x + 1)/(1 + ℯ^x), ℯ*log(1 + ℯ^x), x, 3),
(10^x*ℯ^x, (10*ℯ)^x/(1 + log(10)), x, 1),


# ::Subsection::Closed::
# Method 2)  Substitution for an integral power


(x^3*sin(x^2), (-(1//2))*x^2*cos(x^2) + sin(x^2)/2, x, 3),
(x^7/(x^12 + 1), -(atan((1 - 2*x^4)/sqrt(3))/(4*sqrt(3))) - (1//12)*log(1 + x^4) + (1//24)*log(1 - x^4 + x^8), x, 7),
(x^(3*a)*sin(x^(2*a)), (I*x^(1 + 3*a)*Gamma((1//2)*(3 + 1/a), (-I)*x^(2*a)))/(((-I)*x^(2*a))^((1 + 3*a)/(2*a))*(4*a)) - (I*x^(1 + 3*a)*Gamma((1//2)*(3 + 1/a), I*x^(2*a)))/((I*x^(2*a))^((1 + 3*a)/(2*a))*(4*a)), x, 3),


# ::Subsection::Closed::
# Method 3)  Substitution for a rational root of a linear function of x


(cos(sqrt(x)), 2*cos(sqrt(x)) + 2*sqrt(x)*sin(sqrt(x)), x, 3),
(x*sqrt(x + 1), (-(2//3))*(1 + x)^(3//2) + (2//5)*(1 + x)^(5//2), x, 2),
(1/(x^(1//2) + x^(1//3)), 6*x^(1//6) - 3*x^(1//3) + 2*sqrt(x) - 6*log(1 + x^(1//6)), x, 4),
(sqrt((x + 1)/(2*x + 3)), (1//2)*sqrt(1 + x)*sqrt(3 + 2*x) - asinh(sqrt(2)*sqrt(1 + x))/(2*sqrt(2)), x, 4),


# ::Subsection::Closed::
# Method 4)  Binomial - Chebyschev


(x^4/(1 - x^2)^(5//2), x^3/(3*(1 - x^2)^(3//2)) - x/sqrt(1 - x^2) + asin(x), x, 3),
(x^(1//2)*(1 + x)^(5//2), (5//64)*sqrt(x)*sqrt(1 + x) + (5//32)*x^(3//2)*sqrt(1 + x) + (5//24)*x^(3//2)*(1 + x)^(3//2) + (1//4)*x^(3//2)*(1 + x)^(5//2) - (5*asinh(sqrt(x)))/64, x, 6),


# ::Subsection::Closed::
# Method 5)  Arctrigonometric substitutions


(x^4/(1 - x^2)^(5//2), x^3/(3*(1 - x^2)^(3//2)) - x/sqrt(1 - x^2) + asin(x), x, 3),
(sqrt(A^2 + B^2 - B^2*y^2)/(1 - y^2), B*atan((B*y)/sqrt(A^2 + B^2 - B^2*y^2)) + A*atanh((A*y)/sqrt(A^2 + B^2 - B^2*y^2)), y, 5),


# ::Subsection::Closed::
# Method 6)  Elementary function of trigonometric functions


(sin(x)^2, x/2 - (1//2)*cos(x)*sin(x), x, 2),
# {Sqrt[A^2 + B^2*Sin[x]^2]/Sin[x], x, 6, (-B)*ArcTan[(B*Cos[x])/Sqrt[A^2 + B^2*Sin[x]^2]] - A*ArcTanh[(A*Cos[x])/Sqrt[A^2 + B^2*Sin[x]^2]], (-B)*ArcTan[(B*Cos[x])/Sqrt[A^2 + B^2 - B^2*Cos[x]^2]] - A*ArcTanh[(A*Cos[x])/Sqrt[A^2 + B^2 - B^2*Cos[x]^2]]}
(1/(1 + cos(x)), sin(x)/(1 + cos(x)), x, 1),


# ::Subsection::Closed::
# Method 7)  Rational function times an exponential


(x*ℯ^x, -ℯ^x + ℯ^x*x, x, 2),
((x/(x + 1)^2)*ℯ^x, ℯ^x/(1 + x), x, 1),
((1 + 2*x^2)*ℯ^x^2, ℯ^x^2*x, x, 5),
(ℯ^x^2, (1//2)*sqrt(π)*Erfi(x), x, 1),
(ℯ^x/x, Expinti(x), x, 1),


# ::Subsection::Closed::
# Method 8)  Rational functions


(x/(x^3 + 1), -(atan((1 - 2*x)/sqrt(3))/sqrt(3)) - (1//3)*log(1 + x) + (1//6)*log(1 - x + x^2), x, 6),
# {1/(x^6 - 1), x, 10, -(ArcTan[(Sqrt[3]*x)/(1 - x^2)]/(2*Sqrt[3])) - ArcTanh[x]/3 - (1/6)*ArcTanh[x/(1 + x^2)], ArcTan[(1 - 2*x)/Sqrt[3]]/(2*Sqrt[3]) - ArcTan[(1 + 2*x)/Sqrt[3]]/(2*Sqrt[3]) - ArcTanh[x]/3 + (1/12)*Log[1 - x + x^2] - (1/12)*Log[1 + x + x^2]}
(1/((B^2 - A^2)*x^2 - A^2*B^2 + A^4), atanh(x/A)/(A*(A^2 - B^2)), x, 1),


# ::Subsection::Closed::
# Method 9)  Rational function times a log or arctrigonometric function


(x*log(x), -(x^2//4) + (1//2)*x^2*log(x), x, 1),
(x^2*asin(x), sqrt(1 - x^2)/3 - (1//9)*(1 - x^2)^(3//2) + (1//3)*x^3*asin(x), x, 4),
(1/(x^2 + 2*x + 1), -(1/(1 + x)), x, 2),


# ::Subsection::Closed::
# Method 10)  Rational function times an elementary function of log(a+b x)


(log(x)/(log(x) + 1)^2, x/(1 + log(x)), x, 7),
(1/(x*(1 + log(x)^2)), atan(log(x)), x, 2),
(1/log(x), Expinti(log(x)), x, 1),


# ::Subsection::Closed::
# Method 11)  Expansion of the integrand


(x*(cos(x) + sin(x)), cos(x) - x*cos(x) + sin(x) + x*sin(x), x, 6),
((x + ℯ^x)/ℯ^x, -ℯ^(-x) + x - x/ℯ^x, x, 4),
(x*(1 + ℯ^x)^2, -2*ℯ^x - ℯ^(2*x)/4 + 2*ℯ^x*x + (1//2)*ℯ^(2*x)*x + x^2//2, x, 6),


# ::Section::Closed::
# Chapter 4 - The Third Stage of Sin


(x*cos(x), cos(x) + x*sin(x), x, 2),
(cos(sqrt(x)), 2*cos(sqrt(x)) + 2*sqrt(x)*sin(sqrt(x)), x, 3),


# ::Subsection::Closed::
# The Integration-by-Parts Methods


(x*cos(x), cos(x) + x*sin(x), x, 2),
(x*log(x)^2, x^2//4 - (1//2)*x^2*log(x) + (1//2)*x^2*log(x)^2, x, 2),


# ::Subsection::Closed::
# The Derivative-divides Method


(cos(x)*(1 + sin(x)^3), sin(x) + sin(x)^4//4, x, 2),
(1/(x*(1 + log(x)^2)), atan(log(x)), x, 2),
(1/(sqrt(1 - x^2)*(1 + asin(x)^2)), atan(asin(x)), x, 2),
(sin(x)/(sin(x) + cos(x)), x/2 - (1//2)*log(cos(x) + sin(x)), x, 2),


# ::Subsection::Closed::
# An Example of SIN's Performance


(-sqrt(A^2 + B^2*(1 - y^2))/(1 - y^2), (-B)*atan((B*y)/sqrt(A^2 + B^2 - B^2*y^2)) - A*atanh((A*y)/sqrt(A^2 + B^2 - B^2*y^2)), y, 6),
((-(A^2 + B^2))*(cos(z)^2/(B*(1 - ((A^2 + B^2)/B^2)*sin(z)^2))), (-B)*z - A*atanh((A*tan(z))/B), z, 5),
(-(A^2 + B^2)/(B*(1 + w^2)^2*(1 - ((A^2 + B^2)/B^2)*(w^2/(1 + w^2)))), (-B)*atan(w) - A*atanh((A*w)/B), w, 6),
((-B)*((A^2 + B^2)/((1 + w^2)*(B^2 - A^2*w^2))), (-B)*atan(w) - A*atanh((A*w)/B), w, 4),


# ::Subsection::Closed::
# SAINT and SIN solutions of the same problem


(x^4/(1 - x^2)^(5//2), x^3/(3*(1 - x^2)^(3//2)) - x/sqrt(1 - x^2) + asin(x), x, 3),
(sin(y)^4/cos(y)^4, y - tan(y) + tan(y)^3//3, y, 3),
(z^4/(1 + z^2), -z + z^3//3 + atan(z), z, 3),


# ::Section::Closed::
# Chapter 5 - The Edge Heuristic


((2*x^2 + 1)*ℯ^x^2, ℯ^x^2*x, x, 5),
(((2*x^6 + 5*x^4 + x^3 + 4*x^2 + 1)/(x^2 + 1)^2)*ℯ^x^2, ℯ^x^2*x + ℯ^x^2/(2*(1 + x^2)), x, 10),
(1/ℯ^1/ℯ^x, -ℯ^(-1 - x), x, 1),
((x + 1/x)*log(x), -(x^2//4) + (1//2)*x^2*log(x) + log(x)^2//2, x, 5),
(x/(1 + x^4), atan(x^2)/2, x, 2),
(x^5/(1 + x^4), x^2//2 - atan(x^2)/2, x, 3),
(1/(1 + tan(x)^2), x/2 + (1//2)*cos(x)*sin(x), x, 3),
(x^4/(1 - x^2)^(5//2), x^3/(3*(1 - x^2)^(3//2)) - x/sqrt(1 - x^2) + asin(x), x, 3),
(-x^2/(1 - x^2)^(3//2), -(x/sqrt(1 - x^2)) + asin(x), x, 2),
(sin(x)*ℯ^x, (-(1//2))*ℯ^x*cos(x) + (1//2)*ℯ^x*sin(x), x, 1),


# ::Section::Closed::
# Appendix C - Slagle's Thesis Integration Problems


(1/x, log(x), x, 1),
(sec(2*t)/(1 + sec(t)^2 + 3*tan(t)), (-(1//12))*log(cos(t) - sin(t)) - (1//4)*log(cos(t) + sin(t)) + (1//3)*log(2*cos(t) + sin(t)) - 1/(2*(1 + tan(t))), t, 4),
(1/sec(x)^2, x/2 + (1//2)*cos(x)*sin(x), x, 2),
((x^2 + 1)/sqrt(x), 2*sqrt(x) + (2*x^(5//2))/5, x, 2),
(x/sqrt(x^2 + 2*x + 5), sqrt(5 + 2*x + x^2) - asinh((1 + x)/2), x, 3),
(sin(x)^2*cos(x), sin(x)^3//3, x, 2),
(ℯ^x/(1 + ℯ^x), log(1 + ℯ^x), x, 2),
(ℯ^(2*x)/(1 + ℯ^x), ℯ^x - log(1 + ℯ^x), x, 3),
(1/(1 - cos(x)), -(sin(x)/(1 - cos(x))), x, 1),
(tan(x)*sec(x)^2, sec(x)^2//2, x, 2),
(x*log(x), -(x^2//4) + (1//2)*x^2*log(x), x, 1),
(sin(x)*cos(x), sin(x)^2//2, x, 2),
((x + 1)/sqrt(2*x - x^2), -sqrt(2*x - x^2) - 2*asin(1 - x), x, 3),
(2*(ℯ^x/(2 + 3*ℯ^(2*x))), sqrt(2//3)*atan(sqrt(3//2)*ℯ^x), x, 3),
(x^4/(1 - x^2)^(5//2), x^3/(3*(1 - x^2)^(3//2)) - x/sqrt(1 - x^2) + asin(x), x, 3),
(ℯ^(6*x)/(ℯ^(4*x) + 1), ℯ^(2*x)/2 - (1//2)*atan(ℯ^(2*x)), x, 3),
(log(2 + 3*x^2), -2*x + 2*sqrt(2//3)*atan(sqrt(3//2)*x) + x*log(2 + 3*x^2), x, 3),


# ::Section::Closed::
# Appendix D - MacIntosh Integration Problems


(1/(r*sqrt(2*H*r^2 - a^2)), x/(r*sqrt(-a^2 + 2*H*r^2)), x, 1),
(1/(r*sqrt(2*H*r^2 - a^2 - e^2)), x/(r*sqrt(-a^2 - e^2 + 2*H*r^2)), x, 1),
(1/(r*sqrt(2*H*r^2 - a^2 - 2*K*r^4)), x/(r*sqrt(-a^2 + 2*H*r^2 - 2*K*r^4)), x, 1),
(1/(r*sqrt(2*H*r^2 - a^2 - e^2 - 2*K*r^4)), x/(r*sqrt(-a^2 - e^2 + 2*H*r^2 - 2*K*r^4)), x, 1),
(1/(r*sqrt(2*H*r^2 - a^2 - 2*K*r)), x/(r*sqrt(-a^2 - 2*r*(K - H*r))), x, 1),
# {1/(r*Sqrt[2*H*r^2 - a^2 - e^2 - 2*K*r]), x, 1, If[$VersionNumber>=8, x/(r*Sqrt[-a^2 - e^2 - 2*r*(K - H*r)]), x/(r*Sqrt[-a^2 - e^2 - 2*K*r + 2*H*r^2])]}
(r/sqrt(2*ℯ*r^2 - a^2), (r*x)/sqrt(-a^2 + 2*ℯ*r^2), x, 1),
(r/sqrt(2*ℯ*r^2 - a^2 - e^2), (r*x)/sqrt(-a^2 - e^2 + 2*ℯ*r^2), x, 1),
(r/sqrt(2*ℯ*r^2 - a^2 - 2*K*r^4), (r*x)/sqrt(-a^2 + 2*ℯ*r^2 - 2*K*r^4), x, 1),
(r/sqrt(2*ℯ*r^2 - a^2 - e^2 - 2*K*r^4), (r*x)/sqrt(-a^2 - e^2 + 2*ℯ*r^2 - 2*K*r^4), x, 1),
# {r/Sqrt[2*H*r^2 - a^2 - e^2 - 2*K*r], x, 1, If[$VersionNumber>=8, (r*x)/Sqrt[-a^2 - e^2 - 2*r*(K - H*r)], (r*x)/Sqrt[-a^2 - e^2 - 2*K*r + 2*H*r^2]]}
]

stewart = [
# ::Package::

# ::Title::
# James Stewart - Calculus (1987)


# ::Section::Closed::
# Section 7.1 - Integration by Parts


(x^n, x^(1 + n)/(1 + n), x, 1),
(ℯ^x, ℯ^x, x, 1),
(1/x, log(x), x, 1),
(a^x, a^x/log(a), x, 1),

(sin(x), -cos(x), x, 1),
(cos(x), sin(x), x, 1),
(sec(x)^2, tan(x), x, 2),
(csc(x)^2, -cot(x), x, 2),
(sec(x)*tan(x), sec(x), x, 2),
(csc(x)*cot(x), -csc(x), x, 2),

(sinh(x), cosh(x), x, 1),
(cosh(x), sinh(x), x, 1),
(tan(x), -log(cos(x)), x, 1),
(cot(x), log(sin(x)), x, 1),


(x*sin(x), -x*cos(x) + sin(x), x, 2),
(log(x), -x + x*log(x), x, 1),
(x^2*ℯ^x, 2*ℯ^x - 2*ℯ^x*x + ℯ^x*x^2, x, 3),
(ℯ^x*sin(x), -1//2*ℯ^x*cos(x) + (1//2)*ℯ^x*sin(x), x, 1),
(atan(x), x*atan(x) - log(1 + x^2)/2, x, 2),


(x*ℯ^(2*x), -ℯ^(2*x)/4 + (ℯ^(2*x)*x)/2, x, 2),
(x*cos(x), cos(x) + x*sin(x), x, 2),
(x*sin(4*x), -(x*cos(4*x))/4 + sin(4*x)/16, x, 2),
(x*log(x), -x^2//4 + (x^2*log(x))/2, x, 1),
(x^2*cos(3*x), (2*x*cos(3*x))/9 - (2*sin(3*x))/27 + (x^2*sin(3*x))/3, x, 3),
(x^2*sin(2*x), cos(2*x)/4 - (x^2*cos(2*x))/2 + (x*sin(2*x))/2, x, 3),
(log(x)^2, 2*x - 2*x*log(x) + x*log(x)^2, x, 2),
(asin(x), sqrt(1 - x^2) + x*asin(x), x, 2),
(t*cos(t)*sin(t), -t/4 + (cos(t)*sin(t))/4 + (t*sin(t)^2)/2, t, 3),
(t*sec(t)^2, log(cos(t)) + t*tan(t), t, 2),

(t^2*log(t), -t^3//9 + (t^3*log(t))/3, t, 1),
(t^3*ℯ^t, -6*ℯ^t + 6*ℯ^t*t - 3*ℯ^t*t^2 + ℯ^t*t^3, t, 4),
(ℯ^(2*t)*sin(3*t), (-3*ℯ^(2*t)*cos(3*t))/13 + (2*ℯ^(2*t)*sin(3*t))/13, t, 1),
(cos(3*t)/ℯ^t, -cos(3*t)/(10*ℯ^t) + (3*sin(3*t))/(10*ℯ^t), t, 1),
(y*sinh(y), y*cosh(y) - sinh(y), y, 2),
(y*cosh(a*y), -(cosh(a*y)/a^2) + (y*sinh(a*y))/a, y, 2),
(t/ℯ^t, -ℯ^(-t) - t/ℯ^t, t, 2),
(sqrt(t)*log(t), (-4*t^(3//2))/9 + (2*t^(3//2)*log(t))/3, t, 1),
(x*cos(2*x), cos(2*x)/4 + (x*sin(2*x))/2, x, 2),
(x^2/ℯ^x, -2/ℯ^x - (2*x)/ℯ^x - x^2/ℯ^x, x, 3),

(acos(x), -sqrt(1 - x^2) + x*acos(x), x, 2),
(x*csc(x)^2, -(x*cot(x)) + log(sin(x)), x, 2),
(sin(3*x)*cos(5*x), (1//4)*cos(2*x) - (1//16)*cos(8*x), x, 1),
(sin(2*x)*sin(4*x), (1//4)*sin(2*x) - (1//12)*sin(6*x), x, 1),
(cos(x)*log(sin(x)), -sin(x) + log(sin(x))*sin(x), x, 2),
(x^3*ℯ^(x^2), -ℯ^x^2//2 + (ℯ^x^2*x^2)/2, x, 2),
((3 + 2*x)*ℯ^x, -2*ℯ^x + ℯ^x*(3 + 2*x), x, 2),
(x*5^x, -(5^x/log(5)^2) + (5^x*x)/log(5), x, 2),
(cos(log(x)), (x*cos(log(x)))/2 + (x*sin(log(x)))/2, x, 1),
(ℯ^sqrt(x), -2*ℯ^sqrt(x) + 2*ℯ^sqrt(x)*sqrt(x), x, 3),

(log(sqrt(x)), -x/2 + x*log(sqrt(x)), x, 1),
(sin(log(x)), -(x*cos(log(x)))/2 + (x*sin(log(x)))/2, x, 1),
(sin(sqrt(x)), -2*sqrt(x)*cos(sqrt(x)) + 2*sin(sqrt(x)), x, 3),
(x^5*cos(x^3), cos(x^3)/3 + (x^3*sin(x^3))/3, x, 3),
(x^5*ℯ^(x^2), ℯ^x^2 - ℯ^x^2*x^2 + (ℯ^x^2*x^4)/2, x, 3),
(x*atan(x), -x/2 + atan(x)/2 + (x^2*atan(x))/2, x, 3),


(x*cos(π*x), cos(π*x)/π^2 + (x*sin(π*x))/π, x, 2),
(sqrt(x)*log(x), (-4*x^(3//2))/9 + (2*x^(3//2)*log(x))/3, x, 1),


# ::Section::Closed::
# Section 7.2 - Trigonometric Integrals


(sin(3*x)^2, x/2 - (cos(3*x)*sin(3*x))/6, x, 2),
(cos(x)^2, x/2 + (cos(x)*sin(x))/2, x, 2),
(cos(x)^4, (3*x)/8 + (3*cos(x)*sin(x))/8 + (cos(x)^3*sin(x))/4, x, 3),
(sin(x)^3, -cos(x) + cos(x)^3//3, x, 2),
(sin(x)^3*cos(x)^4, -cos(x)^5//5 + cos(x)^7//7, x, 3),
(sin(x)^4*cos(x)^3, sin(x)^5//5 - sin(x)^7//7, x, 3),
(sin(x)^4*cos(x)^2, x/16 + (cos(x)*sin(x))/16 - (cos(x)^3*sin(x))/8 - (cos(x)^3*sin(x)^3)/6, x, 4),
(sin(x)^2*cos(x)^2, x/8 + (cos(x)*sin(x))/8 - (cos(x)^3*sin(x))/4, x, 3),
((1 - sin(2*x))^2, (3*x)/2 + cos(2*x) - (cos(2*x)*sin(2*x))/4, x, 1),
(sin(x + π/6)*cos(x), x/4 - cos(π/6 + 2*x)/4, x, 3),

(cos(x)^5*sin(x)^5, sin(x)^6//6 - sin(x)^8//4 + sin(x)^10//10, x, 4),
(sin(x)^6, (5*x)/16 - (5*cos(x)*sin(x))/16 - (5*cos(x)*sin(x)^3)/24 - (cos(x)*sin(x)^5)/6, x, 4),
(cos(x)^6, (5*x)/16 + (5//16)*cos(x)*sin(x) + (5//24)*cos(x)^3*sin(x) + (1//6)*cos(x)^5*sin(x), x, 4),
(sin(2*x)^2*cos(2*x)^4, x/16 + (1//32)*cos(2*x)*sin(2*x) + (1//48)*cos(2*x)^3*sin(2*x) - (1//12)*cos(2*x)^5*sin(2*x), x, 4),
(sin(x)^5, -cos(x) + (2*cos(x)^3)/3 - cos(x)^5//5, x, 2),
(sin(x)^4*cos(x)^4, (3*x)/128 + (3//128)*cos(x)*sin(x) + (1//64)*cos(x)^3*sin(x) - (1//16)*cos(x)^5*sin(x) - (1//8)*cos(x)^5*sin(x)^3, x, 5),
(sin(x)^3*sqrt(cos(x)), (-2*cos(x)^(3//2))/3 + (2*cos(x)^(7//2))/7, x, 3),
(cos(x)^3*sqrt(sin(x)), (2//3)*sin(x)^(3//2) - (2//7)*sin(x)^(7//2), x, 3),
(cos(sqrt(x))^2/sqrt(x), sqrt(x) + cos(sqrt(x))*sin(sqrt(x)), x, 3),
(x*sin(x^2)^3, -cos(x^2)/2 + cos(x^2)^3//6, x, 3),

(cos(x)^2*tan(x)^3, cos(x)^2//2 - log(cos(x)), x, 3),
(cot(x)^5*sin(x)^2, (-(1//2))*csc(x)^2 - 2*log(sin(x)) + sin(x)^2//2, x, 4),
((1 - sin(x))/cos(x), log(1 + sin(x)), x, 2),
(1/(1 - sin(x)), cos(x)/(1 - sin(x)), x, 1),
(tan(x)^2, -x + tan(x), x, 2),
(tan(x)^4, x - tan(x) + tan(x)^3//3, x, 3),
(sec(x)^4, tan(x) + tan(x)^3//3, x, 2),
(sec(x)^6, tan(x) + (2*tan(x)^3)/3 + tan(x)^5//5, x, 2),
(tan(x)^4*sec(x)^2, tan(x)^5//5, x, 2),
(tan(x)^2*sec(x)^4, tan(x)^3//3 + tan(x)^5//5, x, 3),

(tan(x)*sec(x)^3, sec(x)^3//3, x, 2),
(tan(x)^3*sec(x)^3, -sec(x)^3//3 + sec(x)^5//5, x, 3),
(tan(x)^5, -log(cos(x)) - tan(x)^2//2 + tan(x)^4//4, x, 3),
(tan(x)^6, -x + tan(x) - tan(x)^3//3 + tan(x)^5//5, x, 4),
(tan(x)^5*sec(x), sec(x) - (2*sec(x)^3)/3 + sec(x)^5//5, x, 3),
(tan(x)^5*sec(x)^3, sec(x)^3//3 - (2*sec(x)^5)/5 + sec(x)^7//7, x, 3),
(tan(x)*sec(x)^6, sec(x)^6//6, x, 2),
(tan(x)^3*sec(x)^6, (-(1//6))*sec(x)^6 + sec(x)^8//8, x, 3),
(sec(x)^2/cot(x), sec(x)^2//2, x, 2),
(sec(x)*tan(x)^2, -atanh(sin(x))/2 + (sec(x)*tan(x))/2, x, 2),

(cot(x)^2, -x - cot(x), x, 2),
(cot(x)^3, -cot(x)^2//2 - log(sin(x)), x, 2),
(cot(x)^4*csc(x)^4, -cot(x)^5//5 - cot(x)^7//7, x, 3),
(cot(x)^3*csc(x)^4, csc(x)^4//4 - csc(x)^6//6, x, 3),
(csc(x), -atanh(cos(x)), x, 1),
(csc(x)^3, -atanh(cos(x))/2 - (cot(x)*csc(x))/2, x, 2),
(cos(x)^2/sin(x), -atanh(cos(x)) + cos(x), x, 3),
(1/sin(x)^4, -cot(x) - cot(x)^3//3, x, 2),
(sin(5*x)*sin(2*x), sin(3*x)/6 - sin(7*x)/14, x, 1),
(sin(3*x)*cos(x), -cos(2*x)/4 - cos(4*x)/8, x, 1),

(cos(3*x)*cos(4*x), sin(x)/2 + sin(7*x)/14, x, 1),
(sin(3*x)*sin(6*x), sin(3*x)/6 - sin(9*x)/18, x, 1),
(sin(x)*cos(x)^5, (-(1//6))*cos(x)^6, x, 2),
(cos(x)*cos(2*x)*cos(3*x), x/4 + (1//8)*sin(2*x) + (1//16)*sin(4*x) + (1//24)*sin(6*x), x, 5),
((1 - tan(x)^2)/sec(x)^2, cos(x)*sin(x), x, 2),
((cos(x) + sin(x))/sin(2*x), -atanh(cos(x))/2 + atanh(sin(x))/2, x, 6),

(sin(x)^2*tan(x), cos(x)^2//2 - log(cos(x)), x, 3),
(cos(x)^2*cot(x)^3, -csc(x)^2//2 - 2*log(sin(x)) + sin(x)^2//2, x, 4),
(sec(x)^3*tan(x), sec(x)^3//3, x, 2),
(sec(x)^3*tan(x)^3, -sec(x)^3//3 + sec(x)^5//5, x, 3),


# ::Section::Closed::
# Section 7.3 - Trigonometric Substitution


(sqrt(9 - x^2)/x^2, -(sqrt(9 - x^2)/x) - asin(x/3), x, 2),
(1/(x^2*sqrt(4 + x^2)), -sqrt(4 + x^2)/(4*x), x, 1),
(x/sqrt(4 + x^2), sqrt(4 + x^2), x, 1),
(1/sqrt(-a^2 + x^2), atanh(x/sqrt(-a^2 + x^2)), x, 2),
(x^3/(9 + 4*x^2)^(3//2), 9/(16*sqrt(9 + 4*x^2)) + sqrt(9 + 4*x^2)/16, x, 3),
(x/sqrt(3 - 2*x - x^2), -sqrt(3 - 2*x - x^2) + asin((-1 - x)/2), x, 3),


(1/(x^2*sqrt(1 - x^2)), -(sqrt(1 - x^2)/x), x, 1),
(x^3*sqrt(4 - x^2), (-4*(4 - x^2)^(3//2))/3 + (4 - x^2)^(5//2)/5, x, 3),
(x/sqrt(1 - x^2), -sqrt(1 - x^2), x, 1),
(x*sqrt(4 - x^2), -(4 - x^2)^(3//2)/3, x, 1),
(sqrt(1 - 4*x^2), (x*sqrt(1 - 4*x^2))/2 + asin(2*x)/4, x, 2),
(x^3/sqrt(x^2 + 4), -4*sqrt(4 + x^2) + (1//3)*(4 + x^2)^(3//2), x, 3),
(1/sqrt(9 + x^2), asinh(x/3), x, 1),
(sqrt(x^2 + 1), (x*sqrt(1 + x^2))/2 + asinh(x)/2, x, 2),
(1/(x^3*sqrt(x^2 - 16)), sqrt(-16 + x^2)/(32*x^2) + atan(sqrt(-16 + x^2)/4)/128, x, 4),
(sqrt(x^2 - a^2)/x^4, (-a^2 + x^2)^(3//2)/(3*a^2*x^3), x, 1),

(sqrt(9*x^2 - 4)/x, sqrt(-4 + 9*x^2) - 2*atan(sqrt(-4 + 9*x^2)/2), x, 4),
(1/(x^2*sqrt(16*x^2 - 9)), sqrt(-9 + 16*x^2)/(9*x), x, 1),
(x^2/(a^2 - x^2)^(3//2), x/sqrt(a^2 - x^2) - atan(x/sqrt(a^2 - x^2)), x, 3),
(x^2/sqrt(5 - x^2), -(x*sqrt(5 - x^2))/2 + (5*asin(x/sqrt(5)))/2, x, 2),
(1/(x*sqrt(3 + x^2)), -(atanh(sqrt(3 + x^2)/sqrt(3))/sqrt(3)), x, 3),
(x/(x^2 + 4)^(5//2), -1/(3*(4 + x^2)^(3//2)), x, 1),
(x^3*sqrt(4 - 9*x^2), (-4*(4 - 9*x^2)^(3//2))/243 + (4 - 9*x^2)^(5//2)/405, x, 3),
(x^2*sqrt(9 - x^2), (-9*x*sqrt(9 - x^2))/8 + (x^3*sqrt(9 - x^2))/4 + (81*asin(x/3))/8, x, 3),
(5*x*sqrt(1 + x^2), (5*(1 + x^2)^(3//2))/3, x, 2),
(1/(4*x^2 - 25)^(3//2), -x/(25*sqrt(-25 + 4*x^2)), x, 1),

(sqrt(2*x - x^2), (-(1//2))*(1 - x)*sqrt(2*x - x^2) - (1//2)*asin(1 - x), x, 3),
(1/sqrt(x^2 + 4*x + 8), asinh((2 + x)/2), x, 2),
(1/sqrt(9*x^2 + 6*x - 8), atanh((1 + 3*x)/sqrt(-8 + 6*x + 9*x^2))/3, x, 2),
(x^2/sqrt(4*x - x^2), -3*sqrt(4*x - x^2) - (1//2)*x*sqrt(4*x - x^2) - 6*asin(1 - x/2), x, 4),
(1/(2 + 2*x + x^2)^2, (1 + x)/(2*(2 + 2*x + x^2)) + atan(1 + x)/2, x, 3),
(1/(5 - 4*x - x^2)^(5//2), (2 + x)/(27*(5 - 4*x - x^2)^(3//2)) + (2*(2 + x))/(243*sqrt(5 - 4*x - x^2)), x, 2),
(ℯ^t*sqrt(9 - ℯ^(2*t)), (ℯ^t*sqrt(9 - ℯ^(2*t)))/2 + (9*asin(ℯ^t/3))/2, t, 3),
(sqrt(ℯ^(2*t) - 9), sqrt(-9 + ℯ^(2*t)) - 3*atan(sqrt(-9 + ℯ^(2*t))/3), t, 4),


# ::Section::Closed::
# Section 7.4 - Integration of Rational Functions by Partial Fractions


(1/sqrt(a^2 + x^2), atanh(x/sqrt(a^2 + x^2)), x, 2),
((5 + x)/(-2 + x + x^2), 2*log(1 - x) - log(2 + x), x, 3),
((x + x^3)/(-1 + x), 2*x + x^2//2 + x^3//3 + 2*log(1 - x), x, 3),
((-1 + 2*x + x^2)/(-2*x + 3*x^2 + 2*x^3), log(1 - 2*x)/10 + log(x)/2 - log(2 + x)/10, x, 3),
((1 + 4*x - 2*x^2 + x^4)/(1 - x - x^2 + x^3), 2/(1 - x) + x + x^2//2 + log(1 - x) - log(1 + x), x, 2),
((4 - x + 2*x^2)/(4*x + x^3), -atan(x/2)/2 + log(x) + log(4 + x^2)/2, x, 6),
((2 - 3*x + 4*x^2)/(3 - 4*x + 4*x^2), x + atan((1 - 2*x)/sqrt(2))/(4*sqrt(2)) + log(3 - 4*x + 4*x^2)/8, x, 6),
((1 + x^2 + x^3)/((-1 + x)*x*(1 + x^2)^3*(1 + x + x^2)), (1 + x)/(8*(1 + x^2)^2) - (3*(1 - x))/(8*(1 + x^2)) + (3*x)/(16*(1 + x^2)) + (7*atan(x))/16 - atan((1 + 2*x)/sqrt(3))/sqrt(3) + log(1 - x)/8 - log(x) + (15*log(1 + x^2))/16 - log(1 + x + x^2)/2, x, 14),
((1 - 3*x + 2*x^2 - x^3)/(x*(x^2 + 1)^2), -((1 + 2*x)/(2*(1 + x^2))) - 2*atan(x) + log(x) - (1//2)*log(1 + x^2), x, 6),
(1/(x^2 + 1)^2, x/(2*(1 + x^2)) + atan(x)/2, x, 2),


(1/((x - 1)*(2 + x)), log(1 - x)/3 - log(2 + x)/3, x, 3),
(7/(-12 + 5*x + 2*x^2), (7*log(3 - 2*x))/11 - (7*log(4 + x))/11, x, 4),
((-4 + 3*x + x^2)/((-1 + 2*x)^2*(3 + 2*x)), -9/(32*(1 - 2*x)) + (41*log(1 - 2*x))/128 - (25*log(3 + 2*x))/128, x, 2),
((-x^2 + x^3)/((-6 + x)*(3 + 5*x)^3), -12/(1375*(3 + 5*x)^2) + 201/(15125*(3 + 5*x)) + (20*log(6 - x))/3993 + (1493*log(3 + 5*x))/499125, x, 3),
(1/(-x^3 + x^4), 1/(2*x^2) + 1/x + log(1 - x) - log(x), x, 3),
((1 - x - x^2 + x^3 + x^4)/(-x + x^3), x + x^2//2 - log(x) + log(1 - x^2)/2, x, 4),

((x^2 - 2)/(x*(x^2 + 2)), -log(x) + log(2 + x^2), x, 3),
((2 - 4*x^2 + x^3)/((1 + x^2)*(2 + x^2)), 6*atan(x) - 5*sqrt(2)*atan(x/sqrt(2)) - log(1 + x^2)/2 + log(2 + x^2), x, 8),
((1 + x^2 + x^4)/((1 + x^2)*(4 + x^2)^2), (-13*x)/(24*(4 + x^2)) + (25*atan(x/2))/144 + atan(x)/9, x, 6),
((1 + 16*x)/((5 + x)^2*(-3 + 2*x)*(1 + x + x^2)), -79/(273*(5 + x)) + (451*atan((1 + 2*x)/sqrt(3)))/(2793*sqrt(3)) + (200*log(3 - 2*x))/3211 + (2731*log(5 + x))/24843 - (481*log(1 + x + x^2))/5586, x, 6),
(x^4/(9 + x^2)^3, -x^3/(4*(9 + x^2)^2) - (3*x)/(8*(9 + x^2)) + atan(x/3)/8, x, 3),
((19*x)/((-1 + x)^3*(3 + 5*x + 4*x^2)^2), -399/(736*(1 - x)^2) - 1843/(4416*(1 - x)) + (19*(39 + 44*x))/(276*(1 - x)^2*(3 + 5*x + 4*x^2)) + (114437*atan((5 + 8*x)/sqrt(23)))/(52992*sqrt(23)) + (209*log(1 - x))/2304 - (209*log(3 + 5*x + 4*x^2))/4608, x, 8),
((1 + x^2 + x^3)/(2*x^2 + x^3 + x^4), -1/(2*x) + atan((1 + 2*x)/sqrt(7))/(4*sqrt(7)) - log(x)/4 + (5*log(2 + x + x^2))/8, x, 7),
(1/(-x^3 + x^6), 1/(2*x^2) - atan((1 + 2*x)/sqrt(3))/sqrt(3) + log(1 - x)/3 - log(1 + x + x^2)/6, x, 8),
(x^2/(1 + x), -x + x^2//2 + log(1 + x), x, 2),
(x/(-5 + x), x + 5*log(5 - x), x, 2),

((-1 + 4*x)/((-1 + x)*(2 + x)), log(1 - x) + 3*log(2 + x), x, 2),
(1/((1 + x)*(2 + x)), log(1 + x) - log(2 + x), x, 3),
((-5 + 6*x)/(3 + 2*x), 3*x - 7*log(3 + 2*x), x, 2),
(1/((a + x)*(b + x)), -(log(a + x)/(a - b)) + log(b + x)/(a - b), x, 3),
((1 + x^2)/(-x + x^2), x + 2*log(1 - x) - log(x), x, 3),
((1 - 12*x + x^2 + x^3)/(-12 + x + x^2), x^2//2 + log(3 - x)/7 - log(4 + x)/7, x, 5),
((3 + 2*x)/(1 + x)^2, -(1 + x)^(-1) + 2*log(1 + x), x, 2),
(1/(x*(1 + x)*(3 + 2*x)), log(x)/3 - log(1 + x) + (2*log(3 + 2*x))/3, x, 2),

((-3 + 5*x + 6*x^2)/(-3*x + 2*x^2 + x^3), 2*log(1 - x) + log(x) + 3*log(3 + x), x, 3),
(x/(4 + 4*x + x^2), 2/(2 + x) + log(2 + x), x, 3),
(1/((-1 + x)^2*(4 + x)), 1/(5*(1 - x)) - log(1 - x)/25 + log(4 + x)/25, x, 2),
(x^2/((-3 + x)*(2 + x)^2), 4/(5*(2 + x)) + (9*log(3 - x))/25 + (16*log(2 + x))/25, x, 2),
((-2 + 3*x + 5*x^2)/(2*x^2 + x^3), x^(-1) + 2*log(x) + 3*log(2 + x), x, 3),
((18 - 2*x - 4*x^2)/(-6 + x + 4*x^2 + x^3), log(1 - x) - 2*log(2 + x) - 3*log(3 + x), x, 2),
((2*x + x^2)/(4 + 3*x^2 + x^3), log(4 + 3*x^2 + x^3)/3, x, 1),
(1/((-1 + x)^2*x^2), (1 - x)^(-1) - x^(-1) - 2*log(1 - x) + 2*log(x), x, 2),

(x^2/(1 + x)^3, -1/(2*(1 + x)^2) + 2/(1 + x) + log(1 + x), x, 2),
(1/(-x^2 + x^4), x^(-1) - atanh(x), x, 3),
((-x + 2*x^3)/(1 - x^2 + x^4), log(1 - x^2 + x^4)/2, x, 1),
(x^3/(1 + x^2), x^2//2 - log(1 + x^2)/2, x, 3),
((-1 + x)/(2 + 2*x + x^2), -2*atan(1 + x) + log(2 + 2*x + x^2)/2, x, 4),

(x/(1 + x + x^2), -(atan((1 + 2*x)/sqrt(3))/sqrt(3)) + log(1 + x + x^2)/2, x, 4),
((7 + 5*x + 4*x^2)/(5 + 4*x + 4*x^2), x + (3//8)*atan(1//2 + x) + (1//8)*log(5 + 4*x + 4*x^2), x, 6),
((5 - 4*x + 3*x^2)/((-1 + x)*(1 + x^2)), -3*atan(x) + 2*log(1 - x) + log(1 + x^2)/2, x, 5),
((3 + 2*x)/(3*x + x^3), (2*atan(x/sqrt(3)))/sqrt(3) + log(x) - log(3 + x^2)/2, x, 6),
(1/(-1 + x^3), -(atan((1 + 2*x)/sqrt(3))/sqrt(3)) + log(1 - x)/3 - log(1 + x + x^2)/6, x, 6),
(x^3/(1 + x^3), x + atan((1 - 2*x)/sqrt(3))/sqrt(3) - log(1 + x)/3 + log(1 - x + x^2)/6, x, 7),
((-1 - 2*x + x^2)/((-1 + x)^2*(1 + x^2)), (-1 + x)^(-1) + atan(x) + log(1 - x) - log(1 + x^2)/2, x, 5),
(x^4/(-1 + x^4), x - atan(x)/2 - atanh(x)/2, x, 4),

((-4 + 6*x - x^2 + 3*x^3)/((1 + x^2)*(2 + x^2)), -3*atan(x) + sqrt(2)*atan(x/sqrt(2)) + (3*log(1 + x^2))/2, x, 6),
((1 + x - 2*x^2 + x^3)/(4 + 5*x^2 + x^4), (-3*atan(x/2))/2 + atan(x) + log(4 + x^2)/2, x, 7),
((-3 + x)/(4 + 2*x + x^2)^2, -(7 + 4*x)/(6*(4 + 2*x + x^2)) - (2*atan((1 + x)/sqrt(3)))/(3*sqrt(3)), x, 3),
((1 + x^4)/(x*(1 + x^2)^2), (1 + x^2)^(-1) + log(x), x, 3),
((cos(x)*(-3 + 2*sin(x)))/(2 - 3*sin(x) + sin(x)^2), log(2 - 3*sin(x) + sin(x)^2), x, 2),
((cos(x)^2*sin(x))/(5 + cos(x)^2), sqrt(5)*atan(cos(x)/sqrt(5)) - cos(x), x, 3),

(1/(x^2 + 2*x - 3), log(1 - x)/4 - log(3 + x)/4, x, 3),
(1/(x^2 - 2*x), log(2 - x)/2 - log(x)/2, x, 1),
((2*x + 1)/(4*x^2 + 12*x - 7), log(1 - 2*x)/8 + (3*log(7 + 2*x))/8, x, 3),
(x/(x^2 + x - 1), ((5 - sqrt(5))*log(1 - sqrt(5) + 2*x))/10 + ((5 + sqrt(5))*log(1 + sqrt(5) + 2*x))/10, x, 3),


# ::Section::Closed::
# Section 7.5 - Rationalization Substitutions


((-32 + 5*x - 27*x^2 + 4*x^3)/(-70 - 299*x - 286*x^2 + 50*x^3 - 13*x^4 + 30*x^5), (3988*atan((1 + 2*x)/sqrt(19)))/(13685*sqrt(19)) - (3146*log(7 - 3*x))/80155 - (334*log(1 + 2*x))/323 + (4822*log(2 + 5*x))/4879 + (11049*log(5 + x + x^2))/260015, x, 6),
((8 - 13*x^2 - 7*x^3 + 12*x^5)/(4 - 20*x + 41*x^2 - 80*x^3 + 116*x^4 - 80*x^5 + 100*x^6), 5828/(9075*(2 - 5*x)) - (313 + 502*x)/(1452*(1 + 2*x^2)) - (251*atan(sqrt(2)*x))/(726*sqrt(2)) + (272*sqrt(2)*atan(sqrt(2)*x))/1331 - (59096*log(2 - 5*x))/99825 + (2843*log(1 + 2*x^2))/7986, x, 7),
(sqrt(4 + x)/x, 2*sqrt(4 + x) - 4*atanh(sqrt(4 + x)/2), x, 3),
(1/(-x^(-1//3) + sqrt(x)), 2*sqrt(x) + (3//5)*sqrt(2*(5 - sqrt(5)))*atan((1 - sqrt(5) + 4*x^(1//6))/sqrt(2*(5 + sqrt(5)))) - (3//5)*sqrt(2*(5 + sqrt(5)))*atan((1//2)*sqrt((1//10)*(5 + sqrt(5)))*(1 + sqrt(5) + 4*x^(1//6))) + (6//5)*log(1 - x^(1//6)) - (3//10)*(1 + sqrt(5))*log(2 + x^(1//6) - sqrt(5)*x^(1//6) + 2*x^(1//3)) - (3//10)*(1 - sqrt(5))*log(2 + x^(1//6) + sqrt(5)*x^(1//6) + 2*x^(1//3)), x, 9),
(1/(-4*cos(x) + 3*sin(x)), -atanh((3*cos(x) + 4*sin(x))/5)/5, x, 2),

(1/(1 + sqrt(x)), 2*sqrt(x) - 2*log(1 + sqrt(x)), x, 3),
(1/(1 + x^(-1//3)), 3*x^(1//3) - (3*x^(2//3))/2 + x - 3*log(1 + 1/x^(1//3)) - log(x), x, 3),
(sqrt(x)/(1 + x), 2*sqrt(x) - 2*atan(sqrt(x)), x, 3),
(1/(x*sqrt(1 + x)), -2*atanh(sqrt(1 + x)), x, 2),
(1/(-x^(1//3) + x), (3*log(1 - x^(2//3)))/2, x, 2),
(1/(x - sqrt(2 + x)), (4*log(2 - sqrt(2 + x)))/3 + (2*log(1 + sqrt(2 + x)))/3, x, 4),
(x^2/sqrt(-1 + x), 2*sqrt(-1 + x) + (4*(-1 + x)^(3//2))/3 + (2*(-1 + x)^(5//2))/5, x, 2),
(sqrt(-1 + x)/(1 + x), 2*sqrt(-1 + x) - 2*sqrt(2)*atan(sqrt(-1 + x)/sqrt(2)), x, 3),
(1/sqrt(1 + sqrt(x)), -4*sqrt(1 + sqrt(x)) + (4*(1 + sqrt(x))^(3//2))/3, x, 3),
(sqrt(x)/(x + x^2), 2*atan(sqrt(x)), x, 3),
((1 + sqrt(x))/(-1 + sqrt(x)), 4*sqrt(x) + x + 4*log(1 - sqrt(x)), x, 3),
((1 + x^(-1//3))/(-1 + x^(-1//3)), -6*x^(1//3) - 3*x^(2//3) - x - 6*log(1 - x^(1//3)), x, 4),
(x^3/(1 + x^2)^(1//3), (-(3//4))*(1 + x^2)^(2//3) + (3//10)*(1 + x^2)^(5//3), x, 3),
(sqrt(x)/(-x^(-1//3) + sqrt(x)), 6*x^(1//6) + x - (3//5)*sqrt(2*(5 + sqrt(5)))*atan((1 - sqrt(5) + 4*x^(1//6))/sqrt(2*(5 + sqrt(5)))) - (3//5)*sqrt(2*(5 - sqrt(5)))*atan((1//2)*sqrt((1//10)*(5 + sqrt(5)))*(1 + sqrt(5) + 4*x^(1//6))) + (6//5)*log(1 - x^(1//6)) - (3//10)*(1 - sqrt(5))*log(2 + x^(1//6) - sqrt(5)*x^(1//6) + 2*x^(1//3)) - (3//10)*(1 + sqrt(5))*log(2 + x^(1//6) + sqrt(5)*x^(1//6) + 2*x^(1//3)), x, 10),
(1/(x^(-1//4) + sqrt(x)), 2*sqrt(x) + (4*atan((1 - 2*x^(1//4))/sqrt(3)))/sqrt(3) + (4*log(1 + x^(1//4)))/3 - (2*log(1 - x^(1//4) + sqrt(x)))/3, x, 9),
(1/(x^(-1//3) + x^(-1//4)), 12*x^(1//12) - 6*x^(1//6) + 4*x^(1//4) - 3*x^(1//3) + (12*x^(5//12))/5 - 2*sqrt(x) + (12*x^(7//12))/7 - (3*x^(2//3))/2 + (4*x^(3//4))/3 - (6*x^(5//6))/5 + (12*x^(11//12))/11 - x + (12*x^(13//12))/13 - (6*x^(7//6))/7 + (4*x^(5//4))/5 - 12*log(1 + x^(1//12)), x, 4),
(sqrt((1 - x)/x), sqrt(-1 + x^(-1))*x - atan(sqrt(-1 + x^(-1))), x, 5),
(cos(x)/(sin(x) + sin(x)^2), log(sin(x)) - log(1 + sin(x)), x, 2),
(ℯ^(2*x)/(2 + 3*ℯ^x + ℯ^(2*x)), -log(1 + ℯ^x) + 2*log(2 + ℯ^x), x, 4),
(1/sqrt(1 + ℯ^x), -2*atanh(sqrt(1 + ℯ^x)), x, 3),
(sqrt(1 - ℯ^x), 2*sqrt(1 - ℯ^x) - 2*atanh(sqrt(1 - ℯ^x)), x, 4),
(1/(3 - 5*sin(x)), -log(cos(x/2) - 3*sin(x/2))/4 + log(3*cos(x/2) - sin(x/2))/4, x, 4),
(1/(cos(x) + sin(x)), -(atanh((cos(x) - sin(x))/sqrt(2))/sqrt(2)), x, 2),
(1/(1 - cos(x) + sin(x)), -log(1 + cot(x/2)), x, 2),
(1/(4*cos(x) + 3*sin(x)), -atanh((3*cos(x) - 4*sin(x))/5)/5, x, 2),
(1/(sin(x) + tan(x)), -atanh(cos(x))/2 + (cot(x)*csc(x))/2 - csc(x)^2//2, x, 6),
(1/(2*sin(x) + sin(2*x)), log(tan(x/2))/4 + tan(x/2)^2//8, x, 4),
(sec(x)/(1 + sin(x)), atanh(sin(x))/2 - 1/(2*(1 + sin(x))), x, 4),
(1/(b*cos(x) + a*sin(x)), -(atanh((a*cos(x) - b*sin(x))/sqrt(a^2 + b^2))/sqrt(a^2 + b^2)), x, 2),
(1/(b^2*cos(x)^2 + a^2*sin(x)^2), atan((a*tan(x))/b)/(a*b), x, 2),


# ::Section::Closed::
# Section 7.6 - Strategy for Integration


(x/(-1 + x^2), log(1 - x^2)/2, x, 1),
((1 + sqrt(x))*sqrt(x), (2*x^(3//2))/3 + x^2//2, x, 2),
(1/(1 - cos(x)), -(sin(x)/(1 - cos(x))), x, 1),
(sec(x)*tan(x)^2, -atanh(sin(x))/2 + (sec(x)*tan(x))/2, x, 2),
(sec(x)^3*tan(x)^3, -sec(x)^3//3 + sec(x)^5//5, x, 3),
(ℯ^sqrt(x), -2*ℯ^sqrt(x) + 2*ℯ^sqrt(x)*sqrt(x), x, 3),
((1 + x^5)/(-10*x - 3*x^2 + x^3), 19*x + (3*x^2)/2 + x^3//3 + (3126*log(5 - x))/35 - log(x)/10 - (31*log(2 + x))/14, x, 3),
(1/(x*sqrt(log(x))), 2*sqrt(log(x)), x, 2),
((5 + 2*x)/(-3 + x), 2*x + 11*log(3 - x), x, 2),
(ℯ^(ℯ^x + x), ℯ^ℯ^x, x, 2),

(cos(x)^2*sin(x)^2, x/8 + (cos(x)*sin(x))/8 - (cos(x)^3*sin(x))/4, x, 3),
((-cos(x) + sin(x))/(cos(x) + sin(x)), -log(cos(x) + sin(x)), x, 1),
(x/sqrt(1 - x^2), -sqrt(1 - x^2), x, 1),
(x^3*log(x), -x^4//16 + (x^4*log(x))/4, x, 1),
(sqrt(-2 + x)/(2 + x), 2*sqrt(-2 + x) - 4*atan(sqrt(-2 + x)/2), x, 3),
(x/(2 + x)^2, 2/(2 + x) + log(2 + x), x, 2),
(log(1 + x^2), -2*x + 2*atan(x) + x*log(1 + x^2), x, 3),
(sqrt(1 + log(x))/(x*log(x)), -2*atanh(sqrt(1 + log(x))) + 2*sqrt(1 + log(x)), x, 4),
((1 + sqrt(x))^8, (-2*(1 + sqrt(x))^9)/9 + (1 + sqrt(x))^10//5, x, 3),
(sec(x)^4*tan(x)^3, (-(1//4))*sec(x)^4 + sec(x)^6//6, x, 3),

(x/(2 - 2*x + x^2), -atan(1 - x) + log(2 - 2*x + x^2)/2, x, 4),
(x*asin(x), (x*sqrt(1 - x^2))/4 - asin(x)/4 + (x^2*asin(x))/2, x, 3),
(sqrt(9 - x^2)/x, sqrt(9 - x^2) - 3*atanh(sqrt(9 - x^2)/3), x, 4),
(x/(2 + 3*x + x^2), -log(1 + x) + 2*log(2 + x), x, 3),
(x^2*cosh(x), -2*x*cosh(x) + 2*sinh(x) + x^2*sinh(x), x, 3),
((1 + x + x^3)/(4*x + 2*x^2 + x^4), log(4*x + 2*x^2 + x^4)/4, x, 1),
(cos(x)/(1 + sin(x)^2), atan(sin(x)), x, 2),
(cos(sqrt(x)), 2*cos(sqrt(x)) + 2*sqrt(x)*sin(sqrt(x)), x, 3),
(sin(π*x), -(cos(π*x)/π), x, 1),
(ℯ^(2*x)/(1 + ℯ^x), ℯ^x - log(1 + ℯ^x), x, 3),

(ℯ^(3*x)*cos(5*x), (3*ℯ^(3*x)*cos(5*x))/34 + (5*ℯ^(3*x)*sin(5*x))/34, x, 1),
(cos(3*x)*cos(5*x), sin(2*x)/4 + sin(8*x)/16, x, 1),
(1/(1 + x + x^2 + x^3), atan(x)/2 + log(1 + x)/2 - log(1 + x^2)/4, x, 5),
(x^2*log(1 + x), -x/3 + x^2//6 - x^3//9 + log(1 + x)/3 + (x^3*log(1 + x))/3, x, 3),
(x^5/ℯ^x^3, -1/(3*ℯ^x^3) - x^3/(3*ℯ^x^3), x, 2),
(tan(4*x)^2, -x + tan(4*x)/4, x, 2),
(1/sqrt(-5 + 12*x + 9*x^2), atanh((2 + 3*x)/sqrt(-5 + 12*x + 9*x^2))/3, x, 2),
(x^2*atan(x), -x^2//6 + (x^3*atan(x))/3 + log(1 + x^2)/6, x, 4),
((1 - sqrt(x))/x^(1//3), (3*x^(2//3))/2 - (6*x^(7//6))/7, x, 2),
(1/(-ℯ^(-x) + ℯ^x), -atanh(ℯ^x), x, 2),
(x/(10 + 2*x^2 + x^4), (1//6)*atan((1//3)*(1 + x^2)), x, 3),

(1/(x^(-1//3) + x), (3*log(1 + x^(4//3)))/4, x, 2),
(cos(x)^4*sin(x)^2, x/16 + (cos(x)*sin(x))/16 + (cos(x)^3*sin(x))/24 - (cos(x)^5*sin(x))/6, x, 4),
(1/sqrt(5 - 4*x - x^2), -asin((-2 - x)/3), x, 2),
(x/(1 - x^2 + sqrt(1 - x^2)), -log(1 + sqrt(1 - x^2)), x, 3),
((1 + cos(x))*csc(x), log(1 - cos(x)), x, 2),
(ℯ^x/(-1 + ℯ^(2*x)), -atanh(ℯ^x), x, 2),
(1/(-8 + x^3), -atan((1 + x)/sqrt(3))/(4*sqrt(3)) + log(2 - x)/12 - log(4 + 2*x + x^2)/24, x, 6),
(x^5*cosh(x), -120*cosh(x) - 60*x^2*cosh(x) - 5*x^4*cosh(x) + 120*x*sinh(x) + 20*x^3*sinh(x) + x^5*sinh(x), x, 6),
(log(tan(x))/(sin(x)*cos(x)), log(tan(x))^2//2, x, 1),

(-2*x + x^2 + x^3, -x^2 + x^3//3 + x^4//4, x, 1),
((1 + ℯ^x)/(1 - ℯ^x), x - 2*log(1 - ℯ^x), x, 3),
(x/((1 + x^2)*(4 + x^2)), log(1 + x^2)/6 - log(4 + x^2)/6, x, 4),
(1/(4 - 5*sin(x)), -log(cos(x/2) - 2*sin(x/2))/3 + log(2*cos(x/2) - sin(x/2))/3, x, 4),
(x*(c + x)^(1//3), (-3*c*(c + x)^(4//3))/4 + (3*(c + x)^(7//3))/7, x, 2),
(ℯ^x^(1//3), 6*ℯ^x^(1//3) - 6*ℯ^x^(1//3)*x^(1//3) + 3*ℯ^x^(1//3)*x^(2//3), x, 4),
(1/(4 + x + sqrt(1 + x)), (-2*atan((1 + 2*sqrt(1 + x))/sqrt(11)))/sqrt(11) + log(4 + x + sqrt(1 + x)), x, 5),
((1 + x^3)/(-x^2 + x^3), 1/x + x + 2*log(1 - x) - log(x), x, 3),

((-3 + 4*x + x^2)*sin(2*x), (7*cos(2*x))/4 - 2*x*cos(2*x) - (x^2*cos(2*x))/2 + sin(2*x) + (x*sin(2*x))/2, x, 8),
(cos(cos(x))*sin(x), -sin(cos(x)), x, 2),
(1/sqrt(16 - x^2), asin(x/4), x, 1),
(x^3/(1 + x)^10, 1/(9*(1 + x)^9) - 3/(8*(1 + x)^8) + 3/(7*(1 + x)^7) - 1/(6*(1 + x)^6), x, 2),
(cot(2*x)^3*csc(2*x)^3, csc(2*x)^3//6 - csc(2*x)^5//10, x, 3),
((x + sin(x))^2, x/2 + x^3//3 - 2*x*cos(x) + 2*sin(x) - (cos(x)*sin(x))/2, x, 6),
(ℯ^atan(x)/(1 + x^2), ℯ^atan(x), x, 1),
(1/(x*(1 + x^4)), log(x) - log(1 + x^4)/4, x, 4),
(t^3/ℯ^(2*t), -3/(8*ℯ^(2*t)) - (3*t)/(4*ℯ^(2*t)) - (3*t^2)/(4*ℯ^(2*t)) - t^3/(2*ℯ^(2*t)), t, 4),
(sqrt(t)/(1 + t^(1//3)), -6*t^(1//6) + 2*sqrt(t) - (6*t^(5//6))/5 + (6*t^(7//6))/7 + 6*atan(t^(1//6)), t, 7),

(sin(x)*sin(2*x)*sin(3*x), -cos(2*x)/8 - cos(4*x)/16 + cos(6*x)/24, x, 5),
(log(x/2), -x + x*log(x/2), x, 1),
(sqrt((1 + x)/(1 - x)), -((1 - x)*sqrt((1 + x)/(1 - x))) + 2*atan(sqrt((1 + x)/(1 - x))), x, 3),
((x*log(x))/sqrt(-1 + x^2), -sqrt(-1 + x^2) + atan(sqrt(-1 + x^2)) + sqrt(-1 + x^2)*log(x), x, 5),
((a + x)/(a^2 + x^2), atan(x/a) + log(a^2 + x^2)/2, x, 3),
(sqrt(1 + x - x^2), -((1 - 2*x)*sqrt(1 + x - x^2))/4 - (5*asin((1 - 2*x)/sqrt(5)))/8, x, 3),
(x^4/(16 + x^10), atan(x^5//4)/20, x, 2),
((2 + x)/(2 + x + x^2), (3*atan((1 + 2*x)/sqrt(7)))/sqrt(7) + log(2 + x + x^2)/2, x, 4),

(x*sec(x)*tan(x), -atanh(sin(x)) + x*sec(x), x, 2),
(x/(-a^4 + x^4), -atanh(x^2/a^2)/(2*a^2), x, 2),
(1/(sqrt(x) + sqrt(1 + x)), (-2*x^(3//2))/3 + (2*(1 + x)^(3//2))/3, x, 3),
(1/(1 - ℯ^(-x) + 2*ℯ^x), log(1 - 2*ℯ^x)/3 - log(1 + ℯ^x)/3, x, 4),
(atan(sqrt(x))/sqrt(x), 2*sqrt(x)*atan(sqrt(x)) - log(1 + x), x, 2),
(log(1 + x)/x^2, log(x) - log(1 + x) - log(1 + x)/x, x, 4),
(1/(-ℯ^x + ℯ^(3*x)), ℯ^(-x) - atanh(ℯ^x), x, 3),
((1 + cos(x)^2)/(1 - cos(x)^2), -x - 2*cot(x), x, 4),


# ::Section::Closed::
# Section 7.?


(1/(x*sqrt(-25 + 2*x)), (2*atan(sqrt(-25 + 2*x)/5))/5, x, 2),
(sin(2*x)/sqrt(9 - cos(x)^4), -asin(cos(x)^2//3), x, 5),
(x^2/sqrt(5 - 4*x^2), -(x*sqrt(5 - 4*x^2))/8 + (5*asin((2*x)/sqrt(5)))/16, x, 2),
(x^3*sin(x), 6*x*cos(x) - x^3*cos(x) - 6*sin(x) + 3*x^2*sin(x), x, 4),
(x*sqrt(4 + 2*x + x^2), -((1 + x)*sqrt(4 + 2*x + x^2))/2 + (4 + 2*x + x^2)^(3//2)/3 - (3*asinh((1 + x)/sqrt(3)))/2, x, 4),
(x*(5 + x^2)^8, (5 + x^2)^9//18, x, 1),
(cos(x)^2*sin(x)^5, -cos(x)^3//3 + (2*cos(x)^5)/5 - cos(x)^7//7, x, 3),
(cos(4*x)/ℯ^(3*x), (-3*cos(4*x))/(25*ℯ^(3*x)) + (4*sin(4*x))/(25*ℯ^(3*x)), x, 1),
(csc(x/2)^3, -atanh(cos(x/2)) - cot(x/2)*csc(x/2), x, 2),
(sqrt(-1 + 9*x^2)/x^2, -(sqrt(-1 + 9*x^2)/x) + 3*atanh((3*x)/sqrt(-1 + 9*x^2)), x, 3),
(sqrt(4 - 3*x^2)/x, sqrt(4 - 3*x^2) - 2*atanh(sqrt(4 - 3*x^2)/2), x, 4),
(ℯ^(3*x)*x^2, (2*ℯ^(3*x))/27 - (2*ℯ^(3*x)*x)/9 + (ℯ^(3*x)*x^2)/3, x, 3),
((cos(x)*sin(x))/sqrt(1 + sin(x)), -2*sqrt(1 + sin(x)) + (2*(1 + sin(x))^(3//2))/3, x, 3),
(x*asin(x^2), sqrt(1 - x^4)/2 + (x^2*asin(x^2))/2, x, 3),
(x^3*asin(x^2), (x^2*sqrt(1 - x^4))/8 - asin(x^2)/8 + (x^4*asin(x^2))/4, x, 5),
(ℯ^x*sech(ℯ^x), atan(sinh(ℯ^x)), x, 2),
(x^2*cos(3*x), (2*x*cos(3*x))/9 - (2*sin(3*x))/27 + (x^2*sin(3*x))/3, x, 3),
(sqrt(5 - 4*x - x^2), ((2 + x)*sqrt(5 - 4*x - x^2))/2 - (9*asin((-2 - x)/3))/2, x, 3),
(x^5/(sqrt(2) + x^2), -(x^2/sqrt(2)) + x^4//4 + log(sqrt(2) + x^2), x, 3),
(sec(x)^5, (3*atanh(sin(x)))/8 + (3*sec(x)*tan(x))/8 + (sec(x)^3*tan(x))/4, x, 3),
(sin(2*x)^6, (5*x)/16 - (5*cos(2*x)*sin(2*x))/32 - (5*cos(2*x)*sin(2*x)^3)/48 - (cos(2*x)*sin(2*x)^5)/12, x, 4),
(cos(x)*log(sin(x))*sin(x)^2, -sin(x)^3//9 + (log(sin(x))*sin(x)^3)/3, x, 4),
(1/(ℯ^x*(1 + 2*ℯ^x)), -ℯ^(-x) - 2*x + 2*log(1 + 2*ℯ^x), x, 3),
(sqrt(2 + 3*cos(x))*tan(x), 2*sqrt(2)*atanh(sqrt(2 + 3*cos(x))/sqrt(2)) - 2*sqrt(2 + 3*cos(x)), x, 4),
(x/sqrt(-4*x + x^2), sqrt(-4*x + x^2) + 4*atanh(x/sqrt(-4*x + x^2)), x, 3),
(cos(x)^5, sin(x) - (2*sin(x)^3)/3 + sin(x)^5//5, x, 2),
(x^4/ℯ^x, -24/ℯ^x - (24*x)/ℯ^x - (12*x^2)/ℯ^x - (4*x^3)/ℯ^x - x^4/ℯ^x, x, 5),
(x^4/sqrt(-2 + x^10), atanh(x^5/sqrt(-2 + x^10))/5, x, 3),
(ℯ^x*cos(4 + 3*x), (ℯ^x*cos(4 + 3*x))/10 + (3*ℯ^x*sin(4 + 3*x))/10, x, 1),
# {E^x*Log[1 + E^x], x, 4, -E^x + (1 + E^x)*Log[1 + E^x], -E^x + Log[1 + E^x] + E^x*Log[1 + E^x]}
(x^2*atan(x), -x^2//6 + (x^3*atan(x))/3 + log(1 + x^2)/6, x, 4),
(sqrt(-1 + ℯ^(2*x)), sqrt(-1 + ℯ^(2*x)) - atan(sqrt(-1 + ℯ^(2*x))), x, 4),
(ℯ^sin(x)*sin(2*x), -2*ℯ^sin(x) + 2*ℯ^sin(x)*sin(x), x, 4),
(x^2*sqrt(5 - x^2), (-5*x*sqrt(5 - x^2))/8 + (x^3*sqrt(5 - x^2))/4 + (25*asin(x/sqrt(5)))/8, x, 3),
(x^2*(1 + x^3)^4, (1 + x^3)^5//15, x, 1),
(cos(x)^3*sin(x)^3, sin(x)^4//4 - sin(x)^6//6, x, 3),
(sec(x)^4*tan(x)^2, tan(x)^3//3 + tan(x)^5//5, x, 3),
(x*sqrt(1 + 2*x), -(1 + 2*x)^(3//2)/6 + (1 + 2*x)^(5//2)/10, x, 2),
(sin(x)^4, (3*x)/8 - (3*cos(x)*sin(x))/8 - (cos(x)*sin(x)^3)/4, x, 3),
(tan(x)^3, log(cos(x)) + tan(x)^2//2, x, 2),
(x^5*sqrt(1 + x^2), (1 + x^2)^(3//2)/3 - (2*(1 + x^2)^(5//2))/5 + (1 + x^2)^(7//2)/7, x, 3),
]

timofeev = [
# ::Package::

# ::Title::
# A. F. Timofeev - Integration of Functions (1948)


# ::Section::Closed::
# Chapter 1 Integration Problems


# ::Subsection::Closed::
# Problems 1 - 5 (p. 25)


(1/(a^2 - b^2*x^2), atanh((b*x)/a)/(a*b), x, 1),
(1/(a^2 + b^2*x^2), atan((b*x)/a)/(a*b), x, 1),
(sec(2*a*x), atanh(sin(2*a*x))/(2*a), x, 1),
(1/(4*sin(x/3)), (-3*atanh(cos(x/3)))/4, x, 2),
(1/cos(3*π/4 - 2*x), -atanh(sin(π/4 + 2*x))/2, x, 1),


# ::Subsection::Closed::
# Problems 6 - 11 (p. 25-26)


(sec(x)*tan(x), sec(x), x, 2),
(csc(x)*cot(x), -csc(x), x, 2),
(tan(x)/sin(2*x), tan(x)/2, x, 2),
(1/(1 + cos(x)), sin(x)/(1 + cos(x)), x, 1),
(1/(1 - cos(x)), -(sin(x)/(1 - cos(x))), x, 1),
(sin(x)/(a - b*cos(x)), log(a - b*cos(x))/b, x, 2),


# ::Subsection::Closed::
# Problems 12 - 16 (p. 26)


(cos(x)/(a^2 + b^2*sin(x)^2), atan((b*sin(x))/a)/(a*b), x, 2),
(cos(x)/(a^2 - b^2*sin(x)^2), atanh((b*sin(x))/a)/(a*b), x, 2),
(sin(2*x)/(a^2 + b^2*sin(x)^2), log(a^2 + b^2*sin(x)^2)/b^2, x, 3),
(sin(2*x)/(a^2 - b^2*sin(x)^2), -log(a^2 - b^2*sin(x)^2)/b^2, x, 3),
# {Sin[2*x]/(a^2 + b^2*Cos[x]^2), x, 3, -Log[a^2 + b^2*Cos[x]^2]/b^2, -Log[a^2 + b^2 - b^2*Sin[x]^2]/b^2}
# {Sin[2*x]/(a^2 - b^2*Cos[x]^2), x, 3, Log[a^2 - b^2*Cos[x]^2]/b^2, Log[a^2 - b^2 + b^2*Sin[x]^2]/b^2}
(1/(4 - cos(x)^2), x/(2*sqrt(3)) + (1/(2*sqrt(3)))*atan((cos(x)*sin(x))/(3 + 2*sqrt(3) + sin(x)^2)), x, 2),


# ::Subsection::Closed::
# Problems 17 - 21 (p. 26)


(ℯ^x/(-1 + ℯ^(2*x)), -atanh(ℯ^x), x, 2),
(1/(x*log(x)), log(log(x)), x, 2),
(1/(x*(1 + log(x)^2)), atan(log(x)), x, 2),
(1/(x*(1 - log(x))), -log(1 - log(x)), x, 2),
(1/(x*(1 + log(x/a))), log(1 + log(x/a)), x, 2),


# ::Subsection::Closed::
# Problems 22 - 26 (p. 27)


((1 - sqrt(x) + x)^2/x^2, -1/x + 4/sqrt(x) - 4*sqrt(x) + x + 3*log(x), x, 3),
((2 - x^(2//3))*(x + sqrt(x))/x^(3//2), 4*sqrt(x) - (3*x^(2//3))/2 - (6*x^(7//6))/7 + 2*log(x), x, 4),
((2*x - 1)/(2*x + 3), x - 2*log(2*x + 3), x, 2),
((2*x - 5)/(3*x^2 - 2), (1//12)*(4 - 5*sqrt(6))*log(sqrt(6) - 3*x) + (1//12)*(4 + 5*sqrt(6))*log(sqrt(6) + 3*x), x, 3),
((2*x - 5)/(3*x^2 + 2), (-5*atan(sqrt(3//2)*x))/sqrt(6) + log(3*x^2 + 2)/3, x, 3),


# ::Subsection::Closed::
# Problems 27 - 33 (p. 27-28)


(sin(x/4)*sin(x), (2*sin((3*x)/4))/3 - (2*sin((5*x)/4))/5, x, 1),
(cos(3*x)*cos(4*x), sin(x)/2 + sin(7*x)/14, x, 1),
(tan(x)*tan(x - a), -x + cot(a)*log(cos(x - a)) - cot(a)*log(cos(x)), x, 4),
(sin(x)^2, x/2 - (cos(x)*sin(x))/2, x, 2),
(cos(x)^2, x/2 + (cos(x)*sin(x))/2, x, 2),
(sin(x)*cos(x)^3, -cos(x)^4//4, x, 2),
(cos(x)^3/sin(x)^4, 1/sin(x) - 1/(3*sin(x)^3), x, 2),
(1/(sin(x)^2*cos(x)^2), tan(x) - cot(x), x, 3),


# ::Subsection::Closed::
# Problems 34 - 37 (p. 28)


(cot(3*x/4)^2, -x - (4*cot((3*x)/4))/3, x, 2),
((1 + tan(2*x))^2, -log(cos(2*x)) + tan(2*x)/2, x, 2),
((tan(x) - cot(x))^2, -4*x - cot(x) + tan(x), x, 4),
((tan(x) - sec(x))^2, -x - (2*cos(x))/(1 + sin(x)), x, 4),


# ::Subsection::Closed::
# Problems 38 - 40 (p. 28)


(sin(x)/(1 + sin(x)), x + cos(x)/(1 + sin(x)), x, 2),
(cos(x)/(1 - cos(x)), -x - sin(x)/(1 - cos(x)), x, 2),
((ℯ^(x/2) - 1)^3*ℯ^(-x/2), 2/ℯ^(x/2) - 6*ℯ^(x/2) + ℯ^x + 3*x, x, 3),


# ::Subsection::Closed::
# Problems 41 - 43 (p. 35)


(1/(5 - 6*x + x^2), -log(1 - x)/4 + log(5 - x)/4, x, 3),
(x^2/(13 - 6*x^3 + x^6), (1//6)*atan((1//2)*(-3 + x^3)), x, 3),
((2 + x)/(-1 - 4*x + x^2), ((5 - 4*sqrt(5))*log(2 - sqrt(5) - x))/10 + ((5 + 4*sqrt(5))*log(2 + sqrt(5) - x))/10, x, 3),


# ::Subsection::Closed::
# Problems 44 - 48c (p. 35-36)


(1/(1 + (1 + x)^(1//3)), -3*(1 + x)^(1//3) + (3*(1 + x)^(2//3))/2 + 3*log(1 + (1 + x)^(1//3)), x, 4),
(1/(sqrt(x)*(a*x + b)), (2*atan((sqrt(a)*sqrt(x))/sqrt(b)))/(sqrt(a)*sqrt(b)), x, 2),
(x^3*sqrt(1 + x^2), -(1 + x^2)^(3//2)/3 + (1 + x^2)^(5//2)/5, x, 3),
(x/sqrt(a^4 - x^4), atan(x^2/sqrt(a^4 - x^4))/2, x, 3),
(1/(x*sqrt(x^2 - a^2)), atan(sqrt(x^2 - a^2)/a)/a, x, 3),
(1/(x*sqrt(a^2 - x^2)), -(atanh(sqrt(a^2 - x^2)/a)/a), x, 3),
(1/(x*sqrt(x^2 + a^2)), -(atanh(sqrt(x^2 + a^2)/a)/a), x, 3),


# ::Subsection::Closed::
# Problems 49 - 54 (p. 36)


(1/sqrt(2 + x - x^2), -asin((1 - 2*x)/3), x, 2),
(1/sqrt(5 - 4*x + 3*x^2), -(asinh((2 - 3*x)/sqrt(11))/sqrt(3)), x, 2),
(1/sqrt(x - x^2), -asin(1 - 2*x), x, 2),
((1 + 2*x)/sqrt(2 + x - x^2), -2*sqrt(2 + x - x^2) - 2*asin((1 - 2*x)/3), x, 3),
(1/(x*sqrt(2 + x - x^2)), -(atanh((4 + x)/(2*sqrt(2)*sqrt(2 + x - x^2)))/sqrt(2)), x, 2),
# {1/((x - 2)*Sqrt[2 + x - x^2]), x, 1, 2*Sqrt[2 + x - x^2]/(3*(x - 2)), -((2*Sqrt[2 + x - x^2])/(3*(2 - x)))}


# ::Subsection::Closed::
# Problems 55 - 60 (p. 36-37)


((2 + 3*sin(x))/(sin(x)*(1 - cos(x))), -atanh(cos(x)) - 1/(1 - cos(x)) - (3*sin(x))/(1 - cos(x)), x, 7),
# {1/(2 + 3*Cos[x]^2), x, 2, x/Sqrt[10] - 1/Sqrt[10]*ArcTan[3*Cos[x]*Sin[x]/(2 + Sqrt[10] + 3*Cos[x]^2)], x/Sqrt[10] - ArcTan[((-1 + Sqrt[5/2])*Cos[x]*Sin[x])/(1 + (-1 + Sqrt[5/2])*Cos[x]^2)]/Sqrt[10]}
((1 - tan(x))/sin(2*x), log(tan(x))/2 - tan(x)/2, x, 3),
((1 + tan(x)^2)/(1 - tan(x)^2), (1//2)*atanh(2*cos(x)*sin(x)), x, 2),
# {(a^2 - 4*Cos[x]^2)^(3/4)*Sin[2*x], x, 3, (1/7)*(a^2 - 4*Cos[x]^2)^(7/4), 1/7*(a^2 - 4 + 4*Sin[x]^2)^(7/4)}
(sin(2*x)/(a^2 - 4*sin(x)^2)^(1//3), -3//8*(a^2 - 4*sin(x)^2)^(2//3), x, 3),


# ::Subsection::Closed::
# Problems 61 - 65 (p. 37)


(1/sqrt(a^(2*x) - 1), atan(sqrt(a^(2*x) - 1))/log(a), x, 3),
(ℯ^(x/2)/sqrt(ℯ^x - 1), 2*atanh(ℯ^(x/2)/sqrt(ℯ^x - 1)), x, 3),
(atan(x)^n/(1 + x^2), atan(x)^(n + 1)/(n + 1), x, 1),
(asin(x/a)^(3//2)/sqrt(a^2 - x^2), (2*a*sqrt(1 - x^2/a^2)*asin(x/a)^(5//2))/(5*sqrt(a^2 - x^2)), x, 1),
(1/(acos(x)^3*sqrt(1 - x^2)), 1/(2*acos(x)^2), x, 1),


# ::Subsection::Closed::
# Problems 66 - 68 (p. 41)


(x*log(x)^2, x^2//4 - (x^2*log(x))/2 + (x^2*log(x)^2)/2, x, 2),
(log(x)/x^5, -1/(16*x^4) - log(x)/(4*x^4), x, 1),
# {x^2*Log[(x - 1)/x], x, 5, -x/3 - x^2/6 + x^3*Log[(x - 1)/x]/3 - Log[x - 1]/3, -(x/3) - x^2/6 + (1/3)*x^3*Log[1 - 1/x] - (1/3)*Log[1 - x]}


# ::Subsection::Closed::
# Problems 69 - 71 (p. 41)


(cos(x)^5, sin(x) - (2*sin(x)^3)/3 + sin(x)^5//5, x, 2),
(sin(x)^2*cos(x)^4, x/16 + (cos(x)*sin(x))/16 + (cos(x)^3*sin(x))/24 - (cos(x)^5*sin(x))/6, x, 4),
(1/sin(x)^5, (-3*atanh(cos(x)))/8 - (3*cot(x)*csc(x))/8 - (cot(x)*csc(x)^3)/4, x, 3),


# ::Subsection::Closed::
# Problems 72 - 76 (p. 42)


(sin(x)/ℯ^x, -cos(x)/(2*ℯ^x) - sin(x)/(2*ℯ^x), x, 1),
(ℯ^(2*x)*sin(3*x), (-3*ℯ^(2*x)*cos(3*x))/13 + (2*ℯ^(2*x)*sin(3*x))/13, x, 1),
(a^x*cos(x), (a^x*cos(x)*log(a))/(1 + log(a)^2) + (a^x*sin(x))/(1 + log(a)^2), x, 1),
(cos(log(x)), (x*cos(log(x)))/2 + (x*sin(log(x)))/2, x, 1),
(sec(x)^2*log(cos(x)), -x + tan(x) + log(cos(x))*tan(x), x, 3),


# ::Subsection::Closed::
# Problems 77 - 81 (p. 42)


(x*tan(x)^2, -x^2//2 + log(cos(x)) + x*tan(x), x, 3),
(asin(x)/x^2, -(asin(x)/x) - atanh(sqrt(1 - x^2)), x, 4),
(asin(x)^2, -2*x + 2*sqrt(1 - x^2)*asin(x) + x*asin(x)^2, x, 3),
(atan(x)*x^2/(1 + x^2), x*atan(x) - atan(x)^2//2 - log(1 + x^2)/2, x, 4),
# {ArcCos[Sqrt[x/(1 + x)]], x, 6, (1 + x)*(Sqrt[1/(1 + x)]*Sqrt[x/(1 + x)] + ArcCos[Sqrt[x/(1 + x)]]), Sqrt[x/(1 + x)^2]*(1 + x) + x*ArcCos[Sqrt[x/(1 + x)]] - (Sqrt[x/(1 + x)^2]*(1 + x)*ArcTan[Sqrt[x]])/Sqrt[x]}


# ::Section::Closed::
# Chapter 2 Integration Problems


# ::Subsection::Closed::
# Problems 1 - 3 (p. 60)


((3*x^2 + 2*x)^3, 2*x^4 + (36*x^5)/5 + 9*x^6 + (27*x^7)/7, x, 2),
((3*x^2 + 2*x - 1)^2*(x - 1), -x + (5*x^2)/2 - (2*x^3)/3 - (7*x^4)/2 + (3*x^5)/5 + (3*x^6)/2, x, 2),
((a + b*x^k)^n*x^(k - 1), (a + b*x^k)^(1 + n)/(b*k*(1 + n)), x, 1),


# ::Subsection::Closed::
# Problems 4 - 9 (p. 62-63)


(x^3/(1 + 2*x), x/8 - x^2//8 + x^3//6 - (1//16)*log(1 + 2*x), x, 2),
(x^6/(2 + 3*x^2), (4*x)/27 - (2*x^3)/27 + x^5//15 - (4//27)*sqrt(2//3)*atan(sqrt(3//2)*x), x, 3),
(1/(3*x^2 - 7*x + 2), (-(1//5))*log(1 - 3*x) + (1//5)*log(2 - x), x, 3),
((3*x - 1)/(x^2 - x + 1), -(atan((1 - 2*x)/sqrt(3))/sqrt(3)) + (3//2)*log(1 - x + x^2), x, 4),
(x^2/(5 + 2*x + x^2), x - (3//2)*atan((1 + x)/2) - log(5 + 2*x + x^2), x, 5),
((6*x^4 - 5*x^3 + 4*x^2)/(2*x^2 - x + 1), -(x^2//2) + x^3 - atan((1 - 4*x)/sqrt(7))/(2*sqrt(7)) + (1//4)*log(1 - x + 2*x^2), x, 7),


# ::Subsection::Closed::
# Problems 10 - 14 (p. 63)


((x^2 + x - 1)/(x^3 + x^2 - 6*x), (1//2)*log(2 - x) + log(x)/6 + (1//3)*log(3 + x), x, 3),
((5*x^2 - 7*a*x + 11*a^2)/(x^3 - 6*a*x^2 + 11*a^2*x - 6*a^3), (9//2)*log(a - x) - 17*log(2*a - x) + (35//2)*log(3*a - x), x, 2),
# {(x^2 - x + 2)/(x^4 - 5*x^2 + 4), x, 12, (-(1/3))*Log[1 - x] + (1/3)*Log[2 - x] + (2/3)*Log[1 + x] - (2/3)*Log[2 + x], (-(1/2))*Log[1 - x] + (1/2)*Log[2 - x] + (1/2)*Log[1 + x] - (1/2)*Log[2 + x] + (1/6)*Log[1 - x^2] - (1/6)*Log[4 - x^2]}
((2*x^2 - 5)/(x^4 - 5*x^2 + 6), -(atanh(x/sqrt(2))/sqrt(2)) - atanh(x/sqrt(3))/sqrt(3), x, 3),
(1/((x - 1)*(x - 2)*(x - 3)*(x - 4)), (-(1//6))*log(1 - x) + (1//2)*log(2 - x) - (1//2)*log(3 - x) + (1//6)*log(4 - x), x, 2),


# ::Subsection::Closed::
# Problems 15 - 17 (p. 64)


((x^2 + 1)/(x - 1)^3, -(1/(1 - x)^2) + 2/(1 - x) + log(1 - x), x, 2),
(x^5/(3 + x)^2, -108*x + (27*x^2)/2 - 2*x^3 + x^4//4 + 243/(3 + x) + 405*log(3 + x), x, 2),
((5*x^3 - 2)/(x^4 - 8*x^3 + 18*x^2 - 27), -(133/(8*(3 - x)^2)) + 407/(16*(3 - x)) + (313//64)*log(3 - x) + (7//64)*log(1 + x), x, 2),


# ::Subsection::Closed::
# Problems 18 - 20 (p. 65)


((x^3 - 6*x^2 + 3*x - 9)/((x + 3)^2*(x + 4)^2), 99/(3 + x) + 181/(4 + x) + 264*log(3 + x) - 263*log(4 + x), x, 2),
((x^3 + x^2 + 2)/(x*(x^2 - 1)^2), (3 + x)/(2*(1 - x^2)) - (3//4)*log(1 - x) + 2*log(x) - (5//4)*log(1 + x), x, 3),
(1/(x^3 - x^4 - x^5 + x^6), 1/(2*(1 - x)) - 1/(2*x^2) - 1/x - (7//4)*log(1 - x) + 2*log(x) - (1//4)*log(1 + x), x, 2),


# ::Subsection::Closed::
# Problems 21 - 25 (p. 66)


((x^4 + 1)/(x^3 - x^2 + x - 1), x + x^2//2 - atan(x) + log(1 - x) - (1//2)*log(1 + x^2), x, 5),
(1/(x*(1 + x)*(1 + x^2)), -(atan(x)/2) + log(x) - (1//2)*log(1 + x) - (1//4)*log(1 + x^2), x, 5),
(x^2/(x^4 + x^2 - 2), (1//3)*sqrt(2)*atan(x/sqrt(2)) - atanh(x)/3, x, 3),
((x^3 + 4*x^2 + 6*x)/(x^4 + 2*x^3 + 3*x^2 + 4*x + 2), 1/(1 + x) + (4//3)*sqrt(2)*atan(x/sqrt(2)) - (1//3)*log(1 + x) + (2//3)*log(2 + x^2), x, 6),
(x/((1 + x)*(1 + 2*x)^2*(1 + x^2)), 2/(5*(1 + 2*x)) + atan(x)/50 - (1//2)*log(1 + x) + (16//25)*log(1 + 2*x) - (7//100)*log(1 + x^2), x, 5),


# ::Subsection::Closed::
# Problems 26 - 27 (p. 67)


((3*x^2 + x - 2)/((x - 1)^3*(x^2 + 1)), -(1/(2*(1 - x)^2)) + 5/(2*(1 - x)) - atan(x) - (3//2)*log(1 - x) + (3//4)*log(1 + x^2), x, 5),
(1/(x^4 + x^2 + 1), -(atan((1 - 2*x)/sqrt(3))/(2*sqrt(3))) + atan((1 + 2*x)/sqrt(3))/(2*sqrt(3)) - (1//4)*log(1 - x + x^2) + (1//4)*log(1 + x + x^2), x, 9),


# ::Subsection::Closed::
# Problems 28 - 32 (p. 68)


((2*x^3 + 3)/(x^5 - 9*x), atan(x/sqrt(3))/sqrt(3) - atanh(x/sqrt(3))/sqrt(3) - log(x)/3 + (1//12)*log(9 - x^4), x, 10),
((5*x^3 + 8*x - 20)/((x - 4)^3*(x^2 - 4*x + 8)), -(83/(4*(4 - x)^2)) + 41/(4*(4 - x)) - (3//16)*atan(1 - x/2) - (45//16)*log(4 - x) + (45//32)*log(8 - 4*x + x^2), x, 6),
(1/((x^2 + 1)*(x^2 + 2)*(x^2 + 3)*(x^2 + 4)), (-(1//12))*atan(x/2) + atan(x)/6 - atan(x/sqrt(2))/(2*sqrt(2)) + atan(x/sqrt(3))/(2*sqrt(3)), x, 6),
(x/((x^2 + 1)*(x^2 + 2)*(x^2 + 3)*(x^2 + 4)), (1//12)*log(1 + x^2) - (1//4)*log(2 + x^2) + (1//4)*log(3 + x^2) - (1//12)*log(4 + x^2), x, 3),
(1/(a^3 + x^3), -(atan((a - 2*x)/(sqrt(3)*a))/(sqrt(3)*a^2)) + log(a + x)/(3*a^2) - log(a^2 - a*x + x^2)/(6*a^2), x, 6),


# ::Subsection::Closed::
# Problems 33 - 44 (p. 69)


(x/(a^3 + x^3), -(atan((a - 2*x)/(sqrt(3)*a))/(sqrt(3)*a)) - log(a + x)/(3*a) + log(a^2 - a*x + x^2)/(6*a), x, 6),
(x^2/(a^3 + x^3), (1//3)*log(a^3 + x^3), x, 1),
(1/(x*(a^3 + x^3)), log(x)/a^3 - log(a^3 + x^3)/(3*a^3), x, 4),
(1/(x^2*(a^3 + x^3)), -(1/(a^3*x)) + atan((a - 2*x)/(sqrt(3)*a))/(sqrt(3)*a^4) + log(a + x)/(3*a^4) - log(a^2 - a*x + x^2)/(6*a^4), x, 7),
(1/(x^3*(a^3 + x^3)), -(1/(2*a^3*x^2)) + atan((a - 2*x)/(sqrt(3)*a))/(sqrt(3)*a^5) - log(a + x)/(3*a^5) + log(a^2 - a*x + x^2)/(6*a^5), x, 7),
(1/(x^4*(a^3 + x^3)), -(1/(3*a^3*x^3)) - log(x)/a^6 + log(a^3 + x^3)/(3*a^6), x, 3),
(1/(x^5*(a^3 + x^3)), -(1/(4*a^3*x^4)) + 1/(a^6*x) - atan((a - 2*x)/(sqrt(3)*a))/(sqrt(3)*a^7) - log(a + x)/(3*a^7) + log(a^2 - a*x + x^2)/(6*a^7), x, 8),
(1/(x^m*(a^3 + x^3)), (x^(1 - m)*hypergeometric2f1(1, (1 - m)/3, (4 - m)/3, -(x^3/a^3)))/(a^3*(1 - m)), x, 1),
(1/(a^4 - x^4), atan(x/a)/(2*a^3) + atanh(x/a)/(2*a^3), x, 3),
(x/(a^4 - x^4), atanh(x^2/a^2)/(2*a^2), x, 2),
(1/(x*(a^4 - x^4)), log(x)/a^4 - log(a^4 - x^4)/(4*a^4), x, 4),
(1/(x^2*(a^4 - x^4)), -(1/(a^4*x)) - atan(x/a)/(2*a^5) + atanh(x/a)/(2*a^5), x, 4),
(1/(x^3*(a^4 - x^4)), -(1/(2*a^4*x^2)) + atanh(x^2/a^2)/(2*a^6), x, 3),
(1/(x^4*(a^4 - x^4)), -(1/(3*a^4*x^3)) + atan(x/a)/(2*a^7) + atanh(x/a)/(2*a^7), x, 4),
(1/(x^m*(a^4 - x^4)), (x^(1 - m)*hypergeometric2f1(1, (1 - m)/4, (5 - m)/4, x^4/a^4))/(a^4*(1 - m)), x, 1),
(x/(a^4 + x^4), atan(x^2/a^2)/(2*a^2), x, 2),
(x^2/(a^4 + x^4), -(atan(1 - (sqrt(2)*x)/a)/(2*sqrt(2)*a)) + atan(1 + (sqrt(2)*x)/a)/(2*sqrt(2)*a) + log(a^2 - sqrt(2)*a*x + x^2)/(4*sqrt(2)*a) - log(a^2 + sqrt(2)*a*x + x^2)/(4*sqrt(2)*a), x, 9),
(1/(a^5 + x^5), -((sqrt((1//2)*(5 + sqrt(5)))*atan(((1 - sqrt(5))*a - 4*x)/(sqrt(2*(5 + sqrt(5)))*a)))/(5*a^4)) - (sqrt((1//2)*(5 - sqrt(5)))*atan((sqrt((1//10)*(5 + sqrt(5)))*((1 + sqrt(5))*a - 4*x))/(2*a)))/(5*a^4) + log(a + x)/(5*a^4) - ((1 - sqrt(5))*log(a^2 - (1//2)*(1 - sqrt(5))*a*x + x^2))/(20*a^4) - ((1 + sqrt(5))*log(a^2 - (1//2)*(1 + sqrt(5))*a*x + x^2))/(20*a^4), x, 6),


# ::Subsection::Closed::
# Problems 45 - 50 (p. 71-72)


(x/(a^5 + x^5), (sqrt((1//2)*(5 - sqrt(5)))*atan(((1 - sqrt(5))*a - 4*x)/(sqrt(2*(5 + sqrt(5)))*a)))/(5*a^3) - (sqrt((1//2)*(5 + sqrt(5)))*atan((sqrt((1//10)*(5 + sqrt(5)))*((1 + sqrt(5))*a - 4*x))/(2*a)))/(5*a^3) - log(a + x)/(5*a^3) + ((1 + sqrt(5))*log(a^2 - (1//2)*(1 - sqrt(5))*a*x + x^2))/(20*a^3) + ((1 - sqrt(5))*log(a^2 - (1//2)*(1 + sqrt(5))*a*x + x^2))/(20*a^3), x, 6),
(x^2/(a^5 + x^5), (sqrt((1//2)*(5 - sqrt(5)))*atan(((1 - sqrt(5))*a - 4*x)/(sqrt(2*(5 + sqrt(5)))*a)))/(5*a^2) - (sqrt((1//2)*(5 + sqrt(5)))*atan((sqrt((1//10)*(5 + sqrt(5)))*((1 + sqrt(5))*a - 4*x))/(2*a)))/(5*a^2) + log(a + x)/(5*a^2) - ((1 + sqrt(5))*log(a^2 - (1//2)*(1 - sqrt(5))*a*x + x^2))/(20*a^2) - ((1 - sqrt(5))*log(a^2 - (1//2)*(1 + sqrt(5))*a*x + x^2))/(20*a^2), x, 6),
(x^3/(a^5 + x^5), -((sqrt((1//2)*(5 + sqrt(5)))*atan(((1 - sqrt(5))*a - 4*x)/(sqrt(2*(5 + sqrt(5)))*a)))/(5*a)) - (sqrt((1//2)*(5 - sqrt(5)))*atan((sqrt((1//10)*(5 + sqrt(5)))*((1 + sqrt(5))*a - 4*x))/(2*a)))/(5*a) - log(a + x)/(5*a) + ((1 - sqrt(5))*log(a^2 - (1//2)*(1 - sqrt(5))*a*x + x^2))/(20*a) + ((1 + sqrt(5))*log(a^2 - (1//2)*(1 + sqrt(5))*a*x + x^2))/(20*a), x, 6),
(x^4/(a^5 + x^5), (1//5)*log(a^5 + x^5), x, 1),
(1/(x*(a^5 + x^5)), log(x)/a^5 - log(a^5 + x^5)/(5*a^5), x, 4),
(1/(x^2*(a^5 + x^5)), -(1/(a^5*x)) + (sqrt((1//2)*(5 + sqrt(5)))*atan(((1 - sqrt(5))*a - 4*x)/(sqrt(2*(5 + sqrt(5)))*a)))/(5*a^6) + (sqrt((1//2)*(5 - sqrt(5)))*atan((sqrt((1//10)*(5 + sqrt(5)))*((1 + sqrt(5))*a - 4*x))/(2*a)))/(5*a^6) + log(a + x)/(5*a^6) - ((1 - sqrt(5))*log(a^2 - (1//2)*(1 - sqrt(5))*a*x + x^2))/(20*a^6) - ((1 + sqrt(5))*log(a^2 - (1//2)*(1 + sqrt(5))*a*x + x^2))/(20*a^6), x, 7),
(1/(x^3*(a^5 + x^5)), -(1/(2*a^5*x^2)) - (sqrt((1//2)*(5 - sqrt(5)))*atan(((1 - sqrt(5))*a - 4*x)/(sqrt(2*(5 + sqrt(5)))*a)))/(5*a^7) + (sqrt((1//2)*(5 + sqrt(5)))*atan((sqrt((1//10)*(5 + sqrt(5)))*((1 + sqrt(5))*a - 4*x))/(2*a)))/(5*a^7) - log(a + x)/(5*a^7) + ((1 + sqrt(5))*log(a^2 - (1//2)*(1 - sqrt(5))*a*x + x^2))/(20*a^7) + ((1 - sqrt(5))*log(a^2 - (1//2)*(1 + sqrt(5))*a*x + x^2))/(20*a^7), x, 7),
(1/(x^4*(a^5 + x^5)), -(1/(3*a^5*x^3)) - (sqrt((1//2)*(5 - sqrt(5)))*atan(((1 - sqrt(5))*a - 4*x)/(sqrt(2*(5 + sqrt(5)))*a)))/(5*a^8) + (sqrt((1//2)*(5 + sqrt(5)))*atan((sqrt((1//10)*(5 + sqrt(5)))*((1 + sqrt(5))*a - 4*x))/(2*a)))/(5*a^8) + log(a + x)/(5*a^8) - ((1 + sqrt(5))*log(a^2 - (1//2)*(1 - sqrt(5))*a*x + x^2))/(20*a^8) - ((1 - sqrt(5))*log(a^2 - (1//2)*(1 + sqrt(5))*a*x + x^2))/(20*a^8), x, 7),
(1/(x^m*(a^5 + x^5)), (x^(1 - m)*hypergeometric2f1(1, (1 - m)/5, (6 - m)/5, -(x^5/a^5)))/(a^5*(1 - m)), x, 1),


# ::Subsection::Closed::
# Problems 51 - 57 (p. 77-79)


((x^4 + 1)/(x^6 + 1), (-(1//3))*atan(sqrt(3) - 2*x) + (2*atan(x))/3 + (1//3)*atan(sqrt(3) + 2*x), x, 22),
(1/(x^2 + 3*x + 5)^3, (3 + 2*x)/(22*(5 + 3*x + x^2)^2) + (3*(3 + 2*x))/(121*(5 + 3*x + x^2)) + (12*atan((3 + 2*x)/sqrt(11)))/(121*sqrt(11)), x, 4),
((x^4 + x^2 + 1)/(x^2 + 1)^4, x/(6*(1 + x^2)^3) - x/(24*(1 + x^2)^2) + (7*x)/(16*(1 + x^2)) + (7*atan(x))/16, x, 4),
((A*x + B)/(a*x^2 + 2*b*x + c)^2, -((b*B - A*c - (A*b - a*B)*x)/(2*(b^2 - a*c)*(c + 2*b*x + a*x^2))) - ((A*b - a*B)*atanh((b + a*x)/sqrt(b^2 - a*c)))/(2*(b^2 - a*c)^(3//2)), x, 3),
((5*x^3 - 27*x^2 + 55*x - 41)/(x^2 - 4*x + 5)^2, (1 - x)/(5 - 4*x + x^2) - 2*atan(2 - x) + (5//2)*log(5 - 4*x + x^2), x, 5),
(1/(x^3 - 1)^2, x/(3*(1 - x^3)) + (2*atan((1 + 2*x)/sqrt(3)))/(3*sqrt(3)) - (2//9)*log(1 - x) + (1//9)*log(1 + x + x^2), x, 7),
((3*x^4 + 4)/(x^2*(x^2 + 1)^3), -(4/x) - (7*x)/(4*(1 + x^2)^2) - (25*x)/(8*(1 + x^2)) - (57*atan(x))/8, x, 4),


# ::Subsection::Closed::
# Problems 58 - 65 (p. 80-81)


(x/(x^6 + 1), -(atan((1 - 2*x^2)/sqrt(3))/(2*sqrt(3))) + (1//6)*log(1 + x^2) - (1//12)*log(1 - x^2 + x^4), x, 7),
# {(x^(n - 1) - 1)/(x^n - n*x), x, 5, Log[x^n - n*x]/n, Log[x] + Log[1 - n*x^(1 - n)]/n}
(x^3/(3*x^4 - 2*x^2 + 1), -(atan((1 - 3*x^2)/sqrt(2))/(6*sqrt(2))) + (1//12)*log(1 - 2*x^2 + 3*x^4), x, 5),
(x^5/(3*x^4 + x^2 - 4), x^2//6 + (1//14)*log(1 - x^2) - (8//63)*log(4 + 3*x^2), x, 5),
(x^2/(9 - 10*x^3 + x^6), (-(1//24))*log(1 - x^3) + (1//24)*log(9 - x^3), x, 4),
((x^3 - 4*x^2 + 1)/(x - 2)^4, -(7/(3*(2 - x)^3)) + 2/(2 - x)^2 + 2/(2 - x) + log(2 - x), x, 2),
(x^3/(x - 1)^12, 1/(11*(1 - x)^11) - 3/(10*(1 - x)^10) + 1/(3*(1 - x)^9) - 1/(8*(1 - x)^8), x, 2),
((x^4 - 3*x)/(1 + 2*x)^5, -(25/(128*(1 + 2*x)^4)) + 7/(24*(1 + 2*x)^3) - 3/(32*(1 + 2*x)^2) + 1/(8*(1 + 2*x)) + (1//32)*log(1 + 2*x), x, 3),


# ::Subsection::Closed::
# Problems 66 - 70 (p. 83-78)


(1/((x + 1)^3*(x - 1)^2), 1/(8*(1 - x)) - 1/(8*(1 + x)^2) - 1/(4*(1 + x)) + (3*atanh(x))/8, x, 3),
(1/(x^2*(5 - 6*x)^2), 6/(25*(5 - 6*x)) - 1/(25*x) - (12//125)*log(5 - 6*x) + (12*log(x))/125, x, 2),
(1/(x^2 - 2*x - 3)^3, (1 - x)/(16*(3 + 2*x - x^2)^2) + (3*(1 - x))/(128*(3 + 2*x - x^2)) + (3//512)*log(3 - x) - (3//512)*log(1 + x), x, 5),
(1/(x^2 - 4*x + 13)^3, -((2 - x)/(36*(13 - 4*x + x^2)^2)) - (2 - x)/(216*(13 - 4*x + x^2)) + (1//648)*atan((1//3)*(-2 + x)), x, 4),
(1/((x + 2)^3*(x + 3)^4), -(1/(2*(2 + x)^2)) + 4/(2 + x) + 1/(3*(3 + x)^3) + 3/(2*(3 + x)^2) + 6/(3 + x) + 10*log(2 + x) - 10*log(3 + x), x, 2),


# ::Subsection::Closed::
# Problems 71 - 82 (p. 86-87)


# {x^6/(x^2 - 2)^2, x, 4, 4*x + x^3/3 - (2*x)/(x^2 - 2) - 5*Sqrt[2]*ArcTanh[x/Sqrt[2]], 5*x + (5*x^3)/6 + x^5/(2*(2 - x^2)) - 5*Sqrt[2]*ArcTanh[x/Sqrt[2]]}
(x^8/(x^2 + 4)^4, (35*x)/16 - x^7/(6*(4 + x^2)^3) - (7*x^5)/(24*(4 + x^2)^2) - (35*x^3)/(48*(4 + x^2)) - (35//8)*atan(x/2), x, 5),
((7*x - 4)/(3*x^2 + 2*x + 5)^2, -((39 + 19*x)/(28*(5 + 2*x + 3*x^2))) - (19*atan((1 + 3*x)/sqrt(14)))/(28*sqrt(14)), x, 3),
((5 - 4*x)/(3*x^2 - 4*x - 2)^2, -((18 - 7*x)/(20*(2 + 4*x - 3*x^2))) - (7*atanh((2 - 3*x)/sqrt(10)))/(20*sqrt(10)), x, 3),
(x^5/(x^4 + 1)^3, -(x^2/(8*(1 + x^4)^2)) + x^2/(16*(1 + x^4)) + atan(x^2)/16, x, 4),
# {x*((x^2 + 1)^3/(x^4 + 2*x^2 + 2)^2), x, 3, 1/(4*(x^4 + 2*x^2 + 2)) + (1/4)*Log[x^4 + 2*x^2 + 2], -((1 + x^2)^2/(4*(2 + 2*x^2 + x^4))) + (1/4)*Log[2 + 2*x^2 + x^4]}
(x^3/(a^4 + x^4)^3, -(1/(8*(a^4 + x^4)^2)), x, 1),
(1/(x*(a^4 + x^4)^3), 1/(8*a^4*(a^4 + x^4)^2) + 1/(4*a^8*(a^4 + x^4)) + log(x)/a^12 - log(a^4 + x^4)/(4*a^12), x, 3),
(1/(x^2*(a^4 + x^4)^3), -(45/(32*a^12*x)) + 1/(8*a^4*x*(a^4 + x^4)^2) + 9/(32*a^8*x*(a^4 + x^4)) + (45*atan(1 - (sqrt(2)*x)/a))/(64*sqrt(2)*a^13) - (45*atan(1 + (sqrt(2)*x)/a))/(64*sqrt(2)*a^13) - (45*log(a^2 - sqrt(2)*a*x + x^2))/(128*sqrt(2)*a^13) + (45*log(a^2 + sqrt(2)*a*x + x^2))/(128*sqrt(2)*a^13), x, 12),
(1/(x^3*(a^4 + x^4)^3), -(15/(16*a^12*x^2)) + 1/(8*a^4*x^2*(a^4 + x^4)^2) + 5/(16*a^8*x^2*(a^4 + x^4)) - (15*atan(x^2/a^2))/(16*a^14), x, 5),
(x^14/(3 + 2*x^5)^3, -(9/(80*(3 + 2*x^5)^2)) + 3/(20*(3 + 2*x^5)) + (1//40)*log(3 + 2*x^5), x, 3),
# {x^6/(3 + 2*x^5)^3, x, 8, If[$VersionNumber<9, -(x^2/(20*(3 + 2*x^5)^2)) + x^2/(150*(3 + 2*x^5)) - (Sqrt[5 + Sqrt[5]]*ArcTan[Sqrt[(1/5)*(5 + 2*Sqrt[5])] - (2*2^(7/10)*x)/(3^(1/5)*Sqrt[5 - Sqrt[5]])])/(250*2^(9/10)*3^(3/5)) - (Sqrt[5 - Sqrt[5]]*ArcTan[Sqrt[(1/5)*(5 - 2*Sqrt[5])] + (2*2^(7/10)*x)/(3^(1/5)*Sqrt[5 + Sqrt[5]])])/(250*2^(9/10)*3^(3/5)) - Log[3^(1/5) + 2^(1/5)*x]/(250*2^(2/5)*3^(3/5)) + ((1 + Sqrt[5])*Log[2^(3/5)*3^(2/5) - (3/2)^(1/5)*(1 - Sqrt[5])*x + 2*x^2])/(1000*2^(2/5)*3^(3/5)) + ((1 - Sqrt[5])*Log[2^(3/5)*3^(2/5) - (3/2)^(1/5)*(1 + Sqrt[5])*x + 2*x^2])/(1000*2^(2/5)*3^(3/5)), -(x^2/(20*(3 + 2*x^5)^2)) + x^2/(150*(3 + 2*x^5)) - (Sqrt[5 + Sqrt[5]]*ArcTan[Sqrt[(1/5)*(5 + 2*Sqrt[5])] - (2*2^(7/10)*x)/(3^(1/5)*Sqrt[5 - Sqrt[5]])])/(250*2^(9/10)*3^(3/5)) - (Sqrt[5 - Sqrt[5]]*ArcTan[Sqrt[(1/5)*(5 - 2*Sqrt[5])] + (2*2^(7/10)*x)/(3^(1/5)*Sqrt[5 + Sqrt[5]])])/(250*2^(9/10)*3^(3/5)) - Log[3^(1/5) + 2^(1/5)*x]/(250*2^(2/5)*3^(3/5)) + ((1 + Sqrt[5])*Log[3^(2/5) - (3^(1/5)*(1 - Sqrt[5])*x)/2^(4/5) + 2^(2/5)*x^2])/(1000*2^(2/5)*3^(3/5)) + ((1 - Sqrt[5])*Log[3^(2/5) - (3^(1/5)*(1 + Sqrt[5])*x)/2^(4/5) + 2^(2/5)*x^2])/(1000*2^(2/5)*3^(3/5))]}


# ::Subsection::Closed::
# Problems 83 - 87 (p. 90-91)


(9/(5*x^2*(3 - 2*x^2)^3), -(1/(8*x)) + 3/(20*x*(3 - 2*x^2)^2) + 1/(8*x*(3 - 2*x^2)) + atanh(sqrt(2//3)*x)/(4*sqrt(6)), x, 5),
((3*x^4 + 4)/(x^2*(x^2 + 1)^3), -(4/x) - (7*x)/(4*(1 + x^2)^2) - (25*x)/(8*(1 + x^2)) - (57*atan(x))/8, x, 4),
((5 - 3*x + 6*x^2 + 5*x^3 - x^4)/(x^5 - x^4 - 2*x^3 + 2*x^2 + x - 1), -(3/(2*(1 - x)^2)) + 2/(1 - x) + 1/(1 + x) + log(1 - x) - 2*log(1 + x), x, 2),
((x^2 + 1)/(x*(x^3 + 1)^2), (x*(x - x^2))/(3*(x^3 + 1)) - atan((1 - 2*x)/sqrt(3))/(3*sqrt(3)) + log(x) - (4//9)*log(1 + x) - (5//18)*log(1 - x + x^2), x, 7),
((x^2 - 3*x - 2)/((x + 1)^2*(x^2 + x + 1)^2), -(2/(1 + x)) - (7 + 5*x)/(3*(1 + x + x^2)) - (25*atan((1 + 2*x)/sqrt(3)))/(3*sqrt(3)) - log(1 + x) + (1//2)*log(1 + x + x^2), x, 7),


# ::Subsection::Closed::
# Problems 88 - 90 (p. 97)


(1/((2 - 3*x)*(1 - 4*x)^3), 1/(10*(1 - 4*x)^2) - 3/(25*(1 - 4*x)) - (9//125)*log(1 - 4*x) + (9//125)*log(2 - 3*x), x, 2),
(x^3/(2 - 5*x^2)^7, 1/(150*(2 - 5*x^2)^6) - 1/(250*(2 - 5*x^2)^5), x, 3),
(x^7/(2 - 5*x^2)^3, -(x^2//250) + 2/(625*(2 - 5*x^2)^2) - 6/(625*(2 - 5*x^2)) - (3//625)*log(2 - 5*x^2), x, 3),


# ::Section::Closed::
# Chapter 3 Integration Problems


# ::Subsection::Closed::
# Problems 1 - 3 (p. 101)


# {1/((x - 2)^3*(x + 1)^2), x, 2, -1/(18*(x - 2)^2) + 2/(27*(x - 2)) + 1/(27*(x + 1)) + Log[x - 2]/27 - Log[x + 1]/27, -(1/(18*(2 - x)^2)) - 2/(27*(2 - x)) + 1/(27*(1 + x)) + (1/27)*Log[2 - x] - (1/27)*Log[1 + x]}
(1/((x + 2)^3*(x + 3)^4), -1/(2*(x + 2)^2) + 4/(x + 2) + 1/(3*(x + 3)^3) + 3/(2*(x + 3)^2) + 6/(x + 3) + 10*log(x + 2) - 10*log(x + 3), x, 2),
(x^5/(3 + x)^2, -108*x + (27*x^2)/2 - 2*x^3 + x^4//4 + 243/(3 + x) + 405*log(3 + x), x, 2),


# ::Subsection::Closed::
# Problems 4 - 9 (p. 105)


((b1 + c1*x)*(a + 2*b*x + c*x^2)^1, a*b1*x + (1//2)*(2*b*b1 + a*c1)*x^2 + (1//3)*(b1*c + 2*b*c1)*x^3 + (1//4)*c*c1*x^4, x, 2),
((b1 + c1*x)*(a + 2*b*x + c*x^2)^2, a^2*b1*x + (1//2)*a*(4*b*b1 + a*c1)*x^2 + (2//3)*(2*b^2*b1 + a*b1*c + 2*a*b*c1)*x^3 + (1//2)*(2*b*b1*c + 2*b^2*c1 + a*c*c1)*x^4 + (1//5)*c*(b1*c + 4*b*c1)*x^5 + (1//6)*c^2*c1*x^6, x, 2),
((b1 + c1*x)*(a + 2*b*x + c*x^2)^3, a^3*b1*x + (1//2)*a^2*(6*b*b1 + a*c1)*x^2 + a*(4*b^2*b1 + a*b1*c + 2*a*b*c1)*x^3 + (1//4)*(8*b^3*b1 + 12*a*b*b1*c + 12*a*b^2*c1 + 3*a^2*c*c1)*x^4 + (1//5)*(12*b^2*b1*c + 3*a*b1*c^2 + 8*b^3*c1 + 12*a*b*c*c1)*x^5 + (1//2)*c*(2*b*b1*c + 4*b^2*c1 + a*c*c1)*x^6 + (1//7)*c^2*(b1*c + 6*b*c1)*x^7 + (1//8)*c^3*c1*x^8, x, 2),
((b1 + c1*x)*(a + 2*b*x + c*x^2)^4, a^4*b1*x + (1//2)*a^3*(8*b*b1 + a*c1)*x^2 + (4//3)*a^2*(6*b^2*b1 + a*b1*c + 2*a*b*c1)*x^3 + a*(8*b^3*b1 + 6*a*b*b1*c + 6*a*b^2*c1 + a^2*c*c1)*x^4 + (2//5)*(8*b^4*b1 + 24*a*b^2*b1*c + 3*a^2*b1*c^2 + 16*a*b^3*c1 + 12*a^2*b*c*c1)*x^5 + (1//3)*(16*b^3*b1*c + 12*a*b*b1*c^2 + 8*b^4*c1 + 24*a*b^2*c*c1 + 3*a^2*c^2*c1)*x^6 + (4//7)*c*(6*b^2*b1*c + a*b1*c^2 + 8*b^3*c1 + 6*a*b*c*c1)*x^7 + (1//2)*c^2*(2*b*b1*c + 6*b^2*c1 + a*c*c1)*x^8 + (1//9)*c^3*(b1*c + 8*b*c1)*x^9 + (1//10)*c^4*c1*x^10, x, 2),
((b1 + c1*x)*(a + 2*b*x + c*x^2)^n, (c1*(a + 2*b*x + c*x^2)^(n + 1))/(2*c*(n + 1)) - (((b1*c - b*c1)*(a + 2*b*x + c*x^2)^(n + 1))/(2*c*(n + 1)*sqrt(b^2 - a*c)*(-((b + c*x - sqrt(b^2 - a*c))/(2*sqrt(b^2 - a*c))))^(n + 1)))*hypergeometric2f1(-n, 1 + n, 2 + n, (b + c*x + sqrt(b^2 - a*c))/(2*sqrt(b^2 - a*c))), x, 2),
((b1 + c1*x)/(a + 2*b*x + c*x^2)^1, -(((b1*c - b*c1)*atanh((b + c*x)/sqrt(b^2 - a*c)))/(c*sqrt(b^2 - a*c))) + (c1*log(a + 2*b*x + c*x^2))/(2*c), x, 4),
((b1 + c1*x)/(a + 2*b*x + c*x^2)^2, -((b*b1 - a*c1 + (b1*c - b*c1)*x)/(2*(b^2 - a*c)*(a + 2*b*x + c*x^2))) + ((b1*c - b*c1)*atanh((b + c*x)/sqrt(b^2 - a*c)))/(2*(b^2 - a*c)^(3//2)), x, 3),
((b1 + c1*x)/(a + 2*b*x + c*x^2)^3, -((b*b1 - a*c1 + (b1*c - b*c1)*x)/(4*(b^2 - a*c)*(a + 2*b*x + c*x^2)^2)) + (3*(b1*c - b*c1)*(b + c*x))/(8*(b^2 - a*c)^2*(a + 2*b*x + c*x^2)) - (3*c*(b1*c - b*c1)*atanh((b + c*x)/sqrt(b^2 - a*c)))/(8*(b^2 - a*c)^(5//2)), x, 4),
((b1 + c1*x)/(a + 2*b*x + c*x^2)^4, -((b*b1 - a*c1 + (b1*c - b*c1)*x)/(6*(b^2 - a*c)*(a + 2*b*x + c*x^2)^3)) + (5*(b1*c - b*c1)*(b + c*x))/(24*(b^2 - a*c)^2*(a + 2*b*x + c*x^2)^2) - (5*c*(b1*c - b*c1)*(b + c*x))/(16*(b^2 - a*c)^3*(a + 2*b*x + c*x^2)) + (5*c^2*(b1*c - b*c1)*atanh((b + c*x)/sqrt(b^2 - a*c)))/(16*(b^2 - a*c)^(7//2)), x, 5),
((b1 + c1*x)/(a + 2*b*x + c*x^2)^n, (c1*(a + 2*b*x + c*x^2)^(1 - n))/(2*c*(1 - n)) - ((b1*c - b*c1)*(-((b - sqrt(b^2 - a*c) + c*x)/sqrt(b^2 - a*c)))^(-1 + n)*(a + 2*b*x + c*x^2)^(1 - n)*hypergeometric2f1(1 - n, n, 2 - n, (b + sqrt(b^2 - a*c) + c*x)/(2*sqrt(b^2 - a*c))))/(2^n*(c*sqrt(b^2 - a*c)*(1 - n))), x, 2),
(x/(3 + 6*x + 2*x^2), (1//4)*(1 - sqrt(3))*log(3 - sqrt(3) + 2*x) + (1//4)*(1 + sqrt(3))*log(3 + sqrt(3) + 2*x), x, 3),
((2*x - 3)/(3 + 6*x + 2*x^2)^3, (5 + 4*x)/(4*(3 + 6*x + 2*x^2)^2) - (3 + 2*x)/(2*(3 + 6*x + 2*x^2)) + atanh((3 + 2*x)/sqrt(3))/sqrt(3), x, 4),
((x - 1)/(x^2 + 5*x + 4)^2, (7*x + 13)/(9*(x^2 + 5*x + 4)) + (7*log(x + 1))/27 - (7*log(x + 4))/27, x, 4),
(1/(x^2 + 3*x + 2)^5, -(2*x + 3)/(4*(x^2 + 3*x + 2)^4) + (7*(2*x + 3))/(6*(x^2 + 3*x + 2)^3) - (35*(2*x + 3))/(6*(x^2 + 3*x + 2)^2) + (35*(2*x + 3))/(x^2 + 3*x + 2) + 70*log(x + 1) - 70*log(x + 2), x, 7),


# ::Subsection::Closed::
# Problems 10 - 12 (p. 109)


(1/(x^3*(7 - 6*x + 2*x^2)^2), -1/(490*x^2) - 69/(1715*x) - (2 - 3*x)/(35*x^2*(7 - 6*x + 2*x^2)) - (234*atan((3 - 2*x)/sqrt(5)))/(12005*sqrt(5)) + (80*log(x))/2401 - (40*log(7 - 6*x + 2*x^2))/2401, x, 7),
(x^9/(x^2 + 3*x + 2)^5, 735*x + (x^8*(4 + 3*x))/(4*(2 + 3*x + x^2)^4) - (x^6*(110 + 81*x))/(12*(2 + 3*x + x^2)^3) + (x^4*(184 + 135*x))/(2*(2 + 3*x + x^2)^2) - (x^2*(2206 + 1593*x))/(2*(2 + 3*x + x^2)) - 1471*log(1 + x) + 1472*log(2 + x), x, 8),
((1 + 2*x)^2/(3 + 5*x + 2*x^2)^5, ((1 + 2*x)*(7 + 6*x))/(4*(3 + 5*x + 2*x^2)^4) + (73 + 62*x)/(3*(3 + 5*x + 2*x^2)^3) - (155*(5 + 4*x))/(3*(3 + 5*x + 2*x^2)^2) + (620*(5 + 4*x))/(3 + 5*x + 2*x^2) + 2480*log(x + 1) - 2480*log(2*x + 3), x, 7),


# ::Subsection::Closed::
# Problems 13 - 14 (p. 113)


((a - b*x^2)^3/x^7, -a^3/(6*x^6) + (3*a^2*b)/(4*x^4) - (3*a*b^2)/(2*x^2) - b^3*log(x), x, 3),
(x^13/(a^4 + x^4)^5, -x^10/(16*(a^4 + x^4)^4) - (5*x^6)/(96*(a^4 + x^4)^3) - (5*x^2)/(128*(a^4 + x^4)^2) + (5*x^2)/(256*a^4*(a^4 + x^4)) + (5*atan(x^2/a^2))/(256*a^6), x, 6),


# ::Section::Closed::
# Chapter 4 Integration Problems


# ::Subsection::Closed::
# Problems 1 - 9 (p. 115-116)


(x^(3//2)*(1 + x^2)*(2*sqrt(x) - x)^2, (8*x^(7//2))/7 - x^4 + (2*x^(9//2))/9 + (8*x^(11//2))/11 - (2*x^6)/3 + (2*x^(13//2))/13, x, 9),
((x^(3//2) - 3*x^(3//5))^2*(4*x^(3//2) - (1//3)*x^(2//3)), -((45*x^(43//15))/43) + (360*x^(37//10))/37 + (60*x^(113//30))/113 - (120*x^(23//5))/23 - x^(14//3)/14 + (8*x^(11//2))/11, x, 5),
(1/(1 + sqrt(1 + x)), 2*sqrt(1 + x) - 2*log(1 + sqrt(1 + x)), x, 4),
(x/(1 + sqrt(1 + x)), (2//3)*(1 + x)^(3//2) - x, x, 2),
((sqrt(1 + x) + 1)/(sqrt(1 + x) - 1), x + 4*sqrt(1 + x) + 4*log(1 - sqrt(1 + x)), x, 4),
(1/((1 + x)^(2//3) - sqrt(1 + x)), 6*(1 + x)^(1//6) + 3*(1 + x)^(1//3) + 6*log(1 - (1 + x)^(1//6)), x, 5),
((1 + x^(1//4))^(1//3)/sqrt(x), (12//7)*(1 + x^(1//4))^(7//3) - 3*(1 + x^(1//4))^(4//3), x, 3),
(1/(x^3*(1 + x)^(3//2)), 15/(4*sqrt(1 + x)) - 1/(2*x^2*sqrt(1 + x)) + 5/(4*x*sqrt(1 + x)) - (15//4)*atanh(sqrt(1 + x)), x, 5),
(1/(x^5*(1 - x)^(7//2)), 3003/(320*(1 - x)^(5//2)) + 1001/(64*(1 - x)^(3//2)) + 3003/(64*sqrt(1 - x)) - 1/(4*(1 - x)^(5//2)*x^4) - 13/(24*(1 - x)^(5//2)*x^3) - 143/(96*(1 - x)^(5//2)*x^2) - 429/(64*(1 - x)^(5//2)*x) - (3003//64)*atanh(sqrt(1 - x)), x, 9),


# ::Subsection::Closed::
# Problems 10 - 12 (p. 117-118)


(1/(x^5*(x - 1)^(2//3)), (x - 1)^(1//3)/(4*x^4) + (11*(x - 1)^(1//3))/(36*x^3) + (11*(x - 1)^(1//3))/(27*x^2) + (55*(x - 1)^(1//3))/(81*x) - 110/(81*sqrt(3))*atan((1 - 2*(x - 1)^(1//3))/sqrt(3)) + (55//81)*log(1 + (x - 1)^(1//3)) - (55*log(x))/243, x, 8),
(sqrt((1 - x)/(1 + x)), (1 + x)*sqrt((1 - x)/(1 + x)) - 2*atan(sqrt((1 - x)/(1 + x))), x, 3),
# {Sqrt[(x - a)/(b - x)]*x, x, 4, (1/4)*(a - 5*b)*Sqrt[(x - a)/(b - x)]*(b - x) + (1/2)*Sqrt[(x - a)/(b - x)]*(b - x)^2 - (1/4)*(a - b)*(a + 3*b)*ArcTan[Sqrt[(x - a)/(b - x)]], (1/4)*(a - 5*b)*Sqrt[-((a - x)/(b - x))]*(b - x) + (1/2)*Sqrt[-((a - x)/(b - x))]*(b - x)^2 - (1/4)*(a - b)*(a + 3*b)*ArcTan[Sqrt[-((a - x)/(b - x))]]}


# ::Subsection::Closed::
# Problems 13 - 15 (p. 119-120)


(sqrt(x - 5)*(sqrt(x + 3)/((x - 1)*(x^2 - 25))), (1//6)*atan((1//4)*sqrt(-5 + x)*sqrt(3 + x)) + atanh((sqrt(5)*sqrt(3 + x))/sqrt(-5 + x))/(3*sqrt(5)), x, 6),
# {x^2*(1 - x^2)^(1/4)*Sqrt[1 + x]/(Sqrt[1 - x]*(Sqrt[1 - x] - Sqrt[1 + x])), x, 33, (5/16)*(1 - x)^(3/4)*(1 + x)^(1/4) - (1/16)*(1 - x)^(1/4)*(1 + x)^(3/4) + (1/24)*(1 - x)^(5/4)*(1 + x)^(3/4) + (7*(1 - x^2)^(5/4))/(24*Sqrt[1 - x]) + (x*(1 - x^2)^(5/4))/(6*Sqrt[1 - x]) + (1/6)*Sqrt[1 + x]*(1 - x^2)^(5/4) - (3*ArcTan[1 - (Sqrt[2]*(1 - x)^(1/4))/(1 + x)^(1/4)])/(8*Sqrt[2]) + (3*ArcTan[1 + (Sqrt[2]*(1 - x)^(1/4))/(1 + x)^(1/4)])/(8*Sqrt[2]) + Log[1 + Sqrt[1 - x]/Sqrt[1 + x] - (Sqrt[2]*(1 - x)^(1/4))/(1 + x)^(1/4)]/(8*Sqrt[2]) - Log[1 + Sqrt[1 - x]/Sqrt[1 + x] + (Sqrt[2]*(1 - x)^(1/4))/(1 + x)^(1/4)]/(8*Sqrt[2]), (-(5/48))*(1 - x)^(3/4)*(1 + x)^(1/4) + (5/24)*(1 - x)^(7/4)*(1 + x)^(1/4) - (1/16)*(1 - x)^(1/4)*(1 + x)^(3/4) + (1/24)*(1 - x)^(5/4)*(1 + x)^(3/4) + (1/6)*(1 - x)^(7/4)*(1 + x)^(5/4) + (1/6)*Sqrt[1 + x]*(1 - x^2)^(5/4) + (1 - x^2)^(9/4)/(3*(1 - x)^(3/2)) - (3*ArcTan[1 - (Sqrt[2]*(1 - x)^(1/4))/(1 + x)^(1/4)])/(8*Sqrt[2]) + (3*ArcTan[1 + (Sqrt[2]*(1 - x)^(1/4))/(1 + x)^(1/4)])/(8*Sqrt[2]) + Log[1 + Sqrt[1 - x]/Sqrt[1 + x] - (Sqrt[2]*(1 - x)^(1/4))/(1 + x)^(1/4)]/(8*Sqrt[2]) - Log[1 + Sqrt[1 - x]/Sqrt[1 + x] + (Sqrt[2]*(1 - x)^(1/4))/(1 + x)^(1/4)]/(8*Sqrt[2])}
# {x*(1 + x)^(2/3)*Sqrt[1 - x]/(Sqrt[1 + x]*(1 - x)^(2/3) - (1 + x)^(1/3)*(1 - x)^(5/6)), x, If[$VersionNumber>=8, -46, -4], (-(1/12))*(1 - 3*x)*(1 - x)^(2/3)*(1 + x)^(1/3) + (1/4)*Sqrt[1 - x]*x*Sqrt[1 + x] - (1/4)*(1 - x)*(3 + x) + (1/12)*(1 - x)^(1/3)*(1 + x)^(2/3)*(1 + 3*x) + (1/12)*(1 - x)^(1/6)*(1 + x)^(5/6)*(2 + 3*x) - (1/12)*(1 - x)^(5/6)*(1 + x)^(1/6)*(10 + 3*x) + (1/6)*ArcTan[(1 + x)^(1/6)/(1 - x)^(1/6)] - (4*ArcTan[((1 - x)^(1/3) - 2*(1 + x)^(1/3))/(Sqrt[3]*(1 - x)^(1/3))])/(3*Sqrt[3]) - (5/6)*ArcTan[((1 - x)^(1/3) - (1 + x)^(1/3))/((1 - x)^(1/6)*(1 + x)^(1/6))] + ArcTanh[(Sqrt[3]*(1 - x)^(1/6)*(1 + x)^(1/6))/((1 - x)^(1/3) + (1 + x)^(1/3))]/(6*Sqrt[3])}


# ::Subsection::Closed::
# Problems 16 - 21 (p. 127)


# {1/((x + 1)^2*(x - 1)^4)^(1/3), x, 2, -((3*(x - 1)*(x + 1))/(2*((x + 1)^2*(x - 1)^4)^(1/3))), (3*(1 - x)*(1 + x))/(2*((1 - x)^4*(1 + x)^2)^(1/3))}
# {1/((x - 1)^3*(x + 2)^5)^(1/4), x, 2, (4*(x - 1)*(2 + x))/(3*((x - 1)^3*(x + 2)^5)^(1/4)), -((4*(1 - x)*(2 + x))/(3*((-(1 - x)^3)*(2 + x)^5)^(1/4)))}
# {1/((x + 1)^2*(x - 1)^7)^(1/3), x, 3, -((3*(x - 1)*(x + 1))/(8*((x + 1)^2*(x - 1)^7)^(1/3))) + (9*(x - 1)^2*(x + 1))/(16*((x + 1)^2*(x - 1)^7)^(1/3)), (3*(1 - x)*(1 + x))/(8*((-(1 - x)^7)*(1 + x)^2)^(1/3)) + (9*(1 - x)^2*(1 + x))/(16*((-(1 - x)^7)*(1 + x)^2)^(1/3))}
(1/((x - 1)^2*(x + 1))^(1//3), sqrt(3)*atan((1/sqrt(3))*(1 + (2*(x - 1))/((x - 1)^2*(x + 1))^(1//3))) - (1//2)*log(x + 1) - (3//2)*log(1 - (x - 1)/((x - 1)^2*(x + 1))^(1//3)), x, -3),
# {(x + 1/x)/Sqrt[(x + 1)^3*(x - 2)], x, 9, -((4*(x - 2)*(x + 1))/(3*Sqrt[(x + 1)^3*(x - 2)])) + (2*Sqrt[x - 2]*(x + 1)^(3/2)*ArcSinh[Sqrt[x - 2]/Sqrt[3]])/Sqrt[(x + 1)^3*(x - 2)] - (Sqrt[2]*Sqrt[x - 2]*(x + 1)^(3/2)*ArcTan[(Sqrt[2]*Sqrt[x + 1])/Sqrt[x - 2]])/Sqrt[(x + 1)^3*(x - 2)], (4*(2 - x)*(1 + x))/(3*Sqrt[-((2 - x)*(1 + x)^3)]) + (2*Sqrt[-2 + x]*(1 + x)^(3/2)*ArcSinh[Sqrt[-2 + x]/Sqrt[3]])/Sqrt[-((2 - x)*(1 + x)^3)] - (Sqrt[2]*Sqrt[-2 + x]*(1 + x)^(3/2)*ArcTan[(Sqrt[2]*Sqrt[1 + x])/Sqrt[-2 + x]])/Sqrt[-((2 - x)*(1 + x)^3)]}
(((x - 1)^2*(x + 1))^(1//3)/x^2, -(((x - 1)^2*(x + 1))^(1//3)/x) - (1/sqrt(3))*atan((1/sqrt(3))*(1 - (2*(x - 1))/((x - 1)^2*(x + 1))^(1//3))) - sqrt(3)*atan((1/sqrt(3))*(1 + (2*(x - 1))/((x - 1)^2*(x + 1))^(1//3))) + log(x)/6 - (2//3)*log(x + 1) - (3//2)*log(1 - (x - 1)/((x - 1)^2*(1 + x))^(1//3)) - (1//2)*log(1 + (x - 1)/((x - 1)^2*(1 + x))^(1//3)), x, -6),


# ::Subsection::Closed::
# Problems 22 - 27 (p. 128)


(1/(x^2 - 2*x - 3)^(5//2), (1 - x)/(12*(x^2 - 2*x - 3)^(3//2)) - (1 - x)/(24*sqrt(x^2 - 2*x - 3)), x, 2),
(1/sqrt(x^3 - 5*x^2 + 3*x + 9), ((3 - x)*sqrt(1 + x)*atanh(sqrt(1 + x)/2))/sqrt(x^3 - 5*x^2 + 3*x + 9), x, 4),
(1/(x^3 - 5*x^2 + 3*x + 9)^(3//2), ((3 - x)*(1 + x))/(8*(x^3 - 5*x^2 + 3*x + 9)^(3//2)) + (5*(3 - x)^2*(1 + x))/(64*(x^3 - 5*x^2 + 3*x + 9)^(3//2)) - (15*(3 - x)^3*(1 + x))/(256*(x^3 - 5*x^2 + 3*x + 9)^(3//2)) + (15*(3 - x)^3*(1 + x)^(3//2)*atanh(sqrt(1 + x)/2))/(512*(x^3 - 5*x^2 + 3*x + 9)^(3//2)), x, 7),
(1/(x^3 - 5*x^2 + 3*x + 9)^(1//3), sqrt(3)*atan((1/sqrt(3))*(1 + (2*(x - 3))/(x^3 - 5*x^2 + 3*x + 9)^(1//3))) - (1//2)*log(x + 1) - (3//2)*log(1 - (x - 3)/(x^3 - 5*x^2 + 3*x + 9)^(1//3)), x, -3),
(1/(x^3 - 5*x^2 + 3*x + 9)^(2//3), (3*(3 - x)*(1 + x))/(4*(x^3 - 5*x^2 + 3*x + 9)^(2//3)), x, 3),
(1/(x^3 - 5*x^2 + 3*x + 9)^(4//3), (3*(3 - x)*(1 + x))/(20*(x^3 - 5*x^2 + 3*x + 9)^(4//3)) + (9*(3 - x)^2*(1 + x))/(80*(x^3 - 5*x^2 + 3*x + 9)^(4//3)) - (27*(3 - x)^3*(1 + x))/(320*(x^3 - 5*x^2 + 3*x + 9)^(4//3)), x, 5),


# ::Subsection::Closed::
# Problems 28 - 37 (p. 143-144)


(1/sqrt(4 + 3*x - 2*x^2), -1/sqrt(2)*asin((3 - 4*x)/sqrt(41)), x, 2),
(1/sqrt(-3 + 4*x - x^2), -asin(2 - x), x, 2),
(1/sqrt(-2 - 5*x - 3*x^2), asin(5 + 6*x)/sqrt(3), x, 2),
(1/((x^2 + 4)*sqrt(1 - x^2)), atan((sqrt(5)*x)/(2*sqrt(1 - x^2)))/(2*sqrt(5)), x, 2),
(1/((x^2 + 4)*sqrt(4*x^2 + 1)), 1/(2*sqrt(15))*atanh((sqrt(15)*x)/(2*sqrt(1 + 4*x^2))), x, 2),
(x/((3 - x^2)*sqrt(5 - x^2)), 1/sqrt(2)*atanh(sqrt(5 - x^2)/sqrt(2)), x, 3),
(x/((5 - x^2)*sqrt(3 - x^2)), -1/sqrt(2)*atan(sqrt(3 - x^2)/sqrt(2)), x, 3),
(1/((x^4 - 1)*sqrt(x^2 + 2)), -1//2*atan(x/sqrt(2 + x^2)) - 1/(2*sqrt(3))*atanh((sqrt(3)*x)/sqrt(2 + x^2)), x, 5),
(x/((x^2 - 1)*sqrt(x^2 + 2*x + 4)), -1/(2*sqrt(7))*atanh((5 + 2*x)/(sqrt(7)*sqrt(x^2 + 2*x + 4))) - 1/(2*sqrt(3))*atanh(sqrt(x^2 + 2*x + 4)/sqrt(3)), x, 5),
(1/((x^3 - 8)*sqrt(x^2 + 2*x + 5)), -1/(4*sqrt(3))*atan((1 + x)/(sqrt(3)*sqrt(x^2 + 2*x + 5))) - 1/(12*sqrt(13))*atanh((7 + 3*x)/(sqrt(13)*sqrt(x^2 + 2*x + 5))) + 1//12*atanh(sqrt(x^2 + 2*x + 5)), x, 9),


# ::Subsection::Closed::
# Problems 38 - 42 (p. 145-146)


(x/((x^2 + x + 4)*sqrt(4*x^2 + 4*x + 5)), (1/sqrt(11))*atan(sqrt(4*x^2 + 4*x + 5)/sqrt(11)) - (1/sqrt(165))*atanh((sqrt(11//15)*(2*x + 1))/sqrt(4*x^2 + 4*x + 5)), x, 5),
((x + 3)/((x^2 + 1)*sqrt(x^2 + x + 1)), -2*sqrt(2)*atan((1 - x)/(sqrt(2)*sqrt(1 + x + x^2))) + sqrt(2)*atanh((1 + x)/(sqrt(2)*sqrt(1 + x + x^2))), x, 5),
((2*x + 1)/((3*x^2 + 4*x + 4)*sqrt(x^2 + 6*x - 1)), (-(5/(6*sqrt(14))))*atan((sqrt(7)*(2 - x))/(2*sqrt(2)*sqrt(x^2 + 6*x - 1))) - (1/(3*sqrt(7)))*atanh((sqrt(7)*(1 + x))/sqrt(x^2 + 6*x - 1)), x, 5),
# {(A*x + B)/((5*x^2 - 18*x + 17)*Sqrt[10*x^2 - 22*x + 13]), x, 5, (-((2*A + B)/Sqrt[35]))*ArcTan[(Sqrt[35]*(2 - x))/Sqrt[10*x^2 - 22*x + 13]] - ((A + B)/(2*Sqrt[35]))*ArcTanh[(Sqrt[35]*(1 - x))/(2*Sqrt[10*x^2 - 22*x + 13])], -(((2*A + B)*ArcTan[(Sqrt[35]*(2 - x))/Sqrt[13 - 22*x + 10*x^2]])/Sqrt[35]) - ((A + B)*ArcTanh[(Sqrt[35]*(A + B - (A + B)*x))/(2*(A + B)*Sqrt[13 - 22*x + 10*x^2])])/(2*Sqrt[35])}
((x - 2)/((5*x^2 - 18*x + 17)*sqrt(10*x^2 - 22*x + 13)), (1/(2*sqrt(35)))*atanh((sqrt(35)*(1 - x))/(2*sqrt(10*x^2 - 22*x + 13))), x, 2),


# ::Subsection::Closed::
# Problems 43 - 49 (p. 163)


(x^4*sqrt(5 - x^2), -25//16*x*sqrt(5 - x^2) - (5//24)*x^3*sqrt(5 - x^2) + (1//6)*x^5*sqrt(5 - x^2) + (125//16)*asin(x/sqrt(5)), x, 4),
(1/(x^6*sqrt(x^2 + 2)), -(sqrt(x^2 + 2)/(10*x^5)) + sqrt(x^2 + 2)/(15*x^3) - sqrt(x^2 + 2)/(15*x), x, 3),
(1/(2*x^2 + 3)^(7//2), x/(15*(2*x^2 + 3)^(5//2)) + (4*x)/(135*(2*x^2 + 3)^(3//2)) + (8*x)/(405*sqrt(2*x^2 + 3)), x, 3),
(x/(1 + x^2 + a*sqrt(1 + x^2)), log(a + sqrt(1 + x^2)), x, 3),
((x^2 - x + 1)/((1 + x^2)*sqrt(1 + x^2)), 1/sqrt(1 + x^2) + asinh(x), x, 2),
(sqrt(1 + x^2)/(2 + x^2), asinh(x) - 1/sqrt(2)*atanh(x/(sqrt(2)*sqrt(1 + x^2))), x, 4),
(1/((2 + x^2)^2*sqrt(1 + x^2)), -((x*sqrt(1 + x^2))/(4*(2 + x^2))) + 3/(4*sqrt(2))*atanh(x/(sqrt(2)*sqrt(1 + x^2))), x, 3),


# ::Subsection::Closed::
# Problems 50 - 62 (p. 164)


(x^2/((x^2 - 6)*sqrt(x^2 - 2)), atanh(x/sqrt(x^2 - 2)) - sqrt(3//2)*atanh((sqrt(2//3)*x)/sqrt(x^2 - 2)), x, 5),
((x^2 + 5)/((1 + x^2)^2*sqrt(1 - x^2)), (x*sqrt(1 - x^2))/(1 + x^2) + 2*sqrt(2)*atan((sqrt(2)*x)/sqrt(1 - x^2)), x, 4),
((4*x - sqrt(1 - x^2))/(5 + sqrt(1 - x^2)), -x - 4*sqrt(1 - x^2) + 5*asin(x) + (25*atan(x/(2*sqrt(6))))/(2*sqrt(6)) - (25*atan((5*x)/(2*sqrt(6)*sqrt(1 - x^2))))/(2*sqrt(6)) + 20*log(5 + sqrt(1 - x^2)), x, 15),
((2 - sqrt(x^2 + 1))*(x^2/(sqrt(x^2 + 1)*((x^2 + 1)^(3//2) - x^3 + 1))), (8*x)/9 - x^2//6 + (8*sqrt(x^2 + 1))/9 - (1//6)*x*sqrt(x^2 + 1) - (41*asinh(x))/54 + (4//27)*sqrt(2)*atan((1 + 3*x)/(2*sqrt(2))) + (4//27)*sqrt(2)*atan((1 + x)/(sqrt(2)*sqrt(x^2 + 1))) + (7//27)*atanh((1 - x)/(2*sqrt(x^2 + 1))) - (7//54)*log(3 + 2*x + 3*x^2), x, 32),
(x*sqrt(2*r*x - x^2), (-(1//2))*r*(r - x)*sqrt(2*r*x - x^2) - (1//3)*(2*r*x - x^2)^(3//2) + r^3*atan(x/sqrt(2*r*x - x^2)), x, 4),
(x^2*sqrt(2*r*x - x^2), -5//8*r^2*(r - x)*sqrt(2*r*x - x^2) - (5//12)*r*(2*r*x - x^2)^(3//2) - (1//4)*x*(2*r*x - x^2)^(3//2) + (5//4)*r^4*atan(x/sqrt(2*r*x - x^2)), x, 5),
(x^3*sqrt(2*r*x - x^2), (-(7//8))*r^3*(r - x)*sqrt(2*r*x - x^2) - (7//12)*r^2*(2*r*x - x^2)^(3//2) - (7//20)*r*x*(2*r*x - x^2)^(3//2) - (1//5)*x^2*(2*r*x - x^2)^(3//2) + (7//4)*r^5*atan(x/sqrt(2*r*x - x^2)), x, 6),
(1/((x^2 - 1)*sqrt(2*x + x^2)), (-(1//2))*atan(sqrt(2*x + x^2)) - 1/(2*sqrt(3))*atanh((1 + 2*x)/(sqrt(3)*sqrt(2*x + x^2))), x, 5),
((3*x - 2)/((x + 1)^3*sqrt(2*x - x^2)), -((5*sqrt(2*x - x^2))/(6*(1 + x)^2)) - (2*sqrt(2*x - x^2))/(3*(1 + x)) + 1/(2*sqrt(3))*atan((1 - 2*x)/(sqrt(3)*sqrt(2*x - x^2))), x, 4),
(1/sqrt(1 + x + x^2), asinh((1 + 2*x)/sqrt(3)), x, 2),
(x^3/sqrt(1 + x + x^2), (1//3)*x^2*sqrt(1 + x + x^2) - (1//24)*(1 + 10*x)*sqrt(1 + x + x^2) + (7//16)*asinh((1 + 2*x)/sqrt(3)), x, 4),
(1/(1 + x + x^2)^(3//2), (2*(1 + 2*x))/(3*sqrt(1 + x + x^2)), x, 1),
(x/(1 + x + x^2)^(3//2), -((2*(2 + x))/(3*sqrt(1 + x + x^2))), x, 1),


# ::Subsection::Closed::
# Problems 63 - 72 (p. 165)


(x^3/(1 + x + x^2)^(3//2), -((2*x^2*(2 + x))/(3*sqrt(1 + x + x^2))) + (1//3)*(5 + 2*x)*sqrt(1 + x + x^2) - (3//2)*asinh((1 + 2*x)/sqrt(3)), x, 4),
(x^2*sqrt(1 + x + x^2), (1//64)*(1 + 2*x)*sqrt(1 + x + x^2) - (5//24)*(1 + x + x^2)^(3//2) + (1//4)*x*(1 + x + x^2)^(3//2) + (3//128)*asinh((1 + 2*x)/sqrt(3)), x, 5),
((1 + x + x^2)^(3//2), (9//64)*(1 + 2*x)*sqrt(1 + x + x^2) + (1//8)*(1 + 2*x)*(1 + x + x^2)^(3//2) + (27//128)*asinh((1 + 2*x)/sqrt(3)), x, 4),
((1 + x + x^2)^(5//2), (45//512)*(1 + 2*x)*sqrt(1 + x + x^2) + (5//64)*(1 + 2*x)*(1 + x + x^2)^(3//2) + (1//12)*(1 + 2*x)*(1 + x + x^2)^(5//2) + 135//1024*asinh((1 + 2*x)/sqrt(3)), x, 5),
(1/(x^2*sqrt(1 + x + x^2)), -(sqrt(1 + x + x^2)/x) + (1//2)*atanh((2 + x)/(2*sqrt(1 + x + x^2))), x, 3),
(1/(x^3*sqrt(1 + x + x^2)), -(sqrt(1 + x + x^2)/(2*x^2)) + (3*sqrt(1 + x + x^2))/(4*x) + (1//8)*atanh((2 + x)/(2*sqrt(1 + x + x^2))), x, 4),
(1/(x^2*(1 + x + x^2)^(3//2)), (2*(1 - x))/(3*x*sqrt(1 + x + x^2)) - (5*sqrt(1 + x + x^2))/(3*x) + (3//2)*atanh((2 + x)/(2*sqrt(1 + x + x^2))), x, 4),
(1/(x^3*(1 + x + x^2)^(3//2)), (2*(1 - x))/(3*x^2*sqrt(1 + x + x^2)) - (7*sqrt(1 + x + x^2))/(6*x^2) + (37*sqrt(1 + x + x^2))/(12*x) - (3//8)*atanh((2 + x)/(2*sqrt(1 + x + x^2))), x, 5),
(1/((x + 1)*sqrt(1 + x + x^2)), -atanh((1 - x)/(2*sqrt(1 + x + x^2))), x, 2),
(1/((x^3 - x)*sqrt(x^2 + 2*x + 4)), (1//2)*atanh((4 + x)/(2*sqrt(x^2 + 2*x + 4))) - 1/(2*sqrt(7))*atanh((5 + 2*x)/(sqrt(7)*sqrt(x^2 + 2*x + 4))) - 1/(2*sqrt(3))*atanh(sqrt(x^2 + 2*x + 4)/sqrt(3)), x, 10),


# ::Subsection::Closed::
# Problems 73 - 79 (p. 166)


(sqrt(x^2 + 2*x + 4)/(x - 1)^2, sqrt(x^2 + 2*x + 4)/(1 - x) + asinh((1 + x)/sqrt(3)) - 2/sqrt(7)*atanh((5 + 2*x)/(sqrt(7)*sqrt(x^2 + 2*x + 4))), x, 6),
((2*x + 3)/((x^2 + 2*x + 3)^2*sqrt(x^2 + 2*x + 4)), -(((3 - x)*sqrt(4 + 2*x + x^2))/(4*(3 + 2*x + x^2))) - atan((1 + x)/(sqrt(2)*sqrt(4 + 2*x + x^2)))/(4*sqrt(2)) + atanh(sqrt(4 + 2*x + x^2)), x, 6),
((2*x^3 + 3*x^2)/((2*x^2 + x - 3)*sqrt(x^2 + 2*x - 3)), sqrt(x^2 + 2*x - 3) + sqrt(x^2 + 2*x - 3)/(2*(1 - x)), x, 4),
((x^4 + 1)/((x^2 + x + 1)*sqrt(x^2 + x + 2)), -7//4*sqrt(x^2 + x + 2) + (1//2)*x*sqrt(x^2 + x + 2) - (1//8)*asinh((1 + 2*x)/sqrt(7)) + 1/sqrt(3)*atan((1 + 2*x)/(sqrt(3)*sqrt(x^2 + x + 2))) - atanh(sqrt(x^2 + x + 2)), x, 14),
(1/(x^2 + 2*x + 4)^(7//2), (1 + x)/(15*(x^2 + 2*x + 4)^(5//2)) + (4*(1 + x))/(135*(x^2 + 2*x + 4)^(3//2)) + (8*(1 + x))/(405*sqrt(x^2 + 2*x + 4)), x, 3),
(1/(3*x^2 + 8*x + 1)^(5//2), -((4 + 3*x)/(39*(3*x^2 + 8*x + 1)^(3//2))) + (2*(4 + 3*x))/(169*sqrt(3*x^2 + 8*x + 1)), x, 2),
(1/(5 + 4*x - 3*x^2)^(5//2), -((2 - 3*x)/(57*(5 + 4*x - 3*x^2)^(3//2))) - (2*(2 - 3*x))/(361*sqrt(5 + 4*x - 3*x^2)), x, 2),


# ::Subsection::Closed::
# Problems 80 - 84 (p. 167)


(1/(1 + sqrt(x^2 + 2*x + 2)), 1/(1 + x) - sqrt(x^2 + 2*x + 2)/(1 + x) + asinh(1 + x), x, 5),
(1/(x + sqrt(1 + x + x^2)), -x + sqrt(1 + x + x^2) - 3//2*asinh((1 + 2*x)/sqrt(3)) + 2*log(x + sqrt(1 + x + x^2)), x, -3),
(x^2/(2*x + 1 + 2*sqrt(1 + x + x^2)), -(x^3//9) - x^4//6 + (1//96)*(1 + 2*x)*sqrt(1 + x + x^2) - (5//36)*(1 + x + x^2)^(3//2) + (1//6)*x*(1 + x + x^2)^(3//2) + (1//64)*asinh((1 + 2*x)/sqrt(3)), x, 7),
((sqrt(1 + x + x^2) - 3*x)/(sqrt(1 + x + x^2) - 1), x - 3*sqrt(1 + x + x^2) + (5//2)*asinh((1 + 2*x)/sqrt(3)) + 4*atanh((1 - x)/(2*sqrt(1 + x + x^2))) - atanh((2 + x)/(2*sqrt(1 + x + x^2))) + log(x) - 4*log(1 + x), x, 26),
((x + 1)/(sqrt(x^2 + 2*x + 4) - sqrt(x^2 + x + 1)), -2*sqrt(x^2 + x + 1) + (1//4)*(1 + 2*x)*sqrt(x^2 + x + 1) - 2*sqrt(x^2 + 2*x + 4) + (1//2)*(1 + x)*sqrt(x^2 + 2*x + 4) + (11//2)*asinh((1 + x)/sqrt(3)) + (43//8)*asinh((1 + 2*x)/sqrt(3)) - 2*sqrt(7)*atanh((1 + 5*x)/(2*sqrt(7)*sqrt(x^2 + x + 1))) + 2*sqrt(7)*atanh((1 - 2*x)/(sqrt(7)*sqrt(x^2 + 2*x + 4))), x, 36),


# ::Subsection::Closed::
# Problems 85 - 91 (p. 177)


(1/(x^3*sqrt(x - 1)), sqrt(x - 1)/(2*x^2) + (3*sqrt(x - 1))/(4*x) + (3//4)*atan(sqrt(x - 1)), x, 4),
(1/(x^2*(1 - 3/x)^(4//3)), -(1/(1 - 3/x)^(1//3)), x, 1),
((3*x - 1)^(4//3)/x^2, 12*(3*x - 1)^(1//3) - (3*x - 1)^(4//3)/x + 4*sqrt(3)*atan((1 - 2*(3*x - 1)^(1//3))/sqrt(3)) + 2*log(x) - 6*log(1 + (3*x - 1)^(1//3)), x, 6),
((4 - 3*x)^(4//3)*x^2, (-(16//63))*(4 - 3*x)^(7//3) + (4//45)*(4 - 3*x)^(10//3) - (1//117)*(4 - 3*x)^(13//3), x, 2),
((1 - 2*x^(1//3))^(3//4)/x, 4*(1 - 2*x^(1//3))^(3//4) + 6*atan((1 - 2*x^(1//3))^(1//4)) - 6*atanh((1 - 2*x^(1//3))^(1//4)), x, 6),
(x/(3 - 2*sqrt(x))^(3//4), (-(27//2))*(3 - 2*sqrt(x))^(1//4) + (27//10)*(3 - 2*sqrt(x))^(5//4) - (1//2)*(3 - 2*sqrt(x))^(9//4) + (1//26)*(3 - 2*sqrt(x))^(13//4), x, 3),
((2*sqrt(x) - 1)^(5//4)/x^2, -((2*sqrt(x) - 1)^(5//4)/x) - (5*(2*sqrt(x) - 1)^(1//4))/(2*sqrt(x)) - (5*atan(1 - sqrt(2)*(2*sqrt(x) - 1)^(1//4)))/(2*sqrt(2)) + (5*atan(1 + sqrt(2)*(2*sqrt(x) - 1)^(1//4)))/(2*sqrt(2)) - (5*log(1 - sqrt(2)*(2*sqrt(x) - 1)^(1//4) + sqrt(2*sqrt(x) - 1)))/(4*sqrt(2)) + (5*log(1 + sqrt(2)*(2*sqrt(x) - 1)^(1//4) + sqrt(2*sqrt(x) - 1)))/(4*sqrt(2)), x, 13),


# ::Subsection::Closed::
# Problems 92 - 100 (p. 178)


((x^7 + 1)^(1//3)*x^6, (3//28)*(x^7 + 1)^(4//3), x, 1),
(x^6/(x^7 + 1)^(5//3), -(3/(14*(x^7 + 1)^(2//3))), x, 1),
(1/(x*(2*x^7 - 27)^(2//3)), (-(1/(21*sqrt(3))))*atan((3 - 2*(2*x^7 - 27)^(1//3))/(3*sqrt(3))) - log(x)/18 + (1//42)*log(3 + (2*x^7 - 27)^(1//3)), x, 5),
((x^7 + 1)^(2//3)/x^8, -((x^7 + 1)^(2//3)/(7*x^7)) + (2*atan((1 + 2*(x^7 + 1)^(1//3))/sqrt(3)))/(7*sqrt(3)) - log(x)/3 + (1//7)*log(1 - (x^7 + 1)^(1//3)), x, 6),
((3 + 4*x^4)^(1//4)/x^2, -((3 + 4*x^4)^(1//4)/x) - atan((sqrt(2)*x)/(3 + 4*x^4)^(1//4))/sqrt(2) + atanh((sqrt(2)*x)/(3 + 4*x^4)^(1//4))/sqrt(2), x, 5),
(x^2*(3 + 4*x^4)^(5//4), (15//32)*x^3*(3 + 4*x^4)^(1//4) + (1//8)*x^3*(3 + 4*x^4)^(5//4) - (45*atan((sqrt(2)*x)/(3 + 4*x^4)^(1//4)))/(128*sqrt(2)) + (45*atanh((sqrt(2)*x)/(3 + 4*x^4)^(1//4)))/(128*sqrt(2)), x, 6),
(x^6*(3 + 4*x^4)^(1//4), (3//128)*x^3*(3 + 4*x^4)^(1//4) + (1//8)*x^7*(3 + 4*x^4)^(1//4) + (27*atan((sqrt(2)*x)/(3 + 4*x^4)^(1//4)))/(512*sqrt(2)) - (27*atanh((sqrt(2)*x)/(3 + 4*x^4)^(1//4)))/(512*sqrt(2)), x, 6),
# {(x*(1 - x^2))^(1/3), x, 6, (1/2)*x*(x*(1 - x^2))^(1/3) + (1/(2*Sqrt[3]))*ArcTan[(2*x - (x*(1 - x^2))^(1/3))/(Sqrt[3]*(x*(1 - x^2))^(1/3))] + Log[x]/12 - (1/4)*Log[x + (x*(1 - x^2))^(1/3)], (1/2)*x*(x - x^3)^(1/3) - (x^(2/3)*(1 - x^2)^(2/3)*ArcTan[(1 - (2*x^(2/3))/(1 - x^2)^(1/3))/Sqrt[3]])/(2*Sqrt[3]*(x - x^3)^(2/3)) - (x^(2/3)*(1 - x^2)^(2/3)*Log[x^(2/3) + (1 - x^2)^(1/3)])/(4*(x - x^3)^(2/3))}
# {Sqrt[x*(1 + x^(1/3))], x, 8, (7/64)*Sqrt[x*(1 + x^(1/3))] - (21*Sqrt[x*(1 + x^(1/3))])/(128*x^(1/3)) - (7/80)*x^(1/3)*Sqrt[x*(1 + x^(1/3))] + (3/40)*x^(2/3)*Sqrt[x*(1 + x^(1/3))] + (3/5)*x*Sqrt[x*(1 + x^(1/3))] + (21/128)*ArcTanh[x^(2/3)/Sqrt[x*(1 + x^(1/3))]], (7/64)*Sqrt[x + x^(4/3)] - (21*Sqrt[x + x^(4/3)])/(128*x^(1/3)) - (7/80)*x^(1/3)*Sqrt[x + x^(4/3)] + (3/40)*x^(2/3)*Sqrt[x + x^(4/3)] + (3/5)*x*Sqrt[x + x^(4/3)] + (21/128)*ArcTanh[x^(2/3)/Sqrt[x + x^(4/3)]]}


# ::Subsection::Closed::
# Problems 101 - 112 (p. 193-194)


(x^3/((x^4 - 1)*sqrt(2*x^8 + 1)), -1/(4*sqrt(3))*atanh((2*x^4 + 1)/(sqrt(3)*sqrt(2*x^8 + 1))), x, 3),
(x^9*sqrt(1 + x^5 + x^10), (-(1//40))*(1 + 2*x^5)*sqrt(1 + x^5 + x^10) + (1//15)*(1 + x^5 + x^10)^(3//2) - (3//80)*asinh((1 + 2*x^5)/sqrt(3)), x, 5),
(1/(x^5*sqrt(4 + 2*x^2 + x^4)), -(sqrt(4 + 2*x^2 + x^4)/(16*x^4)) + (3*sqrt(4 + 2*x^2 + x^4))/(64*x^2) + (1//128)*atanh((4 + x^2)/(2*sqrt(4 + 2*x^2 + x^4))), x, 5),
((x^2 - 1)/(x*sqrt(1 + 3*x^2 + x^4)), atanh((1 + x^2)/sqrt(1 + 3*x^2 + x^4)), x, 3),
((x^4 - 3*x^2)^(3//5)*(2*x^3 - 3*x), (5//16)*(x^4 - 3*x^2)^(8//5), x, 1),
((3*x^8 - 2*x^5 - x^2*(3*x^3 - 1)^(2//3))/(3*x^3 - 1)^(3//4), (-(4//27))*(3*x^3 - 1)^(1//4) - (4//33)*(3*x^3 - 1)^(11//12) + (4//243)*(3*x^3 - 1)^(9//4), x, 9),
(1/((x^3 - 1)*(x^3 + 2)^(1//3)), -(atan((1 + (2*3^(1//3)*x)/(2 + x^3)^(1//3))/sqrt(3))/3^(5//6)) - log(-1 + x^3)/(6*3^(1//3)) + log(3^(1//3)*x - (2 + x^3)^(1//3))/(2*3^(1//3)), x, 1),
(1/((x^4 + 1)*(x^4 + 2)^(1//4)), -(atan(1 - (sqrt(2)*x)/(x^4 + 2)^(1//4))/(2*sqrt(2))) + atan(1 + (sqrt(2)*x)/(x^4 + 2)^(1//4))/(2*sqrt(2)) - log(1 + x^2/sqrt(x^4 + 2) - (sqrt(2)*x)/(x^4 + 2)^(1//4))/(4*sqrt(2)) + log(1 + x^2/sqrt(x^4 + 2) + (sqrt(2)*x)/(x^4 + 2)^(1//4))/(4*sqrt(2)), x, 10),
((x^3 - 1)/(x^3 + 2)^(1//3), (1//3)*x*(2 + x^3)^(2//3) - (5*atan((1 + (2*x)/(2 + x^3)^(1//3))/sqrt(3)))/(3*sqrt(3)) + (5//6)*log(-x + (2 + x^3)^(1//3)), x, 2),
((x^4 + 1)^(3//4)/(x^4 + 2)^2, (x*(x^4 + 1)^(3//4))/(8*(x^4 + 2)) + (3*atan(x/(2^(1//4)*(x^4 + 1)^(1//4))))/(16*2^(3//4)) + (3*atanh(x/(2^(1//4)*(x^4 + 1)^(1//4))))/(16*2^(3//4)), x, 5),
# {(x^5 - 2)^2/((x^5 + 3)^3*(x^5 + 3)^(1/5)), x, 3, -(5*x*(x^5 - 2))/(33*(x^5 + 3)^(11/5)) + (5*x)/(297*(x^5 + 3)^(6/5)) + (97*x)/(891*(x^5 + 3)^(1/5)), (x*(2 - x^5)^2)/(33*(3 + x^5)^(11/5)) + (10*x*(2 - x^5))/(297*(3 + x^5)^(6/5)) + (100*x)/(891*(3 + x^5)^(1/5))}
(1/((x^3 + 3*x^2 + 3*x)*(x^3 + 3*x^2 + 3*x + 3)^(1//3)), -(atan((1 + (2*3^(1//3)*(1 + x))/(2 + (1 + x)^3)^(1//3))/sqrt(3))/3^(5//6)) - log(1 - (1 + x)^3)/(6*3^(1//3)) + log(3^(1//3)*(1 + x) - (2 + (1 + x)^3)^(1//3))/(2*3^(1//3)), x, 3),


# ::Subsection::Closed::
# Problems 113 - 122 (p. 195-196)


((1 - x^2)/((1 + x^2)*sqrt(1 + x^4)), 1/sqrt(2)*atan((sqrt(2)*x)/sqrt(1 + x^4)), x, 2),
((1 + x^2)/((1 - x^2)*sqrt(1 + x^4)), 1/sqrt(2)*atanh((sqrt(2)*x)/sqrt(1 + x^4)), x, 2),
# {(x^2 + 1)/(x*Sqrt[1 + x^4]), x, 6, ArcTanh[(x^2 - 1)/Sqrt[1 + x^4]], ArcSinh[x^2]/2 - (1/2)*ArcTanh[Sqrt[1 + x^4]]}
# {(x^2 - 1)/(x*Sqrt[1 + x^4]), x, 6, ArcTanh[(x^2 + 1)/Sqrt[1 + x^4]], ArcSinh[x^2]/2 + (1/2)*ArcTanh[Sqrt[1 + x^4]]}
((1 + x^2)/((1 - x^2)*sqrt(1 + x^2 + x^4)), (1/sqrt(3))*atanh((sqrt(3)*x)/sqrt(1 + x^2 + x^4)), x, 2),
((1 - x^2)/((1 + x^2)*sqrt(1 + x^2 + x^4)), atan(x/sqrt(1 + x^2 + x^4)), x, 2),
((x^4 - 1)/(x^2*sqrt(x^4 + x^2 + 1)), sqrt(x^4 + x^2 + 1)/x, x, 1),
((1 - x^2)/((1 + 2*a*x + x^2)*sqrt(1 + 2*a*x + 2*b*x^2 + 2*a*x^3 + x^4)), (1/(sqrt(2)*sqrt(1 - b)))*atan((a + 2*(a^2 - b + 1)*x + a*x^2)/(sqrt(2)*sqrt(1 - b)*sqrt(1 + 2*a*x + 2*b*x^2 + 2*a*x^3 + x^4))), x, 1),
(1/((1 + x^4)*sqrt(sqrt(1 + x^4) - x^2)), atan(x/sqrt(sqrt(1 + x^4) - x^2)), x, 2),
(1/((1 + x^(2*n))*((1 + x^(2*n))^(1/n) - x^2)^(1//2)), atan(x/sqrt((1 + x^(2*n))^(1/n) - x^2)), x, 2),


# ::Section::Closed::
# Chapter 5 Integration Problems


# ::Subsection::Closed::
# Problems 1 - 3 (p. 202-203)


(cos(x)^2, x/2 + (1//2)*cos(x)*sin(x), x, 2),
(cos(x)^3, sin(x) - sin(x)^3//3, x, 2),
(sin(x)^4, (3*x)/8 - (3//8)*cos(x)*sin(x) - (1//4)*cos(x)*sin(x)^3, x, 3),


# ::Subsection::Closed::
# Problems 4 - 7 (p. 208)


(cos(x)^6, (5*x)/16 + (5//16)*cos(x)*sin(x) + (5//24)*cos(x)^3*sin(x) + (1//6)*cos(x)^5*sin(x), x, 4),
(sin(x)^8, (35*x)/128 - (35//128)*cos(x)*sin(x) - (35//192)*cos(x)*sin(x)^3 - (7//48)*cos(x)*sin(x)^5 - (1//8)*cos(x)*sin(x)^7, x, 5),
# {Cos[Pi/4 + x/2]^4, x, 3, (3*x)/8 + Cos[x]/2 - (1/8)*Cos[x]*Sin[x], (3*x)/8 + (3/4)*Cos[Pi/4 + x/2]*Sin[Pi/4 + x/2] + (1/2)*Cos[Pi/4 + x/2]^3*Sin[Pi/4 + x/2]}
(sin(3*x - π/12)^3, (-(1//3))*cos(π/12 - 3*x) + (1//9)*cos(π/12 - 3*x)^3, x, 2),


# ::Subsection::Closed::
# Problems 8 - 11 (p. 211)


(1/sin(x)^6, -cot(x) - (2*cot(x)^3)/3 - cot(x)^5//5, x, 2),
(csc(x)^7, (-(5//16))*atanh(cos(x)) - (5//16)*cot(x)*csc(x) - (5//24)*cot(x)*csc(x)^3 - (1//6)*cot(x)*csc(x)^5, x, 4),
(1/cos(x)^12, tan(x) + (5*tan(x)^3)/3 + 2*tan(x)^5 + (10*tan(x)^7)/7 + (5*tan(x)^9)/9 + tan(x)^11//11, x, 2),
(1/cos(π/4 + 3*x)^3, (1//6)*atanh(sin(π/4 + 3*x)) + (1//6)*sec(π/4 + 3*x)*tan(π/4 + 3*x), x, 2),


# ::Subsection::Closed::
# Problems 12 - 14 (p. 213)


(tan(x)^6, -x + tan(x) - tan(x)^3//3 + tan(x)^5//5, x, 4),
(1/tan(x)^5, cot(x)^2//2 - cot(x)^4//4 + log(sin(x)), x, 3),
(cot(x/3 - 3*π/4)^4, x + 3*cot(π/4 + x/3) - cot(π/4 + x/3)^3, x, 3),


# ::Subsection::Closed::
# Problems 15 - 20 (p. 219-220)


(sin(x)^4*cos(x)^6, (3*x)/256 + (3//256)*cos(x)*sin(x) + (1//128)*cos(x)^3*sin(x) + (1//160)*cos(x)^5*sin(x) - (3//80)*cos(x)^7*sin(x) - (1//10)*cos(x)^7*sin(x)^3, x, 6),
(sin(x)^7*cos(x)^6, (-(1//7))*cos(x)^7 + cos(x)^9//3 - (3*cos(x)^11)/11 + cos(x)^13//13, x, 3),
(sin(x)^11/cos(x), (5*cos(x)^2)/2 - (5*cos(x)^4)/2 + (5*cos(x)^6)/3 - (5*cos(x)^8)/8 + cos(x)^10//10 - log(cos(x)), x, 4),
(1/(sin(x)^6*cos(x)^6), -10*cot(x) - (5*cot(x)^3)/3 - cot(x)^5//5 + 10*tan(x) + (5*tan(x)^3)/3 + tan(x)^5//5, x, 3),
(sin(x)^2*cos(x)^2, x/8 + (1//8)*cos(x)*sin(x) - (1//4)*cos(x)^3*sin(x), x, 3),
(sin(x)^4*cos(x)^4, (3*x)/128 + (3//128)*cos(x)*sin(x) + (1//64)*cos(x)^3*sin(x) - (1//16)*cos(x)^5*sin(x) - (1//8)*cos(x)^5*sin(x)^3, x, 5),
(sin(x)^6*cos(x)^6, (5*x)/1024 + (5*cos(x)*sin(x))/1024 + (5*cos(x)^3*sin(x))/1536 + (1//384)*cos(x)^5*sin(x) - (1//64)*cos(x)^7*sin(x) - (1//24)*cos(x)^7*sin(x)^3 - (1//12)*cos(x)^7*sin(x)^5, x, 7),
(sin(x)^8*cos(x)^8, (35*x)/32768 + (35*cos(x)*sin(x))/32768 + (35*cos(x)^3*sin(x))/49152 + (7*cos(x)^5*sin(x))/12288 + (cos(x)^7*sin(x))/2048 - (1//256)*cos(x)^9*sin(x) - (5//384)*cos(x)^9*sin(x)^3 - (1//32)*cos(x)^9*sin(x)^5 - (1//16)*cos(x)^9*sin(x)^7, x, 9),
(sin(x)^(2*m)*cos(x)^(2*m), (cos(x)^(-1 + 2*m)*(cos(x)^2)^(1//2 - m)*hypergeometric2f1((1//2)*(1 - 2*m), (1//2)*(1 + 2*m), (1//2)*(3 + 2*m), sin(x)^2)*sin(x)^(1 + 2*m))/(1 + 2*m), x, 1),
(1/(sin(π/4 + 2*x)^3*cos(π/4 + 2*x)), (-(1//4))*cot(π/4 + 2*x)^2 + (1//2)*log(tan(π/4 + 2*x)), x, 3),


# ::Subsection::Closed::
# Problems 21 - 29 (p. 223)


(tan(x)^2*sec(x)^2, tan(x)^3//3, x, 2),
(cot(x)^3*csc(x), csc(x) - csc(x)^3//3, x, 2),
(tan(x)*sec(x)^3, sec(x)^3//3, x, 2),
(cot(x)^2*csc(x)^3, (1//8)*atanh(cos(x)) + (1//8)*cot(x)*csc(x) - (1//4)*cot(x)*csc(x)^3, x, 3),
(cos(x)^3/sin(x)^7, csc(x)^4//4 - csc(x)^6//6, x, 3),
(tan(x)^5*sec(x)^(3//2), (2//3)*sec(x)^(3//2) - (4//7)*sec(x)^(7//2) + (2//11)*sec(x)^(11//2), x, 3),
(tan(x)^(3//2)*sec(x)^4, (2//5)*tan(x)^(5//2) + (2//9)*tan(x)^(9//2), x, 3),
(cot(x)^4*csc(x)^3, (-(1//16))*atanh(cos(x)) - (1//16)*cot(x)*csc(x) + (1//8)*cot(x)*csc(x)^3 - (1//6)*cot(x)^3*csc(x)^3, x, 4),
(tan(π/4 + x/2)^2*sec(π/4 + x/2)^3, (-(1//4))*atanh(sin(π/4 + x/2)) - (1//4)*sec(π/4 + x/2)*tan(π/4 + x/2) + (1//2)*sec(π/4 + x/2)^3*tan(π/4 + x/2), x, 3),


# ::Subsection::Closed::
# Problems 30 - 32 (p. 228)


# {(a*Sec[x]^2 - Sin[2*x])^2*(Cot[x]^3 + 1), x, 8, x/2 + 4*a*x + 2*Cos[x]^2 + Cos[x]^4 + 4*a*Cot[x] - (1/2)*a^2*Cot[x]^2 + (4 - a)*a*Log[Cos[x]] + (4 + a^2)*Log[Sin[x]] + (1/2)*Cos[x]*Sin[x] - Cos[x]^3*Sin[x] + a^2*Tan[x] + (1/3)*a^2*Tan[x]^3, (1/2)*(1 + 8*a)*x + 4*a*Cot[x] - (1/2)*a^2*Cot[x]^2 + 4*(1 + a)*Log[Cos[x]] + (4 + a^2)*Log[Tan[x]] + Cos[x]^4*(1 - Tan[x]) + a^2*Tan[x] + (1/3)*a^2*Tan[x]^3 + (1/2)*Cos[x]^2*(4 + Tan[x])}
((1 - 1//2*sin(x))^4*(4 - 3*cos(x)), (227*x)/32 + 10*cos(x) - 3*cos(x)^2 - (2*cos(x)^3)/3 - 3*sin(x) - (99//32)*cos(x)*sin(x) - (3*sin(x)^3)/2 - (1//16)*cos(x)*sin(x)^3 + (3*sin(x)^4)/8 - (3*sin(x)^5)/80, x, 15),
((3 - 2*cot(x))^3*(1//2 - 3*cot(x)), -((285*x)/2) + 5*(3 - 2*cot(x))^2 + (3 - 2*cot(x))^3 - 42*cot(x) + 4*log(sin(x)), x, 4),


# ::Subsection::Closed::
# Problems 33 - 36 (p. 229)


(cos(5*x)/cos(x)^5, 16*x - 15*tan(x) + (5*tan(x)^3)/3, x, 4),
(cos(4*x)/cos(x), atanh(sin(x)) - (8*sin(x)^3)/3, x, 4),
(cos(4*x)*cos(x), (1//6)*sin(3*x) + (1//10)*sin(5*x), x, 1),
(cos(4*x)/cos(x)^5, (35//8)*atanh(sin(x)) - (29//8)*sec(x)*tan(x) + (1//4)*sec(x)^3*tan(x), x, 4),


# ::Subsection::Closed::
# Problems 37 - 39 (p. 233)


(cos(4*x)*cos(x)^4, x/16 + (1//8)*sin(2*x) + (3//32)*sin(4*x) + (1//24)*sin(6*x) + (1//128)*sin(8*x), x, 6),
(cos(5*x)/sin(x)^5, 6*csc(x)^2 - csc(x)^4//4 + 16*log(sin(x)), x, 4),
(sin(4*x)/sin(x)^4, -2*csc(x)^2 - 8*log(sin(x)), x, 3),


# ::Subsection::Closed::
# Problems 40 - 49 (p. 254-255)


# {Cos[x]/(Sin[x]*(2 + Sin[2*x])), x, 7, -x/(2*Sqrt[3]) + 1/(2*Sqrt[3])*ArcTan[(1 - 2*Cos[x]^2)/(2 + Sqrt[3] + 2*Cos[x]*Sin[x])] + 1/2*Log[Sin[x]] - 1/4*Log[1 + Cos[x]*Sin[x]], -(x/(2*Sqrt[3])) + ArcTan[(1 - 2*Cos[x]^2)/(2 + Sqrt[3] + 2*Cos[x]*Sin[x])]/(2*Sqrt[3]) + (1/2)*Log[Tan[x]] - (1/4)*Log[1 + Tan[x] + Tan[x]^2]}
# {Cos[x]^2/(Sin[x]*Cos[3*x]), x, 5, -1/2*Log[Csc[x]^2 - 4], Log[Sin[x]] - (1/2)*Log[1 - 4*Sin[x]^2]}
(sin(2*x)/(cos(x)^4 + sin(x)^4), -atan(cos(2*x)), x, 5),
# {1/(4 + Sqrt[3]*Cos[x] + Sin[x]), x, 3, x/(2*Sqrt[3]) + (1/Sqrt[3])*ArcTan[(Cos[x] - Sqrt[3]*Sin[x])/(2*(2 + Sqrt[3]) + Sqrt[3]*Cos[x] + Sin[x])], x/(2*Sqrt[3]) + ArcTan[((4 - Sqrt[3])*Cos[x] + (3 - 4*Sqrt[3])*Sin[x])/(2*(5 + 2*Sqrt[3]) - (3 - 4*Sqrt[3])*Cos[x] + (4 - Sqrt[3])*Sin[x])]/Sqrt[3]}
# {1/(3 + 4*Cos[x] + 4*Sin[x]), x, 3, -1/Sqrt[23]*ArcTanh[Sqrt[23]*(Cos[x] - Sin[x])/(8 + 3*Cos[x] + 3*Sin[x])], -(Log[4*(5 + Sqrt[23]) + 19*Cos[x] + 4*Sqrt[23]*Cos[x] - 4*Sin[x] - Sqrt[23]*Sin[x]]/(2*Sqrt[23])) + Log[4*(5 - Sqrt[23]) + 19*Cos[x] - 4*Sqrt[23]*Cos[x] - 4*Sin[x] + Sqrt[23]*Sin[x]]/(2*Sqrt[23])}
(1/(4 - 3*cos(x)^2 + 5*sin(x)^2), x/3 + (1//3)*atan((2*cos(x)*sin(x))/(1 + 2*sin(x)^2)), x, 2),
(1/(4 + tan(x) + 4*cot(x)), (4*x)/25 - (3//25)*log(2*cos(x) + sin(x)) + 2/(5*(2 + tan(x))), x, 6),
(1/(sin(x) + 2*sec(x))^2, (8*x)/(15*sqrt(15)) - (8/(15*sqrt(15)))*atan((1 - 2*cos(x)^2)/(4 + sqrt(15) + 2*cos(x)*sin(x))) + (1 + 4*tan(x))/(15*(2 + tan(x) + 2*tan(x)^2)), x, 4),
(1/(cos(x) + 2*sec(x))^2, x/(6*sqrt(6)) - (1/(6*sqrt(6)))*atan((cos(x)*sin(x))/(2 + sqrt(6) + cos(x)^2)) + tan(x)/(6*(3 + 2*tan(x)^2)), x, 3),
((5 - tan(x) - 6*tan(x)^2)/(1 + 3*tan(x))^3, -((67*x)/250) - (28//125)*log(cos(x) + 3*sin(x)) - 7/(10*(1 + 3*tan(x))^2) - 29/(50*(1 + 3*tan(x))), x, 4),


# ::Subsection::Closed::
# Problems 50 - 56 (p. 260)


(cos(x)^2/cos(3*x), 1//2*atanh(2*sin(x)), x, 2),
(sin(x)/cos(2*x), atanh(sqrt(2)*cos(x))/sqrt(2), x, 2),
(sin(x)^2/cos(2*x), -x/2 + 1//4*atanh(2*cos(x)*sin(x)), x, 4),
(sin(x)^3/cos(3*x), 1//3*log(cos(x)) - 1//24*log(3 - 4*cos(x)^2), x, 4),
(cos(x)/sin(3*x), 1//3*log(sin(x)) - 1//6*log(3 - 4*sin(x)^2), x, 5),
(sin(x)/sin(4*x), -1//4*atanh(sin(x)) + atanh(sqrt(2)*sin(x))/(2*sqrt(2)), x, 4),
(sin(x)^3/sin(4*x), -1//4*atanh(sin(x)) + atanh(sqrt(2)*sin(x))/(4*sqrt(2)), x, 4),


# ::Subsection::Closed::
# Problems 57 - 61 (p. 266)


(sqrt(1 + sin(2*x)), -(cos(2*x)/sqrt(1 + sin(2*x))), x, 1),
(sqrt(1 - sin(2*x)), cos(2*x)/sqrt(1 - sin(2*x)), x, 1),
(1/sqrt(1 + cos(2*x)), atanh(sin(2*x)/(sqrt(2)*sqrt(1 + cos(2*x))))/sqrt(2), x, 2),
(1/sqrt(1 - cos(2*x)), -1/sqrt(2)*atanh(sin(2*x)/(sqrt(2)*sqrt(1 - cos(2*x)))), x, 2),
(1/(1 - cos(3*x))^(3//2), -(atanh(sin(3*x)/(sqrt(2)*sqrt(1 - cos(3*x))))/(6*sqrt(2))) - sin(3*x)/(6*(1 - cos(3*x))^(3//2)), x, 3),
((1 - sin(2*(x/3)))^(5//2), (32*cos((2*x)/3))/(5*sqrt(1 - sin((2*x)/3))) + (8//5)*cos((2*x)/3)*sqrt(1 - sin((2*x)/3)) + (3//5)*cos((2*x)/3)*(1 - sin((2*x)/3))^(3//2), x, 3),
((2*(1 + 2*sin(x))^(1//4) - cos(x)^2)/(1 + 2*sin(x))^(3//2)*cos(x), 3/(4*sqrt(1 + 2*sin(x))) - 4/(1 + 2*sin(x))^(1//4) - (1//2)*sqrt(1 + 2*sin(x)) + (1//12)*(1 + 2*sin(x))^(3//2), x, 4),


# ::Subsection::Closed::
# Problems 62 - 66 (p. 268)


(sqrt(tan(x)), -(atan(1 - sqrt(2)*sqrt(tan(x)))/sqrt(2)) + atan(1 + sqrt(2)*sqrt(tan(x)))/sqrt(2) + log(1 - sqrt(2)*sqrt(tan(x)) + tan(x))/(2*sqrt(2)) - log(1 + sqrt(2)*sqrt(tan(x)) + tan(x))/(2*sqrt(2)), x, 11),
# {1/Tan[5*x]^(1/3), x, 9, -1/10*Sqrt[3]*ArcTan[(1 - 2*Tan[5*x]^(2/3))/Sqrt[3]] + 3/20*Log[1 + Tan[5*x]^(2/3)] - 1/20*Log[1 + Tan[5*x]^2], (-(1/10))*Sqrt[3]*ArcTan[(1 - 2*Tan[5*x]^(2/3))/Sqrt[3]] + (1/10)*Log[1 + Tan[5*x]^(2/3)] - (1/20)*Log[1 - Tan[5*x]^(2/3) + Tan[5*x]^(4/3)]}
(1/(4 + 3*tan(2*x))^(3//2), -((9*atan((1 - 3*tan(2*x))/(sqrt(2)*sqrt(4 + 3*tan(2*x)))))/(250*sqrt(2))) + (13*atanh((3 + tan(2*x))/(sqrt(2)*sqrt(4 + 3*tan(2*x)))))/(250*sqrt(2)) - 3/(25*sqrt(4 + 3*tan(2*x))), x, 6),
((3*tan(x) - sqrt(4 - 3*tan(x)))/(cos(x)^2*(4 - 3*tan(x))^(3//2)), (1//3)*log(4 - 3*tan(x)) + 8/(3*sqrt(4 - 3*tan(x))) + (2//3)*sqrt(4 - 3*tan(x)), x, 4),
(tan(x)/(sqrt(tan(x)) - 1)^2, -(x/2) + atan((1 - tan(x))/(sqrt(2)*sqrt(tan(x))))/sqrt(2) + atanh((1 + tan(x))/(sqrt(2)*sqrt(tan(x))))/sqrt(2) + (1//2)*log(cos(x)) + log(1 - sqrt(tan(x))) + 1/(1 - sqrt(tan(x))), x, -19),


# ::Subsection::Closed::
# Problems 67 - 75 (p. 272-273)


(sin(x)/sqrt(sin(2*x)), (-(1//2))*asin(cos(x) - sin(x)) - (1//2)*log(cos(x) + sin(x) + sqrt(sin(2*x))), x, 1),
(cos(x)/sqrt(sin(2*x)), (-(1//2))*asin(cos(x) - sin(x)) + (1//2)*log(cos(x) + sin(x) + sqrt(sin(2*x))), x, 1),
(sqrt(sin(2*x))*sin(x), (-(1//4))*asin(cos(x) - sin(x)) + (1//4)*log(cos(x) + sin(x) + sqrt(sin(2*x))) - (1//2)*cos(x)*sqrt(sin(2*x)), x, 2),
((cos(x) - sin(x))*sqrt(sin(2*x)), (-(1//2))*log(cos(x) + sin(x) + sqrt(sin(2*x))) + (1//2)*cos(x)*sqrt(sin(2*x)) + (1//2)*sin(x)*sqrt(sin(2*x)), x, 6),
(sin(x)^7/sin(2*x)^(7//2), -1//16*asin(cos(x) - sin(x)) + 1//16*log(cos(x) + sin(x) + sqrt(sin(2*x))) + sin(x)^5/(5*sin(2*x)^(5//2)) - sin(x)/(4*sqrt(sin(2*x))), x, 4),
(cos(x)^7/sin(2*x)^(7//2), -1//16*asin(cos(x) - sin(x)) - 1//16*log(cos(x) + sin(x) + sqrt(sin(2*x))) - cos(x)^5/(5*sin(2*x)^(5//2)) + cos(x)/(4*sqrt(sin(2*x))), x, 4),
(sin(2*x)^(3//2)/sin(x)^5, (-(1//5))*csc(x)^5*sin(2*x)^(5//2), x, 1),
(1/(cos(x)^3*sqrt(sin(2*x))), (4//5)*sec(x)*sqrt(sin(2*x)) + (1//5)*sec(x)^3*sqrt(sin(2*x)), x, 2),
(1/(sin(x)*sin(2*x)^(3//2)), -((2*cos(x))/(3*sin(2*x)^(3//2))) + (4*sin(x))/(3*sqrt(sin(2*x))), x, 3),
# {(Cos[2*x] - 3*Tan[x])*(Cos[x]^3/((Sin[x]^2 - Sin[2*x])*Sin[2*x]^(5/2))), x, 6, (33/32)*ArcTanh[Sqrt[Sin[2*x]]/(2*Cos[x])] - (9*Cos[x])/(16*Sqrt[Sin[2*x]]) - (5*Cos[x]*Cot[x])/(24*Sqrt[Sin[2*x]]) + (Cos[x]*Cot[x]^2)/(20*Sqrt[Sin[2*x]]), Cos[x]^5/(5*Sin[2*x]^(5/2)) - (5*Cos[x]^4*Sin[x])/(6*Sin[2*x]^(5/2)) - (9*Cos[x]^3*Sin[x]^2)/(4*Sin[2*x]^(5/2)) + (33*ArcTanh[Sqrt[Tan[x]]/Sqrt[2]]*Sin[x]^5)/(4*Sqrt[2]*Sin[2*x]^(5/2)*Tan[x]^(5/2))}


# ::Subsection::Closed::
# Problems 76 - 82 (p. 276)


# {Sqrt[Sin[x]/Cos[x]^5], x, 5, (2/3)*Cos[x]*Sin[x]*Sqrt[Sec[x]^4*Tan[x]], (2*Sec[x]^2*Tan[x]^2)/(3*Sqrt[Tan[x] + 2*Tan[x]^3 + Tan[x]^5])}
# {Sqrt[Sin[x]^5/Cos[x]], x, 13, 3/(4*Sqrt[2])*ArcTan[(1 - Cot[x])*Csc[x]^2*Sqrt[Sin[x]^4*Tan[x]]/Sqrt[2]] + 3/(4*Sqrt[2])*Log[Cos[x] + Sin[x] - Sqrt[2]*Cot[x]*Csc[x]*Sqrt[Sin[x]^4*Tan[x]]] - 1/2*Cot[x]*Sqrt[Sin[x]^4*Tan[x]], (-(1/2))*Cot[x]*Sqrt[Sin[x]^4*Tan[x]] - (3*ArcTan[1 - Sqrt[2]*Sqrt[Tan[x]]]*Sec[x]^2*Sqrt[Sin[x]^4*Tan[x]])/(4*Sqrt[2]*Tan[x]^(5/2)) + (3*ArcTan[1 + Sqrt[2]*Sqrt[Tan[x]]]*Sec[x]^2*Sqrt[Sin[x]^4*Tan[x]])/(4*Sqrt[2]*Tan[x]^(5/2)) + (3*Log[1 - Sqrt[2]*Sqrt[Tan[x]] + Tan[x]]*Sec[x]^2*Sqrt[Sin[x]^4*Tan[x]])/(8*Sqrt[2]*Tan[x]^(5/2)) - (3*Log[1 + Sqrt[2]*Sqrt[Tan[x]] + Tan[x]]*Sec[x]^2*Sqrt[Sin[x]^4*Tan[x]])/(8*Sqrt[2]*Tan[x]^(5/2))}
((sin(x)^2/cos(x)^14)^(1//3), (3//5)*cos(x)^3*sin(x)*(sec(x)^12*tan(x)^2)^(1//3) + (3//11)*cos(x)*sin(x)^3*(sec(x)^12*tan(x)^2)^(1//3), x, 5),
(1/(sin(x)^13*cos(x)^11)^(1//4), -((4*cos(x)^5*sin(x))/(9*(cos(x)^11*sin(x)^13)^(1//4))) - (8*cos(x)^3*sin(x)^3)/(cos(x)^11*sin(x)^13)^(1//4) + (4*cos(x)*sin(x)^5)/(7*(cos(x)^11*sin(x)^13)^(1//4)), x, 4),
# {(Cos[2*x] - Sqrt[Sin[2*x]])/Sqrt[Sin[x]*Cos[x]^3], x, If[$VersionNumber<11, -28, -27], -Sqrt[2]*Log[Cos[x] + Sin[x] - Sqrt[2]*Sec[x]*Sqrt[Cos[x]^3*Sin[x]]] - ArcSin[Cos[x] - Sin[x]]*Cos[x]*Sqrt[Sin[2*x]]/Sqrt[Cos[x]^3*Sin[x]] - ArcTanh[Sin[x]]*Cos[x]*Sqrt[Sin[2*x]]/Sqrt[Cos[x]^3*Sin[x]] - Sin[2*x]/Sqrt[Cos[x]^3*Sin[x]]}
# {(Sqrt[Sin[x]^3*Cos[x]] - 2*Sin[2*x])/(Sqrt[Tan[x]] - Sqrt[Sin[x]*Cos[x]^3]), x, 66, -2*Sqrt[2]*ArcCoth[(Cos[x]*(Cos[x] + Sin[x]))/(Sqrt[2]*Sqrt[Cos[x]^3*Sin[x]])] + 2^(1/4)*ArcCoth[(Cos[x]*(Sqrt[2]*Cos[x] + Sin[x]))/(2^(3/4)*Sqrt[Cos[x]^3*Sin[x]])] - 2^(1/4)*ArcCoth[(Sqrt[2] + Tan[x])/(2^(3/4)*Sqrt[Tan[x]])] - 2*Sqrt[2]*ArcTan[(Cos[x]*(Cos[x] - Sin[x]))/(Sqrt[2]*Sqrt[Cos[x]^3*Sin[x]])] + 2^(1/4)*ArcTan[(Cos[x]*(Sqrt[2]*Cos[x] - Sin[x]))/(2^(3/4)*Sqrt[Cos[x]^3*Sin[x]])] - 2^(1/4)*ArcTan[(Sqrt[2] - Tan[x])/(2^(3/4)*Sqrt[Tan[x]])] + 4*Csc[x]*Sec[x]*Sqrt[Cos[x]^3*Sin[x]] + (1/4)*Csc[x]^2*Log[1 + Cos[x]^2]*Sec[x]^2*Sqrt[Cos[x]^3*Sin[x]]*Sqrt[Cos[x]*Sin[x]^3] + (1/2)*Csc[x]^2*Log[Sin[x]]*Sec[x]^2*Sqrt[Cos[x]^3*Sin[x]]*Sqrt[Cos[x]*Sin[x]^3] + 4/Sqrt[Tan[x]] - (1/4)*Csc[x]^2*Log[1 + Cos[x]^2]*Sqrt[Cos[x]*Sin[x]^3]*Sqrt[Tan[x]] + (1/2)*Csc[x]^2*Log[Sin[x]]*Sqrt[Cos[x]*Sin[x]^3]*Sqrt[Tan[x]], ((-2.0)^(1/4))*ArcTan[1 - 2^(1/4)*Sqrt[Tan[x]]] + 2^(1/4)*ArcTan[1 + 2^(1/4)*Sqrt[Tan[x]]] + Log[Sqrt[2] - 2^(3/4)*Sqrt[Tan[x]] + Tan[x]]/2^(3/4) - Log[Sqrt[2] + 2^(3/4)*Sqrt[Tan[x]] + Tan[x]]/2^(3/4) + 4*Csc[x]*Sec[x]*Sqrt[Cos[x]^3*Sin[x]] - (1/2)*Csc[x]^2*Log[Sec[x]^2]*Sec[x]^2*Sqrt[Cos[x]^3*Sin[x]]*Sqrt[Cos[x]*Sin[x]^3] + Csc[x]^2*Log[Sqrt[Tan[x]]]*Sec[x]^2*Sqrt[Cos[x]^3*Sin[x]]*Sqrt[Cos[x]*Sin[x]^3] + (1/4)*Csc[x]^2*Log[2 + Tan[x]^2]*Sec[x]^2*Sqrt[Cos[x]^3*Sin[x]]*Sqrt[Cos[x]*Sin[x]^3] + (Log[Tan[x]]*Sec[x]^2*Sqrt[Cos[x]*Sin[x]^3])/(2*Tan[x]^(3/2)) - (Log[2 + Tan[x]^2]*Sec[x]^2*Sqrt[Cos[x]*Sin[x]^3])/(4*Tan[x]^(3/2)) + 4/Sqrt[Tan[x]] + (2^(1/4)*ArcTan[1 - 2^(1/4)*Sqrt[Tan[x]]]*Sec[x]^2*Sqrt[Cos[x]^3*Sin[x]])/Sqrt[Tan[x]] - (2^(1/4)*ArcTan[1 + 2^(1/4)*Sqrt[Tan[x]]]*Sec[x]^2*Sqrt[Cos[x]^3*Sin[x]])/Sqrt[Tan[x]] - (2*Sqrt[2]*ArcTan[1 - Sqrt[2]*Sqrt[Tan[x]]]*Sec[x]^2*Sqrt[Cos[x]^3*Sin[x]])/Sqrt[Tan[x]] + (2*Sqrt[2]*ArcTan[1 + Sqrt[2]*Sqrt[Tan[x]]]*Sec[x]^2*Sqrt[Cos[x]^3*Sin[x]])/Sqrt[Tan[x]] + (Sqrt[2]*Log[1 - Sqrt[2]*Sqrt[Tan[x]] + Tan[x]]*Sec[x]^2*Sqrt[Cos[x]^3*Sin[x]])/Sqrt[Tan[x]] - (Sqrt[2]*Log[1 + Sqrt[2]*Sqrt[Tan[x]] + Tan[x]]*Sec[x]^2*Sqrt[Cos[x]^3*Sin[x]])/Sqrt[Tan[x]] - (Log[Sqrt[2] - 2^(3/4)*Sqrt[Tan[x]] + Tan[x]]*Sec[x]^2*Sqrt[Cos[x]^3*Sin[x]])/(2^(3/4)*Sqrt[Tan[x]]) + (Log[Sqrt[2] + 2^(3/4)*Sqrt[Tan[x]] + Tan[x]]*Sec[x]^2*Sqrt[Cos[x]^3*Sin[x]])/(2^(3/4)*Sqrt[Tan[x]])}
# {((Sin[x]/Cos[x]^7)^(1/3) - 3*Tan[x])/(Sin[x]*Cos[x]^5)^(2/3), x, 13, -((9*Sin[x]^4)/(10*(Cos[x]^5*Sin[x])^(2/3))) - (9/4)*Sec[x]^8*(Cos[x]^5*Sin[x])^(4/3) + (3/2)*(Cos[x]^5*Sin[x])^(1/3)*(Sec[x]^6*Tan[x])^(1/3) + (3/4)*(Cos[x]^5*Sin[x])^(1/3)*Tan[x]^2*(Sec[x]^6*Tan[x])^(1/3) + (3/14)*(Cos[x]^5*Sin[x])^(1/3)*Tan[x]^4*(Sec[x]^6*Tan[x])^(1/3), -((9*Cos[x]^2*Sin[x]^2)/(4*(Cos[x]^5*Sin[x])^(2/3))) - (9*Sin[x]^4)/(10*(Cos[x]^5*Sin[x])^(2/3)) + (3*Cos[x]^5*Sin[x]*(Sec[x]^6*Tan[x])^(1/3))/(2*(Cos[x]^5*Sin[x])^(2/3)) + (3*Cos[x]^3*Sin[x]^3*(Sec[x]^6*Tan[x])^(1/3))/(4*(Cos[x]^5*Sin[x])^(2/3)) + (3*Cos[x]*Sin[x]^5*(Sec[x]^6*Tan[x])^(1/3))/(14*(Cos[x]^5*Sin[x])^(2/3))}


# ::Subsection::Closed::
# Problems 83 - 92 (p. 288-289)


# {(2*Cos[x]^2 + 1)^(5/2)*Sin[x], x, 5, -((5*ArcSinh[Sqrt[2]*Cos[x]])/(16*Sqrt[2])) - (5/16)*Cos[x]*Sqrt[1 + 2*Cos[x]^2] - (5/24)*Cos[x]*(1 + 2*Cos[x]^2)^(3/2) - (1/6)*Cos[x]*(1 + 2*Cos[x]^2)^(5/2), -((5*ArcSinh[Sqrt[2]*Cos[x]])/(16*Sqrt[2])) - (5/16)*Cos[x]*Sqrt[2 + Cos[2*x]] - (5/24)*Cos[x]*(2 + Cos[2*x])^(3/2) - (1/6)*Cos[x]*(2 + Cos[2*x])^(5/2)}
((5*cos(x)^2 + sin(x)^2)^(5//2)*cos(x), (625//32)*asin((2*sin(x))/sqrt(5)) + (125//16)*sin(x)*sqrt(5 - 4*sin(x)^2) + (25//24)*sin(x)*(5 - 4*sin(x)^2)^(3//2) + (1//6)*sin(x)*(5 - 4*sin(x)^2)^(5//2), x, 5),
((-cos(x)^2 - 5*sin(x)^2)^(3//2)*cos(x), (3//16)*atan((2*sin(x))/sqrt(-1 - 4*sin(x)^2)) - (3//8)*sin(x)*sqrt(-1 - 4*sin(x)^2) + (1//4)*sin(x)*(-1 - 4*sin(x)^2)^(3//2), x, 5),
(sin(x)/(5*cos(x)^2 - 2*sin(x)^2)^(7//2), cos(x)/(10*(-2 + 7*cos(x)^2)^(5//2)) - cos(x)/(15*(-2 + 7*cos(x)^2)^(3//2)) + cos(x)/(15*sqrt(-2 + 7*cos(x)^2)), x, 4),
(cos(2*x)*(cos(x)/(2 - 5*sin(x)^2)^(3//2)), (2*asin(sqrt(5//2)*sin(x)))/(5*sqrt(5)) + sin(x)/(10*sqrt(2 - 5*sin(x)^2)), x, 3),
(sin(5*x)/(5*cos(x)^2 + 9*sin(x)^2)^(5//2), (-(1//2))*asin((2*cos(x))/3) - (55*cos(x))/(27*(9 - 4*cos(x)^2)^(3//2)) + (295*cos(x))/(243*sqrt(9 - 4*cos(x)^2)), x, 4),
(cos(x)*cos(2*x)*sin(3*x)/(4*sin(x)^2 - 5)^(5//2), -(1/(4*(-5 + 4*sin(x)^2)^(3//2))) - 5/(8*sqrt(-5 + 4*sin(x)^2)) + (1//8)*sqrt(-5 + 4*sin(x)^2), x, 4),
# {(Sin[x]*Cos[2*x] - 2*(Sin[x] - 1)*Cos[x]^3)/(Sin[x]^2*Sqrt[Sin[x]^2 - 5]), x, 18, 2*ArcTan[Cos[x]/Sqrt[Sin[x]^2 - 5]] - (1/Sqrt[5])*ArcTan[(Sqrt[5]*Cos[x])/Sqrt[Sin[x]^2 - 5]] - (2/Sqrt[5])*ArcTan[Sqrt[Sin[x]^2 - 5]/Sqrt[5]] - 2*ArcTanh[Sin[x]/Sqrt[Sin[x]^2 - 5]] + (2*Sqrt[Sin[x]^2 - 5])/(5*Sin[x]) + 2*Sqrt[Sin[x]^2 - 5], 2*ArcTan[Cos[x]/Sqrt[-4 - Cos[x]^2]] - ArcTan[(Sqrt[5]*Cos[x])/Sqrt[-4 - Cos[x]^2]]/Sqrt[5] - (2*ArcTan[Sqrt[-4 - Cos[x]^2]/Sqrt[5]])/Sqrt[5] - 2*ArcTanh[Sin[x]/Sqrt[-5 + Sin[x]^2]] + 2*Sqrt[-4 - Cos[x]^2] + (2/5)*Csc[x]*Sqrt[-5 + Sin[x]^2]}
# {Cos[3*x]/(Sqrt[3*Cos[x]^2 - Sin[x]^2] - Sqrt[8*Cos[x]^2 - 1]), x, 27, (5/(4*Sqrt[2]))*ArcSin[2*Sqrt[2/7]*Sin[x]] + (3/4)*ArcSin[(2*Sin[x])/Sqrt[3]] - (3/4)*ArcTan[Sin[x]/Sqrt[4*Cos[x]^2 - 1]] - (3/4)*ArcTan[Sin[x]/Sqrt[8*Cos[x]^2 - 1]] - (1/2)*Sin[x]*Sqrt[4*Cos[x]^2 - 1] - (1/2)*Sin[x]*Sqrt[8*Cos[x]^2 - 1], (5*ArcSin[2*Sqrt[2/7]*Sin[x]])/(4*Sqrt[2]) + (3/4)*ArcSin[(2*Sin[x])/Sqrt[3]] - (3/4)*ArcTan[Sin[x]/Sqrt[7 - 8*Sin[x]^2]] - (3/4)*ArcTan[Sin[x]/Sqrt[3 - 4*Sin[x]^2]] - (1/2)*Sin[x]*Sqrt[7 - 8*Sin[x]^2] - (1/2)*Sin[x]*Sqrt[3 - 4*Sin[x]^2]}
((2 - 3*sin(x)^2)^(3//5)*sin(4*x), (5//36)*(2 - 3*sin(x)^2)^(8//5) - (20//117)*(2 - 3*sin(x)^2)^(13//5), x, 5),


# ::Subsection::Closed::
# Problems 93 - 97 (p. 293)


(sqrt(cos(2*x))*cos(x), asin(sqrt(2)*sin(x))/(2*sqrt(2)) + (1//2)*sin(x)*sqrt(cos(2*x)), x, 3),
(cos(2*x)^(3//2)*sin(x), (-(3/(8*sqrt(2))))*atanh((sqrt(2)*cos(x))/sqrt(cos(2*x))) + (3//8)*cos(x)*sqrt(cos(2*x)) - (1//4)*cos(x)*cos(2*x)^(3//2), x, 5),
(sin(x)/cos(2*x)^(5//2), -(cos(3*x)/(3*cos(2*x)^(3//2))), x, 1),
(cos(2*x)^(3//2)/cos(x)^3, 2*sqrt(2)*asin(sqrt(2)*sin(x)) - (5//2)*atan(sin(x)/sqrt(cos(2*x))) - (1//2)*sec(x)*tan(x)*sqrt(cos(2*x)), x, 6),
# {(3*Sin[x]^3 - Cos[x]*Sin[4*x])/(Csc[x]^2*Cos[2*x]^(7/2)), x, 11, -(ArcTanh[(Sqrt[2]*Cos[x])/Sqrt[Cos[2*x]]]/Sqrt[2]) - (11*Cos[x])/(20*Cos[2*x]^(3/2)) - (2*Cos[x]^3)/(3*Cos[2*x]^(3/2)) + (63*Cos[x])/(20*Sqrt[Cos[2*x]]) + (3*Cos[x]*Sin[x]^2)/(10*Cos[2*x]^(5/2)), -(ArcTanh[(Sqrt[2]*Cos[x])/Sqrt[Cos[2*x]]]/Sqrt[2]) - (2*Cos[x]^3)/(3*Cos[2*x]^(3/2)) + (13*Cos[x])/(5*Sqrt[Cos[2*x]]) - (4*Cos[x]*Sin[x]^2)/(5*Cos[2*x]^(3/2)) + (3*Cos[x]*Sin[x]^4)/(5*Cos[2*x]^(5/2))}


# ::Subsection::Closed::
# Problems 98 - 103 (p. 297)


((4 - 5*sec(x)^2)^(3//2), 8*atan((2*tan(x))/sqrt(-1 - 5*tan(x)^2)) - (7//2)*sqrt(5)*atan((sqrt(5)*tan(x))/sqrt(-1 - 5*tan(x)^2)) - (5//2)*tan(x)*sqrt(-1 - 5*tan(x)^2), x, 7),
(1/(4 - 5*sec(x)^2)^(3//2), (1//8)*atan((2*tan(x))/sqrt(-1 - 5*tan(x)^2)) - (5*tan(x))/(4*sqrt(-1 - 5*tan(x)^2)), x, 4),
# {(Sin[x] - 2*Cot[x]^2)/(1 + 5*Tan[x]^2)^(3/2), x, 10, -1/4*ArcTanh[(2*Tan[x])/Sqrt[1 + 5*Tan[x]^2]] - Cos[x]/(4*Sqrt[1 + 5*Tan[x]^2]) - (5*Cot[x])/(2*Sqrt[1 + 5*Tan[x]^2]) - 1/8*Cos[x]*Sqrt[1 + 5*Tan[x]^2] + 9/2*Cot[x]*Sqrt[1 + 5*Tan[x]^2], (-(1/4))*ArcTanh[(2*Tan[x])/Sqrt[1 + 5*Tan[x]^2]] + Cos[x]/(4*Sqrt[-4 + 5*Sec[x]^2]) - (5*Sec[x])/(8*Sqrt[-4 + 5*Sec[x]^2]) - (5*Cot[x])/(2*Sqrt[1 + 5*Tan[x]^2]) + (9/2)*Cot[x]*Sqrt[1 + 5*Tan[x]^2]}
((cos(2*x) - 3)/(cos(x)^4*sqrt(4 - cot(x)^2)), (-(2//3))*sqrt(4 - cot(x)^2)*tan(x) - (1//3)*sqrt(4 - cot(x)^2)*tan(x)^3, x, 5),
((3 + sin(x)^2)*tan(x)^3/((cos(x)^2 - 2)*(5 - 4*sec(x)^2)^(3//2)), -(atanh(sqrt(5 - 4*sec(x)^2)/sqrt(3))/(6*sqrt(3))) - atanh(sqrt(5 - 4*sec(x)^2)/sqrt(5))/(5*sqrt(5)) - 2/(15*sqrt(5 - 4*sec(x)^2)), x, 16),
((sec(x)^2 - 3*tan(x)*sqrt(4*sec(x)^2 + 5*tan(x)^2))/(sin(x)^2*(4*sec(x)^2 + 5*tan(x)^2)^(3//2)), (-(3//4))*log(tan(x)) + (3//8)*log(4 + 9*tan(x)^2) - cot(x)/(4*sqrt(4 + 9*tan(x)^2)) - (7*tan(x))/(8*sqrt(4 + 9*tan(x)^2)), x, 10),


# ::Subsection::Closed::
# Problems 104 - 110 (p. 303)


((1 + 5*tan(x)^2)^(5//2)*tan(x), -32*atan((1//2)*sqrt(1 + 5*tan(x)^2)) + 16*sqrt(1 + 5*tan(x)^2) - (4//3)*(1 + 5*tan(x)^2)^(3//2) + (1//5)*(1 + 5*tan(x)^2)^(5//2), x, 7),
(tan(x)/(1 + 5*tan(x)^2)^(5//2), (1//32)*atan((1//2)*sqrt(1 + 5*tan(x)^2)) - 1/(12*(1 + 5*tan(x)^2)^(3//2)) + 1/(16*sqrt(1 + 5*tan(x)^2)), x, 6),
(tan(x)/(a^3 + b^3*tan(x)^2)^(1//3), (sqrt(3)*atan((1 + (2*(a^3 + b^3*tan(x)^2)^(1//3))/(a^3 - b^3)^(1//3))/sqrt(3)))/(2*(a^3 - b^3)^(1//3)) + log(cos(x))/(2*(a^3 - b^3)^(1//3)) + (3*log((a^3 - b^3)^(1//3) - (a^3 + b^3*tan(x)^2)^(1//3)))/(4*(a^3 - b^3)^(1//3)), x, 6),
((1 - 7*tan(x)^2)^(2//3)*tan(x), 2*sqrt(3)*atan((1 + (1 - 7*tan(x)^2)^(1//3))/sqrt(3)) + 2*log(cos(x)) + 3*log(2 - (1 - 7*tan(x)^2)^(1//3)) + (3//4)*(1 - 7*tan(x)^2)^(2//3), x, 7),
(cot(x)/(a^4 + b^4*csc(x)^2)^(1//4), -atan((a^4 + b^4*csc(x)^2)^(1//4)/a)/a + atanh((a^4 + b^4*csc(x)^2)^(1//4)/a)/a, x, 6),
(cot(x)/(a^4 - b^4*csc(x)^2)^(1//4), -atan((a^4 - b^4*csc(x)^2)^(1//4)/a)/a + atanh((a^4 - b^4*csc(x)^2)^(1//4)/a)/a, x, 6),
# {(3*Tan[x]^2 + Sin[x]^2*(1 - 3*Sec[x]^2)^(1/3))/(Cos[x]^2*(1 - 3*Sec[x]^2)^(5/6)*(1 - Sqrt[1 - 3*Sec[x]^2]))*Tan[x], x, 29, Sqrt[3]*ArcTan[(1 + 2*(1 - 3*Sec[x]^2)^(1/6))/Sqrt[3]] + (1/4)*Log[Sec[x]^2] - (3/2)*Log[1 - (1 - 3*Sec[x]^2)^(1/6)] + (1/3)*Log[1 - Sqrt[1 - 3*Sec[x]^2]] - (1 - 3*Sec[x]^2)^(1/6) - (1/4)*(1 - 3*Sec[x]^2)^(2/3) + 1/(2*(1 - Sqrt[1 - 3*Sec[x]^2])), Sqrt[3]*ArcTan[(1 + 2*(1 - 3*Sec[x]^2)^(1/6))/Sqrt[3]] + (1/2)*ArcTanh[Sqrt[1 - 3*Sec[x]^2]] + Cos[x]^2/6 + (1/3)*Log[1 - Sqrt[-((3 - Cos[x]^2)*Sec[x]^2)]] - (3/2)*Log[1 - (1 - 3*Sec[x]^2)^(1/6)] + (1/2)*Log[1 - Sqrt[1 - 3*Sec[x]^2]] - (1 - 3*Sec[x]^2)^(1/6) + (1/6)*Cos[x]^2*Sqrt[1 - 3*Sec[x]^2] - (1/4)*(1 - 3*Sec[x]^2)^(2/3)}
((2*tan(x)^2 - cos(2*x))/(cos(x)^2*(tan(x)*tan(2*x))^(3//2)), 2*atanh(tan(x)/sqrt(tan(x)*tan(2*x))) - (11/(4*sqrt(2)))*atanh((sqrt(2)*tan(x))/sqrt(tan(x)*tan(2*x))) + tan(x)/(2*(tan(x)*tan(2*x))^(3//2)) + (2*tan(x)^3)/(3*(tan(x)*tan(2*x))^(3//2)) + (3*tan(x))/(4*sqrt(tan(x)*tan(2*x))), x, -22),


# ::Subsection::Closed::
# Problems 111 - 113 (p. 305-306)


(tan(x)/(a^3 - b^3*cos(x)^n)^(4//3), (-(sqrt(3)/(a^4*n)))*atan((a + 2*(a^3 - b^3*cos(x)^n)^(1//3))/(sqrt(3)*a)) - 3/(a^3*n*(a^3 - b^3*cos(x)^n)^(1//3)) + log(cos(x))/(2*a^4) - (3*log(a - (a^3 - b^3*cos(x)^n)^(1//3)))/(2*a^4*n), x, 7),
# {(1 + 2*Cos[x]^9)^(5/6)*Tan[x], x, 14, ArcTan[(1 - (1 + 2*Cos[x]^9)^(1/3))/(Sqrt[3]*(1 + 2*Cos[x]^9)^(1/6))]/(3*Sqrt[3]) + (1/3)*ArcTanh[(1 + 2*Cos[x]^9)^(1/6)] - (1/9)*ArcTanh[Sqrt[1 + 2*Cos[x]^9]] - (2/15)*(1 + 2*Cos[x]^9)^(5/6), ArcTan[(1 - 2*(1 + 2*Cos[x]^9)^(1/6))/Sqrt[3]]/(3*Sqrt[3]) - ArcTan[(1 + 2*(1 + 2*Cos[x]^9)^(1/6))/Sqrt[3]]/(3*Sqrt[3]) + (2/9)*ArcTanh[(1 + 2*Cos[x]^9)^(1/6)] - (2/15)*(1 + 2*Cos[x]^9)^(5/6) - (1/18)*Log[1 - (1 + 2*Cos[x]^9)^(1/6) + (1 + 2*Cos[x]^9)^(1/3)] + (1/18)*Log[1 + (1 + 2*Cos[x]^9)^(1/6) + (1 + 2*Cos[x]^9)^(1/3)]}
(sin(x)^9*cot(x)/(2 - 5*sin(x)^3)^(4//3), 4/(125*(2 - 5*sin(x)^3)^(1//3)) + (2//125)*(2 - 5*sin(x)^3)^(2//3) - (1//625)*(2 - 5*sin(x)^3)^(5//3), x, 4),


# ::Subsection::Closed::
# Problems 114 - 120 (p. 308-309)


(((1 + (1 - 8*tan(x)^2)^(1//3))/(cos(x)^2*(1 - 8*tan(x)^2)^(2//3)))*tan(x), (-(3//32))*(1 + (1 - 8*tan(x)^2)^(1//3))^2, x, 2),
# {((1 + (1 - 8*Tan[x]^2)^(1/3))/(Cos[x]^2*(1 - 8*Tan[x]^2)^(2/3)))*Cot[x], x, 15, -Log[Tan[x]] + (3/2)*Log[1 - (1 - 8*Tan[x]^2)^(1/3)], (-(1/2))*Log[1 - Sec[x]^2] + (3/2)*Log[1 - (9 - 8*Sec[x]^2)^(1/3)]}
# {(5*Cos[x]^2 - Sqrt[5*Sin[x]^2 - 1])/((5*Sin[x]^2 - 1)^(1/4)*(2 + Sqrt[5*Sin[x]^2 - 1]))*Tan[x], x, 14, (-(3/Sqrt[2]))*ArcTan[(-1 + 5*Sin[x]^2)^(1/4)/Sqrt[2]] - (1/(2*Sqrt[2]))*ArcTanh[(-1 + 5*Sin[x]^2)^(1/4)/Sqrt[2]] + 2*(-1 + 5*Sin[x]^2)^(1/4) - (-1 + 5*Sin[x]^2)^(1/4)/(2*(2 + Sqrt[-1 + 5*Sin[x]^2])), ArcTan[(4 - 5*Cos[x]^2)^(1/4)/Sqrt[2]]/Sqrt[2] - 2*Sqrt[2]*ArcTan[(4 - 5*Cos[x]^2)^(1/4)/Sqrt[2]] - ArcTanh[(4 - 5*Cos[x]^2)^(1/4)/Sqrt[2]]/(2*Sqrt[2]) + 2*(4 - 5*Cos[x]^2)^(1/4) - (4 - 5*Cos[x]^2)^(1/4)/(2*(2 + Sqrt[4 - 5*Cos[x]^2]))}
(cos(x)^4*cos(2*x)^(2//3)*tan(x), (-(3//40))*cos(2*x)^(5//3) - (3//64)*cos(2*x)^(8//3), x, 4),
(sin(x)^6*(tan(x)/cos(2*x)^(3//4)), atan((1 - sqrt(cos(2*x)))/(sqrt(2)*cos(2*x)^(1//4)))/sqrt(2) - atanh((1 + sqrt(cos(2*x)))/(sqrt(2)*cos(2*x)^(1//4)))/sqrt(2) + (7//4)*cos(2*x)^(1//4) - (1//5)*cos(2*x)^(5//4) + (1//36)*cos(2*x)^(9//4), x, -14),
# {Sqrt[Tan[x]*Tan[2*x]], x, 3, -ArcTanh[Tan[x]/Sqrt[Tan[x]*Tan[2*x]]], -ArcTanh[Tan[2*x]/Sqrt[-1 + Sec[2*x]]]}
(sqrt(cot(2*x)/cot(x)), -(asin(tan(x))/sqrt(2)) + atan((sqrt(2)*tan(x))/sqrt(1 - tan(x)^2)), x, 6),


# ::Section::Closed::
# Chapter 6 Integration Problems


# ::Subsection::Closed::
# Problems 1 - 5 (p. 314)


(1/(x^5*(5 + x^2)), -(1/(20*x^4)) + 1/(50*x^2) + log(x)/125 - (1//250)*log(5 + x^2), x, 3),
(1/(x^6*(5 + x^2)), -(1/(25*x^5)) + 1/(75*x^3) - 1/(125*x) - atan(x/sqrt(5))/(125*sqrt(5)), x, 4),
(1/(x*(x^2 - 4)^4), 1/(24*(4 - x^2)^3) + 1/(64*(4 - x^2)^2) + 1/(128*(4 - x^2)) + log(x)/256 - (1//512)*log(4 - x^2), x, 3),
(1/(x*(x^2 - 2)^(5//2)), -(1/(6*(x^2 - 2)^(3//2))) + 1/(4*sqrt(x^2 - 2)) + atan(sqrt(x^2 - 2)/sqrt(2))/(4*sqrt(2)), x, 5),
((x^2 - 10)^(5//2)/x, 100*sqrt(x^2 - 10) - (10//3)*(x^2 - 10)^(3//2) + (1//5)*(x^2 - 10)^(5//2) - 100*sqrt(10)*atan(sqrt(x^2 - 10)/sqrt(10)), x, 6),


# ::Subsection::Closed::
# Problems 6 - 21 (p. 327-328)


(x^(2*n + 1), x^(2*(n + 1))/(2*(n + 1)), x, 1),
(x^7/(x^2 - 5)^3, x^2//2 - 125/(4*(5 - x^2)^2) + 75/(2*(5 - x^2)) + (15//2)*log(5 - x^2), x, 3),
((3*x^5 - 4*x^3)/(x^2 - 1)^5, 1/(8*(1 - x^2)^4) + 1/(3*(1 - x^2)^3) - 3/(4*(1 - x^2)^2), x, 4),
((1 + x^2)^(9//14)*x^3, -7//23*(1 + x^2)^(23//14) + 7//37*(1 + x^2)^(37//14), x, 3),
(x^5/(x^2 - 4)^(13//6), -(48/(7*(x^2 - 4)^(7//6))) - 24/(x^2 - 4)^(1//6) + (3//5)*(x^2 - 4)^(5//6), x, 3),
(1/(1+2*x^2)^(5//2), x/(3*(1 + 2*x^2)^(3//2)) + (2*x)/(3*sqrt(1 + 2*x^2)), x, 2),
(1/(x^2 - 2*x - 1)^(5//2), (1 - x)/(6*(x^2 - 2*x - 1)^(3//2)) - (1 - x)/(6*sqrt(x^2 - 2*x - 1)), x, 2),
(1/(x^4*(x^2 - 8)^(3//2)), 1/(24*x^3*sqrt(x^2 - 8)) + 1/(48*x*sqrt(x^2 - 8)) - x/(192*sqrt(x^2 - 8)), x, 3),
((x^2 + 5)^2/(x^4*x^(1//3)), -(15/(2*x^(10//3))) - 15/(2*x^(4//3)) + (3*x^(2//3))/2, x, 2),
(1/(x^7*(1 + x^2)^3), -(1/(6*x^6)) + 3/(4*x^4) - 3/x^2 - 1/(4*(1 + x^2)^2) - 2/(1 + x^2) - 10*log(x) + 5*log(1 + x^2), x, 3),
(((2 + x^2)/x^2)^(7//9)/(2 + x^2)^(3//2), -((9*(1 + 2/x^2)^(7//9)*x)/(10*sqrt(2 + x^2))), x, 3),
# {x^4/(Sqrt[10] - x^2)^(9/2), x, 2, x^5/(7*Sqrt[10]*(Sqrt[10] - x^2)^(7/2)) + x^5/(175*(Sqrt[10] - x^2)^(5/2)), x^5/(5*Sqrt[10]*(Sqrt[10] - x^2)^(7/2)) - x^7/(175*(Sqrt[10] - x^2)^(7/2))}
(x^2/(3 - x^2)^(3//2), x/sqrt(3 - x^2) - asin(x/sqrt(3)), x, 2),
((25 - x^2)^(3//2)/x^4, sqrt(25 - x^2)/x - (25 - x^2)^(3//2)/(3*x^3) + asin(x/5), x, 3),
(1/(1 - 2*x^2)^(7//2), x/(5*(1 - 2*x^2)^(5//2)) + (4*x)/(15*(1 - 2*x^2)^(3//2)) + (8*x)/(15*sqrt(1 - 2*x^2)), x, 3),
(1/(-x^2 + 6*x - 7)^(5//2), -((3 - x)/(6*(-x^2 + 6*x - 7)^(3//2))) - (3 - x)/(6*sqrt(-x^2 + 6*x - 7)), x, 2),


# ::Subsection::Closed::
# Problems 22 - 25 (p. 329)


((-2*x^2 - 2*x + 1)^3, x - 3*x^2 + 2*x^3 + 4*x^4 - (12*x^5)/5 - 4*x^6 - (8*x^7)/7, x, 2),
((x^2 - x - 1)^2*(5*x - 1), -x + (3*x^2)/2 + (11*x^3)/3 - (3*x^4)/4 - (11*x^5)/5 + (5*x^6)/6, x, 2),
((3*x + 1)/(2*x^2 - 8*x + 1)^(5//2), (1 - 2*x)/(6*(2*x^2 - 8*x + 1)^(3//2)) - (2*(2 - x))/(21*sqrt(2*x^2 - 8*x + 1)), x, 2),
((8*x^3 - 8*x - 1)/(1 + 2*x - 4*x^2)^(5//2), -((4*(1 + x))/(15*(1 + 2*x - 4*x^2)^(3//2))) - (7 + 122*x)/(75*sqrt(1 + 2*x - 4*x^2)), x, 2),


# ::Section::Closed::
# Chapter 7 Integration Problems


# ::Subsection::Closed::
# Problems 1 - 4 (p. 334)


(x^2*cos(x)^5, (16//15)*x*cos(x) + (8//45)*x*cos(x)^3 + (2//25)*x*cos(x)^5 - (298*sin(x))/225 + (8//15)*x^2*sin(x) + (4//15)*x^2*cos(x)^2*sin(x) + (1//5)*x^2*cos(x)^4*sin(x) + (76*sin(x)^3)/675 - (2*sin(x)^5)/125, x, 9),
(x^3*sin(x)^3, (40//9)*x*cos(x) - (2//3)*x^3*cos(x) - (40*sin(x))/9 + 2*x^2*sin(x) + (2//9)*x*cos(x)*sin(x)^2 - (1//3)*x^3*cos(x)*sin(x)^2 - (2*sin(x)^3)/27 + (1//3)*x^2*sin(x)^3, x, 8),
(x^2*sin(x)^6, -((245*x)/1152) + (5*x^3)/48 + (245*cos(x)*sin(x))/1152 - (5//16)*x^2*cos(x)*sin(x) + (5//16)*x*sin(x)^2 + (65*cos(x)*sin(x)^3)/1728 - (5//24)*x^2*cos(x)*sin(x)^3 + (5//48)*x*sin(x)^4 + (1//108)*cos(x)*sin(x)^5 - (1//6)*x^2*cos(x)*sin(x)^5 + (1//18)*x*sin(x)^6, x, 13),
(x^2*sin(x)^2*cos(x), (4//9)*x*cos(x) - (4*sin(x))/9 + (2//9)*x*cos(x)*sin(x)^2 - (2*sin(x)^3)/27 + (1//3)*x^2*sin(x)^3, x, 4),


# ::Subsection::Closed::
# Problems 5 - 9 (p. 342-343)


(x*cos(x)^4/sin(x)^2, -((3*x^2)/4) - cos(x)^2//4 - x*cot(x) + log(sin(x)) - (1//2)*x*cos(x)*sin(x), x, 6),
(x*sin(x)^3/cos(x)^4, (5//6)*atanh(sin(x)) - x*sec(x) + (1//3)*x*sec(x)^3 - (1//6)*sec(x)*tan(x), x, 5),
(x*sin(x)/cos(x)^3, (1//2)*x*sec(x)^2 - tan(x)/2, x, 3),
(x*sin(x)^3/cos(x), x/4 + (I*x^2)/2 - x*log(1 + ℯ^(2*I*x)) + (1//2)*I*PolyLog_reli(2, -ℯ^(2*I*x)) - (1//4)*cos(x)*sin(x) - (1//2)*x*sin(x)^2, x, 8),
(x*sin(x)^3/cos(x)^3, x/2 - (I*x^2)/2 + x*log(1 + ℯ^(2*I*x)) - (1//2)*I*PolyLog_reli(2, -ℯ^(2*I*x)) - tan(x)/2 + (1//2)*x*tan(x)^2, x, 7),


# ::Subsection::Closed::
# Problems 10 - 11 (p. 344)


((2*x+sin(2*x))/(x*sin(x)+cos(x))^2, 2/(1 + cot(x)/x), x, 2),
((x/(x*cos(x)-sin(x)))^2, -cot(x) + (x*csc(x))/(x*cos(x) - sin(x)), x, 3),


# ::Section::Closed::
# Chapter 8 Integration Problems


# ::Subsection::Closed::
# Problems 1 - 5 (p. 346)


(a^(m*x)*b^(n*x), (a^(m*x)*b^(n*x))/(m*log(a) + n*log(b)), x, 2),
# {(a^x - b^x)^2/(a^x*b^x), x, 9, -2*x + (a^x/b^x - b^x/a^x)/(Log[a] - Log[b]), -2*x + a^x/(b^x*(Log[a] - Log[b])) - b^x/(a^x*(Log[a] - Log[b]))}
((ℯ^x - ℯ^(-x))^1, ℯ^x + ℯ^(-x), x, 3),
((ℯ^x - ℯ^(-x))^2, -(1//2)/ℯ^(2*x) + ℯ^(2*x)/2 - 2*x, x, 4),
((ℯ^x - ℯ^(-x))^3, 1/(3*ℯ^(3*x)) - 3/ℯ^x - 3*ℯ^x + ℯ^(3*x)/3, x, 3),
((ℯ^x - ℯ^(-x))^4, -(1//4)/ℯ^(4*x) + 2/ℯ^(2*x) - 2*ℯ^(2*x) + ℯ^(4*x)/4 + 6*x, x, 4),
# {(E^x - E^(-x))^n, x, 4, -(((-E^(-x) + E^x)^n*(1 - E^(2*x))*Hypergeometric2F1[1, (2 + n)/2, 1 - n/2, E^(2*x)])/n), -(((-E^(-x) + E^x)^n*Hypergeometric2F1[-n, -(n/2), 1 - n/2, E^(2*x)])/((1 - E^(2*x))^n*n))}
((a^(-4*x) - a^(2*x))^3, 3*x - 1/(a^(12*x)*(12*log(a))) + 1/(a^(6*x)*(2*log(a))) - a^(6*x)/(6*log(a)), x, 4),
((a^(k*x) + a^(l*x))^1, a^(k*x)/(k*log(a)) + a^(l*x)/(l*log(a)), x, 3),
((a^(k*x) + a^(l*x))^2, a^(2*k*x)/(2*k*log(a)) + a^(2*l*x)/(2*l*log(a)) + (2*a^((k + l)*x))/((k + l)*log(a)), x, 6),
((a^(k*x) + a^(l*x))^3, a^(3*k*x)/(3*k*log(a)) + a^(3*l*x)/(3*l*log(a)) + (3*a^((2*k + l)*x))/((2*k + l)*log(a)) + (3*a^((k + 2*l)*x))/((k + 2*l)*log(a)), x, 7),
((a^(k*x) + a^(l*x))^4, a^(4*k*x)/(4*k*log(a)) + a^(4*l*x)/(4*l*log(a)) + (3*a^(2*(k + l)*x))/((k + l)*log(a)) + (4*a^((3*k + l)*x))/((3*k + l)*log(a)) + (4*a^((k + 3*l)*x))/((k + 3*l)*log(a)), x, 8),
# {(a^(k*x) + a^(l*x))^n, x, 2, (((1 + a^((k - l)*x))*(a^(k*x) + a^(l*x))^n)/(l*n*Log[a]))*Hypergeometric2F1[1, 1 + (k*n)/(k - l), 1 + (l*n)/(k - l), -a^((k - l)*x)], ((a^(k*x) + a^(l*x))^n*Hypergeometric2F1[-n, -((k*n)/(k - l)), 1 - (k*n)/(k - l), -a^(-((k - l)*x))])/((1 + a^(-((k - l)*x)))^n*(k*n*Log[a]))}
((a^(k*x) - a^(l*x))^1, a^(k*x)/(k*log(a)) - a^(l*x)/(l*log(a)), x, 3),
((a^(k*x) - a^(l*x))^2, a^(2*k*x)/(2*k*log(a)) + a^(2*l*x)/(2*l*log(a)) - (2*a^((k + l)*x))/((k + l)*log(a)), x, 6),
((a^(k*x) - a^(l*x))^3, a^(3*k*x)/(3*k*log(a)) - a^(3*l*x)/(3*l*log(a)) - (3*a^((2*k + l)*x))/((2*k + l)*log(a)) + (3*a^((k + 2*l)*x))/((k + 2*l)*log(a)), x, 7),
((a^(k*x) - a^(l*x))^4, a^(4*k*x)/(4*k*log(a)) + a^(4*l*x)/(4*l*log(a)) + (3*a^(2*(k + l)*x))/((k + l)*log(a)) - (4*a^((3*k + l)*x))/((3*k + l)*log(a)) - (4*a^((k + 3*l)*x))/((k + 3*l)*log(a)), x, 8),
# {(a^(k*x) - a^(l*x))^n, x, 2, (((1 - a^((k - l)*x))*(a^(k*x) - a^(l*x))^n)/(l*n*Log[a]))*Hypergeometric2F1[1, 1 + (k*n)/(k - l), 1 + (l*n)/(k - l), a^((k - l)*x)], ((a^(k*x) - a^(l*x))^n*Hypergeometric2F1[-n, -((k*n)/(k - l)), 1 - (k*n)/(k - l), a^(-((k - l)*x))])/((1 - a^(-((k - l)*x)))^n*(k*n*Log[a]))}


# ::Subsection::Closed::
# Problems 6 - 9 (p. 346)


((1 + a^(m*x))^1, x + a^(m*x)/(m*log(a)), x, 2),
((1 + a^(m*x))^2, x + (2*a^(m*x))/(m*log(a)) + a^(2*m*x)/(2*m*log(a)), x, 3),
((1 + a^(m*x))^3, x + (3*a^(m*x))/(m*log(a)) + (3*a^(2*m*x))/(2*m*log(a)) + a^(3*m*x)/(3*m*log(a)), x, 3),
((1 + a^(m*x))^4, x + (4*a^(m*x))/(m*log(a)) + (3*a^(2*m*x))/(m*log(a)) + (4*a^(3*m*x))/(3*m*log(a)) + a^(4*m*x)/(4*m*log(a)), x, 3),
((1 + a^(m*x))^n, -(((1 + a^(m*x))^(1 + n)*hypergeometric2f1(1, 1 + n, 2 + n, 1 + a^(m*x)))/(m*(1 + n)*log(a))), x, 2),
((1 - a^(m*x))^1, x - a^(m*x)/(m*log(a)), x, 2),
((1 - a^(m*x))^2, x - (2*a^(m*x))/(m*log(a)) + a^(2*m*x)/(2*m*log(a)), x, 3),
((1 - a^(m*x))^3, x - (3*a^(m*x))/(m*log(a)) + (3*a^(2*m*x))/(2*m*log(a)) - a^(3*m*x)/(3*m*log(a)), x, 3),
((1 - a^(m*x))^4, x - (4*a^(m*x))/(m*log(a)) + (3*a^(2*m*x))/(m*log(a)) - (4*a^(3*m*x))/(3*m*log(a)) + a^(4*m*x)/(4*m*log(a)), x, 3),
((1 - a^(m*x))^n, -(((1 - a^(m*x))^(1 + n)*hypergeometric2f1(1, 1 + n, 2 + n, 1 - a^(m*x)))/(m*(1 + n)*log(a))), x, 2),
(1/(a*ℯ^(n*x) + b), x/b - log(b + a*ℯ^(n*x))/(b*n), x, 4),
# {E^x/(a*E^(3*x) + b), x, 7, -(ArcTan[(b^(1/3) - 2*a^(1/3)*E^x)/(Sqrt[3]*b^(1/3))]/(Sqrt[3]*a^(1/3)*b^(2/3))) + Log[b^(1/3) + a^(1/3)*E^x]/(2*a^(1/3)*b^(2/3)) - Log[b + a*E^(3*x)]/(6*a^(1/3)*b^(2/3)), -(ArcTan[(b^(1/3) - 2*a^(1/3)*E^x)/(Sqrt[3]*b^(1/3))]/(Sqrt[3]*a^(1/3)*b^(2/3))) + Log[b^(1/3) + a^(1/3)*E^x]/(3*a^(1/3)*b^(2/3)) - Log[b^(2/3) - a^(1/3)*b^(1/3)*E^x + a^(2/3)*E^(2*x)]/(6*a^(1/3)*b^(2/3))}
((ℯ^x - 1)/(ℯ^x + 1), -x + 2*log(1 + ℯ^x), x, 3),


# ::Subsection::Closed::
# Problems 10 - 16 (p. 347)


(ℯ^(4*x)/(3*ℯ^(4*x) - 2*ℯ^(2*x) + 1), -(atan((1 - 3*ℯ^(2*x))/sqrt(2))/(6*sqrt(2))) + (1//12)*log(1 - 2*ℯ^(2*x) + 3*ℯ^(4*x)), x, 5),
((ℯ^(5*x) + ℯ^x)/(ℯ^(3*x) - ℯ^(2*x) + ℯ^x - 1), ℯ^x + ℯ^(2*x)/2 - atan(ℯ^x) + log(1 - ℯ^x) - (1//2)*log(1 + ℯ^(2*x)), x, 6),
((a + b*ℯ^(n*x))^(r/s)*ℯ^(n*x), s*(a + b*ℯ^(n*x))^((s + r)/s)/(b*n*(s + r)), x, 2),
((1 - 2*ℯ^(x/3))^(1//4), 12*(1 - 2*ℯ^(x/3))^(1//4) - 6*atan((1 - 2*ℯ^(x/3))^(1//4)) - 6*atanh((1 - 2*ℯ^(x/3))^(1//4)), x, 6),
((a + b*ℯ^(n*x))^(r/s), -(((a + b*ℯ^(n*x))^((r + s)/s)*s*hypergeometric2f1(1, (r + s)/s, 2 + r/s, 1 + (b*ℯ^(n*x))/a))/(a*n*(r + s))), x, 2),
(ℯ^x/sqrt(ℯ^(2*x) + a^2), atanh(ℯ^x/sqrt(a^2 + ℯ^(2*x))), x, 3),
(ℯ^x/sqrt(ℯ^(2*x) - a^2), atanh(ℯ^x/sqrt(-a^2 + ℯ^(2*x))), x, 3),
(ℯ^((3//4)*x)/((ℯ^((3//4)*x) - 2)*sqrt(ℯ^((3//2)*x) + ℯ^((3//4)*x) - 2)), (2//3)*atanh((2 - 5*ℯ^((3*x)/4))/(4*sqrt(-2 + ℯ^((3*x)/4) + ℯ^((3*x)/2)))), x, 3),


# ::Subsection::Closed::
# Problems 17 - 18 (p. 348)


# {(E^(7*x) - 3)^(2/3)/E^(2*x), x, 4, ((1/6)*(-3 + E^(7*x))^(5/3)*Hypergeometric2F1[1, 29/21, 5/7, E^(7*x)/3])/E^(2*x), -((3^(2/3)*(-3 + E^(7*x))^(2/3)*Hypergeometric2F1[-(2/3), -(2/7), 5/7, E^(7*x)/3])/(E^(2*x)*(2*(3 - E^(7*x))^(2/3))))}
(ℯ^(2*x)/(3 - ℯ^(x/2))^(3//4), -216*(3 - ℯ^(x/2))^(1//4) + (216//5)*(3 - ℯ^(x/2))^(5//4) - 8*(3 - ℯ^(x/2))^(9//4) + (8//13)*(3 - ℯ^(x/2))^(13//4), x, 3),


# ::Subsection::Closed::
# Problems 19 - 24 (p. 351)


(x^3/ℯ^(x/2), -96/ℯ^(x/2) - (48*x)/ℯ^(x/2) - (12*x^2)/ℯ^(x/2) - (2*x^3)/ℯ^(x/2), x, 4),
(1/(x^3*ℯ^(x/2)), -(1/(ℯ^(x/2)*(2*x^2))) + 1/(ℯ^(x/2)*(4*x)) + (1//8)*Expinti(-(x/2)), x, 3),
(x^2*a^(3*x), (2*a^(3*x))/(27*log(a)^3) - (2*a^(3*x)*x)/(9*log(a)^2) + (a^(3*x)*x^2)/(3*log(a)), x, 3),
(x*(x^2 + 1)*ℯ^x^2, (1//2)*ℯ^x^2*x^2, x, 5),
(x/(ℯ^x + ℯ^(-x))^2, x/2 - x/(2*(1 + ℯ^(2*x))) - (1//4)*log(1 + ℯ^(2*x)), x, 6),
((1 - x - x^2)/sqrt(1 - x^2)*ℯ^x, ℯ^x*sqrt(1 - x^2), x, 1),


# ::Subsection::Closed::
# Problems 25 - 32 (p. 353)


(cos(2*x)/ℯ^(3*x), ((-(3//13))*cos(2*x))/ℯ^(3*x) + ((2//13)*sin(2*x))/ℯ^(3*x), x, 1),
((sin(x/2) + cos(x/2))/(ℯ^x)^(1//3), -((30*cos(x/2))/(13*(ℯ^x)^(1//3))) + (6*sin(x/2))/(13*(ℯ^x)^(1//3)), x, 6),
(cos(3*x/2)/(3^(3*x))^(1//4), -((4*cos((3*x)/2)*log(3))/(3*(3^(3*x))^(1//4)*(4 + log(3)^2))) + (8*sin((3*x)/2))/(3*(3^(3*x))^(1//4)*(4 + log(3)^2)), x, 2),
(ℯ^(m*x)*cos(x)^2, (2*ℯ^(m*x))/(m*(4 + m^2)) + (ℯ^(m*x)*m*cos(x)^2)/(4 + m^2) + (2*ℯ^(m*x)*cos(x)*sin(x))/(4 + m^2), x, 2),
(ℯ^(m*x)*sin(x)^3, -((6*ℯ^(m*x)*cos(x))/(9 + 10*m^2 + m^4)) + (6*ℯ^(m*x)*m*sin(x))/(9 + 10*m^2 + m^4) - (3*ℯ^(m*x)*cos(x)*sin(x)^2)/(9 + m^2) + (ℯ^(m*x)*m*sin(x)^3)/(9 + m^2), x, 2),
(cos(x/3)^3/sqrt(ℯ^x), -((48*cos(x/3))/(65*sqrt(ℯ^x))) - (2*cos(x/3)^3)/(5*sqrt(ℯ^x)) + (32*sin(x/3))/(65*sqrt(ℯ^x)) + (4*cos(x/3)^2*sin(x/3))/(5*sqrt(ℯ^x)), x, 3),
(ℯ^(2*x)*sin(x)^2*cos(x)^2, ℯ^(2*x)/16 - (1//80)*ℯ^(2*x)*cos(4*x) - (1//40)*ℯ^(2*x)*sin(4*x), x, 4),
(ℯ^(3*x)*sin(3*(x/2))^2*cos(3*(x/2))^2, ℯ^(3*x)/24 - (1//120)*ℯ^(3*x)*cos(6*x) - (1//60)*ℯ^(3*x)*sin(6*x), x, 4),


# ::Subsection::Closed::
# Problems 33 - 36 (p. 355)


# {E^(m*x)*Tan[x]^2, x, 5, -(E^(m*x)/m) + 4*E^((2*I + m)*x)*Hypergeometric2F1[2, 1 - (I*m)/2, 2 - (I*m)/2, -E^(2*I*x)]/(2*I + m), -(E^(m*x)/m) + (4*E^(m*x)*Hypergeometric2F1[1, -((I*m)/2), 1 - (I*m)/2, -E^(2*I*x)])/m - (4*E^(m*x)*Hypergeometric2F1[2, -((I*m)/2), 1 - (I*m)/2, -E^(2*I*x)])/m}
(ℯ^(m*x)/sin(x)^2, -((4*ℯ^((2*I + m)*x)*hypergeometric2f1(2, 1 - (I*m)/2, 2 - (I*m)/2, ℯ^(2*I*x)))/(2*I + m)), x, 1),
# {E^(m*x)/Cos[x]^3, x, 2, ((8*E^((3*I + m)*x))/(3*I + m))*Hypergeometric2F1[3, (3 - I*m)/2, (5 - I*m)/2, -E^(2*I*x)], (-E^((I + m)*x))*(I - m)*Hypergeometric2F1[1, (1/2)*(1 - I*m), (1/2)*(3 - I*m), -E^(2*I*x)] - (1/2)*E^(m*x)*m*Sec[x] + (1/2)*E^(m*x)*Sec[x]*Tan[x]}
(ℯ^x/(1 + cos(x)), (1 - I)*ℯ^((1 + I)*x)*hypergeometric2f1(2, 1 - I, 2 - I, -ℯ^(I*x)), x, 2),
(ℯ^x/(1 - cos(x)), -(1 - I)*ℯ^((1 + I)*x)*hypergeometric2f1(2, 1 - I, 2 - I, ℯ^(I*x)), x, 2),
(ℯ^x/(1 + sin(x)), (-1 + I)*ℯ^((1 - I)*x)*hypergeometric2f1(1 + I, 2, 2 + I, -I/ℯ^(I*x)), x, 2),
(ℯ^x/(1 - sin(x)), (1 + I)*ℯ^((1 + I)*x)*hypergeometric2f1(1 - I, 2, 2 - I, (-I)*ℯ^(I*x)), x, 2),


# ::Subsection::Closed::
# Problems 37 - 44 (p. 356)


(ℯ^x*((1 - sin(x))/(1 - cos(x))), -ℯ^x*sin(x)/(1 - cos(x)), x, 1),
# {E^x*((1 + Sin[x])/(1 - Cos[x])), x, 7, (E^x*Sin[x])/(1 - Cos[x]) - 2*(1 - I)*E^((1 + I)*x)*Hypergeometric2F1[2, 1 - I, 2 - I, E^(I*x)], 2*I*E^x - 4*I*E^x*Hypergeometric2F1[-I, 1, 1 - I, E^(I*x)] - (E^x*Sin[x])/(1 - Cos[x])}
(ℯ^x*((1 + sin(x))/(1 + cos(x))), ℯ^x*sin(x)/(1 + cos(x)), x, 1),
# {E^x*((1 - Sin[x])/(1 + Cos[x])), x, 7, -((E^x*Sin[x])/(1 + Cos[x])) + 2*(1 - I)*E^((1 + I)*x)*Hypergeometric2F1[2, 1 - I, 2 - I, -E^(I*x)], 2*I*E^x - 4*I*E^x*Hypergeometric2F1[-I, 1, 1 - I, -E^(I*x)] + (E^x*Sin[x])/(1 + Cos[x])}

# {E^x*((1 - Cos[x])/(1 - Sin[x])), x, 7, -((E^x*Cos[x])/(1 - Sin[x])) + 2*(1 + I)*E^((1 + I)*x)*Hypergeometric2F1[2, 1 - I, 2 - I, (-I)*E^(I*x)], 2*I*E^x - 4*I*E^x*Hypergeometric2F1[-I, 1, 1 - I, (-I)*E^(I*x)] + (E^x*Cos[x])/(1 - Sin[x])}
(ℯ^x*((1 + cos(x))/(1 - sin(x))), ℯ^x*cos(x)/(1 - sin(x)), x, 1),
# {E^x*((1 + Cos[x])/(1 + Sin[x])), x, 7, (E^x*Cos[x])/(1 + Sin[x]) - 2*(1 + I)*E^((1 + I)*x)*Hypergeometric2F1[2, 1 - I, 2 - I, I*E^(I*x)], -2*I*E^x + 4*I*E^x*Hypergeometric2F1[I, 1, 1 + I, -I/E^(I*x)] - (E^x*Cos[x])/(1 + Sin[x])}
(ℯ^x*((1 - cos(x))/(1 + sin(x))), -ℯ^x*cos(x)/(1 + sin(x)), x, 1),


# ::Subsection::Closed::
# Problems 45 - 49 (p. 357-358)


(x*ℯ^x*cos(x), (1//2)*ℯ^x*x*cos(x) - (1//2)*ℯ^x*sin(x) + (1//2)*ℯ^x*x*sin(x), x, 4),
(x^2*ℯ^x*sin(x), (-(1//2))*ℯ^x*cos(x) + ℯ^x*x*cos(x) - (1//2)*ℯ^x*x^2*cos(x) - (1//2)*ℯ^x*sin(x) + (1//2)*ℯ^x*x^2*sin(x), x, 11),
(x^2*(sin(x)/ℯ^(3*x)), ((-(13//250))*cos(x))/ℯ^(3*x) - ((3//25)*x*cos(x))/ℯ^(3*x) - ((1//10)*x^2*cos(x))/ℯ^(3*x) - ((9//250)*sin(x))/ℯ^(3*x) - ((4//25)*x*sin(x))/ℯ^(3*x) - ((3//10)*x^2*sin(x))/ℯ^(3*x), x, 11),
(ℯ^(x/2)*x^2*cos(x)^3, (-(132//125))*ℯ^(x/2)*cos(x) + (18//25)*ℯ^(x/2)*x*cos(x) + (48//185)*ℯ^(x/2)*x^2*cos(x) + (2//37)*ℯ^(x/2)*x^2*cos(x)^3 - (428*ℯ^(x/2)*cos(3*x))/50653 + (70*ℯ^(x/2)*x*cos(3*x))/1369 - (24//125)*ℯ^(x/2)*sin(x) - (24//25)*ℯ^(x/2)*x*sin(x) + (96//185)*ℯ^(x/2)*x^2*sin(x) + (12//37)*ℯ^(x/2)*x^2*cos(x)^2*sin(x) - (792*ℯ^(x/2)*sin(3*x))/50653 - (24*ℯ^(x/2)*x*sin(3*x))/1369, x, -31),
(ℯ^(2*x)*x^2*sin(4*x), (1//250)*ℯ^(2*x)*cos(4*x) + (2//25)*ℯ^(2*x)*x*cos(4*x) - (1//5)*ℯ^(2*x)*x^2*cos(4*x) - (11//500)*ℯ^(2*x)*sin(4*x) + (3//50)*ℯ^(2*x)*x*sin(4*x) + (1//10)*ℯ^(2*x)*x^2*sin(4*x), x, 11),


# ::Subsection::Closed::
# Problems 50 (p. 359)


(ℯ^(x/2)*x^2*sin(x)^2*cos(x), (-(44//125))*ℯ^(x/2)*cos(x) + (6//25)*ℯ^(x/2)*x*cos(x) + (1//10)*ℯ^(x/2)*x^2*cos(x) + (428*ℯ^(x/2)*cos(3*x))/50653 - (70*ℯ^(x/2)*x*cos(3*x))/1369 - (1//74)*ℯ^(x/2)*x^2*cos(3*x) - (8//125)*ℯ^(x/2)*sin(x) - (8//25)*ℯ^(x/2)*x*sin(x) + (1//5)*ℯ^(x/2)*x^2*sin(x) + (792*ℯ^(x/2)*sin(3*x))/50653 + (24*ℯ^(x/2)*x*sin(3*x))/1369 - (3//37)*ℯ^(x/2)*x^2*sin(3*x), x, 24),


# ::Subsection::Closed::
# Problems 51 - 55 (p. 361)


(cosh(x), sinh(x), x, 1),
(sinh(x), cosh(x), x, 1),
(tanh(x), log(cosh(x)), x, 1),
(coth(x), log(sinh(x)), x, 1),
(sech(x), atan(sinh(x)), x, 1),
(csch(x), -atanh(cosh(x)), x, 1),
(cosh(x)^2, x/2 + (1//2)*cosh(x)*sinh(x), x, 2),
(sinh(x)^5, cosh(x) - (2*cosh(x)^3)/3 + cosh(x)^5//5, x, 2),


# ::Subsection::Closed::
# Problems 56 - 60 (p. 365)


(tanh(x)^4, x - tanh(x) - tanh(x)^3//3, x, 3),
(csch(x)^3, (1//2)*atanh(cosh(x)) - (1//2)*coth(x)*csch(x), x, 2),
(1/cosh(x)^5, (3//8)*atan(sinh(x)) + (3//8)*sech(x)*tanh(x) + (1//4)*sech(x)^3*tanh(x), x, 3),
(tanh(x)^5/sech(x)^4, -cosh(x)^2 + cosh(x)^4//4 + log(cosh(x)), x, 4),
(tanh(x)^5*sech(x)^(3//4), (-(4//3))*sech(x)^(3//4) + (8//11)*sech(x)^(11//4) - (4//19)*sech(x)^(19//4), x, 3),


# ::Subsection::Closed::
# Problems 61 - 65 (p. 365-366)


# {1/(a + b*Cosh[x]), x, 2, (2*ArcTanh[((a - b)*Tanh[x/2])/Sqrt[a^2 - b^2]])/Sqrt[a^2 - b^2], (2*ArcTanh[(Sqrt[a - b]*Tanh[x/2])/Sqrt[a + b]])/(Sqrt[a - b]*Sqrt[a + b])}
(1/(1 + cosh(x))^2, sinh(x)/(3*(1 + cosh(x))^2) + sinh(x)/(3*(1 + cosh(x))), x, 2),
(1/(a + b*tanh(x)), (a*x)/(a^2 - b^2) - (b*log(a*cosh(x) + b*sinh(x)))/(a^2 - b^2), x, 2),
(1/(a^2 + b^2*cosh(x)^2), atanh((a*tanh(x))/sqrt(a^2 + b^2))/(a*sqrt(a^2 + b^2)), x, 2),
(1/(a^2 - b^2*cosh(x)^2), atanh((a*tanh(x))/sqrt(a^2 - b^2))/(a*sqrt(a^2 - b^2)), x, 2),
(1/(1 - sinh(x)^4), atanh(sqrt(2)*tanh(x))/(2*sqrt(2)) + tanh(x)/2, x, 3),


# ::Subsection::Closed::
# Problems 66 - 72 (p. 366-367)


((cosh(x)^3 - sinh(x)^3)/(cosh(x)^3 + sinh(x)^3), -((4*atan((1 - 2*tanh(x))/sqrt(3)))/(3*sqrt(3))) - 1/(3*(1 + tanh(x))), x, 5),
(cosh(x)*cosh(2*x)*cosh(3*x), x/4 + 1//8*sinh(2*x) + 1//16*sinh(4*x) + 1//24*sinh(6*x), x, 5),
(sinh(x)*cosh(3*x/2)*sinh(5*x/2), -x/4 + 1//8*sinh(2*x) - 1//12*sinh(3*x) + 1//20*sinh(5*x), x, 5),
# {(Tanh[x] - Cosh[2*x])*(Cosh[x]/((Sinh[2*x] + Sinh[x]^2)*Sqrt[Sinh[2*x]])), x, 8, Sqrt[2]*ArcTan[Sech[x]*Sqrt[Cosh[x]*Sinh[x]]] + (1/6)*ArcTan[Sinh[x]/Sqrt[Sinh[2*x]]] - (1/3)*Sqrt[2]*ArcTanh[Sech[x]*Sqrt[Cosh[x]*Sinh[x]]] + Cosh[x]/Sqrt[Sinh[2*x]], Cosh[x]/Sqrt[Sinh[2*x]] + (2*ArcTan[Sqrt[Tanh[x]]]*Sinh[x])/(Sqrt[Sinh[2*x]]*Sqrt[Tanh[x]]) + (ArcTan[Sqrt[Tanh[x]]/Sqrt[2]]*Sinh[x])/(3*Sqrt[2]*Sqrt[Sinh[2*x]]*Sqrt[Tanh[x]]) - (2*ArcTanh[Sqrt[Tanh[x]]]*Sinh[x])/(3*Sqrt[Sinh[2*x]]*Sqrt[Tanh[x]])}
(sinh(x)/(4*cosh(x)^2 - 9)^(5//2), -(cosh(x)/(27*(-9 + 4*cosh(x)^2)^(3//2))) + (2*cosh(x))/(243*sqrt(-9 + 4*cosh(x)^2)), x, 3),
(sinh(x)^2*(sinh(2*x)/(1 - sinh(x)^2)^(3//2)), 2/sqrt(1 - sinh(x)^2) + 2*sqrt(1 - sinh(x)^2), x, 5),
(cosh(x)/sqrt(cosh(2*x)), asinh(sqrt(2)*sinh(x))/sqrt(2), x, 2),


# ::Subsection::Closed::
# Problems 73 - 75 (p. 368)


(x*tanh(x)^2, x^2//2 + log(cosh(x)) - x*tanh(x), x, 3),
(x*coth(x)^2, x^2//2 - x*coth(x) + log(sinh(x)), x, 3),
((x + sinh(x) + cosh(x))/(cosh(x) - sinh(x)), -ℯ^x + ℯ^(2*x)/2 + ℯ^x*x, x, 13),
((x + sinh(x) + cosh(x))/(1 + cosh(x)), x - (1 - x)*tanh(x/2), x, 8),


# ::Subsection::Closed::
# Problems 76 - 82 (p. 373)


(ℯ^(2*x)/sinh(x)^4, (8*ℯ^(6*x))/(3*(1 - ℯ^(2*x))^3), x, 3),
(1/(ℯ^(2*x)*cosh(x)^4), -(8/(3*(1 + ℯ^(2*x))^3)), x, 3),
(ℯ^x/(cosh(x) - sinh(x)), ℯ^(2*x)/2, x, 2),
# {E^(m*x)/(Cosh[x] + Sinh[x]), x, 3, E^((m - 1)*x)/(m - 1), -(1/(E^((1 - m)*x)*(1 - m)))}
(ℯ^x/(cosh(x) + sinh(x)), x, x, 2),
(ℯ^x/(1 - cosh(x)), -(2/(1 - ℯ^x)) - 2*log(1 - ℯ^x), x, 4),
(ℯ^x*((1 + sinh(x))/(1 + cosh(x))), ℯ^x + 2/(1 + ℯ^x), x, 3),
(ℯ^x*((1 - sinh(x))/(1 - cosh(x))), ℯ^x - 2/(1 - ℯ^x), x, 3),


# ::Subsection::Closed::
# Problems 83 - 87 (p. 375)


(x^m*log(x), -(x^(1 + m)/(1 + m)^2) + (x^(1 + m)*log(x))/(1 + m), x, 1),
(x^m*log(x)^2, (2*x^(1 + m))/(1 + m)^3 - (2*x^(1 + m)*log(x))/(1 + m)^2 + (x^(1 + m)*log(x)^2)/(1 + m), x, 2),
(log(x)^2/x^(5//2), -(16/(27*x^(3//2))) - (8*log(x))/(9*x^(3//2)) - (2*log(x)^2)/(3*x^(3//2)), x, 2),
((a + b*x)*log(x), (-a)*x - (b*x^2)/4 + a*x*log(x) + (1//2)*b*x^2*log(x), x, 2),
((a + b*x)^3*log(x), (-a^3)*x - (3//4)*a^2*b*x^2 - (1//3)*a*b^2*x^3 - (b^3*x^4)/16 - (a^4*log(x))/(4*b) + ((a + b*x)^4*log(x))/(4*b), x, 4),


# ::Subsection::Closed::
# Problems 88 - 89 (p. 375)


(3*log(x)^3 - 8*log(x)^2 - 1, -35*x + 34*x*log(x) - 17*x*log(x)^2 + 3*x*log(x)^3, x, 6),
((x^4 + 1)*(log(x)^3 - 2*log(x) + 1), -3*x + (169*x^5)/625 + 4*x*log(x) - (44//125)*x^5*log(x) - 3*x*log(x)^2 - (3//25)*x^5*log(x)^2 + x*log(x)^3 + (1//5)*x^5*log(x)^3, x, 13),


# ::Subsection::Closed::
# Problems 90 - 92 (p. 376)


(1/(x^3*log(x)^4), (-(4//3))*Expinti(-2*log(x)) - 1/(3*x^2*log(x)^3) + 1/(3*x^2*log(x)^2) - 2/(3*x^2*log(x)), x, 5),
(log(x)/(a + b*x), (log(x)*log(1 + (b*x)/a))/b + PolyLog_reli(2, -((b*x)/a))/b, x, 2),
(log(x)/(a + b*x)^2, (x*log(x))/(a*(a + b*x)) - log(a + b*x)/(a*b), x, 2),


# ::Subsection::Closed::
# Problems 93 - 97 (p. 377)


(log(x)^n/x, log(x)^(1 + n)/(1 + n), x, 2),
((a + b*log(x))^n/x, (a + b*log(x))^(1 + n)/(b*(1 + n)), x, 2),
(1/(x*(a + b*log(x))), log(a + b*log(x))/b, x, 2),
(1/(x*(a + b*log(x))^n), (a + b*log(x))^(1 - n)/(b*(1 - n)), x, 2),
(1/(x*sqrt(log(x)^2 + a^2)), atanh(log(x)/sqrt(log(x)^2 + a^2)), x, 3),
(1/(x*sqrt(log(x)^2 - a^2)), atanh(log(x)/sqrt(log(x)^2 - a^2)), x, 3),
(1/(x*sqrt(a^2 - log(x)^2)), atan(log(x)/sqrt(a^2 - log(x)^2)), x, 3),
(1/(x*log(x)*sqrt(a^2 + log(x)^2)), -(atanh(sqrt(a^2 + log(x)^2)/a)/a), x, 4),
(1/(x*log(x)*sqrt(a^2 - log(x)^2)), -(atanh(sqrt(a^2 - log(x)^2)/a)/a), x, 4),
(1/(x*log(x)*sqrt(log(x)^2 - a^2)), atan(sqrt(-a^2 + log(x)^2)/a)/a, x, 4),
(log(log(x))^1/x, -log(x) + log(x)*log(log(x)), x, 1),
(log(log(x))^2/x, 2*log(x) - 2*log(x)*log(log(x)) + log(x)*log(log(x))^2, x, 3),
(log(log(x))^3/x, -6*log(x) + 6*log(x)*log(log(x)) - 3*log(x)*log(log(x))^2 + log(x)*log(log(x))^3, x, 4),
(log(log(x))^4/x, 24*log(x) - 24*log(x)*log(log(x)) + 12*log(x)*log(log(x))^2 - 4*log(x)*log(log(x))^3 + log(x)*log(log(x))^4, x, 5),
(log(log(x))^n/x, (Gamma(1 + n, -log(log(x)))*log(log(x))^n)/(-log(log(x)))^n, x, 3),


# ::Subsection::Closed::
# Problems 98 - 103 (p. 377-378)


(cot(x)/log(sin(x)), log(log(sin(x))), x, 3),
((ℯ^log(cos(x)) + ℯ^(-log(cos(x))))*tan(x), -cos(x) + sec(x), x, 3),
(sinh(x)*log(cosh(x)), -cosh(x) + cosh(x)*log(cosh(x)), x, 2),
(tanh(x)*log(cosh(x)), (1//2)*log(cosh(x))^2, x, 2),
(log(x - sqrt(1 + x^2)), sqrt(1 + x^2) + x*log(x - sqrt(1 + x^2)), x, 2),
(log(x - 1)/x^3, 1/(2*x) + (1//2)*log(1 - x) - log(-1 + x)/(2*x^2) - log(x)/2, x, 3),


# ::Subsection::Closed::
# Problems 104 - 109 (p. 378)


((ℯ^x - ℯ^(-x))*log(ℯ^(2*x) + 1), -2*ℯ^x + log(1 + ℯ^(2*x))/ℯ^x + ℯ^x*log(1 + ℯ^(2*x)), x, 8),
(ℯ^(3*x/2)*log(ℯ^x - 1), -((4*ℯ^(x/2))/3) - (4//9)*ℯ^((3*x)/2) + (4//3)*atanh(ℯ^(x/2)) + (2//3)*ℯ^((3*x)/2)*log(-1 + ℯ^x), x, 6),
(cos(x)^3*log(sin(x)), -sin(x) + log(sin(x))*sin(x) + sin(x)^3//9 - (1//3)*log(sin(x))*sin(x)^3, x, 4),
(log(tan(x))/cos(x)^4, -tan(x) + log(tan(x))*tan(x) - tan(x)^3//9 + (1//3)*log(tan(x))*tan(x)^3, x, 4),
(log(cos(x/2))/(1 + cos(x)), -(x/2) + (log(cos(x/2))*sin(x))/(1 + cos(x)) + tan(x/2), x, 4),
(cos(x)*log(sin(x))/(1 + cos(x))^2, -((2*x)/3) - sin(x)/(9*(1 + cos(x))^2) + (8*sin(x))/(9*(1 + cos(x))) - (log(sin(x))*sin(x))/(3*(1 + cos(x))^2) + (2*log(sin(x))*sin(x))/(3*(1 + cos(x))), x, 6),


# ::Section::Closed::
# Chapter 9 Integration Problems


# ::Subsection::Closed::
# Problems 1 - 6 (p. 391-392)


(acos(x)^2/x^5, -(1/(12*x^2)) + (sqrt(1 - x^2)*acos(x))/(6*x^3) + (sqrt(1 - x^2)*acos(x))/(3*x) - acos(x)^2/(4*x^4) + log(x)/3, x, 5),
(x^2*asin(x)^2, -((4*x)/9) - (2*x^3)/27 + (4//9)*sqrt(1 - x^2)*asin(x) + (2//9)*x^2*sqrt(1 - x^2)*asin(x) + (1//3)*x^3*asin(x)^2, x, 5),
(atan(x)^2*x^3, x^2//12 + (1//2)*x*atan(x) - (1//6)*x^3*atan(x) - atan(x)^2//4 + (1//4)*x^4*atan(x)^2 - (1//3)*log(1 + x^2), x, 10),
(atan(x)^2/x^5, -(1/(12*x^2)) - atan(x)/(6*x^3) + atan(x)/(2*x) + atan(x)^2//4 - atan(x)^2/(4*x^4) - (2*log(x))/3 + (1//3)*log(1 + x^2), x, 13),
(acsc(x)^2*x^3, x^2//12 + (1//3)*sqrt(1 - 1/x^2)*x*acsc(x) + (1//6)*sqrt(1 - 1/x^2)*x^3*acsc(x) + (1//4)*x^4*acsc(x)^2 + log(x)/3, x, 5),
(asec(x)^4/x^5, -(3/(128*x^4)) - 45/(128*x^2) - (3*sqrt(1 - 1/x^2)*asec(x))/(32*x^3) - (45*sqrt(1 - 1/x^2)*asec(x))/(64*x) - (45*asec(x)^2)/128 + (3*asec(x)^2)/(16*x^4) + (9*asec(x)^2)/(16*x^2) + (sqrt(1 - 1/x^2)*asec(x)^3)/(4*x^3) + (3*sqrt(1 - 1/x^2)*asec(x)^3)/(8*x) + (3*asec(x)^4)/32 - asec(x)^4/(4*x^4), x, 10),


# ::Subsection::Closed::
# Problems 7 - 18 (p. 397-398)


(asin(x)*sqrt(1 - x^2), -(x^2//4) + (1//2)*x*sqrt(1 - x^2)*asin(x) + asin(x)^2//4, x, 3),
(acos(x)*sqrt(1 - x^2), x^2//4 + (1//2)*x*sqrt(1 - x^2)*acos(x) - acos(x)^2//4, x, 3),
(acos(x)*x*sqrt(1 - x^2), -(x/3) + x^3//9 - (1//3)*(1 - x^2)^(3//2)*acos(x), x, 2),
(asin(x)*(1 - x^2)^(3//2), -((5*x^2)/16) + x^4//16 + (3//8)*x*sqrt(1 - x^2)*asin(x) + (1//4)*x*(1 - x^2)^(3//2)*asin(x) + (3*asin(x)^2)/16, x, 6),
(asin(x)*x*(1 - x^2)^(3//2), x/5 - (2*x^3)/15 + x^5//25 - (1//5)*(1 - x^2)^(5//2)*asin(x), x, 3),
(acos(x)*x^3*(1 - x^2)^(3//2), (-(1//35))*(2*x) - x^3//105 + (8*x^5)/175 - x^7//49 - (1//5)*(1 - x^2)^(5//2)*acos(x) + (1//7)*(1 - x^2)^(7//2)*acos(x), x, 4),
((acos(x)*(1 - x^2)^(3//2))/x, (4*x)/3 - x^3//9 + sqrt(1 - x^2)*acos(x) + (1//3)*(1 - x^2)^(3//2)*acos(x) + 2*I*acos(x)*atan(ℯ^(I*acos(x))) - I*PolyLog_reli(2, (-I)*ℯ^(I*acos(x))) + I*PolyLog_reli(2, I*ℯ^(I*acos(x))), x, 10),
((asin(x)*(1 - x^2)^(3//2))/x^6, -(1/(20*x^4)) + 1/(5*x^2) - ((1 - x^2)^(5//2)*asin(x))/(5*x^5) + log(x)/5, x, 4),
((asin(x)*x^2)/sqrt(1 - x^2), x^2//4 - (1//2)*x*sqrt(1 - x^2)*asin(x) + asin(x)^2//4, x, 3),
((asin(x)*x^4)/sqrt(1 - x^2), (3*x^2)/16 + x^4//16 - (3//8)*x*sqrt(1 - x^2)*asin(x) - (1//4)*x^3*sqrt(1 - x^2)*asin(x) + (3*asin(x)^2)/16, x, 5),
((asin(x)*x)/(1 - x^2)^(3//2), asin(x)/sqrt(1 - x^2) - atanh(x), x, 2),
((acos(x)*x)/(1 - x^2)^(3//2), acos(x)/sqrt(1 - x^2) + atanh(x), x, 2),
(asin(x)/(1 - x^2)^(5//2), -(1/(6*(1 - x^2))) + (x*asin(x))/(3*(1 - x^2)^(3//2)) + (2*x*asin(x))/(3*sqrt(1 - x^2)) + (1//3)*log(1 - x^2), x, 4),
((asin(x)*x^3)/(1 - x^2)^(3//2), -x + asin(x)/sqrt(1 - x^2) + sqrt(1 - x^2)*asin(x) - atanh(x), x, 3),


# ::Subsection::Closed::
# Problems 19 - 22 (p. 401)


(asin(x)/(x*(1 - x^2)^(3//2)), asin(x)/sqrt(1 - x^2) - 2*asin(x)*atanh(ℯ^(I*asin(x))) - atanh(x) + I*PolyLog_reli(2, -ℯ^(I*asin(x))) - I*PolyLog_reli(2, ℯ^(I*asin(x))), x, 8),
(acos(x)/(x^4*sqrt(1 - x^2)), 1/(6*x^2) - (sqrt(1 - x^2)*acos(x))/(3*x^3) - (2*sqrt(1 - x^2)*acos(x))/(3*x) - (2*log(x))/3, x, 4),
(acos(x)^2*x*sqrt(1 - x^2), (4*sqrt(1 - x^2))/9 + (2//27)*(1 - x^2)^(3//2) - (2//3)*x*acos(x) + (2//9)*x^3*acos(x) - (1//3)*(1 - x^2)^(3//2)*acos(x)^2, x, 5),
((asin(x)^3*x^2)/sqrt(1 - x^2), -((3*x^2)/8) + (3//4)*x*sqrt(1 - x^2)*asin(x) - (3*asin(x)^2)/8 + (3//4)*x^2*asin(x)^2 - (1//2)*x*sqrt(1 - x^2)*asin(x)^3 + asin(x)^4//8, x, 6),


# ::Subsection::Closed::
# Problems 23 - 26 (p. 404-405)


((atan(x)*x)/(1 + x^2)^2, x/(4*(1 + x^2)) + atan(x)/4 - atan(x)/(2*(1 + x^2)), x, 3),
((atan(x)*x)/(1 + x^2)^3, x/(16*(1 + x^2)^2) + (3*x)/(32*(1 + x^2)) + (3*atan(x))/32 - atan(x)/(4*(1 + x^2)^2), x, 4),
((atan(x)*x^2)/(1 + x^2), x*atan(x) - atan(x)^2//2 - (1//2)*log(1 + x^2), x, 4),
((atan(x)*x^3)/(1 + x^2), -(x/2) + atan(x)/2 + (1//2)*x^2*atan(x) + (1//2)*I*atan(x)^2 + atan(x)*log(2/(1 + I*x)) + (1//2)*I*PolyLog_reli(2, 1 - 2/(1 + I*x)), x, 8),


# ::Subsection::Closed::
# Problems 27 - 32 (p. 407-408)


((atan(x)*x^2)/(1 + x^2)^2, -(1/(4*(1 + x^2))) - (x*atan(x))/(2*(1 + x^2)) + atan(x)^2//4, x, 2),
((atan(x)*x^3)/(1 + x^2)^2, -(x/(4*(1 + x^2))) - atan(x)/4 + atan(x)/(2*(1 + x^2)) - (1//2)*I*atan(x)^2 - atan(x)*log(2/(1 + I*x)) - (1//2)*I*PolyLog_reli(2, 1 - 2/(1 + I*x)), x, 8),
((atan(x)*x^5)/(1 + x^2)^2, -(x/2) + x/(4*(1 + x^2)) + (3*atan(x))/4 + (1//2)*x^2*atan(x) - atan(x)/(2*(1 + x^2)) + I*atan(x)^2 + 2*atan(x)*log(2/(1 + I*x)) + I*PolyLog_reli(2, 1 - 2/(1 + I*x)), x, 17),
((atan(x)*(1 + x^2))/x^2, -(atan(x)/x) + x*atan(x) + log(x) - log(1 + x^2), x, 8),
((atan(x)*(1 + x^2))/x^5, -(1/(12*x^3)) - 1/(4*x) - ((1 + x^2)^2*atan(x))/(4*x^4), x, 3),
((atan(x)*(1 + x^2)^2)/x^5, -(1/(12*x^3)) - 3/(4*x) - (3*atan(x))/4 - atan(x)/(4*x^4) - atan(x)/x^2 + (1//2)*I*PolyLog_reli(2, (-I)*x) - (1//2)*I*PolyLog_reli(2, I*x), x, 12),


# ::Subsection::Closed::
# Problems 33 - 36 (p. 409)


(atan(x)/(x^2*(1 + x^2)), -(atan(x)/x) - atan(x)^2//2 + log(x) - (1//2)*log(1 + x^2), x, 7),
(atan(x)^2/x^3, -(atan(x)/x) - atan(x)^2//2 - atan(x)^2/(2*x^2) + log(x) - (1//2)*log(1 + x^2), x, 8),
((atan(x)^2*(1 + x^2))/x^5, -(1/(12*x^2)) - atan(x)/(6*x^3) - atan(x)/(2*x) - ((1 + x^2)^2*atan(x)^2)/(4*x^4) + log(x)/3 - (1//6)*log(1 + x^2), x, 11),
# {(ArcTan[x]^2*x^3)/(1 + x^2)^3, x, 4, -(1/(32*(1 + x^2)^2)) + 5/(32*(1 + x^2)) + (x^3*ArcTan[x])/(8*(1 + x^2)^2) + (3*x*ArcTan[x])/(16*(1 + x^2)) - (3*ArcTan[x]^2)/32 + (x^4*ArcTan[x]^2)/(4*(1 + x^2)^2), -(x^4/(32*(1 + x^2)^2)) + 3/(32*(1 + x^2)) + (x^3*ArcTan[x])/(8*(1 + x^2)^2) + (3*x*ArcTan[x])/(16*(1 + x^2)) - (3*ArcTan[x]^2)/32 + (x^4*ArcTan[x]^2)/(4*(1 + x^2)^2)}


# ::Subsection::Closed::
# Problems 37 - 43 (p. 412-414)


# {(ArcSec[x]*Sqrt[x^2 - 1])/x^2, x, 9, -(Sqrt[x^2]/x^2) - (Sqrt[-1 + x^2]*ArcSec[x])/x - (2*I*Sqrt[x^2]*ArcSec[x]*ArcTan[E^(I*ArcSec[x])])/x + (I*Sqrt[x^2]*PolyLog[2, (-I)*E^(I*ArcSec[x])])/x - (I*Sqrt[x^2]*PolyLog[2, I*E^(I*ArcSec[x])])/x, -(Sqrt[x^2]/x^2) - (Sqrt[1 - 1/x^2]*Sqrt[x^2]*ArcSec[x])/x - (2*I*Sqrt[x^2]*ArcSec[x]*ArcTan[E^(I*ArcSec[x])])/x + (I*Sqrt[x^2]*PolyLog[2, (-I)*E^(I*ArcSec[x])])/x - (I*Sqrt[x^2]*PolyLog[2, I*E^(I*ArcSec[x])])/x}
# {(ArcCsc[x]*(x^2 - 1)^(5/2))/x^3, x, 11, (3 + 2*x^4)/(12*x*Sqrt[x^2]) - (5*(x^2 - 1)^(3/2)*ArcCsc[x])/(3*x^2) - (5*Sqrt[x^2 - 1]*ArcCsc[x])/(2*x^2) + ((x^2 - 1)^(5/2)*ArcCsc[x])/(3*x^2) - (5*x*ArcCsc[x]^2)/(4*Sqrt[x^2]) - (7*x*Log[x])/(3*Sqrt[x^2]), Sqrt[x^2]/(4*x^3) + (x*Sqrt[x^2])/6 - (5/3)*(1 - 1/x^2)^(3/2)*Sqrt[x^2]*ArcCsc[x] - (5*Sqrt[1 - 1/x^2]*Sqrt[x^2]*ArcCsc[x])/(2*x^2) + (1/3)*(1 - 1/x^2)^(5/2)*(x^2)^(3/2)*ArcCsc[x] - (5*Sqrt[x^2]*ArcCsc[x]^2)/(4*x) - (7*Sqrt[x^2]*Log[x])/(3*x)}
((asec(x)*sqrt(x^2 - 1))/x^4, 1/(3*sqrt(x^2)) - 1/(9*x^2)/sqrt(x^2) + ((x^2 - 1)^(3//2)*asec(x))/(3*x^3), x, 4),
# {ArcSec[x]/(x^2 - 1)^(5/2), x, 4, Sqrt[x^2]/(6*(1 - x^2)) - (x*ArcSec[x])/(3*(x^2 - 1)^(3/2)) + (2*x*ArcSec[x])/(3*Sqrt[x^2 - 1]) + (5*ArcCoth[Sqrt[x^2]])/6, Sqrt[x^2]/(6*(1 - x^2)) - (x*ArcSec[x])/(3*(-1 + x^2)^(3/2)) + (2*x*ArcSec[x])/(3*Sqrt[-1 + x^2]) + (5*x*ArcTanh[x])/(6*Sqrt[x^2])}
# {(ArcSec[x]*x^2)/(x^2 - 1)^(5/2), x, 4, Sqrt[x^2]/(6*(1 - x^2)) - (x^3*ArcSec[x])/(3*(x^2 - 1)^(3/2)) - ArcCoth[Sqrt[x^2]]/6, Sqrt[x^2]/(6*(1 - x^2)) - (x^3*ArcSec[x])/(3*(-1 + x^2)^(3/2)) - (x*ArcTanh[x])/(6*Sqrt[x^2])}
# {(ArcSec[x]*x^3)/(x^2 - 1)^(5/2), x, 5, x/(6*Sqrt[x^2]*(1 - x^2)) - ArcSec[x]/(3*(x^2 - 1)^(3/2)) - ArcSec[x]/Sqrt[x^2 - 1] - (2*x*Log[x])/(3*Sqrt[x^2]) + (x*Log[x^2 - 1])/(3*Sqrt[x^2]), x/(6*Sqrt[x^2]*(1 - x^2)) - ArcSec[x]/(3*(-1 + x^2)^(3/2)) - ArcSec[x]/Sqrt[-1 + x^2] - (2*x*Log[x])/(3*Sqrt[x^2]) + (x*Log[1 - x^2])/(3*Sqrt[x^2])}
# {(ArcSec[x]*x^6)/(x^2 - 1)^(5/2), x, 16, (Sqrt[x^2]*(2 - 3*x^2))/(6*(-1 + x^2)) - (13/6)*ArcCoth[Sqrt[x^2]] - (5*x^3*ArcSec[x])/(6*(-1 + x^2)^(3/2)) + (x^5*ArcSec[x])/(2*(-1 + x^2)^(3/2)) - (5*x*ArcSec[x])/(2*Sqrt[-1 + x^2]) - (5*I*Sqrt[x^2]*ArcSec[x]*ArcTan[E^(I*ArcSec[x])])/x + (5*I*Sqrt[x^2]*PolyLog[2, (-I)*E^(I*ArcSec[x])])/(2*x) - (5*I*Sqrt[x^2]*PolyLog[2, I*E^(I*ArcSec[x])])/(2*x), -((3*Sqrt[x^2])/4) + Sqrt[x^2]/(4*(1 - 1/x^2)) - (5*Sqrt[x^2])/(12*(1 - 1/x^2)*x^2) - (13*Sqrt[x^2]*ArcCoth[x])/(6*x) - (5*Sqrt[x^2]*ArcSec[x])/(6*(1 - 1/x^2)^(3/2)*x) - (5*Sqrt[x^2]*ArcSec[x])/(2*Sqrt[1 - 1/x^2]*x) + (x*Sqrt[x^2]*ArcSec[x])/(2*(1 - 1/x^2)^(3/2)) - (5*I*Sqrt[x^2]*ArcSec[x]*ArcTan[E^(I*ArcSec[x])])/x + (5*I*Sqrt[x^2]*PolyLog[2, (-I)*E^(I*ArcSec[x])])/(2*x) - (5*I*Sqrt[x^2]*PolyLog[2, I*E^(I*ArcSec[x])])/(2*x)}


# ::Subsection::Closed::
# Problems 44 - 48 (p. 416-417)


(asec(x)/(x^2*sqrt(x^2 - 1)), 1/sqrt(x^2) + (sqrt(x^2 - 1)*asec(x))/x, x, 2),
# {ArcCsc[x]/(x^2*(x^2 - 1)^(5/2)), x, 5, -(1/Sqrt[x^2]) + Sqrt[x^2]/(6*(x^2 - 1)) + ((3 - 12*x^2 + 8*x^4)*ArcCsc[x])/(3*x*(x^2 - 1)^(3/2)) - (11*ArcCoth[Sqrt[x^2]])/6, -(1/Sqrt[x^2]) - Sqrt[x^2]/(6*(1 - x^2)) + ArcCsc[x]/(x*(-1 + x^2)^(3/2)) - (4*x*ArcCsc[x])/(3*(-1 + x^2)^(3/2)) + (8*x*ArcCsc[x])/(3*Sqrt[-1 + x^2]) - (11*x*ArcTanh[x])/(6*Sqrt[x^2])}
# {ArcCsc[x]^4/(x^2*Sqrt[x^2 - 1]), x, 6, (24*Sqrt[x^2 - 1])/x + (24*ArcCsc[x])/Sqrt[x^2] - (12*Sqrt[x^2 - 1]*ArcCsc[x]^2)/x - (4*ArcCsc[x]^3)/Sqrt[x^2] + (Sqrt[x^2 - 1]*ArcCsc[x]^4)/x, (24*Sqrt[1 - 1/x^2]*Sqrt[x^2])/x + (24*Sqrt[x^2]*ArcCsc[x])/x^2 - (12*Sqrt[1 - 1/x^2]*Sqrt[x^2]*ArcCsc[x]^2)/x - (4*Sqrt[x^2]*ArcCsc[x]^3)/x^2 + (Sqrt[1 - 1/x^2]*Sqrt[x^2]*ArcCsc[x]^4)/x}
# {(ArcSec[x]^2*(x^2 - 1)^(3/2))/x^5, x, 11, (Sqrt[x^2 - 1]*(17*x^2 - 2))/(64*x^4) - (3*ArcSec[x])/(8*x*Sqrt[x^2]) + (9*x*ArcSec[x])/(64*Sqrt[x^2]) + ((x^2 - 1)^2*ArcSec[x])/(8*x^3*Sqrt[x^2]) - (3*Sqrt[x^2 - 1]*ArcSec[x]^2)/(8*x^2) - ((x^2 - 1)^(3/2)*ArcSec[x]^2)/(4*x^4) + (x*ArcSec[x]^3)/(8*Sqrt[x^2]), (15*Sqrt[1 - 1/x^2]*Sqrt[x^2])/(64*x^2) + ((1 - 1/x^2)^(3/2)*Sqrt[x^2])/(32*x^2) - (9*Sqrt[x^2]*ArcCsc[x])/(64*x) - (3*Sqrt[x^2]*ArcSec[x])/(8*x^3) + ((1 - 1/x^2)^2*Sqrt[x^2]*ArcSec[x])/(8*x) - (3*Sqrt[1 - 1/x^2]*Sqrt[x^2]*ArcSec[x]^2)/(8*x^2) - ((1 - 1/x^2)^(3/2)*Sqrt[x^2]*ArcSec[x]^2)/(4*x^2) + (Sqrt[x^2]*ArcSec[x]^3)/(8*x)}
# {(ArcSec[x]^3*Sqrt[x^2 - 1])/x^4, x, 8, (2*(1 - 21*x^2))/(27*x^2*Sqrt[x^2]) - (4*Sqrt[x^2 - 1]*ArcSec[x])/(3*x) - (2*(x^2 - 1)^(3/2)*ArcSec[x])/(9*x^3) + (2*ArcSec[x]^2)/(3*Sqrt[x^2]) + ((x^2 - 1)*ArcSec[x]^2)/(3*x^2*Sqrt[x^2]) + ((x^2 - 1)^(3/2)*ArcSec[x]^3)/(3*x^3), (2*Sqrt[x^2])/(27*x^4) - (14*Sqrt[x^2])/(9*x^2) - (4*Sqrt[1 - 1/x^2]*Sqrt[x^2]*ArcSec[x])/(3*x) - (2*(1 - 1/x^2)^(3/2)*Sqrt[x^2]*ArcSec[x])/(9*x) + (2*Sqrt[x^2]*ArcSec[x]^2)/(3*x^2) + ((1 - 1/x^2)*Sqrt[x^2]*ArcSec[x]^2)/(3*x^2) + ((1 - 1/x^2)^(3/2)*Sqrt[x^2]*ArcSec[x]^3)/(3*x)}


# ::Subsection::Closed::
# Problems 49 - 56 (p. 422)


(asin(sqrt((x - a)/(x + a))), -sqrt(2)*a*sqrt((x - a)/(x + a))/sqrt(a/(x + a)) + (x + a)*asin(sqrt((x - a)/(x + a))), x, -8),
(atan(sqrt((x - a)/(x + a))), x*atan(sqrt(-((a - x)/(a + x)))) - a*atanh(sqrt(-((a - x)/(a + x)))), x, 4),
(atan(x)/(1 + x)^3, -(1/(4*(1 + x))) - atan(x)/(2*(1 + x)^2) + (1//4)*log(1 + x) - (1//8)*log(1 + x^2), x, 5),
(atan(x - a)/(x + a), atan(a - x)*log(2/(1 - I*(a - x))) - atan(a - x)*log(-((2*(a + x))/((I - 2*a)*(1 - I*(a - x))))) - (1//2)*I*PolyLog_reli(2, 1 - 2/(1 - I*(a - x))) + (1//2)*I*PolyLog_reli(2, 1 + (2*(a + x))/((I - 2*a)*(1 - I*(a - x)))), x, 5),
(asin(sqrt(1 - x^2))/sqrt(1 - x^2), -sqrt(x^2)*asin(sqrt(1 - x^2))^2/(2*x), x, 2),
(atan(sqrt(1 + x^2))*x/sqrt(1 + x^2), sqrt(1 + x^2)*atan(sqrt(1 + x^2)) - (1//2)*log(2 + x^2), x, 2),
(asin(x)/(1 - x)^(5//2), -(sqrt(1 + x)/(3*(1 - x))) + (2*asin(x))/(3*(1 - x)^(3//2)) - (1/(3*sqrt(2)))*atanh(sqrt(1 + x)/sqrt(2)), x, 5),
# {ArcCsc[x]*(x - 1)^(5/2), x, 7, (4*x*(83 - 19*x + 3*x^2)*Sqrt[x^2 - 1])/(105*Sqrt[x - 1]*Sqrt[x^2]) + (2/7)*(x - 1)^(7/2)*ArcCsc[x] + ((4*x)/(7*Sqrt[x^2]))*ArcTanh[Sqrt[x^2 - 1]/Sqrt[x - 1]], (4*Sqrt[-1 + x]*(1 + x))/(Sqrt[1 - 1/x^2]*x) - (20*Sqrt[-1 + x]*(1 + x)^2)/(21*Sqrt[1 - 1/x^2]*x) + (4*Sqrt[-1 + x]*(1 + x)^3)/(35*Sqrt[1 - 1/x^2]*x) + (2/7)*(-1 + x)^(7/2)*ArcCsc[x] + (4*Sqrt[-1 + x]*Sqrt[1 + x]*ArcTanh[Sqrt[1 + x]])/(7*Sqrt[1 - 1/x^2]*x)}


# ::Subsection::Closed::
# Problems 57 - 59 (p. 427)


# {ArcSin[Sinh[x]]*Sech[x]^4, x, 5, (-2/3)*ArcSin[Cosh[x]/Sqrt[2]] + (1/6)*Sqrt[1 - Sinh[x]^2]*Sech[x] + ArcSin[Sinh[x]]*Tanh[x] - (1/3)*ArcSin[Sinh[x]]*Tanh[x]^3, (-(2/3))*ArcSin[Cosh[x]/Sqrt[2]] + (1/6)*Sqrt[2 - Cosh[x]^2]*Sech[x] + ArcSin[Sinh[x]]*Tanh[x] - (1/3)*ArcSin[Sinh[x]]*Tanh[x]^3}
(acot(cosh(x))*cosh(x)/sinh(x)^4, atanh(tanh(x)/sqrt(2))/(6*sqrt(2)) + coth(x)/6 - (1//3)*acot(cosh(x))*csch(x)^3, x, 6),
(asin(tanh(x))*ℯ^x, ℯ^x*asin(tanh(x)) - cosh(x)*log(1 + ℯ^(2*x))*sqrt(sech(x)^2), x, 5),
]

#=
welz = [
# ::Package::

# ::Title::
# Martin Welz - posts on Sci.Math.Symbolic


# ::Section::Closed::
# 4 June 2010


# {x*(x^2 + 3)/(2*a^2 + b^2*(x^2 + 1))^(5/2)*Log[(Sqrt[2]*x*Sqrt[2*a^2 + b^2*(x^2 + 1)] - 2*x*a + b*(x^2 + 1))/x], x, 0, Sqrt[2]*(43*a^6 + 63*b^2*a^4 + 33*b^4*a^2 + 5*b^6)*(ArcTan[b*(x/Sqrt[2*a^2 + b^2])]/(6*b^4*Sqrt[2*a^2 + b^2]*(3*a^2 + b^2)^3)) + Sqrt[2]*(Sqrt[4*a^2 + b^2] + a)^3*(3*a*Sqrt[4*a^2 + b^2] - 7*a^2 - 2*b^2)*(Log[Sqrt[2]*(Sqrt[4*a^2 + b^2] - a)*Sqrt[2*a^2 + b^2*(x^2 + 1)] + b*x*Sqrt[4*a^2 + b^2] + 2*a^2 - 2*b*x*a + b^2]/(6*b^4*(3*a^2 + b^2)^3)) + Sqrt[2]*(Sqrt[4*a^2 + b^2] - a)^3*(3*a*Sqrt[4*a^2 + b^2] + 7*a^2 + 2*b^2)*(Log[Sqrt[2]*(Sqrt[4*a^2 + b^2] + a)*Sqrt[2*a^2 + b^2*(x^2 + 1)] + b*x*Sqrt[4*a^2 + b^2] - 2*a^2 + 2*b*x*a - b^2]/(6*b^4*(3*a^2 + b^2)^3)) - (4*a^2 + b^2*(3*x^2 + 5))*(Log[(Sqrt[2]*x*Sqrt[2*a^2 + b^2*(x^2 + 1)] - 2*x*a + b*(x^2 + 1))/x]/(3*b^4*(2*a^2 + b^2*(x^2 + 1))^(3/2))) - (4*a^2 + 5*b^2)*(Log[(Sqrt[2*a^2 + b^2*(x^2 + 1)] - Sqrt[2*a^2 + b^2])/x]/(3*b^4*(2*a^2 + b^2)^(3/2))) + Sqrt[2]*(2*a^2 + b^2)*(Log[Sqrt[2*a^2 + b^2*(x^2 + 1)] - Sqrt[2]*a]/(6*b^4*a^3)) - Sqrt[2]*(5*a^2 + b^2)*(8*a^6 + 9*b^2*a^4 + 6*b^4*a^2 + b^6)*(Log[2*a^2 + b^2*(x^2 + 1)]/(12*b^4*a^3*(3*a^2 + b^2)^3)) + Sqrt[2]*(b^2 - a^2)*((Sqrt[2]*Sqrt[2*a^2 + b^2*(x^2 + 1)]*(10*a^6 + 2*b*x*a^5 + 16*b^2*a^4 + 7*b^4*a^2 + b^6) + 12*a^7 + 6*b*x*a^6 + 16*b^2*a^5 + 5*b^3*x*a^4 + 7*b^4*a^3 + b^5*x*a^2 + b^6*a)/(6*b^4*a^2*(2*a^2 + b^2)*(2*a^2 + b^2*(x^2 + 1))*(3*a^2 + b^2)^2))}

# The following two integrands are equivalent!
(1/sqrt(1 - a*x), -((2*sqrt(1 - a*x))/a), x, 1),
# {(Log[a*x - 1] - 2*Log[-Sqrt[a*x - 1]])/(2*Pi*Sqrt[a*x - 1]), x, 5, -((2*Sqrt[1 - a*x])/a), -((2*Sqrt[-1 + a*x]*Log[-Sqrt[-1 + a*x]])/(a*Pi)) + (Sqrt[-1 + a*x]*Log[-1 + a*x])/(a*Pi)}


# ::Section::Closed::
# 6 June 2010


# {Sqrt[b^2*x^2 + 2*a^2 + b^2]/(b^3*x^4 + 4*a*b^2*x^3 + 2*a^2*b*x^2 + 4*a*x*(2*a^2 + b^2) - b*(2*a^2 + b^2)), x, 0, 0}
(sqrt(b^2*x^2 + 2*a^2 + b^2)/(b^3*x^6 + 4*a*b^2*x^5 + b*x^4*(2*a^2 + b^2) + 8*a*x^3*(a^2 + b^2) - b^3*x^2 + 4*a*x*(2*a^2 + b^2) - b*(2*a^2 + b^2)), 0, x, 0),
# {x/((b^2*x^2 + 2*a^2 + b^2)*((b*x^2 - 2*a*x + b)*Sqrt[b^2*x^2 + 2*a^2 + b^2] + Sqrt[2]*b^2*x^3 + Sqrt[2]*x*(2*a^2 + b^2))), x, 0, 0} *)


# ::Section::Closed::
# 20 June 2010


# ::Subsubsection::Closed::
# Problem #1


(1/(sqrt(x^2 + 1) + 2*x)^2, (4*x)/(3*(1 - 3*x^2)) - (2*sqrt(1 + x^2))/(3*(1 - 3*x^2)) - atanh(sqrt(3)*x)/(3*sqrt(3)) + atanh((1//2)*sqrt(3)*sqrt(1 + x^2))/(3*sqrt(3)), x, 9),


# ::Subsubsection::Closed::
# Problem #2


(1/(sqrt(x^2 - 1)*(3*x^2 - 4)^2), (3*x*sqrt(-1 + x^2))/(8*(4 - 3*x^2)) + (5//16)*atanh(x/(2*sqrt(-1 + x^2))), x, 3),


# ::Subsubsection::Closed::
# Problem #3


(1/(2*sqrt(x) + sqrt(x + 1))^2, 8/(9*(1 - 3*x)) - (4*sqrt(x)*sqrt(1 + x))/(3*(1 - 3*x)) - (8*asinh(sqrt(x)))/9 + (10//9)*atanh((2*sqrt(x))/sqrt(1 + x)) + (5//9)*log(1 - 3*x), x, 8),


# ::Subsubsection::Closed::
# Problem #4


(sqrt(x^2 - 1)/(x - I)^2, sqrt(-1 + x^2)/(I - x) - (I*atan((1 - I*x)/(sqrt(2)*sqrt(-1 + x^2))))/sqrt(2) + atanh(x/sqrt(-1 + x^2)), x, 6),


# ::Subsubsection::Closed::
# Problem #5


(1/(sqrt(x^2 - 1)*(x^2 + 1)^2), -((x*sqrt(-1 + x^2))/(4*(1 + x^2))) + (3*atanh((sqrt(2)*x)/sqrt(-1 + x^2)))/(4*sqrt(2)), x, 3),


# ::Subsubsection::Closed::
# Problem #6


(1/(sqrt(x - 1)*(sqrt(x - 1) + sqrt(x))^2), 2*sqrt(-1 + x) + (4//3)*(-1 + x)^(3//2) - (4*x^(3//2))/3, x, 4),


# ::Subsubsection::Closed::
# Problem #7


(1/(sqrt(x^2 - 1)*(sqrt(x^2 - 1) + sqrt(x))^2), (2 - 4*x)/(5*(sqrt(x) + sqrt(-1 + x^2))) + (1//25)*sqrt(-110 + 50*sqrt(5))*atan((1//2)*sqrt(2 + 2*sqrt(5))*sqrt(x)) - (1//50)*sqrt(-110 + 50*sqrt(5))*atan((sqrt(-2 + 2*sqrt(5))*sqrt(-1 + x^2))/(2 - (1 - sqrt(5))*x)) - (1//25)*sqrt(110 + 50*sqrt(5))*atanh((1//2)*sqrt(-2 + 2*sqrt(5))*sqrt(x)) - (1//50)*sqrt(110 + 50*sqrt(5))*atanh((sqrt(2 + 2*sqrt(5))*sqrt(-1 + x^2))/(2 - x - sqrt(5)*x)), x, -18),


((sqrt(x) - sqrt(-1 + x^2))^2/((1 + x - x^2)^2*sqrt(-1 + x^2)), (2 - 4*x)/(5*(sqrt(x) + sqrt(-1 + x^2))) + (1//25)*sqrt(-110 + 50*sqrt(5))*atan((1//2)*sqrt(2 + 2*sqrt(5))*sqrt(x)) - (1//50)*sqrt(-110 + 50*sqrt(5))*atan((sqrt(-2 + 2*sqrt(5))*sqrt(-1 + x^2))/(2 - (1 - sqrt(5))*x)) - (1//25)*sqrt(110 + 50*sqrt(5))*atanh((1//2)*sqrt(-2 + 2*sqrt(5))*sqrt(x)) - (1//50)*sqrt(110 + 50*sqrt(5))*atanh((sqrt(2 + 2*sqrt(5))*sqrt(-1 + x^2))/(2 - x - sqrt(5)*x)), x, -25),


(1/(sqrt(2)*(1 + x)^2*sqrt(-I + x^2)) + 1/(sqrt(2)*(1 + x)^2*sqrt(I + x^2)), -(((1//2 + I/2)*sqrt(-I + x^2))/(sqrt(2)*(1 + x))) - ((1//2 - I/2)*sqrt(I + x^2))/(sqrt(2)*(1 + x)) + atanh((I + x)/(sqrt(1 - I)*sqrt(-I + x^2)))/((1 - I)^(3//2)*sqrt(2)) - atanh((I - x)/(sqrt(1 + I)*sqrt(I + x^2)))/((1 + I)^(3//2)*sqrt(2)), x, 7),


# ::Subsubsection::Closed::
# Problem #8


(sqrt(sqrt(x^4 + 1) + x^2)/((x + 1)^2*sqrt(x^4 + 1)), -(sqrt(1 - I*x^2)/(2*(1 + x))) - sqrt(1 + I*x^2)/(2*(1 + x)) - (1//4)*(1 - I)^(3//2)*atanh((1 + I*x)/(sqrt(1 - I)*sqrt(1 - I*x^2))) - (1//4)*(1 + I)^(3//2)*atanh((1 - I*x)/(sqrt(1 + I)*sqrt(1 + I*x^2))), x, 7),
(sqrt(sqrt(x^4 + 1) + x^2)/((x + 1)*sqrt(x^4 + 1)), (-(1//2))*sqrt(1 - I)*atanh((1 + I*x)/(sqrt(1 - I)*sqrt(1 - I*x^2))) - (1//2)*sqrt(1 + I)*atanh((1 - I*x)/(sqrt(1 + I)*sqrt(1 + I*x^2))), x, 5),
(sqrt(sqrt(x^4 + 1) + x^2)/sqrt(x^4 + 1), atanh((sqrt(2)*x)/sqrt(x^2 + sqrt(1 + x^4)))/sqrt(2), x, 2),
(sqrt(sqrt(x^4 + 1) - x^2)/sqrt(x^4 + 1), atan((sqrt(2)*x)/sqrt(-x^2 + sqrt(1 + x^4)))/sqrt(2), x, 2),


# ::Subsubsection::Closed::
# Problem #9


(((x - 1)^(3//2) + (x + 1)^(3//2))/((x + 1)^(3//2)*(x - 1)^(3//2)), -(2/sqrt(-1 + x)) - 2/sqrt(1 + x), x, 2),


# ::Section::Closed::
# 15 August 2010


((x + sqrt(x^2 + a))^b, -((a*(x + sqrt(a + x^2))^(-1 + b))/(2*(1 - b))) + (x + sqrt(a + x^2))^(1 + b)/(2*(1 + b)), x, 3),
((x - sqrt(x^2 + a))^b, -((a*(x - sqrt(a + x^2))^(-1 + b))/(2*(1 - b))) + (x - sqrt(a + x^2))^(1 + b)/(2*(1 + b)), x, 3),
((x + sqrt(x^2 + a))^b/sqrt(x^2 + a), (x + sqrt(a + x^2))^b/b, x, 2),
((x - sqrt(x^2 + a))^b/sqrt(x^2 + a), -((x - sqrt(a + x^2))^b/b), x, 2),


(1/(a + b*ℯ^(p*x))^2, 1/(a*(a + b*ℯ^(p*x))*p) + x/a^2 - log(a + b*ℯ^(p*x))/(a^2*p), x, 3),
(1/(a*ℯ^(p*x) + b*ℯ^(-p*x))^2, -(1/(2*a*(b + a*ℯ^(2*p*x))*p)), x, 2),
(x/(a*ℯ^(p*x) + b*ℯ^(-p*x))^2, x/(2*a*b*p) - x/(2*a*(b + a*ℯ^(2*p*x))*p) - log(b + a*ℯ^(2*p*x))/(4*a*b*p^2), x, 6),


# ::Section::Closed::
# 2 September 2012


# ::Item::
# Example from Welz's paper "Two-term Recurrence Formulae for Indefinite Algebraic Integrals" available at https://arxiv.org/abs/1209.3758v2


((1 - x + 3*x^2)/((1 + x + x^2)^2*sqrt(1 - x + x^2)), ((1 + x)*sqrt(1 - x + x^2))/(1 + x + x^2) + sqrt(2)*atan((sqrt(2)*(1 + x))/sqrt(1 - x + x^2)) - atanh((sqrt(2//3)*(1 - x))/sqrt(1 - x + x^2))/sqrt(6), x, 6),


# ::Section::Closed::
# 21 January 2013


# From James Davenport's algint package documentation for Reduce
(sqrt(x + sqrt(a^2 + x^2))/sqrt(a^2 + x^2), 2*sqrt(x + sqrt(a^2 + x^2)), x, 2),
(sqrt(b*x + sqrt(a + b^2*x^2))/sqrt(a + b^2*x^2), (2*sqrt(b*x + sqrt(a + b^2*x^2)))/b, x, 2),


(1/(x*sqrt(a^2 + x^2)*sqrt(x + sqrt(a^2 + x^2))), -((2*atan(sqrt(x + sqrt(a^2 + x^2))/sqrt(a)))/a^(3//2)) - (2*atanh(sqrt(x + sqrt(a^2 + x^2))/sqrt(a)))/a^(3//2), x, 5),
(sqrt(sqrt(a^2 + x^2) + x)/x, 2*sqrt(x + sqrt(a^2 + x^2)) - 2*sqrt(a)*atan(sqrt(x + sqrt(a^2 + x^2))/sqrt(a)) - 2*sqrt(a)*atanh(sqrt(x + sqrt(a^2 + x^2))/sqrt(a)), x, 6),


# ::Section::Closed::
# 17 September 2014


(x^3*log(2 + x)^3*log(3 + x), -((302177*x)/1152) + (8029*x^2)/2304 - (763*x^3)/3456 + (3*x^4)/256 + (377//64)*(2 + x)^2 - (71//216)*(2 + x)^3 + (3//256)*(2 + x)^4 + (2069//144)*log(2 + x) - (187//64)*x^2*log(2 + x) + (83//288)*x^3*log(2 + x) - (3//128)*x^4*log(2 + x) + (6733//32)*(2 + x)*log(2 + x) - (377//32)*(2 + x)^2*log(2 + x) + (71//72)*(2 + x)^3*log(2 + x) - (3//64)*(2 + x)^4*log(2 + x) - (43//12)*log(2 + x)^2 - (17//48)*x^3*log(2 + x)^2 + (3//64)*x^4*log(2 + x)^2 - (1251//16)*(2 + x)*log(2 + x)^2 + (273//32)*(2 + x)^2*log(2 + x)^2 - (3//4)*(2 + x)^3*log(2 + x)^2 + (3//64)*(2 + x)^4*log(2 + x)^2 + (65//4)*(2 + x)*log(2 + x)^3 - (33//8)*(2 + x)^2*log(2 + x)^3 + (3//4)*(2 + x)^3*log(2 + x)^3 - (1//16)*(2 + x)^4*log(2 + x)^3 + (3891//128)*log(3 + x) - (115//48)*x^2*log(3 + x) + (37//144)*x^3*log(3 + x) - (3//128)*x^4*log(3 + x) + (415//12)*(3 + x)*log(3 + x) - (4083//32)*log(2 + x)*log(3 + x) - 25*x*log(2 + x)*log(3 + x) + (13//4)*x^2*log(2 + x)*log(3 + x) - (7//12)*x^3*log(2 + x)*log(3 + x) + (3//32)*x^4*log(2 + x)*log(3 + x) + (963//16)*log(2 + x)^2*log(3 + x) + 6*x*log(2 + x)^2*log(3 + x) - (3//2)*x^2*log(2 + x)^2*log(3 + x) + (1//2)*x^3*log(2 + x)^2*log(3 + x) - (3//16)*x^4*log(2 + x)^2*log(3 + x) - (81//4)*log(2 + x)^3*log(3 + x) + (1//4)*x^4*log(2 + x)^3*log(3 + x) - (5609//96)*PolyLog_reli(2, -2 - x) + (563//8)*log(2 + x)*PolyLog_reli(2, -2 - x) - (195//4)*log(2 + x)^2*PolyLog_reli(2, -2 - x) - (563//8)*PolyLog_reli(3, -2 - x) + (195//2)*log(2 + x)*PolyLog_reli(3, -2 - x) - (195//2)*PolyLog_reli(4, -2 - x), x, 359),


# ::Section::Closed::
# 12 January 2016


((sqrt(x^2 + b) + x)^a/sqrt(x^2 + b), (x + sqrt(b + x^2))^a/a, x, 2),


((sqrt(x^2 + b) + x)^a, -((b*(x + sqrt(b + x^2))^(-1 + a))/(2*(1 - a))) + (x + sqrt(b + x^2))^(1 + a)/(2*(1 + a)), x, 3),


((x^(3*a) + x^(2*a) + x^a)*(2*x^(2*a) + 3*x^a + 6)^(1/a), (x^(1 + a)*(6 + 3*x^a + 2*x^(2*a))^(1 + 1/a))/(6*(1 + a)), x, 2),


(1/(x*(1 - x^2)^(1//3)), (1//2)*sqrt(3)*atan((1 + 2*(1 - x^2)^(1//3))/sqrt(3)) - log(x)/2 + (3//4)*log(1 - (1 - x^2)^(1//3)), x, 5),


(1/(x*(1 - x^2)^(2//3)), (-(1//2))*sqrt(3)*atan((1 + 2*(1 - x^2)^(1//3))/sqrt(3)) - log(x)/2 + (3//4)*log(1 - (1 - x^2)^(1//3)), x, 5),


(1/(1 - x^3)^(1//3), -(atan((1 - (2*x)/(1 - x^3)^(1//3))/sqrt(3))/sqrt(3)) + (1//2)*log(x + (1 - x^3)^(1//3)), x, 1),


(1/(x*(1 - x^3)^(1//3)), atan((1 + 2*(1 - x^3)^(1//3))/sqrt(3))/sqrt(3) - log(x)/2 + (1//2)*log(1 - (1 - x^3)^(1//3)), x, 5),


(1/((1 + x)*(1 - x^3)^(1//3)), -((sqrt(3)*atan((1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3)))/(2*2^(1//3))) - log((1 - x)*(1 + x)^2)/(4*2^(1//3)) + (3*log(-1 + x + 2^(2//3)*(1 - x^3)^(1//3)))/(4*2^(1//3)), x, 1),


(x/((1 + x)*(1 - x^3)^(1//3)), (sqrt(3)*atan((1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3)))/(2*2^(1//3)) - atan((1 - (2*x)/(1 - x^3)^(1//3))/sqrt(3))/sqrt(3) + log((1 - x)*(1 + x)^2)/(4*2^(1//3)) + (1//2)*log(x + (1 - x^3)^(1//3)) - (3*log(-1 + x + 2^(2//3)*(1 - x^3)^(1//3)))/(4*2^(1//3)), x, 3),


(1/(x*(x^2 - 3*x + 2)^(1//3)), -((sqrt(3)*atan(1/sqrt(3) + (2^(1//3)*(2 - x))/(sqrt(3)*(2 - 3*x + x^2)^(1//3))))/(2*2^(1//3))) - log(2 - x)/(4*2^(1//3)) - log(x)/(2*2^(1//3)) + (3*log(2 - x - 2^(2//3)*(2 - 3*x + x^2)^(1//3)))/(4*2^(1//3)), x, -2),


(1/(x^3 - 3*x^2 + 7*x - 5)^(1//3), (1//2)*sqrt(3)*atan(1/sqrt(3) + (2*(-1 + x))/(sqrt(3)*(-5 + 7*x - 3*x^2 + x^3)^(1//3))) + (1//4)*log(1 - x) - (3//4)*log(1 - x + (-5 + 7*x - 3*x^2 + x^3)^(1//3)), x, -5),


(1/(x*(x^2 - q))^(1//3), (1//2)*sqrt(3)*atan(1/sqrt(3) + (2*x)/(sqrt(3)*(x*(-q + x^2))^(1//3))) + log(x)/4 - (3//4)*log(-x + (x*(-q + x^2))^(1//3)), x, -5),


(1/((x - 1)*(x^2 - 2*x + q))^(1//3), (1//2)*sqrt(3)*atan(1/sqrt(3) + (2*(-1 + x))/(sqrt(3)*((-1 + x)*(q - 2*x + x^2))^(1//3))) + (1//4)*log(1 - x) - (3//4)*log(1 - x + ((-1 + x)*(q - 2*x + x^2))^(1//3)), x, -5),


(1/(x*((x - 1)*(x^2 - 2*q*x + q))^(1//3)), (sqrt(3)*atan(1/sqrt(3) + (2*q^(1//3)*(-1 + x))/(sqrt(3)*((-1 + x)*(q - 2*q*x + x^2))^(1//3))))/(2*q^(1//3)) + log(1 - x)/(4*q^(1//3)) + log(x)/(2*q^(1//3)) - (3*log((-q^(1//3))*(-1 + x) + ((-1 + x)*(q - 2*q*x + x^2))^(1//3)))/(4*q^(1//3)), x, -2),


((2 - (k + 1)*x)/((1 - (k + 1)*x)*(x*(1 - x)*(1 - k*x))^(1//3)), (sqrt(3)*atan((1 + (2*k^(1//3)*x)/((1 - x)*x*(1 - k*x))^(1//3))/sqrt(3)))/k^(1//3) + log(x)/(2*k^(1//3)) + log(1 - (1 + k)*x)/(2*k^(1//3)) - (3*log((-k^(1//3))*x + ((1 - x)*x*(1 - k*x))^(1//3)))/(2*k^(1//3)), x, -3),


((1 - k*x)/((1 + (k - 2)*x)*(x*(1 - x)*(1 - k*x))^(2//3)), -((sqrt(3)*atan((1 + (2^(1//3)*(1 - k*x))/((1 - k)^(1//3)*((1 - x)*x*(1 - k*x))^(1//3)))/sqrt(3)))/(2^(2//3)*(1 - k)^(1//3))) + log(1 - (2 - k)*x)/(2^(2//3)*(1 - k)^(1//3)) + log(1 - k*x)/(2*2^(2//3)*(1 - k)^(1//3)) - (3*log(-1 + k*x + 2^(2//3)*(1 - k)^(1//3)*((1 - x)*x*(1 - k*x))^(1//3)))/(2*2^(2//3)*(1 - k)^(1//3)), x, -1),


# {(a + b*x + c*x^2)/((1 - x + x^2)*(1 - x^3)^(1/3)), x, 19, ((a + b)*ArcTan[(1 - (2*2^(1/3)*(1 - x))/(1 - x^3)^(1/3))/Sqrt[3]])/(2^(1/3)*Sqrt[3]) + ((a + b)*ArcTan[(1 + (2^(1/3)*(1 - x))/(1 - x^3)^(1/3))/Sqrt[3]])/(2*2^(1/3)*Sqrt[3]) - (c*ArcTan[(1 - (2*x)/(1 - x^3)^(1/3))/Sqrt[3]])/Sqrt[3] - ((a - c)*ArcTan[(1 - (2*2^(1/3)*x)/(1 - x^3)^(1/3))/Sqrt[3]])/(2^(1/3)*Sqrt[3]) + ((b + c)*ArcTan[(1 + 2^(2/3)*(1 - x^3)^(1/3))/Sqrt[3]])/(2^(1/3)*Sqrt[3]) + ((a + b)*Log[(1 - x)*(1 + x)^2])/(12*2^(1/3)) - ((a - c)*Log[1 + x^3])/(6*2^(1/3)) - ((b + c)*Log[1 + x^3])/(6*2^(1/3)) + ((a + b)*Log[1 + (2^(2/3)*(1 - x)^2)/(1 - x^3)^(2/3) - (2^(1/3)*(1 - x))/(1 - x^3)^(1/3)])/(6*2^(1/3)) - ((a + b)*Log[1 + (2^(1/3)*(1 - x))/(1 - x^3)^(1/3)])/(3*2^(1/3)) + ((b + c)*Log[2^(1/3) - (1 - x^3)^(1/3)])/(2*2^(1/3)) + ((a - c)*Log[((-2.0)^(1/3))*x - (1 - x^3)^(1/3)])/(2*2^(1/3)) + (1/2)*c*Log[x + (1 - x^3)^(1/3)] - ((a + b)*Log[-1 + x + 2^(2/3)*(1 - x^3)^(1/3)])/(4*2^(1/3)), ((a + b)*ArcTan[(1 - (2*2^(1/3)*(1 - x))/(1 - x^3)^(1/3))/Sqrt[3]])/(2^(1/3)*Sqrt[3]) + ((a + b)*ArcTan[(1 + (2^(1/3)*(1 - x))/(1 - x^3)^(1/3))/Sqrt[3]])/(2*2^(1/3)*Sqrt[3]) - (c*ArcTan[(1 - (2*x)/(1 - x^3)^(1/3))/Sqrt[3]])/Sqrt[3] - (a*ArcTan[(1 - (2*2^(1/3)*x)/(1 - x^3)^(1/3))/Sqrt[3]])/(2^(1/3)*Sqrt[3]) + (c*ArcTan[(1 - (2*2^(1/3)*x)/(1 - x^3)^(1/3))/Sqrt[3]])/(2^(1/3)*Sqrt[3]) + ((b + c)*ArcTan[(1 + 2^(2/3)*(1 - x^3)^(1/3))/Sqrt[3]])/(2^(1/3)*Sqrt[3]) + ((a + b)*Log[(1 - x)*(1 + x)^2])/(12*2^(1/3)) - (a*Log[1 + x^3])/(6*2^(1/3)) + (c*Log[1 + x^3])/(6*2^(1/3)) - ((b + c)*Log[1 + x^3])/(6*2^(1/3)) + ((a + b)*Log[1 + (2^(2/3)*(1 - x)^2)/(1 - x^3)^(2/3) - (2^(1/3)*(1 - x))/(1 - x^3)^(1/3)])/(6*2^(1/3)) - ((a + b)*Log[1 + (2^(1/3)*(1 - x))/(1 - x^3)^(1/3)])/(3*2^(1/3)) + ((b + c)*Log[2^(1/3) - (1 - x^3)^(1/3)])/(2*2^(1/3)) + (a*Log[((-2.0)^(1/3))*x - (1 - x^3)^(1/3)])/(2*2^(1/3)) - (c*Log[((-2.0)^(1/3))*x - (1 - x^3)^(1/3)])/(2*2^(1/3)) + (1/2)*c*Log[x + (1 - x^3)^(1/3)] - ((a + b)*Log[-1 + x + 2^(2/3)*(1 - x^3)^(1/3)])/(4*2^(1/3))}


# ::Section::Closed::
# 27 March 2016


(1/((1 + x + 2*x^2)^5*(3 - 2*x)^(11//2)), -(19255/(395136*(3 - 2*x)^(9//2))) - 462025/(30118144*(3 - 2*x)^(7//2)) - 38491/(8605184*(3 - 2*x)^(5//2)) - 141045/(120472576*(3 - 2*x)^(3//2)) - 38225/(240945152*sqrt(3 - 2*x)) + x/(28*(3 - 2*x)^(9//2)*(1 + x + 2*x^2)^4) + (23 + 73*x)/(1176*(3 - 2*x)^(9//2)*(1 + x + 2*x^2)^3) + (1387 + 3049*x)/(32928*(3 - 2*x)^(9//2)*(1 + x + 2*x^2)^2) + (5*(3049 + 4377*x))/(153664*(3 - 2*x)^(9//2)*(1 + x + 2*x^2)) + (5*sqrt((1//2)*(149046503977 + 40815066112*sqrt(14)))*atan((sqrt(7 + 2*sqrt(14)) - 2*sqrt(3 - 2*x))/sqrt(-7 + 2*sqrt(14))))/3373232128 - (5*sqrt((1//2)*(149046503977 + 40815066112*sqrt(14)))*atan((sqrt(7 + 2*sqrt(14)) + 2*sqrt(3 - 2*x))/sqrt(-7 + 2*sqrt(14))))/3373232128 + (5*sqrt((1//2)*(-149046503977 + 40815066112*sqrt(14)))*log(3 + sqrt(14) - sqrt(7 + 2*sqrt(14))*sqrt(3 - 2*x) - 2*x))/6746464256 - (5*sqrt((1//2)*(-149046503977 + 40815066112*sqrt(14)))*log(3 + sqrt(14) + sqrt(7 + 2*sqrt(14))*sqrt(3 - 2*x) - 2*x))/6746464256, x, 19),
(1/((1 + x + 2*x^2)^10*(3 - 2*x)^(21//2)), 4718120139975/(351733660450816*(3 - 2*x)^(19//2)) - 815900548375/(629418129227776*(3 - 2*x)^(17//2)) - 3029508823715/(1555033025150976*(3 - 2*x)^(15//2)) - 13515743021825/(13476952884641792*(3 - 2*x)^(13//2)) - 5846828446875/(14513641568075776*(3 - 2*x)^(11//2)) - 37283626871975/(261245548225363968*(3 - 2*x)^(9//2)) - 132355162272575/(2844673747342852096*(3 - 2*x)^(7//2)) - 11557581705725/(812763927812243456*(3 - 2*x)^(5//2)) - 46601678385075/(11378694989371408384*(3 - 2*x)^(3//2)) - 24229218097975/(22757389978742816768*sqrt(3 - 2*x)) + x/(63*(3 - 2*x)^(19//2)*(1 + x + 2*x^2)^9) + (53 + 173*x)/(7056*(3 - 2*x)^(19//2)*(1 + x + 2*x^2)^8) + (8477 + 21409*x)/(691488*(3 - 2*x)^(19//2)*(1 + x + 2*x^2)^7) + (5*(21409 + 47471*x))/(6453888*(3 - 2*x)^(19//2)*(1 + x + 2*x^2)^6) + (41*(47471 + 92875*x))/(90354432*(3 - 2*x)^(19//2)*(1 + x + 2*x^2)^5) + (41*(3436375 + 5677637*x))/(5059848192*(3 - 2*x)^(19//2)*(1 + x + 2*x^2)^4) + (451*(811091 + 998691*x))/(10119696384*(3 - 2*x)^(19//2)*(1 + x + 2*x^2)^3) + (451*(28962039 + 14627273*x))/(283351498752*(3 - 2*x)^(19//2)*(1 + x + 2*x^2)^2) + (11275*(14627273 - 35058731*x))/(3966920982528*(3 - 2*x)^(19//2)*(1 + x + 2*x^2)) + (11275*sqrt((1//2)*(7 + 2*sqrt(14)))*(9756589235 + 2148932869*sqrt(14))*atan((sqrt(7 + 2*sqrt(14)) - 2*sqrt(3 - 2*x))/sqrt(-7 + 2*sqrt(14))))/318603459702399434752 - (11275*sqrt((1//2)*(7 + 2*sqrt(14)))*(9756589235 + 2148932869*sqrt(14))*atan((sqrt(7 + 2*sqrt(14)) + 2*sqrt(3 - 2*x))/sqrt(-7 + 2*sqrt(14))))/318603459702399434752 + (11275*(9756589235 - 2148932869*sqrt(14))*sqrt((1//2)*(-7 + 2*sqrt(14)))*log(3 + sqrt(14) - sqrt(7 + 2*sqrt(14))*sqrt(3 - 2*x) - 2*x))/637206919404798869504 - (11275*(9756589235 - 2148932869*sqrt(14))*sqrt((1//2)*(-7 + 2*sqrt(14)))*log(3 + sqrt(14) + sqrt(7 + 2*sqrt(14))*sqrt(3 - 2*x) - 2*x))/637206919404798869504, x, 29),
(1/((1 + x + 2*x^2)^20*(3 - 2*x)^(41//2)), -(13056959628363355534285785425/(106924014357253562723941220352*(3 - 2*x)^(39//2))) - 3948194343291401740321996415/(202881463139404195937734623232*(3 - 2*x)^(37//2)) - 304688229262620222736480811/(537361713180043545997243056128*(3 - 2*x)^(35//2)) + 2124315846756567455653862925/(1688851098565851144562763890688*(3 - 2*x)^(33//2)) + 47657515074514118796095929535/(66632852434325399703658138959872*(3 - 2*x)^(31//2)) + 34911619993974714062172751985/(124667917457770102671360389021696*(3 - 2*x)^(29//2)) + 149066309808794760843017404825/(1624981820656451683095663001731072*(3 - 2*x)^(27//2)) + 15848613964169066543734380171/(601845118761648771516912222863360*(3 - 2*x)^(25//2)) + 11155168222970774232376891145/(1685166332532616560247354224017408*(3 - 2*x)^(23//2)) + 14011818498091020272474956375/(10110997995195699361484125344104448*(3 - 2*x)^(21//2)) + 173441368149804378661935869705/(896508488907352010051592447177261056*(3 - 2*x)^(19//2)) - 22724090823469905152713519545/(1604278348571050965355481221264572416*(3 - 2*x)^(17//2)) - 101190274412779618678573275245/(3963511214116714149701777134888943616*(3 - 2*x)^(15//2)) - 460503190416958283087439337135/(34350430522344855964082068502370844672*(3 - 2*x)^(13//2)) - 2211619588790911794826342607495/(406920484649315986036049119181931544576*(3 - 2*x)^(11//2)) - 143401467550777247627940437025/(73985542663511997461099839851260280832*(3 - 2*x)^(9//2)) - 4611053278117143010907562317585/(7250583181024175751187784305423507521536*(3 - 2*x)^(7//2)) - 405965372440630510720926890227/(2071595194578335928910795515835287863296*(3 - 2*x)^(5//2)) - 4986681479187781853417316522775/(87006998172290109014253411665082090258432*(3 - 2*x)^(3//2)) - 927027754781476746208047620505/(58004665448193406009502274443388060172288*sqrt(3 - 2*x)) + x/(133*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^19) + (113 + 373*x)/(33516*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^18) + (40657 + 107329*x)/(7976808*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^17) + (5*(751303 + 1831285*x))/(595601664*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^16) + (184959785 + 429411497*x)/(25015269888*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^15) + (41652915209 + 92630823167*x)/(4902992898048*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^14) + (2871555518177 + 6100156355517*x)/(297448235814912*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^13) + (77559130805859 + 156274047129113*x)/(7138757659557888*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^12) + (5*(2656658801194921 + 5020880176134289*x))/(1099368679571914752*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^11) + (45187921585208601 + 78752911037377255*x)/(3420258114223734784*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^10) + (6063974149878048635 + 9477172618423641847*x)/(430952522392190582784*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^9) + (691833601144925854831 + 919498192874055581221*x)/(48266682507925345271808*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^8) + (23*(919498192874055581221 + 908287136092467468517*x))/(1576711628592227945545728*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^7) + (115*(908287136092467468517 + 298281884944522225747*x))/(10187982830903626725064704*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^6) + (23*(2599313568802265110081 - 10426142448623187379187*x))/(20375965661807253450129408*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^5) - (23*(10426142448623187379187 + 27513723463194262383705*x))/(20018492580021161284337664*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^4) - (115*(26513224428169016478843 + 30673415406553789342019*x))/(76434244396444433994743808*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^3) - (115*(88411609113007981044643 - 5712269536245152162963*x))/(125891696652967303050166272*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)^2) + (115*(28561347681225760814815 + 965934812839019490346107*x))/(195831528126838026966925312*(3 - 2*x)^(39//2)*(1 + x + 2*x^2)) + (115*sqrt((1//2)*(7 + 2*sqrt(14)))*(30297118912219360725028693061 + 8061110911143276053983022787*sqrt(14))*atan((sqrt(7 + 2*sqrt(14)) - 2*sqrt(3 - 2*x))/sqrt(-7 + 2*sqrt(14))))/812065316274707684133031842207432842412032 - (115*sqrt((1//2)*(7 + 2*sqrt(14)))*(30297118912219360725028693061 + 8061110911143276053983022787*sqrt(14))*atan((sqrt(7 + 2*sqrt(14)) + 2*sqrt(3 - 2*x))/sqrt(-7 + 2*sqrt(14))))/812065316274707684133031842207432842412032 + (115*(30297118912219360725028693061 - 8061110911143276053983022787*sqrt(14))*sqrt((1//2)*(-7 + 2*sqrt(14)))*log(3 + sqrt(14) - sqrt(7 + 2*sqrt(14))*sqrt(3 - 2*x) - 2*x))/1624130632549415368266063684414865684824064 - (115*(30297118912219360725028693061 - 8061110911143276053983022787*sqrt(14))*sqrt((1//2)*(-7 + 2*sqrt(14)))*log(3 + sqrt(14) + sqrt(7 + 2*sqrt(14))*sqrt(3 - 2*x) - 2*x))/1624130632549415368266063684414865684824064, x, 49),


(1/((1 + x + 2*x^2)^5*(3 - 2*x + x^2)^(11//2)), -((3450497 - 2004270*x)/(123480000*(3 - 2*x + x^2)^(9//2))) - (4878869 - 2578034*x)/(411600000*(3 - 2*x + x^2)^(7//2)) - (30316369 - 15043110*x)/(6860000000*(3 - 2*x + x^2)^(5//2)) - (63043297 - 29625922*x)/(41160000000*(3 - 2*x + x^2)^(3//2)) - (31*(7434109 - 3088870*x))/(411600000000*sqrt(3 - 2*x + x^2)) - (1 - 10*x)/(280*(3 - 2*x + x^2)^(9//2)*(1 + x + 2*x^2)^4) + (28 + 67*x)/(1050*(3 - 2*x + x^2)^(9//2)*(1 + x + 2*x^2)^3) + (5485 + 8878*x)/(117600*(3 - 2*x + x^2)^(9//2)*(1 + x + 2*x^2)^2) + (3*(8822 + 8233*x))/(343000*(3 - 2*x + x^2)^(9//2)*(1 + x + 2*x^2)) + (sqrt((1//70)*(151363871237318045 + 110320475741093888*sqrt(2)))*atan((sqrt(5/(7*(151363871237318045 + 110320475741093888*sqrt(2))))*(308108167 + 312239803*sqrt(2) + (932587773 + 620347970*sqrt(2))*x))/sqrt(3 - 2*x + x^2)))/137200000000 - (sqrt((1//70)*(-151363871237318045 + 110320475741093888*sqrt(2)))*atanh((sqrt(5/(7*(-151363871237318045 + 110320475741093888*sqrt(2))))*(308108167 - 312239803*sqrt(2) + (932587773 - 620347970*sqrt(2))*x))/sqrt(3 - 2*x + x^2)))/137200000000, x, 14),
(1/((1 + x + 2*x^2)^10*(3 - 2*x + x^2)^(21//2)), (37358055634422583 - 14024622879097678*x)/(1840124479200000000*(3 - 2*x + x^2)^(19//2)) + (476849951294984711 - 125181871472148210*x)/(104273720488000000000*(3 - 2*x + x^2)^(17//2)) + (7851758375483333511 + 1942164996204584234*x)/(15641058073200000000000*(3 - 2*x + x^2)^(15//2)) - (11*(7502325106308201089 - 7813986379726516886*x))/(406667509903200000000000*(3 - 2*x + x^2)^(13//2)) - (3*(69053268515296359011 - 44840736195018286006*x))/(1147010925368000000000000*(3 - 2*x + x^2)^(11//2)) - (838519439380295335657 - 466189390555853643870*x)/(9384634843920000000000000*(3 - 2*x + x^2)^(9//2)) - (1117646664729238460189 - 568839749685437871554*x)/(31282116146400000000000000*(3 - 2*x + x^2)^(7//2)) - (6551405511565449301689 - 3127298559983309301910*x)/(521368602440000000000000000*(3 - 2*x + x^2)^(5//2)) - (4179039782398459850819 - 1886993445589652402694*x)/(1042737204880000000000000000*(3 - 2*x + x^2)^(3//2)) - (12105495874518671061833 - 5117656435043679338190*x)/(10427372048800000000000000000*sqrt(3 - 2*x + x^2)) - (1 - 10*x)/(630*(3 - 2*x + x^2)^(19//2)*(1 + x + 2*x^2)^9) + (887 + 2218*x)/(88200*(3 - 2*x + x^2)^(19//2)*(1 + x + 2*x^2)^8) + (14453 + 29371*x)/(1080450*(3 - 2*x + x^2)^(19//2)*(1 + x + 2*x^2)^7) + (8837931 + 17459234*x)/(605052000*(3 - 2*x + x^2)^(19//2)*(1 + x + 2*x^2)^6) + (447940041 + 813432205*x)/(26471025000*(3 - 2*x + x^2)^(19//2)*(1 + x + 2*x^2)^5) + (592729157441 + 911061463974*x)/(29647548000000*(3 - 2*x + x^2)^(19//2)*(1 + x + 2*x^2)^4) + (277010166219 + 310705340015*x)/(12353145000000*(3 - 2*x + x^2)^(19//2)*(1 + x + 2*x^2)^3) + (5488221294349 + 1384103301166*x)/(276710448000000*(3 - 2*x + x^2)^(19//2)*(1 + x + 2*x^2)^2) - (37857197792117 + 146548895467025*x)/(2421216420000000*(3 - 2*x + x^2)^(19//2)*(1 + x + 2*x^2)) + (1//32282885600000000000000000)*(sqrt((1//70)*(81042225921274689605478944797800854846405 + 57305922523001707126026363878666500308992*sqrt(2)))*atan((1/sqrt(3 - 2*x + x^2))*(sqrt(5/(7*(81042225921274689605478944797800854846405 + 57305922523001707126026363878666500308992*sqrt(2))))*(272944589523248381749 + 191941026386645109841*sqrt(2) + (656826642296538601431 + 464885615909893491590*sqrt(2))*x)))) - (1//32282885600000000000000000)*(sqrt((1//70)*(-81042225921274689605478944797800854846405 + 57305922523001707126026363878666500308992*sqrt(2)))*atanh((1/sqrt(3 - 2*x + x^2))*(sqrt(5/(7*(-81042225921274689605478944797800854846405 + 57305922523001707126026363878666500308992*sqrt(2))))*(272944589523248381749 - 191941026386645109841*sqrt(2) + (656826642296538601431 - 464885615909893491590*sqrt(2))*x)))), x, 24),
# {1/((1 + x + 2*x^2)^20*(3 - 2*x + x^2)^(41/2)), x, 44, -((3383098994350701191445410431293305057 - 4267253240538659853185782736614548266*x)/(525136027977674906956800000000000000000*(3 - 2*x + x^2)^(39/2))) - (78177705015622070276322636989526467357 - 46302218258158218301107776830095849518*x)/(10226333176407353451264000000000000000000*(3 - 2*x + x^2)^(37/2)) - (590941515369388885204630563227557418493 - 284553012686483535620642865600923199674*x)/(170438886273455890854400000000000000000000*(3 - 2*x + x^2)^(35/2)) - (762583115349707009263396051658444299451 - 316786081987045018642707627274029983850*x)/(661703911414593458611200000000000000000000*(3 - 2*x + x^2)^(33/2)) - (20504482297963009703756354886476682604921 - 7087722971997170533955928118157817528778*x)/(68376070846174657389824000000000000000000000*(3 - 2*x + x^2)^(31/2)) - (1094782756101056712471590885456644828438471 - 231319367589693551565762758087902994595834*x)/(19829060545390650643048960000000000000000000000*(3 - 2*x + x^2)^(29/2)) - (11012693190699376908809163895637681160105723 + 17696165071101966113331245255080607119456186*x)/(5353846347255475673623219200000000000000000000000*(3 - 2*x + x^2)^(27/2)) + (23*(18006082293219149330614702781906676996906581 - 12878862225352936849259678853843700644232934*x))/(102958583601066839877369600000000000000000000000000*(3 - 2*x + x^2)^(25/2)) + (3754355493750207391617343068085143489914966741 - 1976623777595197423359895741289079398167213586*x)/(1578698281883024878119667200000000000000000000000000*(3 - 2*x + x^2)^(23/2)) + (34322768124014799813009030113095008046843253 - 15319362686882129647628001638529620053980446*x)/(37439484945842487228134400000000000000000000000000*(3 - 2*x + x^2)^(21/2)) + (1953413335087203199033100669694117118003927337 - 733793240328640817816796967921215709697806706*x)/(7113502139710072573345536000000000000000000000000000*(3 - 2*x + x^2)^(19/2)) + (8322318541720916240549421691461341741448155507 - 2188425336528033679699131827282128928574446618*x)/(134366151527856926385415680000000000000000000000000000*(3 - 2*x + x^2)^(17/2)) + (137736099847510239083414355324468252291068692723 + 33478342054315312692979309199522921351750372786*x)/(20154922729178538957812352000000000000000000000000000000*(3 - 2*x + x^2)^(15/2)) - (1430395239362680496541085612662519163791606856135 - 1495983440171367688360072315937267940781419612058*x)/(524027990958642012903121152000000000000000000000000000000*(3 - 2*x + x^2)^(13/2)) - (46873324150704277658299560286668706773614009227097 - 30488099877102642762965997747126514882873436125826*x)/(19214359668483540473114442240000000000000000000000000000000*(3 - 2*x + x^2)^(11/2)) - (2090128362125698805507947714009988943496892649558547 - 1163930059835896170450961511486397522547379198063338*x)/(1729292370163518642580299801600000000000000000000000000000000*(3 - 2*x + x^2)^(9/2)) - (8369636990081146161067558056610779041437928173813933 - 4269376136031342769573244116290179332114846542231394*x)/(17292923701635186425802998016000000000000000000000000000000000*(3 - 2*x + x^2)^(7/2)) - (49166828083706788194824969884579797183621714007506697 - 23559210708081011868758976108072328010974084474928758*x)/(288215395027253107096716633600000000000000000000000000000000000*(3 - 2*x + x^2)^(5/2)) - (94521492350271713145340025542493858321141702707908121 - 43021608081072494822903916879274373698601078834559154*x)/(1729292370163518642580299801600000000000000000000000000000000000*(3 - 2*x + x^2)^(3/2)) - (279132222218499281305380296125539838445333294423861707 - 121216775195529638294422516813426829250767045105497738*x)/(17292923701635186425802998016000000000000000000000000000000000000*Sqrt[3 - 2*x + x^2]) - (1 - 10*x)/(1330*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^19) + (1877 + 4778*x)/(418950*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^18) + (39403 + 85822*x)/(7122150*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^17) + (13*(233559 + 522986*x))/(531787200*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^16) + (87552089 + 193315879*x)/(13959414000*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^15) + (383091931241 + 813307430102*x)/(54720902880000*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^14) + (15997439501471 + 32531972209601*x)/(2074834234200000*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^13) + (11661968128341449 + 22618400149542870*x)/(1394288605382400000*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^12) + (3*(44358079769457553 + 81352009087314543*x))/(14911142029784000000*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^11) + (55501961232421996697 + 95060342178362451574*x)/(5964456811913600000000*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^10) + (4402445415670842624937 + 6915121726888913987767*x)/(469700973938196000000000*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^9) + (9405293191839054568597199 + 13154801664162951037742138*x)/(1052130181621559040000000000*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^8) + (33329414380999440825700335 + 39194075260407572910301649*x)/(4296198241621366080000000000*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^7) + (3079446144576372279132551987 + 2588106060473365045793782354*x)/(555201003532607308800000000000*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^6) + (51676596892030833963565793623 - 3738166859166819756452589047*x)/(24290043904551569760000000000000*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^5) - (18477591983841452420673740004241 + 27597746968514352562858392071302*x)/(9068283057699252710400000000000000*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^4) - (133360959223342832431783756808269 - 49432151929857088186548766720461*x)/(34006061466372197664000000000000000*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^3) + (1057289143422928552044099202272635 + 2439572907056622740540415493441154*x)/(115414511643445034496000000000000000*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)^2) + (27710574638863668700887240018723697 - 1800525975551829959478731340624273*x)/(336625658960048017280000000000000000*(3 - 2*x + x^2)^(39/2)*(1 + x + 2*x^2)) + (53*Sqrt[(1/70)*(879210910919588630492825297744872020413651017635360866499074296032260778656372643901 + 621696002391807670114685903911372073177064710967794175872353924738917423916160909312*Sqrt[2])]*ArcTan[(1/Sqrt[3 - 2*x + x^2])*(Sqrt[5/(7*(879210910919588630492825297744872020413651017635360866499074296032260778656372643901 + 621696002391807670114685903911372073177064710967794175872353924738917423916160909312*Sqrt[2]))]*(896457640030471180988134177305100813179145 + 634009778425632881804463219060525222303381*Sqrt[2] + (2164477196881736944597060615426151257785907 + 1530467418456104062792597396365626035482526*Sqrt[2])*x))])/416873881065074944000000000000000000000000000000000000 - (53*Sqrt[(1/70)*(-879210910919588630492825297744872020413651017635360866499074296032260778656372643901 + 621696002391807670114685903911372073177064710967794175872353924738917423916160909312*Sqrt[2])]*ArcTanh[(1/Sqrt[3 - 2*x + x^2])*(Sqrt[5/(7*(-879210910919588630492825297744872020413651017635360866499074296032260778656372643901 + 621696002391807670114685903911372073177064710967794175872353924738917423916160909312*Sqrt[2]))]*(896457640030471180988134177305100813179145 - 634009778425632881804463219060525222303381*Sqrt[2] + (2164477196881736944597060615426151257785907 - 1530467418456104062792597396365626035482526*Sqrt[2])*x))])/416873881065074944000000000000000000000000000000000000}


# ::Section::Closed::
# 19 June 2016


((x - a - sqrt(a^2 + 1))/((x - a + sqrt(a^2 + 1))*sqrt((x - a)*(x^2 + 1))), (-sqrt(2))*sqrt(a + sqrt(1 + a^2))*atan((sqrt(2)*sqrt(-a + sqrt(1 + a^2))*(-a + x))/sqrt((-a + x)*(1 + x^2))), x, -9),


# ::Section::Closed::
# 17 August 2016


((a + b*x)/((3 + x^2)*(1 - x^2)^(1//3)), (a*atan(sqrt(3)/x))/(2*2^(2//3)*sqrt(3)) + (sqrt(3)*b*atan((1 + (2 - 2*x^2)^(1//3))/sqrt(3)))/(2*2^(2//3)) + (a*atan((sqrt(3)*(1 - 2^(1//3)*(1 - x^2)^(1//3)))/x))/(2*2^(2//3)*sqrt(3)) - (a*atanh(x))/(6*2^(2//3)) + (a*atanh(x/(1 + 2^(1//3)*(1 - x^2)^(1//3))))/(2*2^(2//3)) - (b*log(3 + x^2))/(4*2^(2//3)) + (3*b*log(2^(2//3) - (1 - x^2)^(1//3)))/(4*2^(2//3)), x, 7),
((a + b*x)/((3 - x^2)*(1 + x^2)^(1//3)), -((a*atan(x))/(6*2^(2//3))) + (a*atan(x/(1 + 2^(1//3)*(1 + x^2)^(1//3))))/(2*2^(2//3)) - (sqrt(3)*b*atan((1 + 2^(1//3)*(1 + x^2)^(1//3))/sqrt(3)))/(2*2^(2//3)) - (a*atanh(sqrt(3)/x))/(2*2^(2//3)*sqrt(3)) - (a*atanh((sqrt(3)*(1 - 2^(1//3)*(1 + x^2)^(1//3)))/x))/(2*2^(2//3)*sqrt(3)) + (b*log(3 - x^2))/(4*2^(2//3)) - (3*b*log(2^(2//3) - (1 + x^2)^(1//3)))/(4*2^(2//3)), x, 7),
(1/(x*(3*x^2 - 6*x + 4)^(1//3)), -(atan(1/sqrt(3) + (2^(2//3)*(2 - x))/(sqrt(3)*(4 - 6*x + 3*x^2)^(1//3)))/(2^(2//3)*sqrt(3))) - log(x)/(2*2^(2//3)) + log(6 - 3*x - 3*2^(1//3)*(4 - 6*x + 3*x^2)^(1//3))/(2*2^(2//3)), x, 1),
(x*(1 - x^3)^(1//3), (1//3)*x^2*(1 - x^3)^(1//3) - atan((1 - (2*x)/(1 - x^3)^(1//3))/sqrt(3))/(3*sqrt(3)) - (1//6)*log(-x - (1 - x^3)^(1//3)), x, 2),
((1 - x^3)^(1//3)/x, (1 - x^3)^(1//3) - atan((1 + 2*(1 - x^3)^(1//3))/sqrt(3))/sqrt(3) - log(x)/2 + (1//2)*log(1 - (1 - x^3)^(1//3)), x, 6),
((1 - x^3)^(1//3)/(1 + x), (1 - x^3)^(1//3) + (2^(1//3)*atan((1 - (2*2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3)))/sqrt(3) + atan((1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3))/(2^(2//3)*sqrt(3)) - atan((1 - (2*x)/(1 - x^3)^(1//3))/sqrt(3))/sqrt(3) + (2^(1//3)*atan((1 - (2*2^(1//3)*x)/(1 - x^3)^(1//3))/sqrt(3)))/sqrt(3) - (2^(1//3)*atan((1 + 2^(2//3)*(1 - x^3)^(1//3))/sqrt(3)))/sqrt(3) - (1//3)*2^(1//3)*log(1 + x^3) + log(2^(2//3) - (1 - x)/(1 - x^3)^(1//3))/(3*2^(2//3)) - log(1 + (2^(2//3)*(1 - x)^2)/(1 - x^3)^(2//3) - (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/(3*2^(2//3)) + (1//3)*2^(1//3)*log(1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3)) - log(2*2^(1//3) + (1 - x)^2/(1 - x^3)^(2//3) + (2^(2//3)*(1 - x))/(1 - x^3)^(1//3))/(6*2^(2//3)) + log(2^(1//3) - (1 - x^3)^(1//3))/2^(2//3) - (1//2)*log(-x - (1 - x^3)^(1//3)) + log(((-2.0)^(1//3))*x - (1 - x^3)^(1//3))/2^(2//3), x, 25),
# {(1 - x^3)^(1/3)/(1 - x + x^2), x, 19, (Sqrt[3]*ArcTan[(1 + (2*2^(1/3)*(-1 + x))/(1 - x^3)^(1/3))/Sqrt[3]])/2^(2/3) + ArcTan[(1 - (2*x)/(1 - x^3)^(1/3))/Sqrt[3]]/Sqrt[3] - ArcTan[(1 - (2*2^(1/3)*x)/(1 - x^3)^(1/3))/Sqrt[3]]/(2^(2/3)*Sqrt[3]) - ArcTan[(1 + 2^(2/3)*(1 - x^3)^(1/3))/Sqrt[3]]/(2^(2/3)*Sqrt[3]) - Log[-3*(-1 + x)*(1 - x + x^2)]/(2*2^(2/3)) + Log[2^(1/3) - (1 - x^3)^(1/3)]/(2*2^(2/3)) + (3*Log[((-2.0)^(1/3))*(-1 + x) + (1 - x^3)^(1/3)])/(2*2^(2/3)) + (1/2)*Log[x + (1 - x^3)^(1/3)] - Log[2^(1/3)*x + (1 - x^3)^(1/3)]/(2*2^(2/3)), (2^(1/3)*ArcTan[(1 - (2*2^(1/3)*(1 - x))/(1 - x^3)^(1/3))/Sqrt[3]])/Sqrt[3] + ArcTan[(1 + (2^(1/3)*(1 - x))/(1 - x^3)^(1/3))/Sqrt[3]]/(2^(2/3)*Sqrt[3]) + ArcTan[(1 - (2*x)/(1 - x^3)^(1/3))/Sqrt[3]]/Sqrt[3] - (2^(1/3)*ArcTan[(1 - (2*2^(1/3)*x)/(1 - x^3)^(1/3))/Sqrt[3]])/Sqrt[3] + Log[1 + x^3]/(3*2^(2/3)) + Log[2^(2/3) - (1 - x)/(1 - x^3)^(1/3)]/(3*2^(2/3)) - Log[1 + (2^(2/3)*(1 - x)^2)/(1 - x^3)^(2/3) - (2^(1/3)*(1 - x))/(1 - x^3)^(1/3)]/(3*2^(2/3)) + (1/3)*2^(1/3)*Log[1 + (2^(1/3)*(1 - x))/(1 - x^3)^(1/3)] - Log[2*2^(1/3) + (1 - x)^2/(1 - x^3)^(2/3) + (2^(2/3)*(1 - x))/(1 - x^3)^(1/3)]/(6*2^(2/3)) + (1/2)*Log[-x - (1 - x^3)^(1/3)] - Log[((-2.0)^(1/3))*x - (1 - x^3)^(1/3)]/2^(2/3)}


# ::Section::Closed::
# 22 September 2016


# {1/(x^3 - 3*x^2 + 7*x - 4)^(1/3), x, 0, 0}
# {1/(x*(3*x^2 - 6*x + 5)^(1/3)), x, 0, 0} *)


((1 - x^3)^(1//3)/(2 + x), (1 - x^3)^(1//3) + (1//2)*x*SymbolicIntegration.appell_f1(1//3, -(1//3), 1, 4//3, x^3, -(x^3//8)) - (2*atan((1 - (2*x)/(1 - x^3)^(1//3))/sqrt(3)))/sqrt(3) + 3^(1//6)*atan((1 - (3^(2//3)*x)/(1 - x^3)^(1//3))/sqrt(3)) - 3^(1//6)*atan(1/sqrt(3) + (2*(1 - x^3)^(1//3))/(3*3^(1//6))) - log(8 + x^3)/3^(1//3) + (1//2)*3^(2//3)*log(3^(2//3) - (1 - x^3)^(1//3)) - log(-x - (1 - x^3)^(1//3)) + (1//2)*3^(2//3)*log((-(1//2))*3^(2//3)*x - (1 - x^3)^(1//3)), x, 12),
((2 + x)/((1 + x + x^2)*(2 + x^3)^(1//3)), -((x^2*SymbolicIntegration.appell_f1(2//3, 1, 1//3, 5//3, x^3, -(x^3//2)))/(2*2^(1//3))) + (2*atan((1 + (2*3^(1//3)*x)/(2 + x^3)^(1//3))/sqrt(3)))/3^(5//6) + atan((3^(1//3) + 2*(2 + x^3)^(1//3))/3^(5//6))/3^(5//6) + log(1 - x^3)/(6*3^(1//3)) + log(3^(1//3) - (2 + x^3)^(1//3))/(2*3^(1//3)) - log(3^(1//3)*x - (2 + x^3)^(1//3))/3^(1//3), x, 9),


# ::Section::Closed::
# 14 January 2017


((3 - 3*x + 30*x^2 + 160*x^3)/(9 + 24*x - 12*x^2 + 80*x^3 + 320*x^4), (1//8)*log(9 + 24*x - 12*x^2 + 80*x^3 + 320*x^4), x, 1),
((3 + 12*x + 20*x^2)/(9 + 24*x - 12*x^2 + 80*x^3 + 320*x^4), -(atan((7 - 40*x)/(5*sqrt(11)))/(2*sqrt(11))) + atan((57 + 30*x - 40*x^2 + 800*x^3)/(6*sqrt(11)))/(2*sqrt(11)), x, 1),
(-(84 + 576*x + 400*x^2 - 2560*x^3)/(9 + 24*x - 12*x^2 + 80*x^3 + 320*x^4), 2*sqrt(11)*atan((7 - 40*x)/(5*sqrt(11))) - 2*sqrt(11)*atan((57 + 30*x - 40*x^2 + 800*x^3)/(6*sqrt(11))) + 2*log(9 + 24*x - 12*x^2 + 80*x^3 + 320*x^4), x, 2),


# ::Section::Closed::
# 31 January 2017


(sqrt(1 - x^4)/(1 + x^4), (1//2)*atan((x*(1 + x^2))/sqrt(1 - x^4)) + (1//2)*atanh((x*(1 - x^2))/sqrt(1 - x^4)), x, 1),
(sqrt(1 + x^4)/(1 - x^4), atan((sqrt(2)*x)/sqrt(1 + x^4))/(2*sqrt(2)) + atanh((sqrt(2)*x)/sqrt(1 + x^4))/(2*sqrt(2)), x, 4),


# ::Section::Closed::
# 7 February 2017


(sqrt(1 + p*x^2 + x^4)/(1 - x^4), (1//4)*sqrt(2 - p)*atan((sqrt(2 - p)*x)/sqrt(1 + p*x^2 + x^4)) + (1//4)*sqrt(2 + p)*atanh((sqrt(2 + p)*x)/sqrt(1 + p*x^2 + x^4)), x, 4),
(sqrt(1 + p*x^2 - x^4)/(1 + x^4), -((sqrt(p + sqrt(4 + p^2))*atan((sqrt(p + sqrt(4 + p^2))*x*(p - sqrt(4 + p^2) - 2*x^2))/(2*sqrt(2)*sqrt(1 + p*x^2 - x^4))))/(2*sqrt(2))) + (sqrt(-p + sqrt(4 + p^2))*atanh((sqrt(-p + sqrt(4 + p^2))*x*(p + sqrt(4 + p^2) - 2*x^2))/(2*sqrt(2)*sqrt(1 + p*x^2 - x^4))))/(2*sqrt(2)), x, 1),


# ::Section::Closed::
# 28 August 2017


# {(3 + x^2)/((1 + x^2)*(1 + 6*x^2 + x^4)^(1/4)), x, 0, 0}
# {(3 - x^2)/((1 - x^2)*(1 - 6*x^2 + x^4)^(1/4)), x, 0, 0} *)


((a + b*x)/((2 - x^2)*(-1 + x^2)^(1//4)), (a*atan(x/(sqrt(2)*(-1 + x^2)^(1//4))))/(2*sqrt(2)) - b*atan((-1 + x^2)^(1//4)) + (a*atanh(x/(sqrt(2)*(-1 + x^2)^(1//4))))/(2*sqrt(2)) + b*atanh((-1 + x^2)^(1//4)), x, 7),
((a + b*x)/((2 + x^2)*(-1 - x^2)^(1//4)), (a*atan(x/(sqrt(2)*(-1 - x^2)^(1//4))))/(2*sqrt(2)) + b*atan((-1 - x^2)^(1//4)) + (a*atanh(x/(sqrt(2)*(-1 - x^2)^(1//4))))/(2*sqrt(2)) - b*atanh((-1 - x^2)^(1//4)), x, 7),

((a + b*x)/((2 - x^2)*(1 - x^2)^(1//4)), (b*atan((1 - sqrt(1 - x^2))/(sqrt(2)*(1 - x^2)^(1//4))))/sqrt(2) + (1//2)*a*atan((1 - sqrt(1 - x^2))/(x*(1 - x^2)^(1//4))) + (b*atanh((1 + sqrt(1 - x^2))/(sqrt(2)*(1 - x^2)^(1//4))))/sqrt(2) + (1//2)*a*atanh((1 + sqrt(1 - x^2))/(x*(1 - x^2)^(1//4))), x, 3),
((a + b*x)/((2 + x^2)*(1 + x^2)^(1//4)), -((b*atan((1 - sqrt(1 + x^2))/(sqrt(2)*(1 + x^2)^(1//4))))/sqrt(2)) - (1//2)*a*atan((1 + sqrt(1 + x^2))/(x*(1 + x^2)^(1//4))) - (1//2)*a*atanh((1 - sqrt(1 + x^2))/(x*(1 + x^2)^(1//4))) - (b*atanh((1 + sqrt(1 + x^2))/(sqrt(2)*(1 + x^2)^(1//4))))/sqrt(2), x, 3),


# ::Section::Closed::
# 20 January 2018


(x/((4 - x^3)*sqrt(1 - x^3)), -(atan((sqrt(3)*(1 - 2^(1//3)*x))/sqrt(1 - x^3))/(3*2^(2//3)*sqrt(3))) + atan(sqrt(1 - x^3)/sqrt(3))/(3*2^(2//3)*sqrt(3)) - atanh((1 + 2^(1//3)*x)/sqrt(1 - x^3))/(3*2^(2//3)) + atanh(sqrt(1 - x^3))/(9*2^(2//3)), x, 1),
(x/((4 - d*x^3)*sqrt(-1 + d*x^3)), -(atan((1 + 2^(1//3)*d^(1//3)*x)/sqrt(-1 + d*x^3))/(3*2^(2//3)*d^(2//3))) - atan(sqrt(-1 + d*x^3))/(9*2^(2//3)*d^(2//3)) - atanh((sqrt(3)*(1 - 2^(1//3)*d^(1//3)*x))/sqrt(-1 + d*x^3))/(3*2^(2//3)*sqrt(3)*d^(2//3)) - atanh(sqrt(-1 + d*x^3)/sqrt(3))/(3*2^(2//3)*sqrt(3)*d^(2//3)), x, 1),


(x/((x^3 + 8)*sqrt(x^3 - 1)), (1//18)*atan((1 - x)^2/(3*sqrt(-1 + x^3))) + (1//18)*atan((1//3)*sqrt(-1 + x^3)) - atanh((sqrt(3)*(1 - x))/sqrt(-1 + x^3))/(6*sqrt(3)), x, 8),
(x/((8 - d*x^3)*sqrt(1 + d*x^3)), -(atan((sqrt(3)*(1 + d^(1//3)*x))/sqrt(1 + d*x^3))/(6*sqrt(3)*d^(2//3))) + atanh((1 + d^(1//3)*x)^2/(3*sqrt(1 + d*x^3)))/(18*d^(2//3)) - atanh((1//3)*sqrt(1 + d*x^3))/(18*d^(2//3)), x, 8),


# ::Section::Closed::
# 25 January 2018


(1/((3 - x^2)*(1 - 3*x^2)^(1//3)), (1//4)*atan((1 - (1 - 3*x^2)^(1//3))/x) + atanh(x/sqrt(3))/(4*sqrt(3)) - atanh((1 - (1 - 3*x^2)^(1//3))^2/(3*sqrt(3)*x))/(4*sqrt(3)), x, 1),
(1/((3 + x^2)*(1 + 3*x^2)^(1//3)), atan(x/sqrt(3))/(4*sqrt(3)) + atan((1 - (1 + 3*x^2)^(1//3))^2/(3*sqrt(3)*x))/(4*sqrt(3)) - (1//4)*atanh((1 - (1 + 3*x^2)^(1//3))/x), x, 1),


(1/((3 + x^2)*(1 - x^2)^(1//3)), atan(sqrt(3)/x)/(2*2^(2//3)*sqrt(3)) + atan((sqrt(3)*(1 - 2^(1//3)*(1 - x^2)^(1//3)))/x)/(2*2^(2//3)*sqrt(3)) - atanh(x)/(6*2^(2//3)) + atanh(x/(1 + 2^(1//3)*(1 - x^2)^(1//3)))/(2*2^(2//3)), x, 1),
(1/((3 - x^2)*(1 + x^2)^(1//3)), -(atan(x)/(6*2^(2//3))) + atan(x/(1 + 2^(1//3)*(1 + x^2)^(1//3)))/(2*2^(2//3)) - atanh(sqrt(3)/x)/(2*2^(2//3)*sqrt(3)) - atanh((sqrt(3)*(1 - 2^(1//3)*(1 + x^2)^(1//3)))/x)/(2*2^(2//3)*sqrt(3)), x, 1),


# ::Section::Closed::
# 27 January 2018


((x + a)/((x - a)*sqrt(x^3 - x^2*(a^2 + 1) + a^2*x)), -((2*sqrt(x)*sqrt(a^2 - (1 + a^2)*x + x^2)*atan(((1 - a)*sqrt(x))/sqrt(a^2 - (1 + a^2)*x + x^2)))/((1 - a)*sqrt(a^2*x - (1 + a^2)*x^2 + x^3))), x, 4),


((x + a - 2)/((x - a)*sqrt(x^3 + x^2*(a^2 - 2*a - 1) + a*x*(2 - a))), 0, x, -5),


((x*(2*a - 1) - a)/((x - a)*sqrt(x^3*(2*a - 1) - x^2*(a^2 + 2*a - 1) + a^2*x)), log((-a^2 + 2*a*x + x^2 - 2*(x + sqrt((-(-1 + x))*x*(a^2 + x - 2*a*x))))/(a - x)^2), x, -7),


# ::Section::Closed::
# 7 February 2018


((1 - 2^(1//3)*x)/((2^(2//3) + x)*sqrt(1 + x^3)), (2*atan((sqrt(3)*(1 + 2^(1//3)*x))/sqrt(1 + x^3)))/sqrt(3), x, 2),


# ::Section::Closed::
# 14 February 2018


((1 + x)/((-2 + x)*sqrt(1 + x^3)), (-(2//3))*atanh((1 + x)^2/(3*sqrt(1 + x^3))), x, 2),


# ::Section::Closed::
# 21 February 2018


(x/((10 + 6*sqrt(3) + x^3)*sqrt(1 + x^3)), -(((2 - sqrt(3))*atan((3^(1//4)*(1 + sqrt(3))*(1 + x))/(sqrt(2)*sqrt(1 + x^3))))/(2*sqrt(2)*3^(3//4))) - ((2 - sqrt(3))*atan(((1 - sqrt(3))*sqrt(1 + x^3))/(sqrt(2)*3^(3//4))))/(3*sqrt(2)*3^(3//4)) - ((2 - sqrt(3))*atanh((3^(1//4)*(1 + sqrt(3) - 2*x))/(sqrt(2)*sqrt(1 + x^3))))/(3*sqrt(2)*3^(1//4)) - ((2 - sqrt(3))*atanh((3^(1//4)*(1 - sqrt(3))*(1 + x))/(sqrt(2)*sqrt(1 + x^3))))/(6*sqrt(2)*3^(1//4)), x, 1),
(x/((10 - 6*sqrt(3) + x^3)*sqrt(1 + x^3)), -(((2 + sqrt(3))*atan((3^(1//4)*(1 - sqrt(3) - 2*x))/(sqrt(2)*sqrt(1 + x^3))))/(3*sqrt(2)*3^(1//4))) - ((2 + sqrt(3))*atan((3^(1//4)*(1 + sqrt(3))*(1 + x))/(sqrt(2)*sqrt(1 + x^3))))/(6*sqrt(2)*3^(1//4)) + ((2 + sqrt(3))*atanh((3^(1//4)*(1 - sqrt(3))*(1 + x))/(sqrt(2)*sqrt(1 + x^3))))/(2*sqrt(2)*3^(3//4)) + ((2 + sqrt(3))*atanh(((1 + sqrt(3))*sqrt(1 + x^3))/(sqrt(2)*3^(3//4))))/(3*sqrt(2)*3^(3//4)), x, 1),
(x/((-10 - 6*sqrt(3) + x^3)*sqrt(-1 + x^3)), ((2 - sqrt(3))*atan((3^(1//4)*(1 - sqrt(3))*(1 - x))/(sqrt(2)*sqrt(-1 + x^3))))/(6*sqrt(2)*3^(1//4)) + ((2 - sqrt(3))*atan((3^(1//4)*(1 + sqrt(3) + 2*x))/(sqrt(2)*sqrt(-1 + x^3))))/(3*sqrt(2)*3^(1//4)) + ((2 - sqrt(3))*atanh((3^(1//4)*(1 + sqrt(3))*(1 - x))/(sqrt(2)*sqrt(-1 + x^3))))/(2*sqrt(2)*3^(3//4)) - ((2 - sqrt(3))*atanh(((1 - sqrt(3))*sqrt(-1 + x^3))/(sqrt(2)*3^(3//4))))/(3*sqrt(2)*3^(3//4)), x, 1),
(x/((-10 + 6*sqrt(3) + x^3)*sqrt(-1 + x^3)), -(((2 + sqrt(3))*atan((3^(1//4)*(1 - sqrt(3))*(1 - x))/(sqrt(2)*sqrt(-1 + x^3))))/(2*sqrt(2)*3^(3//4))) + ((2 + sqrt(3))*atan(((1 + sqrt(3))*sqrt(-1 + x^3))/(sqrt(2)*3^(3//4))))/(3*sqrt(2)*3^(3//4)) + ((2 + sqrt(3))*atanh((3^(1//4)*(1 + sqrt(3))*(1 - x))/(sqrt(2)*sqrt(-1 + x^3))))/(6*sqrt(2)*3^(1//4)) + ((2 + sqrt(3))*atanh((3^(1//4)*(1 - sqrt(3) + 2*x))/(sqrt(2)*sqrt(-1 + x^3))))/(3*sqrt(2)*3^(1//4)), x, 1),


# ::Section::Closed::
# 24 February 2018 via email


((1 - sqrt(3) + x)/((1 + sqrt(3) + x)*sqrt(-4 + 4*sqrt(3)*x^2 + x^4)), (1//3)*sqrt(-3 + 2*sqrt(3))*atanh((1 - sqrt(3) + x)^2/(sqrt(3*(-3 + 2*sqrt(3)))*sqrt(-4 + 4*sqrt(3)*x^2 + x^4))), x, 2),


((1 + sqrt(3) + x)/((1 - sqrt(3) + x)*sqrt(-4 - 4*sqrt(3)*x^2 + x^4)), -(1//3)*sqrt(3 + 2*sqrt(3))*atan((1 + sqrt(3) + x)^2/(sqrt(3*(3 + 2*sqrt(3)))*sqrt(-4 - 4*sqrt(3)*x^2 + x^4))), x, 2),


# ::Section::Closed::
# 1 March 2018


((x - 1)/((x + 1)*(x^3 + 2)^(1//3)), sqrt(3)*atan((1 + (2*(2 + x))/(2 + x^3)^(1//3))/sqrt(3)) + log(1 + x) - (3//2)*log(2 + x - (2 + x^3)^(1//3)), x, 1),


(1/((x + 1)*(x^3 + 2)^(1//3)), atan((1 + (2*x)/(2 + x^3)^(1//3))/sqrt(3))/(2*sqrt(3)) - (1//2)*sqrt(3)*atan((1 + (2*(2 + x))/(2 + x^3)^(1//3))/sqrt(3)) - (1//2)*log(1 + x) + (3//4)*log(2 + x - (2 + x^3)^(1//3)) - (1//4)*log(-x + (2 + x^3)^(1//3)), x, 3),


# ::Section::Closed::
# 1 April 2018


# {(x^2 + 2*x - 3)/((x^4 - 8*x^3 + 94*x^2 + 552*x + 657)*Sqrt[x^3 - 15*x - 22]), x, 0, 0}


# ::Section::Closed::
# 26 September 2018


(1/((1 - x^3)*(a + b*x^3)^(1//3)), atan((1 + (2*(a + b)^(1//3)*x)/(a + b*x^3)^(1//3))/sqrt(3))/(sqrt(3)*(a + b)^(1//3)) + log(1 - x^3)/(6*(a + b)^(1//3)) - log((a + b)^(1//3)*x - (a + b*x^3)^(1//3))/(2*(a + b)^(1//3)), x, 1),
((1 + x)/((1 + x + x^2)*(a + b*x^3)^(1//3)), atan((1 + (2*(a + b)^(1//3)*x)/(a + b*x^3)^(1//3))/sqrt(3))/(sqrt(3)*(a + b)^(1//3)) + atan((1 + (2*(a + b*x^3)^(1//3))/(a + b)^(1//3))/sqrt(3))/(sqrt(3)*(a + b)^(1//3)) + log((a + b)^(1//3) - (a + b*x^3)^(1//3))/(2*(a + b)^(1//3)) - log((a + b)^(1//3)*x - (a + b*x^3)^(1//3))/(2*(a + b)^(1//3)), x, 8),
(x^2/((1 - x^3)*(a + b*x^3)^(1//3)), -(atan((1 + (2*(a + b*x^3)^(1//3))/(a + b)^(1//3))/sqrt(3))/(sqrt(3)*(a + b)^(1//3))) + log(1 - x^3)/(6*(a + b)^(1//3)) - log((a + b)^(1//3) - (a + b*x^3)^(1//3))/(2*(a + b)^(1//3)), x, 5),


# ::Section::Closed::
# 12 October 2018


(1/((1 + x^3)*(1 - x^3)^(1//3)), -(atan((1 - (2*2^(1//3)*x)/(1 - x^3)^(1//3))/sqrt(3))/(2^(1//3)*sqrt(3))) - log(1 + x^3)/(6*2^(1//3)) + log(((-2.0)^(1//3))*x - (1 - x^3)^(1//3))/(2*2^(1//3)), x, 1),
(x/((1 + x^3)*(1 - x^3)^(1//3)), atan((1 - (2*2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3))/(2^(1//3)*sqrt(3)) + atan((1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3))/(2*2^(1//3)*sqrt(3)) + log((1 - x)*(1 + x)^2)/(12*2^(1//3)) + log(1 + (2^(2//3)*(1 - x)^2)/(1 - x^3)^(2//3) - (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/(6*2^(1//3)) - log(1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/(3*2^(1//3)) - log(-1 + x + 2^(2//3)*(1 - x^3)^(1//3))/(4*2^(1//3)), x, 8),
(x^2/((1 + x^3)*(1 - x^3)^(1//3)), atan((1 + 2^(2//3)*(1 - x^3)^(1//3))/sqrt(3))/(2^(1//3)*sqrt(3)) - log(1 + x^3)/(6*2^(1//3)) + log(2^(1//3) - (1 - x^3)^(1//3))/(2*2^(1//3)), x, 5),


# Integrands are equal.
((1 + x)/((1 - x + x^2)*(1 - x^3)^(1//3)), (sqrt(3)*atan((1 - (2*2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3)))/2^(1//3) + log(1 + (2^(2//3)*(1 - x)^2)/(1 - x^3)^(2//3) - (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/(2*2^(1//3)) - log(1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/2^(1//3), x, -16),
((1 + x)^2/((1 + x^3)*(1 - x^3)^(1//3)), (sqrt(3)*atan((1 - (2*2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3)))/2^(1//3) + log(1 + (2^(2//3)*(1 - x)^2)/(1 - x^3)^(2//3) - (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/(2*2^(1//3)) - log(1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/2^(1//3), x, -17),


((1 - x)/((1 + x + x^2)*(1 + x^3)^(1//3)), -((sqrt(3)*atan((1 - (2*2^(1//3)*(1 + x))/(1 + x^3)^(1//3))/sqrt(3)))/2^(1//3)) - log(1 + (2^(2//3)*(1 + x)^2)/(1 + x^3)^(2//3) - (2^(1//3)*(1 + x))/(1 + x^3)^(1//3))/(2*2^(1//3)) + log(1 + (2^(1//3)*(1 + x))/(1 + x^3)^(1//3))/2^(1//3), x, -16),


# Integrands are equal.
((1 - x^3)^(2//3)/(1 + x + x^2)^2, 1/(1 - x^3)^(1//3) + x/(1 - x^3)^(1//3) - x^2*hypergeometric2f1(2//3, 4//3, 5//3, x^3), x, 5),
((1 - x)/((1 + x + x^2)*(1 - x^3)^(1//3)), 1/(1 - x^3)^(1//3) + x/(1 - x^3)^(1//3) - x^2*hypergeometric2f1(2//3, 4//3, 5//3, x^3), x, 5),
((1 - x)^2/(1 - x^3)^(4//3), (1 + (1 - 2*x)*x)/(1 - x^3)^(1//3) + x^2*hypergeometric2f1(1//3, 2//3, 5//3, x^3), x, 3),


# ::Section::Closed::
# 16 October 2018


((1 - x^3)^(2//3), (1//3)*x*(1 - x^3)^(2//3) - (2*atan((1 - (2*x)/(1 - x^3)^(1//3))/sqrt(3)))/(3*sqrt(3)) + (1//3)*log(x + (1 - x^3)^(1//3)), x, 2),
((1 - x^3)^(2//3)/x, (1//2)*(1 - x^3)^(2//3) + atan((1 + 2*(1 - x^3)^(1//3))/sqrt(3))/sqrt(3) - log(x)/2 + (1//2)*log(1 - (1 - x^3)^(1//3)), x, 6),
((1 - x^3)^(2//3)/(a + b*x), (1 - x^3)^(2//3)/(2*b) - ((a^3 + b^3)*x^2*SymbolicIntegration.appell_f1(2//3, 1//3, 1, 5//3, x^3, -((b^3*x^3)/a^3)))/(2*a^2*b^2) + (a^2*atan((1 - (2*x)/(1 - x^3)^(1//3))/sqrt(3)))/(sqrt(3)*b^3) - ((a^3 + b^3)^(2//3)*atan((1 - (2*(a^3 + b^3)^(1//3)*x)/(a*(1 - x^3)^(1//3)))/sqrt(3)))/(sqrt(3)*b^3) + ((a^3 + b^3)^(2//3)*atan((1 + (2*b*(1 - x^3)^(1//3))/(a^3 + b^3)^(1//3))/sqrt(3)))/(sqrt(3)*b^3) + (a*x^2*hypergeometric2f1(1//3, 2//3, 5//3, x^3))/(2*b^2) - ((a^3 + b^3)^(2//3)*log(a^3 + b^3*x^3))/(3*b^3) + ((a^3 + b^3)^(2//3)*log(-(((a^3 + b^3)^(1//3)*x)/a) - (1 - x^3)^(1//3)))/(2*b^3) - (a^2*log(x + (1 - x^3)^(1//3)))/(2*b^3) + ((a^3 + b^3)^(2//3)*log((a^3 + b^3)^(1//3) - b*(1 - x^3)^(1//3)))/(2*b^3), x, 13),


# ::Section::Closed::
# 17 October 2018


((1 - x^3)^(2//3)/(1 - x + x^2)^2, -((1 - x^3)^(2//3)/(3*(1 + x^3))) + (x*(1 - x^3)^(2//3))/(3*(1 + x^3)) + (2*x^2*(1 - x^3)^(2//3))/(3*(1 + x^3)) - (2^(2//3)*atan((1 - (2*2^(1//3)*x)/(1 - x^3)^(1//3))/sqrt(3)))/(3*sqrt(3)) - (2^(2//3)*atan((1 + 2^(2//3)*(1 - x^3)^(1//3))/sqrt(3)))/(3*sqrt(3)) + (1//3)*x^2*hypergeometric2f1(1//3, 2//3, 5//3, x^3) - log(2^(1//3) - (1 - x^3)^(1//3))/(3*2^(1//3)) + log(((-2.0)^(1//3))*x - (1 - x^3)^(1//3))/(3*2^(1//3)), x, 13),


# {(1 - 2*x)*(1 - x^3)^(2/3)/(1 - x + x^2)^2, x, 14, (1 - x^3)^(2/3)/(1 - x + x^2) - (2*ArcTan[(1 - (2*x)/(1 - x^3)^(1/3))/Sqrt[3]])/Sqrt[3] + (2^(2/3)*ArcTan[(1 - (2*2^(1/3)*x)/(1 - x^3)^(1/3))/Sqrt[3]])/Sqrt[3] + (2^(2/3)*ArcTan[(1 + 2^(2/3)*(1 - x^3)^(1/3))/Sqrt[3]])/Sqrt[3] + Log[2^(1/3) - (1 - x^3)^(1/3)]/2^(1/3) - Log[((-2.0)^(1/3))*x - (1 - x^3)^(1/3)]/2^(1/3) + Log[x + (1 - x^3)^(1/3)], (1 - x^3)^(2/3)/(1 + x^3) + (x*(1 - x^3)^(2/3))/(1 + x^3) - (2*ArcTan[(1 - (2*x)/(1 - x^3)^(1/3))/Sqrt[3]])/Sqrt[3] + (2^(2/3)*ArcTan[(1 - (2*2^(1/3)*x)/(1 - x^3)^(1/3))/Sqrt[3]])/Sqrt[3] + (2^(2/3)*ArcTan[(1 + 2^(2/3)*(1 - x^3)^(1/3))/Sqrt[3]])/Sqrt[3] + Log[2^(1/3) - (1 - x^3)^(1/3)]/2^(1/3) + Log[((-2.0)^(1/3))*x - (1 - x^3)^(1/3)]/(3*2^(1/3)) - (2/3)*2^(2/3)*Log[((-2.0)^(1/3))*x - (1 - x^3)^(1/3)] + Log[x + (1 - x^3)^(1/3)]}


# ::Section::Closed::
# 22 October 2018


((1 - x^3)^(2//3)/(1 + x), (1//2)*(1 - x^3)^(2//3) - (sqrt(3)*atan((1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3)))/2^(1//3) + atan((1 - (2*x)/(1 - x^3)^(1//3))/sqrt(3))/sqrt(3) + (1//2)*x^2*hypergeometric2f1(1//3, 2//3, 5//3, x^3) - log((1 - x)*(1 + x)^2)/(2*2^(1//3)) - (1//2)*log(x + (1 - x^3)^(1//3)) + (3*log(-1 + x + 2^(2//3)*(1 - x^3)^(1//3)))/(2*2^(1//3)), x, 5),
((1 - x + x^2)*(1 - x^3)^(2//3)/(1 + x^3), (1//2)*(1 - x^3)^(2//3) - (sqrt(3)*atan((1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3)))/2^(1//3) + atan((1 - (2*x)/(1 - x^3)^(1//3))/sqrt(3))/sqrt(3) + (1//2)*x^2*hypergeometric2f1(1//3, 2//3, 5//3, x^3) - log((1 - x)*(1 + x)^2)/(2*2^(1//3)) - (1//2)*log(x + (1 - x^3)^(1//3)) + (3*log(-1 + x + 2^(2//3)*(1 - x^3)^(1//3)))/(2*2^(1//3)), x, 6),


# ::Section::Closed::
# 24 October 2018


((1 - x^3)^(2//3)/(1 + x^3), atan((1 - (2*x)/(1 - x^3)^(1//3))/sqrt(3))/sqrt(3) - (2^(2//3)*atan((1 - (2*2^(1//3)*x)/(1 - x^3)^(1//3))/sqrt(3)))/sqrt(3) - log(1 + x^3)/(3*2^(1//3)) + log(((-2.0)^(1//3))*x - (1 - x^3)^(1//3))/2^(1//3) - (1//2)*log(x + (1 - x^3)^(1//3)), x, 3),


(x*(1 - x^3)^(2//3)/(1 + x^3), (2^(2//3)*atan((1 - (2*2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3)))/sqrt(3) + atan((1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3))/(2^(1//3)*sqrt(3)) - (1//2)*x^2*hypergeometric2f1(1//3, 2//3, 5//3, x^3) + log((1 - x)*(1 + x)^2)/(6*2^(1//3)) + log(1 + (2^(2//3)*(1 - x)^2)/(1 - x^3)^(2//3) - (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/(3*2^(1//3)) - (1//3)*2^(2//3)*log(1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3)) - log(-1 + x + 2^(2//3)*(1 - x^3)^(1//3))/(2*2^(1//3)), x, 10),


# ::Section::Closed::
# 4 November 2018


((1 - x)*(1 - x^3)^(2//3)/(1 + x^3), -((2^(2//3)*atan((1 - (2*2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3)))/sqrt(3)) - atan((1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3))/(2^(1//3)*sqrt(3)) + atan((1 - (2*x)/(1 - x^3)^(1//3))/sqrt(3))/sqrt(3) - (2^(2//3)*atan((1 - (2*2^(1//3)*x)/(1 - x^3)^(1//3))/sqrt(3)))/sqrt(3) + (1//2)*x^2*hypergeometric2f1(1//3, 2//3, 5//3, x^3) - log((1 - x)*(1 + x)^2)/(6*2^(1//3)) - log(1 + x^3)/(3*2^(1//3)) - log(1 + (2^(2//3)*(1 - x)^2)/(1 - x^3)^(2//3) - (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/(3*2^(1//3)) + (1//3)*2^(2//3)*log(1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3)) + log(((-2.0)^(1//3))*x - (1 - x^3)^(1//3))/2^(1//3) - (1//2)*log(x + (1 - x^3)^(1//3)) + log(-1 + x + 2^(2//3)*(1 - x^3)^(1//3))/(2*2^(1//3)), x, -17),


# {(1 + x^3)*(1 - x^3)^(2/3)/(1 + x^3 + x^6), x, 0, 0}


((1 - x^3)^(1//3)/(1 + x^3), (2^(1//3)*atan((1 - (2*2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3)))/sqrt(3) + atan((1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/sqrt(3))/(2^(2//3)*sqrt(3)) + log(2^(2//3) - (1 - x)/(1 - x^3)^(1//3))/(3*2^(2//3)) - log(1 + (2^(2//3)*(1 - x)^2)/(1 - x^3)^(2//3) - (2^(1//3)*(1 - x))/(1 - x^3)^(1//3))/(3*2^(2//3)) + (1//3)*2^(1//3)*log(1 + (2^(1//3)*(1 - x))/(1 - x^3)^(1//3)) - log(2*2^(1//3) + (1 - x)^2/(1 - x^3)^(2//3) + (2^(2//3)*(1 - x))/(1 - x^3)^(1//3))/(6*2^(2//3)), x, 14),
]
=#
wester = [
# ::Package::

# ::Title::
# Michael Wester


# Gradshteyn and Ryzhik 2.244(8)
((-5 + 3*x)^2/(-1 + 2*x)^(7//2), -(49/(20*(-1 + 2*x)^(5//2))) + 7/(2*(-1 + 2*x)^(3//2)) - 9/(4*sqrt(-1 + 2*x)), x, 2),


# => 1/[2 m sqrt (10)] log ([-5 + e^(m x) sqrt (10)]/[-5 - e^(m x) sqrt (10)])
#       [Gradshteyn and Ryzhik 2.314] *)
(1/(-5/ℯ^(m*x) + 2*ℯ^(m*x)), -(atanh(sqrt(2//5)*ℯ^(m*x))/(sqrt(10)*m)), x, 2),


# This example involves several symbolic parameters
#    => 1/sqrt(b^2 - a^2) log ([sqrt (b^2 - a^2) tan (x/2) + a + b]/
#                             [sqrt (b^2 - a^2) tan (x/2) - a - b])   (a^2 < b^2)
#       [Gradshteyn and Ryzhik 2.553(3)] *)
#
# {1/(a + b*Cos[x]), x, 0, Assumptions -> a^2 < b^2,
#  1/Sqrt[b^2 - a^2]*Log[(Sqrt[b^2 - a^2]*Tan[x/2] + a + b)/
#                        (Sqrt[b^2 - a^2]*Tan[x/2] - a - b)]}
# *)
(1/(a + b*cos(x)), (2*atan((sqrt(a - b)*tan(x/2))/sqrt(a + b)))/(sqrt(a - b)*sqrt(a + b)), x, 2),
# The integral of 1/(a + 3 cos x + 4 sin x) can have 4 different forms
#    depending on the value of a !   [Gradshteyn and Ryzhik 2.558(4)] *)
(1/(3 + 3*cos(x) + 4*sin(x)), (1//4)*log(3 + 4*tan(x/2)), x, 2),
(1/(4 + 3*cos(x) + 4*sin(x)), (-(1//3))*log(4 + 3*cot(π/4 + x/2)), x, 2),
# {1/(5 + 3*Cos[x] + 4*Sin[x]), x, 1, -1/(2 + Tan[x/2]), -((4 - 5*Sin[x])/(4*(4*Cos[x] - 3*Sin[x])))}
# => (a = 6) 2/sqrt(11) arctan ([3 tan (x/2) + 4]/sqrt(11))
(1/(6 + 3*cos(x) + 4*sin(x)), x/sqrt(11) + (2*atan((4*cos(x) - 3*sin(x))/(6 + sqrt(11) + 3*cos(x) + 4*sin(x))))/sqrt(11), x, 3),


# => x log|x^2 - a^2| - 2 x + a log|(x + a)/(x - a)|
#       [Gradshteyn and Ryzhik 2.736(1)] *)
# {Log[Abs[x^2 - a^2]], x, 0, x*Log[Abs[x^2 - a^2]] - 2*x + a*Log[(x + a)/(x - a)]}
((1//2)*log((-a^2 + x^2)^2), -2*x + 2*a*atanh(x/a) + (1//2)*x*log((-a^2 + x^2)^2), x, 4),
]

file_tests = vcat(apostol,
                  bondarenko,
                  bronstein,
                  charlwood,
                  hearn,
                  hebisch,
                  jeffrey,
                  moses,
                  stewart,
                  timofeev,
                  #welz,
                  wester
                 )



@testset "Testing integration" begin
    _run_test(r) =  !contains_int(integrate(r[1],r[3]))
    us = [(i,_run_test(r)) for (i,r) ∈ enumerate(file_tests)]
    for (i, (f,a,dx,k)) ∈ enumerate(file_tests)
        out = integrate(f, dx)
        u =  !contains_int(out)
        #show i, u
        #@test u
    end
end
