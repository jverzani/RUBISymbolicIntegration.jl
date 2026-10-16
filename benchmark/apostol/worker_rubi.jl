const T_START = time()
using Symbolics, SymbolicUtils
using SymbolicUtils: @syms
import RUBISymbolicIntegration as R
@syms w::Real x::Real y::Real z::Real t::Real d::Real n::Real m::Real a::Real b::Real c::Real h::Real k::Real l::Real p::Real q::Real r::Real s::Real alpha::Real epsilon::Real e::Real mc::Real A::Real B::Real H::Real K::Real b1::Real c1::Real
const VAR = Dict{Symbol,Any}(v => getfield(Main, v) for v in (:w, :x, :y, :z, :t, :d, :n, :m, :a, :b, :c, :h, :k, :l, :p, :q, :r, :s, :alpha, :epsilon, :e, :mc, :A, :B, :H, :K, :b1, :c1))
INTEGRATE(f, x) = R.integrate(f, x)
SOLVED(out) = !R.contains_int(out) && !occursin("Cannot", string(out))
TOSU(ex) = Symbolics.unwrap(ex)
include("core.jl")
