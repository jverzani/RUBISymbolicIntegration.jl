module RUBISymbolicIntegration

using TermInterface
using SpecialFunctions
using PolyLog: PolyLog, reli # Liₙ(z) is `reli(n, z)` in the rules
using HypergeometricFunctions: HypergeometricFunctions, _₂F₁ # ₂F₁(a, b; c; z) is `_₂F₁(a, b, c, z)`
export integrate

# matching
using CommutativePatternMatching
import CommutativePatternMatching: Rule, _eachmatch, _match, _rewrite, unwrap_const

include("general.jl")
include("interface.jl")

# applying rules
include("string_manipulator_helpers.jl") # `pretty_print_rule` for `verbose`
include("frontend.jl")
include("polynomial-defns.jl")
include("rules-utility-functions.jl")

# rules
# using hacked version; could regenerate with hacked
# translator_of_rules.jl
# Loaded last: guards and right-hand sides refer to the functions above
include("rules_loader.jl")

end
