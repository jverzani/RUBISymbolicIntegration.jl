const T_START = time()
using SymbolicUtils, SymJ
import RUBISymbolicIntegration as R
SymJ.@syms w x y z t d n m a b c h k l p q r s alpha epsilon e mc A B H K b1 c1
const VAR = Dict{Symbol,Any}(v => getfield(Main, v) for v in (:w, :x, :y, :z, :t, :d, :n, :m, :a, :b, :c, :h, :k, :l, :p, :q, :r, :s, :alpha, :epsilon, :e, :mc, :A, :B, :H, :K, :b1, :c1))
INTEGRATE(f, x) = R.integrate(f, x)
SOLVED(out) = !R.contains_int(out) && !occursin("Cannot", string(out))
# evaluate by substituting each variable, then `N`; a function with no
# numeric method (such as `Fresnels`) throws, so is not a number here
function EVAL(ex, vals)
    isa(ex, Sym) || return isa(ex, Number) ? complex(ex) : nothing
    u = try
        N(subs(ex, (VAR[v] => p for (v, p) in vals)...))
    catch
        return nothing
    end
    isa(u, Number) && !isa(u, Sym) ? complex(u) : nothing
end
include("core.jl")
