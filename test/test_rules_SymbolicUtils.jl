module SymbolicUtilsRulesTest

using Symbolics # loads this package's extension for SymbolicUtils terms
using Symbolics.SymbolicUtils: @syms
# real, as for `Symbolics.@variables`; registered functions such as `reli` need it
@syms w::Real x::Real y::Real z::Real t::Real d::Real n::Real m::Real a::Real b::Real c::Real h::Real k::Real l::Real p::Real q::Real r::Real s::Real alpha::Real epsilon::Real e::Real mc::Real A::Real B::Real H::Real K::Real b1::Real c1::Real
const I = im

include("rules_test_common.jl")
include("problems_apostol.jl")

test_problems("apostol (SymbolicUtils)", apostol; min_passed = 128)

end
