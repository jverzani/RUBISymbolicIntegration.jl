# Apostol comparison

Rule-based integration of the 175 apostol problems of
`test/problems_apostol.jl`: this package with three term types, and the
rule-based method of SymbolicIntegration.jl.

| Method | Package | Terms |
|---|---|---|
| `rubi_symengine` | RUBISymbolicIntegration (this package), RUBI rules | [SymEngine](https://github.com/symengine/SymEngine.jl) |
| `rubi_symj` | RUBISymbolicIntegration | [SymJ](https://github.com/jverzani/SymJ.jl) |
| `rubi_symbolicutils` | RUBISymbolicIntegration | [SymbolicUtils](https://github.com/JuliaSymbolics/SymbolicUtils.jl) |
| `si_rules` | [SymbolicIntegration](https://github.com/JuliaSymbolics/SymbolicIntegration.jl), `RuleBasedMethod()` | [Symbolics](https://github.com/JuliaSymbolics/Symbolics.jl) |

The result is a page, `results/apostol_comparison.html`, with a summary
(counts and times) and a grid with one row per method, one column per
problem. Selecting a problem shows the integrand and each method's answer.

## Running it

`env_rubi` uses this package from this checkout and the other packages,
including AssociativeCommutativePatternMatching (which now holds the matcher
of CommutativePatternMatching), from the registry. SymJ is not registered
yet, so it comes from the `main` branch of
https://github.com/jverzani/SymJ.jl (a `[sources]` entry in
`env_rubi/Project.toml`). `results/commits.tsv` records which commit of each
was used.

```sh
cd benchmark/apostol
julia --project=env_rubi -e 'using Pkg; Pkg.instantiate()'   # once, or after changing a package
julia --project=env_si -e 'using Pkg; Pkg.instantiate()'
julia run_all.jl            # or `julia run_all.jl 60` for a 60 s limit per problem
```

`run_all.jl` runs the methods one after another, so they do not compete for
the CPU, and then builds the page.

After adding a package to an environment's `Project.toml`, run
`Pkg.resolve()` in that environment before `Pkg.instantiate()`.
Open `results/apostol_comparison.html` in a browser; it is self-contained.

To run or rerun one method, then rebuild the page:

```sh
julia supervise.jl rubi_symbolicutils env_rubi 120
julia build.jl
```

To pick up newer versions, such as a new release of
AssociativeCommutativePatternMatching or SymbolicIntegration, or a new commit
to SymJ's `main`, run
`Pkg.update()` in the environment first, e.g. `julia --project=env_rubi -e 'using Pkg; Pkg.update()'`. The
`Manifest.toml` files are not committed, so a fresh checkout resolves to the
newest compatible versions.

## How it works

| File | Role |
|---|---|
| `problems.jl` | parses (does not evaluate) `test/problems_apostol.jl` into `(integrand, variable)` expressions |
| `worker_*.jl` | one per method: loads the packages, makes the variables, and defines `INTEGRATE`, `SOLVED` and `TOSU` or `EVAL` |
| `core.jl` | shared by the workers: builds each integrand with the worker's variables, integrates, checks, writes a line per problem |
| `supervise.jl` | runs a worker; if one problem takes longer than the limit, kills the process, records a timeout and restarts at the next problem |
| `build.jl`, `template.html` | turn the results into the page |
| `env_rubi`, `env_si` | the two environments: `env_rubi` for this package (with SymEngine, SymJ and SymbolicUtils), `env_si` for SymbolicIntegration |

Each integrand is built from its expression with the worker's own variables:
SymEngine `@vars x ...` for `rubi_symengine`,
SymJ `@syms x ...` for `rubi_symj`,
SymbolicUtils `@syms x::Real ...` for `rubi_symbolicutils`, and Symbolics
`@variables x ...` for `si_rules`. The problems use this package's `⨸` operator
(e.g. `1 ⨸ 2`); each worker defines it as `//` for integers and `/` otherwise, so
every method gets the same input.

What is recorded:

- **Solved**: the method returned a result with no unevaluated `∫` and threw
  nothing; this package's `Cannot…` markers also count as not solved.
- **Verified**: a central difference of the answer at `x = 0.31` and `x = 0.57`
  (every other variable given a fixed value) matches the integrand to 1e-4. Real
  values are tried first, then complex ones if the real evaluation fails.
- **Not checked**: solved, but the answer has a function the term type can not
  evaluate numerically. With SymEngine the special functions (`Expinti`,
  `reli`, `_₂F₁`, ...) stay unevaluated. Such an answer may be wrong.
- **Differs**: solved, but the derivative does not match: a wrong answer.
- **Times**: each method starts cold in a new process. Integration time is the
  sum of the per-problem times, so it includes compiling; load time is loading
  the packages; wall time is everything, restarts included. Times depend on the
  machine and the Julia version, so compare times only within one run.

`results/results_NAME.tsv` has one line per event, tab separated:

| Line | Fields |
|---|---|
| `L` | load time in seconds, first problem of this process (one line per process start) |
| `V` | package name, version (first process only) |
| `S` | problem, start time (used by `supervise.jl` to enforce the limit) |
| `R` | problem, status (`solved`, `unsolved`, `error`, `timeout`, `crash`), check (`verified`, `unverified`, `wrong`, `none`), seconds, the answer or error (first 400 characters) |
| `D` | the worker finished |
| `T` | wall time in seconds, limit in seconds |

`results/commits.tsv` records, when `run_all.jl` ran, the commit of this
package (and whether it had uncommitted changes) and, for a package taken from
GitHub, the commit of the branch used.

## Adding a method

Write `worker_NAME.jl` following the others. Before `include("core.jl")` it
must set `T_START`, load the packages, and define

- `VAR::Dict{Symbol,Any}`: the variables `w x y z t d n m a b c h k l p q r s alpha epsilon e mc A B H K b1 c1`
- `INTEGRATE(f, x)`: the method
- `SOLVED(out)::Bool`: did it return an antiderivative?
- for the numeric check, either `TOSU(ex)`, the answer as a SymbolicUtils term,
  or `EVAL(ex, vals)`, the value of `ex` with each variable `v` replaced by the
  number `vals[v]` (a `Dict{Symbol,Number}`), or `nothing` if it does not
  evaluate to a number. `worker_rubi_symengine.jl` and
  `worker_rubi_symj.jl` define `EVAL`.

Then add it to the loop in `run_all.jl` and to `METHODS` in `build.jl`.

## Updating the page

`build.jl` fills in the numbers, grid, times and versions. The "What stands
out" section is written by hand in `template.html`; check it against the new
results and edit it before publishing.

The package README has a badge comparing the number of apostol problems
verified by `rubi_symbolicutils` and `si_rules` (SymbolicIntegration's
`RuleBasedMethod`, Symbolics), and a sentence that also gives the other two
term types. The badge links to the page at a fixed commit through
rawcdn.githack.com, and the sentence links to it on `main` through
htmlpreview.github.io. It is a static badge: after a run, update the commit
in its link (one that has the new page and is on GitHub) and, if the numbers
changed, them in the badge URL, its alt text and that sentence.

## Things learned along the way

- With SymbolicUtils, `==` on terms returns a symbolic value, so `x ∈ (a, b)`
  or `if x == y` can throw `TypeError: non-boolean ... used in boolean context`.
  Compare with `isequal`. This was the cause of most of this package's errors in
  the first run (in CommutativePatternMatching's `different_powers`).
- SymbolicUtils `@syms x` makes a `Number`-typed variable; functions registered
  with `@register_symbolic` (such as `reli`) expect `Real`, so the workers use
  `@syms x::Real`.
- To evaluate a SymbolicUtils term numerically:
  `SymbolicUtils.unwrap_const(SymbolicUtils.substitute(ex, d; fold = Val(true)))`.
- In zsh, a glob that matches nothing is an error and stops the command
  (e.g. `rm -f results_*.tsv` with no results yet).

## Results so far

Solved (verified) out of 175. Times are on one machine and only comparable
within a run.

| Date | Julia | Change | rubi_symengine | rubi_simpleexpressions | rubi_symbolicutils | si_rules |
|---|---|---|---|---|---|---|
| 2026-10-17 | 1.13.0 | only rule-based methods; SymEngine added | 128 (115), 13 not checked | 133 (133) | 128 (125) | 124 (117), 4 wrong |
| 2026-10-17 | 1.13.0 | CPM `nospecialize` branch (`82ea70a`): the matcher is not specialized on the subject's type. SimpleExpressions integration 456 s → 273 s (wall 564 s → 358 s); the others unchanged | 128 (115) | 133 (133) | 128 (125) | 124 (117) |
| 2026-10-18 | 1.13.0 | released packages: AssociativeCommutativePatternMatching 1.1.1 (CPM's matcher, with compiled patterns) and SimpleExpressions 1.4.0. Integration time: SimpleExpressions 273 s → 237 s, SymbolicUtils 68 s → 60 s, SymEngine 34 s → 33 s; no answer changed | 128 (115) | 133 (133) | 128 (125) | 124 (117) |

From 2026-10-23 SymJ (unregistered, `main` of
https://github.com/jverzani/SymJ.jl) replaces SimpleExpressions:

| Date | Julia | Change | rubi_symengine | rubi_symj | rubi_symbolicutils | si_rules |
|---|---|---|---|---|---|---|
| 2026-10-23 | 1.13.0 | SymJ extension added (SymJ `787277f`); SimpleExpressions no longer run. Integration time: SymJ 35.5 s, SymEngine 32.8 s, SymbolicUtils 60.3 s, SymbolicIntegration 28.1 s. SymJ's one "differs", problem 88, is a correct answer whose complex `asin` is checked across its branch cut | 128 (115) | 131 (130), 1 differs | 128 (125) | 124 (117), 4 wrong |

SymbolicIntegration's rule-based method is wrong on problems 23–25 because of
rule `4_1_10_1_1` (it adds the remaining integral where it should subtract
it), fixed in this package but still in SymbolicIntegration.jl 3.8.1.

### Earlier runs

These also compared RischIntegrate and SymbolicIntegration's `RischMethod`,
since moved elsewhere. `rubi` is now `rubi_symbolicutils`, and `rubi_se`
`rubi_simpleexpressions`.


| Date | Julia | Change | rubi | risch | si_rules | si_risch |
|---|---|---|---|---|---|---|
| 2026-10-16 | 1.12.7 | first run | 86 (77), 37 errors | 163 (162) | 124 (117) | 97 (97) |
| 2026-10-16 | 1.13.0 | CPM: `isequal` in `different_powers`; Symbolics extension: special functions keep their arguments | 112 (103), 4 errors | 162 (161) | 124 (117) | 97 (97) |
| 2026-10-16 | 1.13.0 | sign of rule `4_1_10_1_1`, (c+dx)^m cos(e+fx) (RUBISymbolicIntegration `067a185`, CPM `dba8415`) | 112 (106), 4 errors, none wrong | 162 (161) | 124 (117) | 97 (97) |
| 2026-10-16 | 1.13.0 | added `rubi_se`: 127 (110), none wrong, 17 not checked; 393 s wall, mostly compiling | 112 (106) | 162 (161) | 124 (117) | 97 (97) |
| 2026-10-16 | 1.13.0 | `rubi_se`: SimpleExpressions extension builds `Expinti`, `Gamma`, `LogGamma` with SpecialFunctions: 127 (119), 8 not checked (`hypergeometric2f1`) | 112 (106) | 162 (161) | 124 (117) | 97 (97) |
| 2026-10-16 | 1.13.0 | ₂F₁ is HypergeometricFunctions.jl's `_₂F₁` (SimpleExpressions extension for it): `rubi_se` 127 (127) | 112 (108) | 162 (161) | 124 (117) | 97 (97) |
| 2026-10-16 | 1.13.0 | CPM matches a quotient against a quotient, and `1/sqrt(u)` against `u^(-1//2)`; SimpleExpressions `_simplify` expands (problems 64, 105) (`2e70b7f`, CPM `05a6c95`): `rubi_se` 129 (129) | 113 (109) | 162 (161) | 124 (117) | 97 (97) |
| 2026-10-16 | 1.13.0 | CPM splits a quotient's denominator into factors; `ext_expand` keeps rational integrands factored; the frontend also tries the expanded integral (problems 110, 111, 126, 129, 130) (`2f574b4`, CPM `e7e3e9e`): `rubi_se` 133 (133) | 128 (125), no errors | 162 (161) | 124 (117) | 97 (97) |

- RischIntegrate's one change between the first two runs is problem 165
  (∫ eᵗ log(1 + t) dt): an `expinti` answer on Julia 1.12, `NotElementary` on
  Julia 1.13, with the same code.
