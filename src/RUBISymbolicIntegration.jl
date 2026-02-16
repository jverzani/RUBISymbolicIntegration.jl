module RUBISymbolicIntegration

using TermInterface
using SpecialFunctions
#using MatchPy
#using SymbolicIntegrationRules
export integrate

# matching
using Combinatorics: permutations, combinations
include("utils.jl")
include("rule2a.jl")

# rules
# using hacked version; could regenerate with hacked
# translator_of_rules.jl
include("general.jl")
include("rules_loader.jl")


# applying rules
include("frontend.jl")
include("polynomial-defns.jl")
include("rules-utility-functions.jl")
end
