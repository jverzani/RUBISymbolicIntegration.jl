const T_START = time()
using SymbolicUtils, SimpleExpressions
import RUBISymbolicIntegration as R
SimpleExpressions.@symbolic_variables w x y z t d n m a b c h k l p q r s alpha epsilon e mc A B H K b1 c1
const VAR = Dict{Symbol,Any}(v => getfield(Main, v) for v in (:w, :x, :y, :z, :t, :d, :n, :m, :a, :b, :c, :h, :k, :l, :p, :q, :r, :s, :alpha, :epsilon, :e, :mc, :A, :B, :H, :K, :b1, :c1))
INTEGRATE(f, x) = R.integrate(f, x)
SOLVED(out) = !R.contains_int(out) && !occursin("Cannot", string(out))
# evaluate by replacing each variable, then calling the constant expression
function EVAL(ex, vals)
    isa(ex, Number) && return complex(ex)
    e = replace(ex, (VAR[v] => p for (v, p) in vals)...)
    u = R.unwrap_const(e)
    isa(u, Number) ? complex(u) : nothing
end
include("core.jl")
