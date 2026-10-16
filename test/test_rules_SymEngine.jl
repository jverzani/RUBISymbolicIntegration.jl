module SymEngineRulesTest

using SymEngine
@vars w x y z t d n m a b c h k l p q r s alpha epsilon e mc A B H K b1 c1
const I = SymEngine.IM

include("rules_test_common.jl")
include("problems_apostol.jl")

test_problems("apostol (SymEngine)", apostol; min_passed = 124)

end
