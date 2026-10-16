const T_START = time()
using Symbolics, SymbolicUtils
using SymbolicIntegration
@variables w x y z t d n m a b c h k l p q r s alpha epsilon e mc A B H K b1 c1
const VAR = Dict{Symbol,Any}(v => getfield(Main, v) for v in (:w, :x, :y, :z, :t, :d, :n, :m, :a, :b, :c, :h, :k, :l, :p, :q, :r, :s, :alpha, :epsilon, :e, :mc, :A, :B, :H, :K, :b1, :c1))
INTEGRATE(f, x) = integrate(f, x, RischMethod())
SOLVED(out) = !occursin("∫", string(out))
TOSU(ex) = Symbolics.unwrap(ex)
include("core.jl")
