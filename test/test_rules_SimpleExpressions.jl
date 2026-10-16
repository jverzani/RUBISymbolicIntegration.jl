module SimpleExpressionsRulesTest

using SimpleExpressions
SimpleExpressions.@symbolic_variables w x y z t d n m a b c h k l p q r s alpha epsilon e mc A B H K b1 c1
const I = SimpleExpressions.SymbolicNumber(im)

include("rules_test_common.jl")
include("problems_apostol.jl")

test_problems("apostol (SimpleExpressions)", apostol; min_passed = 127)

end
