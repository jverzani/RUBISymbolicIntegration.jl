```@meta
CurrentModule = RUBISymbolicIntegration
```

# RUBISymbolicIntegration

Documentation for [RUBISymbolicIntegration](https://github.com/jverzani/RUBISymbolicIntegration.jl).

This is basically the rules-based part of [SymbolicIntegration](https://github.com/JuliaSymbolics/SymbolicIntegration.jl).

The main function is `integrate(f, x)`, which returns an antiderivative of `f`
with respect to `x`. The rules are those of [Rubi](https://rulebasedintegration.org/).
Any symbolic type implementing [TermInterface.jl](https://github.com/JuliaSymbolics/TermInterface.jl)
can be used once an extension for it is loaded; extensions are included for
SymEngine, SymbolicUtils (through Symbolics) and SimpleExpressions.

## Examples with SymEngine

Load the package and [SymEngine](https://github.com/symengine/SymEngine.jl),
and create some symbolic variables:

```@example symengine
using RUBISymbolicIntegration, SymEngine
@vars x a b n
nothing # hide
```

### Polynomials and linear substitutions

```@example symengine
integrate(3x^2 + 2x + 1, x)
```

```@example symengine
integrate((2 + 3x)^5, x)
```

```@example symengine
integrate(1 / (2 + 3x), x)
```

### Symbolic parameters

Parameters may appear in the integrand. A rule applies only when its
conditions hold; for ``(a + bx)^n`` the rule requires ``n \ne -1``, which a
symbolic `n` is taken to satisfy:

```@example symengine
integrate((a + b*x)^n, x)
```

```@example symengine
integrate(x^n * log(x), x)
```

### Exponentials, logarithms and trigonometric functions

Integration by parts:

```@example symengine
integrate(x * exp(x), x)
```

```@example symengine
integrate(x^2 * sin(x), x)
```

```@example symengine
integrate(atan(x), x)
```

Substitutions:

```@example symengine
integrate(log(x) / x, x)
```

```@example symengine
integrate(1 / (x * log(x)), x)
```

```@example symengine
integrate(x / sqrt(1 + x^2), x)
```

### Rational functions

```@example symengine
integrate(1 / ((x - 1) * (x - 2)), x)
```

```@example symengine
integrate((2x + 3) / (x^2 + 3x + 2), x)
```

```@example symengine
integrate(1 / (x^3 - x), x)
```

### Special functions

Some antiderivatives are not elementary. The answer then uses special
functions: the sine integral ``\operatorname{Si}(x)``, the exponential
integral ``\operatorname{Ei}(x)`` and the dilogarithm
``\operatorname{Li}_2(x)``:

```@example symengine
integrate(sin(x) / x, x)
```

```@example symengine
integrate(exp(x) / x, x)
```

```@example symengine
integrate(log(1 + x) / x, x)
```

With SymEngine these stay unevaluated functions, such as `Sinint` and
`reli` (PolyLog.jl's ``\operatorname{Li}_n``). With SimpleExpressions or
Symbolics they are the functions of SpecialFunctions.jl, PolyLog.jl and
HypergeometricFunctions.jl, so such an answer can be evaluated numerically.

### Checking an answer

Differentiate the antiderivative and compare it with the integrand:

```@example symengine
f = x^2 * sin(x)
F = integrate(f, x)
expand(diff(F, x) - f)
```

SymEngine does not always reduce such a difference to `0`, for instance when
fractions would need combining. Checking at a value works in any case:

```@example symengine
f = 1 / (x^3 - x)
F = integrate(f, x)
N(subs(diff(F, x) - f, x => 3))
```

### When no rule applies

If no rule applies, the integral is returned unevaluated:

```@example symengine
F = integrate(1 / (a + b * cos(x)), x)
```

```@example symengine
RUBISymbolicIntegration.contains_int(F)
```
