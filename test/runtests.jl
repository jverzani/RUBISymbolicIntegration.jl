using Test
using Random
using RUBISymbolicIntegration

include("test-matching.jl")

# integrate the apostol problems with each symbolic package
include("test_rules_SymEngine.jl")
include("test_rules_SimpleExpressions.jl")
include("test_rules_SymbolicUtils.jl")
