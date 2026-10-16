# RUBISymbolicIntegration

[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://jverzani.github.io/RUBISymbolicIntegration.jl/stable)
[![Development documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://jverzani.github.io/RUBISymbolicIntegration.jl/dev)
[![Test workflow status](https://github.com/jverzani/RUBISymbolicIntegration.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/jverzani/RUBISymbolicIntegration.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jverzani/RUBISymbolicIntegration.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/jverzani/RUBISymbolicIntegration.jl)
[![Docs workflow Status](https://github.com/jverzani/RUBISymbolicIntegration.jl/actions/workflows/Docs.yml/badge.svg?branch=main)](https://github.com/jverzani/RUBISymbolicIntegration.jl/actions/workflows/Docs.yml?query=branch%3Amain)
[![BestieTemplate](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/JuliaBesties/BestieTemplate.jl/main/docs/src/assets/badge.json)](https://github.com/JuliaBesties/BestieTemplate.jl)
[![Apostol, verified of 175: this package 108, SymbolicIntegration rules 117](https://img.shields.io/badge/apostol%2C%20verified%20of%20175-this%20package%20108%20%C2%B7%20SymbolicIntegration%20rules%20117-2a4f8f)](https://htmlpreview.github.io/?https://github.com/jverzani/RUBISymbolicIntegration.jl/blob/main/benchmark/apostol/results/apostol_comparison.html)

This is part of [SymbolicIntegration.jl](https://github.com/JuliaSymbolics/SymbolicIntegration.jl/) repackaged to allow SymEngine and other symbolic representations to utilize the rules-based integration approach.

[RUBI](https://rulebasedintegration.org/) is a rule-based approach to integrating indefinite integrals:

> By systematically applying its extensive, coherent collection of symbolic integration rules, Rubi is able to find the optimal antiderivative of large classes of mathematical expressions. Also Rubi can show the rules and intermediate steps it uses to integrate an expression, making the system a great tool for both learning and doing mathematics.


The main function is `integrate(f, dx)` where `f` is the expression to integrate and `dx` the variable to integrate with respect to.

The apostol badge compares this package, with SymbolicUtils terms, to the rule-based method of SymbolicIntegration.jl, with Symbolics terms: the number of the 175 problems from Apostol's *Calculus* each integrates with an answer that checks out numerically. The [comparison](https://htmlpreview.github.io/?https://github.com/jverzani/RUBISymbolicIntegration.jl/blob/main/benchmark/apostol/results/apostol_comparison.html) also has RischIntegrate, SymbolicIntegration.jl's Risch method, and this package with SimpleExpressions terms (127 verified); see `benchmark/apostol/README.md` to rerun it.
