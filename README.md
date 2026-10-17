# RUBISymbolicIntegration

[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://jverzani.github.io/RUBISymbolicIntegration.jl/stable)
[![Development documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://jverzani.github.io/RUBISymbolicIntegration.jl/dev)
[![Test workflow status](https://github.com/jverzani/RUBISymbolicIntegration.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/jverzani/RUBISymbolicIntegration.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jverzani/RUBISymbolicIntegration.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/jverzani/RUBISymbolicIntegration.jl)
[![Docs workflow Status](https://github.com/jverzani/RUBISymbolicIntegration.jl/actions/workflows/Docs.yml/badge.svg?branch=main)](https://github.com/jverzani/RUBISymbolicIntegration.jl/actions/workflows/Docs.yml?query=branch%3Amain)
[![BestieTemplate](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/JuliaBesties/BestieTemplate.jl/main/docs/src/assets/badge.json)](https://github.com/JuliaBesties/BestieTemplate.jl)
[![Apostol, verified of 175: this package 125, SymbolicIntegration rules 117](https://img.shields.io/badge/apostol%2C%20verified%20of%20175-this%20package%20125%20%C2%B7%20SymbolicIntegration%20rules%20117-2f8a4c)](https://htmlpreview.github.io/?https://github.com/jverzani/RUBISymbolicIntegration.jl/blob/main/benchmark/apostol/results/apostol_comparison.html)

This is part of [SymbolicIntegration.jl](https://github.com/JuliaSymbolics/SymbolicIntegration.jl/) repackaged to allow symbolic packages that conform with the [TermInterface.jl] contract, like [SymEngine], to utilize the rules-based integration approach.

[RUBI](https://rulebasedintegration.org/) is a rule-based approach to integrating indefinite integrals:

> By systematically applying its extensive, coherent collection of symbolic integration rules, Rubi is able to find the optimal antiderivative of large classes of mathematical expressions. Also Rubi can show the rules and intermediate steps it uses to integrate an expression, making the system a great tool for both learning and doing mathematics.


The main function is `integrate(f, dx)` where `f` is the expression to integrate and `dx` the variable to integrate with respect to.

The apostol badge compares this package, with [SymbolicUtils] terms, to the rule-based method of SymbolicIntegration.jl, with [Symbolics] terms: the number of the 175 problems from Apostol's *Calculus* each integrates with an answer that checks out numerically. The [comparison](https://htmlpreview.github.io/?https://github.com/jverzani/RUBISymbolicIntegration.jl/blob/main/benchmark/apostol/results/apostol_comparison.html) also has this package with [SymEngine] terms (115 verified) and with [SimpleExpressions] terms (133 verified); see `benchmark/apostol/README.md` to rerun it.

[TermInterface.jl]: https://github.com/JuliaSymbolics/TermInterface.jl
[SymEngine]: https://github.com/symengine/SymEngine.jl
[SymbolicUtils]: https://github.com/JuliaSymbolics/SymbolicUtils.jl
[Symbolics]: https://github.com/JuliaSymbolics/Symbolics.jl
[SimpleExpressions]: https://github.com/jverzani/SimpleExpressions.jl
