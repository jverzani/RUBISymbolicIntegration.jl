using Test
using Random
using RUBISymbolicIntegration

# integrate the apostol problems with each symbolic package
include("test_rules_SymEngine.jl")
#include("test_rules_SimpleExpressions.jl")  # too slow; uncomment to test
include("test_rules_SymbolicUtils.jl")
