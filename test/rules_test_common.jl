# Shared by the `test_rules_*.jl` files. Include it in the test's module
# after defining the variables (`x`, ...) and `I` for the symbolic package;
# then include a file of problems and call `test_problems`.

using Test
using RUBISymbolicIntegration
import RUBISymbolicIntegration: integrate, make_integral, contains_int, ⨸,
    Expinti, Gamma, Elliptic_e, Elliptic_f, Elliptic_pi, Erf, Erfi,
    Sinint, Cosint, hypergeometric2f1, reli, CannotIntegrate, Unintegrable

# Integrate a problem `(integrand, antiderivative, variable, steps)`.
# `:success` means no unevaluated integral is left; the antiderivative is
# not checked.
function run_test(problem)
    f, _, dx, _ = problem
    out = try
        integrate(f, dx)
    catch err
        make_integral(f, dx)
    end
    solved = !contains_int(out) && !contains(string(out), "Cannot")
    return (solved ? :success : :failed, out)
end

# Integrate each problem; at least `min_passed` must be solved
function test_problems(name, problems; min_passed)
    @testset "$name" begin
        results = run_test.(problems)
        passed = count(u -> first(u) == :success, results)
        @info "$name: $passed of $(length(problems)) problems integrated"
        @test passed ≥ min_passed
    end
end
