# RUBISymbolicIntegraion

[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://jverzani.github.io/RUBISymbolicIntegraion.jl/stable)
[![Development documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://jverzani.github.io/RUBISymbolicIntegraion.jl/dev)
[![Test workflow status](https://github.com/jverzani/RUBISymbolicIntegraion.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/jverzani/RUBISymbolicIntegraion.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jverzani/RUBISymbolicIntegraion.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/jverzani/RUBISymbolicIntegraion.jl)
[![Docs workflow Status](https://github.com/jverzani/RUBISymbolicIntegraion.jl/actions/workflows/Docs.yml/badge.svg?branch=main)](https://github.com/jverzani/RUBISymbolicIntegraion.jl/actions/workflows/Docs.yml?query=branch%3Amain)
[![BestieTemplate](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/JuliaBesties/BestieTemplate.jl/main/docs/src/assets/badge.json)](https://github.com/JuliaBesties/BestieTemplate.jl)

This is part of [SymbolicIntegration.jl](https://github.com/JuliaSymbolics/SymbolicIntegration.jl/) repackaged to allow SymEngine and other symbolic represenations to utilize the rules-based integration approach.

[RUBI](https://rulebasedintegration.org/) is a rule-based approach to integrating indefinite integrals:

> By systematically applying its extensive, coherent collection of symbolic integration rules, Rubi is able to find the optimal antiderivative of large classes of mathematical expressions. Also Rubi can show the rules and intermediate steps it uses to integrate an expression, making the system a great tool for both learning and doing mathematics.


The main function is `integrate(f, dx)` where `f` is the expression to integrate and `dx` the variable to integrate with respect to.
