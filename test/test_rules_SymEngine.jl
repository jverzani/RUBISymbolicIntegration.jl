module SymEngineRulesTest

using SymEngine
@vars w x y z t d n m a b c h k l p q r s alpha epsilon e mc A B H K b1 c1
const I = SymEngine.IM

include("rules_test_common.jl")
include("problems_apostol.jl")

test_problems("apostol (SymEngine)", apostol; min_passed = 128)

@testset "verbose" begin
    integrate = RUBISymbolicIntegration.integrate
    out = mktemp() do path, io
        F = redirect_stdout(io) do
            integrate(1 / (x * log(x)), x; verbose = true)
        end
        close(io)
        @test F == log(log(x))
        read(path, String)
    end
    # the substitution rule, with the integral it does in turn inside its step
    @test occursin("┌ rule 3_1_2_2 on ∫(1/(x*log(x)), x)", out)
    @test occursin("│ ┌ rule 1_1_1_1_1 on ∫(x^(-1), x)", out)
    @test occursin("└ gives log(log(x))", out)
    # the setting does not outlast the call
    quiet = mktemp() do path, io
        redirect_stdout(() -> integrate(1 / (x * log(x)), x), io)
        close(io)
        read(path, String)
    end
    @test isempty(quiet)
end

end
