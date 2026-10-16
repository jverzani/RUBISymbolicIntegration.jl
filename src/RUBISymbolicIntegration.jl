module RUBISymbolicIntegration

using TermInterface
using SpecialFunctions
using PolyLog: PolyLog, reli # Liₙ(z) is `reli(n, z)` in the rules
export integrate

# matching
using CommutativePatternMatching
import CommutativePatternMatching: Rule, _eachmatch, _match, _rewrite, unwrap_const

include("general.jl")
include("interface.jl")

# applying rules
include("frontend.jl")
include("polynomial-defns.jl")
include("rules-utility-functions.jl")

# rules
# using hacked version; could regenerate with hacked
# translator_of_rules.jl
# Loaded last: guards and right-hand sides refer to the functions above
include("rules_loader.jl")

end
