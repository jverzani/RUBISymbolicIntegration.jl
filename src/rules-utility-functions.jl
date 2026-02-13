### make more generic
XXX() = throw("Create a method")

∫(f, dx) = make_integral(f, dx)
_substitute() = XXX()
_simplify(x, args...;kwargs...) = x
_simpler(args...; kwargs...) = _simplify(args...; kwargs...)
_expand() = XXX()
_expand(x::Number) = x
_derivative() = XXX()
is_constant(x::Number) = true
is_symbolic(x) = false
is_symbol(x) = false
_iszero(x) = iszero(x)
ext_coeff(u::Number, x::Number, n) = 0
unwrap_const(x::Number) = x
unwrap(x::Number) = x
Gamma() = XXX()
LogGamma() = XXX()
appell_f1() = XXX()
hypergeometric2f1() = XXX()
Expinti() = XXX()
Erf() = XXX()
Erfi() = XXX()
Elliptic_e() = XXX()
Elliptic_f() = XXX()
Elliptic_pi() = XXX()
Sinint() = XXX()
Cosint() = XXX()
FresnelIntegrals_fresnels() = XXX()
FresnelIntegrals_fresnelsc() = XXX()
PolyLog_reli() = XXX()
coshintegral() = XXX()
sinhintegral() = XXX()
CannotIntegrate() = XXX()
Unintegrable() = XXX()

USE_GAMMA = false

### ------- TermInterface only below here ------
_is_operation(fs::Tuple)   = @nospecialize(x) -> iscall(x) && (operation(x) ∈ fs)
_is_operation(fn)   = _is_operation((fn, Symbol(fn)))
eq_op(op1, op2) = op1 == op2 || Symbol(op1) == Symbol(op2)

## --------- From SymbolicIntegration

## This is basically a translation of https://github.com/JuliaSymbolics/SymbolicIntegration.jl/blob/main/src/methods/rule_based/rules_utility_functions.jl

## UFI = Union{Number, SymType} # Union{Num, SymbolicUtils.BasicSymbolic, Rational, Integer} or UFI = Union{Number, SymbolicUtils.BasicSymbolic{SymbolicUtils.SymReal}}


# this custom division function is added to produce
# - rationals if called with integers
# - floats if called with floats
# it's a infix operator with the same precedence of /
function ⨸(x::Union{Rational, Integer}, y::Union{Rational, Integer})
    iszero(y) && return NaN
    res = x // y
    ext_isinteger(res) ? Int(res) : res
end
⨸(x, y) = (_iszero(y) ? NaN : x / y)

# this custom exponentiation function should be used whenever there are
# fractional powers, because (-1)^(1/2) errors
# it's a infix operator with the same precedence of ^
⟰(x, y) = lt(x, 0) ? Complex(x) ^ y : x ^ y
⟰(x, y::Integer) = x ^ y

# if expr contains variable var return true
#function contains_var(expr, var)
#    # Define for symbolic type for var
#end

# the last argument is the variable to check the other expr against
contains_var(x)::Bool = (as...) -> contains_var(as..., x)
function contains_var(args...)::Bool
    var = args[end]
    any(contains_var(expr, var) for expr in args[1:end-1])
end

function contains_op(op, expr)
    if iscall(expr)
        if Symbol(operation(expr)) === Symbol(op)
            return true
        end
        return any(contains_op(op, a) for a in arguments(expr))
    end
    return false
end

function complexfree(expr)
    isa(expr, Complex) && !eq(imag(expr),0) && return true
    return false
end

# to distinguish between symbolic expressions and numbers
s(u) = !is_constant(u) #isa(Symbolics.unwrap(u), SymbolicUtils.BasicSymbolic)

function eq(a, b)::Bool
    a = unwrap_const(a)
    b = unwrap_const(b)
    isequal(_simplify(a - b), 0)
end

ext_isinteger(u::Number) = isinteger(u)
ext_isinteger(u::Any) = false
ext_isinteger(args...) = all(ext_isinteger(arg) for arg in args)

#half_integer(u::SymbolicUtils.BasicSymbolic) = false
#half_integer(u::Number) = isinteger(u - 1//2)
half_integer(u::Any) = ext_isinteger(_expand(u - 1//2))
half_integer(args...) = all(half_integer(arg) for arg in args)


function ext_iseven(u)
    s(u) && return false # for symbolic expressions
    isa(u, Number) && return iseven(u) # for numeric types
    return false
end

function ext_isodd(u)
    s(u) && return false # for symbolic expressions
    isa(u, Number) && return isodd(u) # for numeric types
    return false
end

# If m, n, ... are explicit fractions, fraction(m,n,...) returns true
isfraction(args...) = all(isa(arg, Rational) && ext_den(arg)!=1 for arg in args)
# If m, n, ... are integers or fractions, rational(m,n,...) returns true
_isrational(arg) = isa(arg, Rational) || isa(arg, Integer)
_isrational(arg::Expr) = is_operation(:(//))(arg)
isrational(args...) = all(_isrational, args)

# If u is a sum, sumQ(u) returns true; else it returns false.
function issum(u)
    u = unwrap(u)
    return _is_operation((+,:+))(u)
#    return SymbolicUtils.iscall(u) && SymbolicUtils.operation(u) === +
end

function isprod(u)
    u = unwrap(u)
    return _is_operation((*,:*))(u)
end

function isdiv(u)
    u = unwrap(u)
    return _is_operation((/,:/))(u)
end

function ispow(u)
    u = unwrap(u)
    return _is_operation((^,:^))(u)
end

simp(u,x) = _simplify(u)


const trig_functions = (sin, cos, tan, cot,sec, csc,
                        :sin, :cos, :tan, :cot, :sec, :csc)
istrig(funct) = in(funct, trig_functions)

function ext_coeff(u, x)
    return ext_coeff(u, x, 1)
end
ext_coeff(u::Number, x, n) = 0
#= specialized above on u, x
function ext_coeff(u, x, n)
    try
        _coeff(u,x,n)
    catch err
        println("error", err)
        return 0
    end
end
=#
# SimplifyIntegrand[u,x] simplifies u and returns the result in a standard form recognizable by integration rules
function ext_simplify(u, x)
    _simplify(u)
end

# If u is a polynomial in x, expand_linear_product(v, u, a, b, x) expands v*u
# into a sum of terms of the form c*v*(a+b*x)^n where n is a non-negative integer
# usually v = (a + bx)^(non integer number)
# Example:
# julia> SymbolicIntegration.expand_linear_product((3 + 6x)^(2.1),(-1 + 2x)^2, 3, 6, x)
# (4//1)*((3 + 6x)^2.1) - (4//3)*((3 + 6x)^3.1) + (1//9)*((3 + 6x)^4.1)
function expand_linear_product(v, u, a, b, x)
    !poly(u, x) && throw(ArgumentError("u must be a polynomial in x"))
    contains_var(a, b, x) && throw(ArgumentError("a and b must be constants (free of x)"))

    u_transformed = _expand(_substitute(u, x => (x - a) / b))

    # Extract coefficients of the transformed polynomial
    coeffs = Any[] #Num[]

    N = poly_degree(u_transformed, x)
    isnothing(N) && return nothing
    for i in 0:N
        coeff = ext_coeff(u_transformed, x, i)
        push!(coeffs, simp(coeff, x)) # Simplify each coefficient
    end

    # Build the sum: v * coeff[i] * (a+b*x)^(i-1) for all coeffs
    return sum(v * c * (a + b*x)^(i-1) for (i,c) in enumerate(coeffs))
end

# TODO this is not enough, not taking all the cases of rubi
# TODO function ext_expand(expr::Union{SymbolicUtils.BasicSymbolic{Real}, Num}, x::Union{SymbolicUtils.BasicSymbolic{Real}, Num})
# TODO address x / ((1 + x)^2)
function ext_expand(expr, x)
    # have issue with defining guards within this function
    # due to eval call. Workaround by looping over eachmatch
    f(a) = !contains_var(a,x)
    p(a) = poly(a,x)
    𝑥 = Symbol(x)

    ## do guards after match
    # note that m can be a non integer
    case1 = :((~u)*((~a) + (~!b)*$𝑥)^(~m))
    for σ ∈  _eachmatch(case1, expr) # t stands for tmp
        (p(σ[:u]) &&
         f(σ[:a]) &&
         f(σ[:b]) &&
         f(σ[:m])) || continue
        #@show :case1
        return expand_linear_product((σ[:a]+σ[:b]*x)^σ[:m],σ[:u], σ[:a], σ[:b], x)
    end
    #case1 = case1 = @rule (~u::p)*((~a::f) + (~!b::f)*x)^(~m::f) => ~


    case1_1 =  :((~u)/(((~a) + (~!b)*$𝑥)^(~m)))
    for σ ∈  _eachmatch(case1_1, expr) # t stands for tmp
        (p(σ[:u]) &&
         f(σ[:a]) &&
         f(σ[:b]) &&
         f(σ[:m])) || continue
        #@show :case11
        return expand_linear_product((σ[:a]+σ[:b]*x)^(-σ[:m]),σ[:u], σ[:a], σ[:b], x)
    end
    #case1_1 =  @rule (~u::(p->poly(p,x)))/(((~a::f) + (~!b::f)*x)^(~m::f)) => ~ # TODO needed because of neim problem


    case2, rhs = :((~!a + ~!b*$𝑥)^(~!m)/(~!c + ~!d*$𝑥)) => :((~b*(~a+~b*$𝑥)^(~m-1))⨸~d + ((~a*~d-~b*~c)*(~a+~b*x)^(~m-1))⨸(~d*(~c+~d*$𝑥)))
    for σ ∈ _eachmatch(case2, expr) # t stands for tmp
        (f(σ[:a]) &&
         f(σ[:b]) &&
         ext_isinteger(σ[:m]) &&
         f(σ[:c]) &&
         f(σ[:d])) || continue
        #@show :case2
        return ((σ[:b]*(σ[:a]+σ[:b]*x)^(σ[:m]-1))⨸σ[:d] + ((σ[:a]*σ[:d]-σ[:b]*σ[:c])*(σ[:a]+σ[:b]*x)^(σ[:m]-1))⨸(σ[:d]*(σ[:c]+σ[:d]*x)))
    end
    #case2 = @rule (~!a::f + ~!b::f*x)^(~!m::ext_isinteger)/(~!c::f + ~!d::f*x) => (~b*(~a+~b*x)^(~m-1))⨸~d + ((~a*~d-~b*~c)*(~a+~b*x)^(~m-1))⨸(~d*(~c+~d*x))

    case4, rhs = :($𝑥/(~a + ~b*$𝑥)) => :(1⨸~b - ~a⨸(~b*(~a + ~b*$𝑥)))
    for σ ∈ _eachmatch(case1, expr) # t stands for tmp
        (f(σ[:a]) &&
         f(σ[:b])
         ) || continue
        #@show :case4
        return (1⨸σ[:b] - σ[:a]⨸(σ[:b]*(σ[:a] + σ[:b]*x)))
    end
    #case4 = @rule x/(~a::f + ~b::f*x) => 1⨸~b - ~a⨸(~b*(~a + ~b*x))

    case5, rhs = :((~d + ~!e*$𝑥)/(x*(~a + $𝑥^2))) => :((~d+~e*$𝑥)/($𝑥*~a) - (~d+~e*$𝑥)*$𝑥/(~a*(~a + $𝑥^2)))
    for σ ∈  _eachmatch(case5, expr) # t stands for tmp
        (f(σ[:d]) &&
         f(σ[:e]) &&
         f(σ[:a])
         ) || continue
        #@show :case5
        return ((σ[:d]+σ[:e]*x)/(x*σ[:a]) - (σ[:d]+σ[:e]*x)*x/(σ[:a]*(σ[:a] + x^2)))
    end
    #case5 = @rule (~d::f + ~!e::f*x)/(x*(~a::f + x^2)) => (~d+~e*x)/(x*~a) - (~d+~e*x)*x/(~a*(~a + x^2))

    case6, rhs = :((~u)/(~v)) => :(exponent_of(~u,$𝑥)>=exponent_of(~v,$𝑥) ? polynomial_divide(~u,~v,$𝑥) : nothing)
    for σ ∈ _eachmatch(case6, expr) # t stands for tmp
        (p(σ[:u]) &&
         p(σ[:v])) || continue
        #@show :case6
        (exponent_of(σ[:u],x)>=exponent_of(σ[:v],x)) &&
         return polynomial_divide(σ[:u],σ[:v],x)
    end
    #case6 = @rule (~u::p)/(~v::p) => exponent_of(~u,x)>=exponent_of(~v,x) ? polynomial_divide(~u,~v,x) : nothing

    return _expand(expr)
end

function ext_expand(u, v, x)
    _expand(u * v)
end

function ext_expand_trig(u, x)
    @show :ext_expand_trig, u
    _expand(u)
end

function ext_expand_integrand(u, x)
    @show :ext_expand_integrand, u
    _expand(u)
end

# ExpandToSum[u,x] returns u expanded into a sum of monomials of x.*
function expand_to_sum(u, x)
    @show :ext_expand_to_sum, u
    _expand(u)
end

# ExpandToSum[u,v,x] returns v expanded into a sum of monomials of x and distributes u over v.
function expand_to_sum(u, v, x)
    _expand_to_sum(u * v)
end

function expand_trig_reduce(u, x)
    𝑥 = Symbol(x)

    pat1 = :(sin((~!a)*$𝑥)*cos((~!a)*$𝑥))
    σs = _eachmatch(pat1, u)
    for σ ∈ σs
        return sin(σ[:a] * x)
    end

    pat2 = :((~!a)*cos((~!b)*$𝑥)^2 - (~!a)*sin((~!b)*$𝑥)^2)
    σs = _eachmatch(pat2, u)
    for σ ∈ σs
        return σ[:a] * cos(2σ[:b]*x)
    end

    pat3 = :((~!a)*cos((~!b)*$𝑥)^2 + (~!a)*sin((~!b)*$𝑥)^2)
    σs = _eachmatch(pat3, u)
    for σ ∈ σs
        return one(x)
    end

    pat4 = :((~!a)*cos((~!b)*$𝑥)^2)
    σs = _eachmatch(pat4, u)
    for σ ∈ σs
        return σ[:a] * (1 - sin(σ[:b]*x)^2)
    end

    return u
end
expand_trig_reduce(v,u,x) = expand_trig_reduce(u*v, x)

# FracPart[u] returns the sum of the non-integer terms of u.
# fracpart(3//2 + x) = (1//2) + x, fracpart(2.4) = 2.4
function fracpart(a)
    if isrational(a)
        a - trunc(a)
    elseif issum(a)
        # If a is a sum, we return the sum of the fractional parts of each term
        #return sum(fracpart(term) for term in SymbolicUtils.arguments(Symbolics.unwrap(a)))
        return sum(fracpart, arguments(a))
    else
        return a
    end
end

# IntPart[u] returns the sum of the integer terms of u.
function intpart(a)
    if isrational(a)
        trunc(a)
    elseif issum(a)
        # If a is a sum, we return the sum of the integer parts of each term
        #return sum(intpart(term) for term in SymbolicUtils.arguments(Symbolics.unwrap(a)))
        return sum(intpart, arguments(a))
    else
        return 0
    end
end

# Greater than
function gt(u, v)::Bool
    u = unwrap_const(u)
    v = unwrap_const(v)
    (s(u) || s(v)) ? false : u > v
end

gt(u, v, w) = gt(u, v) && gt(v, w)
function ge(u, v)
    u = unwrap_const(u)
    v = unwrap_const(v)
    (s(u) || s(v)) ? false : u >= v
end
ge(u, v, w) = ge(u, v) && ge(v, w)
function lt(u, v)
    u = unwrap_const(u)
    v = unwrap_const(v)
    (s(u) || s(v)) ? false : u < v
end
lt(u, v, w) = lt(u, v) && lt(v, w)
function le(u, v)
    u = unwrap_const(u)
    v = unwrap_const(v)
    (s(u) || s(v)) ? false : u <= v
end
le(u, v, w) = le(u, v) && le(v, w)

# If a is an integer and a>b, igtQ(a,b) returns true, else it returns false.
igt(a, b) = begin
    ext_isinteger(a) && gt(unwrap_const(a), unwrap_const(b))
end
ige(a, b) = ext_isinteger(a) && ge(a,b)
ilt(a, b) = ext_isinteger(a) && lt(a,b)
ile(a, b) = ext_isinteger(a) && le(a,b)

# returns the simplest nth root of u
# TODO this doesnt allow for exact simplification of roots, maybe use SymbolicUtils.Pow{Real}(u, 1⨸n)?
function rt(u, n::Integer)
    ext_isodd(n) && lt(u, 0) && return -((-u)^(1⨸n))
    if !s(u) && lt(u,0)
        u = Complex(u)
    end
    eq(n, 2) && return sqrt(u)
    return u^(1⨸n)
end

# If u is not 0 and has a positive form, posQ(u) returns True, else it returns False
function pos(u)::Bool
    u = unwrap(u)
    !s(u) && return !eq(u, 0) && gt(u, 0)
    u = _simplify(u)
    atom(u) && return true
    (isprod(u) || isdiv(u)) && return all(pos(arg) for arg in arguments(u))
    return true
end
neg(u) = !pos(u) && !eq(u, 0)

# extended denominator

ext_den(u::Number) = denominator(u)
ext_den(u::AbstractFloat) = 1
#ext_den(u) = denominator(1)
#ext_num(u::Union{Num, SymbolicUtils.BasicSymbolic, Rational, Integer}) = numerator(u)
ext_num(u::Number) = u


# IntLinearQ[a,b,c,d,m,n,x] returns True iff (a+b*x)^m*(c+d*x)^n is integrable wrt x in terms of non-hypergeometric functions.
int_linear(a, b, c, d, m, n, x) =
    igt(m, 0) || igt(n, 0) ||
    ext_isinteger(3*m, 3*n) || ext_isinteger(4*m, 4*n) ||
    ext_isinteger(2*m, 6*n) || ext_isinteger(6*m, 2*n) ||
    ilt(m + n, -1) || (ext_isinteger(m + n) && isrational(m))

# IntBinomialQ[a,b,c,n,m,p,x] returns True iff (c*x)^m*(a+b*x^n)^p  is integrable wrt x in terms of non-hypergeometric functions.
int_binomial(a, b, c, n, m, p, x) =
    igt(p, 0) ||
    (isrational(m) && ext_isinteger(n, 2*p)) ||
    ext_isinteger((m + 1)⨸n + p) ||
    (eq(n, 2) || eq(n, 4)) && ext_isinteger(2*m, 4*p) ||
    eq(n, 2) && ext_isinteger(6*p) && (ext_isinteger(m) || ext_isinteger(m - p))

# IntBinomialQ[a,b,c,d,n,p,q,x] returns True iff  (a+b*x^n)^p*(c+d*x^n)^q is integrable wrt x in terms of non-Appell  functions.
int_binomial(a, b, c, d, n, p, q, x) =
    ext_isinteger(p, q) ||
    igt(p, 0) ||
    igt(q, 0) ||
    (eq(n, 2) || eq(n, 4)) && (ext_isinteger(p, 4*q) ||
    ext_isinteger(4*p, q)) ||
    eq(n, 2) && (ext_isinteger(2*p, 2*q) ||
    ext_isinteger(3*p, q) && eq(b*c + 3*a*d, 0) ||
    ext_isinteger(p, 3*q) && eq(3*b*c + a*d, 0)) ||
    eq(n, 3) && (ext_isinteger(p + 1//3, q) ||
    ext_isinteger(q + 1//3, p)) ||
    eq(n, 3) && (ext_isinteger(p + 2//3, q) ||
    ext_isinteger(q + 2//3, p)) && eq(b*c + a*d, 0)

# IntBinomialQ[a,b,c,d,e,m,n,p,q,x] returns True iff  (e*x)^m*(a+b*x^n)^p*(c+d*x^n)^q is integrable wrt x in terms of  non-Appell functions.
int_binomial(a, b, c, d, e, m, n, p, q, x) =
    ext_isinteger(p, q) ||
    igt(p, 0) ||
    igt(q, 0) ||
    eq(n, 2) && (ext_isinteger(m, 2*p, 2*q) || ext_isinteger(2*m, p, 2*q) || ext_isinteger(2*m, 2*p, q)) ||
    eq(n, 4) && (ext_isinteger(m, p, 2*q) || ext_isinteger(m, 2*p, q)) ||
    eq(n, 2) && ext_isinteger(m/2, p + 1//3, q) && (eq(b*c + 3*a*d, 0) || eq(b*c - 9*a*d, 0)) ||
    eq(n, 2) && ext_isinteger(m/2, q + 1//3, p) && (eq(a*d + 3*b*c, 0) || eq(a*d - 9*b*c, 0)) ||
    eq(n, 3) && ext_isinteger((m - 1)/3, q, p - 1//2) && (eq(b*c - 4*a*d, 0) || eq(b*c + 8*a*d, 0) || eq(b^2*c^2 - 20*a*b*c*d - 8*a^2*d^2, 0)) ||
    eq(n, 3) && ext_isinteger((m - 1)/3, p, q - 1//2) && (eq(4*b*c - a*d, 0) || eq(8*b*c + a*d, 0) || eq(8*b^2*c^2 + 20*a*b*c*d - a^2*d^2, 0)) ||
    eq(n, 3) && (ext_isinteger(m, q, 3*p) || ext_isinteger(m, p, 3*q)) && eq(b*c + a*d, 0) ||
    eq(n, 3) && (ext_isinteger((m + 2)/3, p + 2//3, q) || ext_isinteger((m + 2)/3, q + 2//3, p)) ||
    eq(n, 3) && (ext_isinteger(m/3, p + 1//3, q) || ext_isinteger(m/3, q + 1//3, p))

# IntQuadraticQ[a,b,c,d,e,m,p,x] returns True iff  (d+e*x)^m*(a+b*x+c*x^2)^p is integrable wrt x in terms of non-Appell  functions.
int_quadratic(a,b,c,d,e,m,p,x) =
    ext_isinteger(p) || igt(m, 0) ||
    ext_isinteger(2*m, 2*p) || ext_isinteger(m, 4*p) ||
    ext_isinteger(m, p + 1//3) &&
    (eq(c^2*d^2 - b*c*d*e + b^2*e^2 - 3*a*c*e^2, 0) ||
     eq(c^2*d^2 - b*c*d*e - 2*b^2*e^2 + 9*a*c*e^2, 0))

# If u has a nice squareroot (e.g. a positive number or none of the degrees of
# the factors of the squareroot of u are fractions), return true
function nice_sqrt(u)::Bool
    !s(u) && return gt(u,0)
    return !fractional_power_factor(rt(u,2))
end

# If a factor of u is a complex constant or a fractional power returns true
# julia> SymbolicIntegration.fractional_power_factor(((1+x)^(1//2))*x)
# true
function fractional_power_factor(expr)
    expr = unwrap(expr)
    atom(expr) && return false
    !iscall(expr) && return false
    ispow(expr) && return (!ext_isinteger(arguments(expr)[2]) && isfraction(arguments(expr)[2]))
    isprod(expr) && return any(fractional_power_factor(f) for f in arguments(expr))
    return false
end

# If u is simpler than v, SimplerQ[u,v] returns True, else it
# returns False.  SimplerQ[u,u] returns False.
function simpler(u, v)
    if ext_isinteger(u)
        if ext_isinteger(v)
            if isequal(u, v)
                return false
            elseif isequal(u, -v)
                return lt(v, 0)
            else
                return abs(u) < abs(v)
            end
        else
            return true
        end
    end
    # If v is an integer but u is not
    if ext_isinteger(v)
        return false
    end
    # If u is a fraction
    if isa(u, Rational)
        if isa(v, Rational)
            if isequal(denominator(u), denominator(v))
                return simpler(numerator(u), numerator(v))
            else
                return denominator(u) < denominator(v)
            end
        else
            return true
        end
    end
    # If v is a fraction but u is not
    if isa(v, Rational)
        return false
    end
    return node_count(u) < node_count(v)
end

# from SymbolicUtils
node_count(t) = iscall(t) ? reduce(+, node_count(x) for x in arguments(t), init = 0) + 1 : 1


# True if expr is an expression which cannot be divided into subexpressions, false otherwise
function atom(expr)
    expr = unwrap(expr)
    if !iscall(expr)
        return true
    end
    # If expr is a call, check if it has any arguments
    return isempty(arguments(expr))
end

# If u+v is simpler than u, SumSimplerQ[u,v] returns True, else it returns False.
sumsimpler(u, v) = simpler(u + v, u) && !eq(u + v, u) && !eq(v, 0)

# If u is free of inverse, calculus and hypergeometric functions involving x, returns true; else it returns False
const inverse_functions = [
    asin, acos, atan, acot, asec, acsc,
    asinh, acosh, atanh, acoth, asech, acsch,
    #HypergeometricFunctions._₂F₁, appell_f1 # XXX------XXX
]
function contains_inverse_function(expr,x)
    any(contains_op(op, expr) for op in inverse_functions)
end

#=
also `substitute(integrate(integrand, int_var), from => to)` works
but using a custom function is better because
- if the integral is not solved, substitute does bad things like substituting the integration variable
- if the rule is stupid and does a substitution in which from and to are equal, we can stop it
- we can print rule application
=#
function int_and_subst(fu, du, from, to, rule_from_identifier)
    isequal(from, to) && return make_integral(fu, du)

    out = integrate(fu, du)
    if  !contains_int(out)
        return _substitute(out, from => to)
    else
        #@show fu, du, from => to
        #@show out
        #isequal(out, make_integral(fu, du)) && (@show :hi, error(""))

        #placeholder symbolic function
        @show fu, du
        return _substitute_after_int(fu, du, from, to)
    end

end

_substitute_after_int(fu,du,from,to) = begin
    out = make_integral(_substitute(fu, from => to), _substitute(du, from => to))
    CannotIntegrate(out)
end

# distributes exp1 over exp2
# rule 1662 calls dist(a,b)
function dist(exp1, exp2)
    exp1 = unwrap(exp1)
    exp2 = unwrap(exp2)
    if is_operation(+)(exp2) || is_operation(:+)(exp2)
        return sum(exp1*t for t in arguments(exp2))
    else
        return exp1*exp2
    end
end
dist(exp1, exp2, x) = dist(exp1, exp2)

# linear(a+3x,x) true
# linear((x+1)^2 - x^2 - 1,x) true
function linear(args...)
    var = args[end]
    # Symbolics.linear_expansion(a + bx, x) = (b, a, true)
    for u in args[1:end-1]
        tmp = linear_expansion(_simplify(u; expand = true), var)
        if !tmp[3] || eq(tmp[1], 0)
            return false
        end
    end
    return true
end

# Symbolics When `islinear`, return `a` and `b` such that `a * x + b == t`. Instead of calling
function linear_expansion(mxb, x)
    mxb = _expand(mxb)
    a = ext_coeff(mxb, x, 0)
    b = ext_coeff(mxb, x, 1)
    (a, b, eq(_expand((mxb - a) - b*x),0))
end

# linear_without_simplify((x+1)^2 - x^2 - 1,x) false
function linear_without_simplify(args...)
    var = args[end]
    for u in args[1:end-1]
        tmp = linear_expansion(u, var)
        if !tmp[3] || isequal(tmp[1], 0)
            return false
        end
    end
    return true
end

# if u is an expression equivalent to a+bx^n with a,b,n constants,
# b and n != 0, returns n
function binomial_degree(u, x)
    # f(p) = !contains_var(p, x) # f stands for free of x
    # (@rule (~a::f) + (~!b::f)*x^(~!n::f) => ~n)(u)
    𝑥 = Symbol(x)
    pat = :(~a + ~!b*$𝑥^(~!n))
    σs =  _eachmatch(pat, u)
    for σ ∈ σs
        !contains_var(getindex.((σ,), (:a,:b,:n))..., x) && return σ[:n]
    end
    return nothing
end
# if u is an expression equivalent to a+bx^n with a,b,n constants,
# b and n != 0, returns true
isbinomial_without_simplify(u, x)::Bool = binomial_degree(u,x) !== nothing
isbinomial_without_simplify(u, x, pow)::Bool = isequal(binomial_degree(u,x), pow)

isbinomial(u, x)::Bool = isbinomial_without_simplify(_simplify(u; expand = true),x)
isbinomial(u::Vector,x)::Bool = all(isbinomial(e,x) for e in u)
isbinomial(u, x, n)::Bool = isbinomial_without_simplify(_simplify(u; expand = true), x, n)
isbinomial(u::Vector,x,n)::Bool = all(isbinomial(e,x,n) for e in u)

# if u is an expression equivalent to a*x^q+b*x^nwith a,b,n,q constants return n-q
function generalized_binomial_degree(u,x)
    𝑥 = Symbol(x)
    pat = :((~a)*$𝑥^(~!q) + (~!b)*$𝑥^(~!n))
    σs = _eachmatch(pat, u)
    for σ ∈ σs
        a,b,q,n = σ[:a], σ[:b], σ[:q], σ[:n]
        !contains_var(a,b,q,n,x) && return σ[:n] - σ[:q]
    end
    return nothing
    #MatchPy.rewrite(σ, :(~n - ~q))
    #(@rule (~a::f)*x^(~!q::f) + (~!b::f)*x^(~!n::f) => ~n-~q)(u)
end
generalized_binomial_without_simplify(u,x) = generalized_binomial_degree(u,x)!==nothing
generalized_binomial(u,x) = generalized_binomial_without_simplify(_simplify(u;expand=true),x)
function binomial_without_simplify(xs...)
    isbinomial_without_simplify(xs...)
end

# if u is an expression equivalent to a+b*x^n+c*x^(2n) with a,b,n non zero constants,
# b and n != 0, returns n

function trinomial_degree(u, x)
    f(p) = !contains_var(p, x) # f stands for free of x
    pat, rhs = :((~a::f) + (~!b::f)*x^(~!n::f) + (~!c::f)*x^(~n2::f)) => :(~)
    for σ ∈ _eachmatch(pat, u)
        (f(σ[:a]) &&
         f(σ[:b]) &&
         f(σ[:n]) &&
         f(σ[:c]) &&
         f(σ[:n2])) || continue

        n, n2 = σ[:n], σ[:n2]
        eq(n*2,n2) && return n
        eq(n2,2*n2) && return n2
    end
    return nothing
end


trinomial_without_simplify(u, x) = trinomial_degree(u,x) !== nothing

trinomial(u, x) = trinomial_without_simplify(_simplify(u; expand = true),x)

trinomial(u::Vector,x) = all(trinomial(e,x) for e in u)

# if u is an expression equivalent to a*x^q + b*x^n + c*x^(2*n-q) where n!=0, q!=0, b!=0 and c!=0, returns n-q
function generalized_trinomial_degree(u, x)
    #f(p) = !contains_var(p, x) # f stands for free of x
    #result = (@rule (~a::f)*x^(~q::f) + (~!b::f)*x^(~!n::f) + (~!c::f)*x^(~n2::f)=> ~)(u)
    #result===nothing && return nothing
    𝑥 = Symbol(x)
    pat = :((~a)*$𝑥^(~q) + (~!b)*$𝑥^(~!n) + (~!c)*$𝑥^(~n2))
    for σ ∈ _eachmatch(pat, u)
        # TODO all these cases are for oooomm problem
        q, n, n2,a,b = σ[:q], σ[:n], σ[:n2], σ[:a], σ[:b]
        q,n,n2 = unwrap_const.((q,n,n2))
        !contains_var(q,n,n2,a,b,x) || continue
        2*n-q == n2 && return n-q
        2*q-n == n2 && return q-n
        2*n2-q == n && return n2-q
        2*q-n2 == n && return q-n2
        2*n-n2 == q && return n-n2
        2*n2-n == q && return n2-n
    end
    return nothing
end


# if u is an expression equivalent to a+bx^n with a,b,n constants,
# b and n != 0, returns true
generalized_trinomial_without_simplify(u, x) = generalized_trinomial_degree(u,x) !== nothing

generalized_trinomial(u, x) = generalized_trinomial_without_simplify(_simplify(u; expand = true),x)

generalized_trinomial(u::Vector,x) = all(generalized_trinomial(e,x) for e in u)

# If u is a monomial in x (either b(x^m) or (bx)^m), monomial(u,x) returns the degree of u in x; else it returns nothing.
function monomial(u, x)
    !is_symbolic(u) && return 0
    𝑥 = Symbol(x)
    for σ ∈ _eachmatch(:((~!b)*$𝑥^(~!m)), u)
        contains_var(σ[:b], x) && return nothing
        m = σ[:m]
        igt(m,0) && return unwrap_const(m)
    end
    for σ ∈ _eachmatch(:(((~!b)*$𝑥)^(~!m)), u)
        contains_var(σ[:b], x) && return false
        m = σ[:m]
        igt(m, 0) && return unwrap_const(m)
    end
    return nothing
end



# quadratic(u,x) returns True iff u is a polynomial of degree 2 and not a monomial of the form x^2
function quadratic(u,x)
   poly_degree(u,x)==2 && !(monomial(u,x)==2)
end


# returns True iff u matches patterns of the form a+b x+c x^2 or a+c x^2 where a, b and c are free of x.
function quadratic_without_simplify(u,x)

    pat = :((~!a) + (~!b)*x + (~!c)*x^2)
    ret = false
    for σ ∈ _eachmatch(pat, u)
        contains_var(getindex.((σ,), (:a,:b,:c))..., x) && continue
        ret = true
        break
    end

    ret1 = false
    pat = :((~!a) + (~!c)*x^2)
    for σ ∈ _eachmatch(pat, u)
        contains_var(getindex.((σ,), (:a,:c))..., x) && continue
        ret1 = true
        break
    end

    return ret || ret1
end

#=
function quadratic_without_simplify(u,x)
    f(p) = !contains_var(p, x) # f stands for free of x
    case1 = @rule (~!a::f) + (~!b::f)*x + (~!c::f)*x^2 => 1
    case2 = @rule (~!a::f) + (~!c::f)*x^2 => 1
    (case1(u) !== nothing || case2(u) !== nothing) && return true
    return false
end
=#


# If u is a polynomial in x, Poly[u,x] returns True; else it returns False.
# If u is a polynomial in x of degree n, Poly[u,x,n] returns True; else it returns False.
poly(u, x) = is_polynomial(u,x)
poly(x) = Base.Fix2(poly, x)

#=
function poly(u, x)
    # could have been implemented as poly(u, x) = poly_degree(u, x) !== nothing but this is more efficient
    x = Symbolics.unwrap(x)
    u = Symbolics.unwrap(u)

    u = expand(u)

    # if u is a sum call monomial on each term
    !SymbolicUtils.iscall(u) && return true
    issum(u) && return all(monomial(t, x)!==nothing for t in SymbolicUtils.arguments(u))
    return monomial(u, x)!==nothing
end
=#
function poly(u, x, n)
    poly_degree(u, x) == n
end


function poly_coefficients(p,x)
    n = poly_degree(p,x)
    isnothing(n) && throw("first argument is not a polynomial")
    cs, _ = is_Πₙ(p,x,n)
    return cs
end
#=
function poly_coefficients(p, x)
    deg = poly_degree(p, x)
    deg===nothing && throw("first argument is not a polynomial")
    p = expand(p)
    coeffs = Num[]
    for i in 0:deg
        push!(coeffs, Symbolics.coeff(p, x^i))
    end
    return coeffs
end
=#

# gives the quotient of p / q, treated as polynomials in x, with any remainder dropped
function poly_quotient(p, q, x)
    p = unwrap(p)
    q = unwrap(q)
    x = unwrap(x)

    deg_p = poly_degree(p, x)
    deg_q = poly_degree(q, x)

    (deg_p === nothing || deg_q === nothing) && throw("poly_quotient called with non-polynomials")

    # find coefficients
    p_coeffs = poly_coefficients(p, x)
    q_coeffs = poly_coefficients(q, x)

    # Guard against division by the zero polynomial
    if all(eq(c, 0) for c in q_coeffs)
        throw("poly_quotient division by zero polynomial")
    end

    # If degree of numerator is smaller, quotient is zero
    if deg_p < deg_q
        return 0
    end

    # Perform long division on coefficient arrays (ascending powers)
    # r_coeffs will be destructively updated to track the remainder during division
    r_coeffs = copy(p_coeffs)
    quotient_len = deg_p - deg_q + 1
    quotient_coeffs = Any[zero(first(p_coeffs)) for _ in 1:quotient_len]

    q_lead = q_coeffs[deg_q + 1]
    eq(q_lead, 0) && throw("poly_quotient invalid divisor leading coefficient is zero")

    # Work from highest degree down to 0
    for k in reverse(0:(deg_p - deg_q))
        # current leading term in remainder corresponding to x^(deg_q + k)
        rc = r_coeffs[deg_q + k + 1]
        # If rc is zero, this step contributes nothing
        if !eq(rc, 0)
            t = rc / q_lead
            quotient_coeffs[k + 1] = t
            # Subtract t * x^k * q(x) from remainder
            for i in 0:deg_q
                r_coeffs[i + k + 1] = _simplify(r_coeffs[i + k + 1] - t * q_coeffs[i + 1])
            end
        end
    end

    # Build quotient polynomial expression from coefficients
    quotient = zero(p)
    for i in 0:(quotient_len - 1)
        c = quotient_coeffs[i + 1]
        # Drop symbolic zeros
        if !eq(c, 0)
            quotient += c * x^i
        end
    end
    return _simplify(quotient)
end


# gives the remainder of p and q, treated as polynomials in x
function poly_remainder(p, q, x)
    p = unwrap(p)
    q = unwrap(q)
    x = unwrap(x)

    deg_p = poly_degree(p, x)
    deg_q = poly_degree(q, x)

    (deg_p === nothing || deg_q === nothing) && throw("poly_remainder called with non-polynomials")

    # find coefficients
    p_coeffs = poly_coefficients(p, x)
    q_coeffs = poly_coefficients(q, x)

    # Guard against division by the zero polynomial
    if all(eq(c, 0) for c in q_coeffs)
        throw("poly_remainder division by zero polynomial")
    end

    # If degree of numerator is smaller, remainder is p itself
    if deg_p < deg_q
        return p
    end

    # Long division to compute remainder
    r_coeffs = copy(p_coeffs)

    q_lead = q_coeffs[deg_q + 1]
    eq(q_lead, 0) && throw("poly_remainder invalid divisor leading coefficient is zero")
    for k in reverse(0:(deg_p - deg_q))
        rc = r_coeffs[deg_q + k + 1]
        if !eq(rc, 0)
            t = rc / q_lead
            for i in 0:deg_q
                r_coeffs[i + k + 1] = _simplify(r_coeffs[i + k + 1] - t * q_coeffs[i + 1])
            end
        end
    end

    # Build remainder polynomial expression from r_coeffs (degree < deg_q)
    remainder = zero(p)
    # Degree of remainder is at most deg_q-1; but symbolic cancellation may lower it further
    max_i = min(length(r_coeffs), deg_q)
    for i in 0:(max_i - 1)
        c = r_coeffs[i + 1]
        if !eq(c, 0)
            remainder += c * x^i
        end
    end
    return _simplify(remainder)
end



# If u and v are polynomials in x, PolynomialDivide[u,v,x] returns the polynomial quotient of u and v plus the polynomial remainder divided by v.
function polynomial_divide(u, v, x)
    u = unwrap(u)
    v = unwrap(v)
    x = unwrap(x)

    deg_u = poly_degree(u, x)
    deg_v = poly_degree(v, x)

    (deg_u === nothing || deg_v === nothing) && throw("polynomial_divide called with non-polynomials")

    quotient = poly_quotient(u, v, x)
    remainder = poly_remainder(u, v, x)

    return quotient + remainder / v
end

# gives the maximum power with which form appears in the expanded form of expr.
# TODO for now works only with polynomials
function exponent_of(expr, form)
    res = poly_degree(expr, form)
    if res === nothing
        throw("exponent_of is implemented only for polynomials in form")
    end
    return res
end

function perfect_square(expr)
    expr = unwrap(expr)
    !s(expr) && return isequal(sqrt(expr), floor(sqrt(expr)))
    !iscall(expr) && return false
    (operation(expr) === ^) && iseven(arguments(expr)[2]) && return true
    return false
end

# puts terms in a sum over a common denominator, and cancels factors in the result
# together(a/b + c/d) = (a*d + b*c) / (b*d)
function together(expr)
    expr = unwrap(expr)
    !iscall(expr) && return expr
    !is_operation(+)(expr) && return expr

    # Get the common denominator
    terms = arguments(expr)
    denominators = [ext_den(term) for term in terms]
    common_denominator = reduce(*, denominators)

    # Combine the numerators
    numerators = [ext_num(term) * (common_denominator // ext_den(term)) for term in terms]

    _simplify(sum(numerators) // common_denominator)
end

# LinearPairQ[u,v,x] returns True iff u and v are linear not equal x but u/v is a constant wrt x.
function linear_pair(u,v,x)
    linear(u,x) && linear(v,x) &&
    !eq(u, x) && !eq(v, x) &&
    #eq(Symbolics.coeff(u,x) * Symbolics.coeff(v,1) - Symbolics.coeff(u,1) * Symbolics.coeff(v,x), 0)
    eq(ext_coeff(u,x,1) * ext_coeff(v,x,0) - ext_coeff(u,x,0) * ext_coeff(v,x,1), 0)
end

# returns true if u is a algebraic function of x
function algebraic_function(u, x)
    !iscall(u) && return true
    o = operation(u)
    ar = arguments(u)
    o in [*, +, /] && return all(algebraic_function(a,x) for a in ar)

    (o===^) && return algebraic_function(ar[1],x) && isrational(ar[2]) # an alternative can be !contains_var(ar[2],x) instead of isrational(ar[2])

    (o===sqrt) && return algebraic_function(arguments(u)[1], x)
    return false
end

#function algebraic_function(u::Num, x::Num)
#    u = unwrap(u)
#    x = unwrap(x)

# returns true if u is a rational function of x
function rational_function(u, x)
    !iscall(u) && return true
    o = Symbol(operation(u))
    ar = arguments(u)
    o in (:+,:*,:/) && return all(rational_function(a,x) for a in ar)
    (o == :^) && return ext_isinteger(ar[2]) && rational_function(ar[1],x)
    # non integrer powers make it a non rational function
    return false
end

#function rational_function(u::Num, x::Num)
#    u = unwrap(u)
#    x = unwrap(x)
#    rational_function(u, x)
#end

# FunctionOfExponentialQ[u,x] returns True iff u is a function of F^v where F is a constant and v is linear in x, and such an exponential explicitly occurs in u
function function_of_exponential(u, x)
    !iscall(u) && return false
    o = operation(u)
    ar = arguments(u)

    eq_op(o, exp) && return linear(ar[1], x)
    eq_op(o, ^) && return isa(ar[1], Number) && linear(ar[2], x)
    (o in (+,:+, *,:*, /, :/)) && return any(function_of_exponential(a,x) for a in ar)
    return false
    #(o === exp) && return linear(ar[1], x)
    #(o === ^) && return isa(ar[1], Number) && linear(ar[2], x)
    #(o in [+,*,/]) && return any(function_of_exponential(a,x) for a in ar)
    #return false
end

#function_of_exponential(u::Num, x::Num) = function_of_exponential(unwrap(u), Symbolics.unwrap(x))

# returns the product of the factors of u free of x
function free_factors(u, x)
    u = unwrap(u)
    x = unwrap(x)
    isprod(u) && return prod(contains_var(f, x) ? 1 : f for f in arguments(u))
    return contains_var(u, x) ? 1 : u
end

# returns the product of the factors of u not free of x
function nonfree_factors(u, x)
    u = unwrap(u)
    x = unwrap(x)
    isprod(u) && return prod(contains_var(f, x) ? f : 1 for f in arguments(u))
    return contains_var(u, x) ? 1 : u
end

# returns the product of the addends of u free of x
function free_addednds(u, x)
    u = unwrap(u)
    x = unwrap(x)
    issum(u) && return sum(contains_var(a, x) ? 0 : a for a in arguments(u))
    return contains_var(u, x) ? 1 : u
end

# returns the product of the addends of u not free of x
function nonfree_addends(u, x)
    u = unwrap(u)
    x = unwrap(x)
    issum(u) && return prod(contains_var(a, x) ? a : 0 for a in arguments(u))
    return contains_var(u, x) ? 1 : u
end

## XXXX-------XXXX
# TODO are all this unwrap needed?

## from one_var_predicates
P_igt_x_plus_half(x::Any)   = igt(x + 1/2, 0)::Bool
P_ilt_x_plus_3half(x::Any)  = ilt(x + 3/2, 0)::Bool
P_ilt_x_neg1(x::Any)        = ilt(x, -1)::Bool
P_lt_x_neg1(x::Any)         = lt(x, -1)::Bool
P_ilt_x_0(x::Any)           = ilt(x, 0)::Bool
P_lt_neg1_x_0(x::Any)       = lt(-1, x, 0)::Bool
P_gt_0(x::Any)              = gt(x, 0)::Bool
P_lt_x_0(x::Any)            = lt(x, 0)::Bool
P_le_neg1_x_0(x::Any)       = le(-1, x, 0)::Bool

## Extras
function f11372(pq, x)
    pat = :((~u)*$(Symbol(x))^(~m::ext_isinteger) )
    return !isnothing(_match(pat, pq))
end
