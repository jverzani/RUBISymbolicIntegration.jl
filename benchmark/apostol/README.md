# Apostol comparison

Four symbolic integrators on the 175 apostol problems of
`test/problems_apostol.jl`:

| Method | Package | Terms |
|---|---|---|
| `rubi` | RUBISymbolicIntegration (this package), RUBI rules | SymbolicUtils |
| `risch` | [RischIntegrate](https://github.com/jverzani/RischIntegrate.jl) | SymbolicUtils |
| `si_rules` | [SymbolicIntegration](https://github.com/JuliaSymbolics/SymbolicIntegration.jl), `RuleBasedMethod()` | Symbolics |
| `si_risch` | SymbolicIntegration, `RischMethod()` | Symbolics |

The result is a page, `results/apostol_comparison.html`, with a summary
(counts and times) and a 4 × 175 grid: one row per method, one column per
problem. Selecting a problem shows the integrand and each method's answer.

## Running it

The environments expect sibling checkouts of the local packages, next to
this repository:

```
~/julia/RUBISymbolicIntegration.jl     (this repository)
~/julia/CommutativePatternMatching     (used by this package through its [sources])
~/julia/RischIntegrate
```

SymbolicIntegration, Symbolics and SymbolicUtils come from the registry.

```sh
cd benchmark/apostol
julia --project=env_su -e 'using Pkg; Pkg.instantiate()'   # once, or after changing a package
julia --project=env_si -e 'using Pkg; Pkg.instantiate()'
julia run_all.jl            # or `julia run_all.jl 60` for a 60 s limit per problem
```

`run_all.jl` runs the four methods one after another, so they do not compete
for the CPU, and then builds the page. The whole run takes a few minutes.
Open `results/apostol_comparison.html` in a browser; it is self-contained.

To run or rerun one method, then rebuild the page:

```sh
julia supervise.jl rubi env_su 120
julia build.jl
```

To pick up a newer registered SymbolicIntegration, run
`julia --project=env_si -e 'using Pkg; Pkg.update()'` first. The
`Manifest.toml` files are not committed, so a fresh checkout resolves to the
newest compatible versions.

## How it works

| File | Role |
|---|---|
| `problems.jl` | parses (does not evaluate) `test/problems_apostol.jl` into `(integrand, variable)` expressions |
| `worker_*.jl` | one per method: loads the packages, makes the variables, and defines `INTEGRATE`, `SOLVED` and `TOSU` |
| `core.jl` | shared by the workers: builds each integrand with the worker's variables, integrates, checks, writes a line per problem |
| `supervise.jl` | runs a worker; if one problem takes longer than the limit, kills the process, records a timeout and restarts at the next problem |
| `build.jl`, `template.html` | turn the results into the page |
| `env_su`, `env_si` | the two environments: `env_su` for this package and RischIntegrate, `env_si` for SymbolicIntegration |

Each integrand is built from its expression with the worker's own variables:
SymbolicUtils `@syms x::Real ...` for `rubi` and `risch`, Symbolics
`@variables x ...` for `si_*`. The problems use this package's `⨸` operator
(e.g. `1 ⨸ 2`); each worker defines it as `//` for integers and `/` otherwise, so
every method gets the same input.

What is recorded:

- **Solved**: the method returned a result with no unevaluated `∫` and threw
  nothing. RischIntegrate throws when it can not integrate. SymbolicIntegration
  and this package return an unevaluated `∫` instead; this package's `Cannot…`
  markers also count as not solved.
- **Verified**: a central difference of the answer at `x = 0.31` and `x = 0.57`
  (every other variable given a fixed value) matches the integrand to 1e-4. Real
  values are tried first, then complex ones if the real evaluation fails.
- **Not checked**: solved, but the answer has a function the term type can not
  evaluate numerically (an unevaluated `hypergeometric2f1`, say). Such an
  answer may be wrong.
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

`results/commits.tsv` records the git commit of each local package (and
whether it had uncommitted changes) when `run_all.jl` ran.

## Adding a method

Write `worker_NAME.jl` following the others. Before `include("core.jl")` it
must set `T_START`, load the packages, and define

- `VAR::Dict{Symbol,Any}`: the variables `w x y z t d n m a b c h k l p q r s alpha epsilon e mc A B H K b1 c1`
- `INTEGRATE(f, x)`: the method
- `SOLVED(out)::Bool`: did it return an antiderivative?
- `TOSU(ex)`: the answer as a SymbolicUtils term, for the numeric check (for
  another term type, `core.jl`'s `value` needs a way to substitute and evaluate)

Then add it to the loop in `run_all.jl` and to `METHODS` in `build.jl`.

## Updating the page

`build.jl` fills in the numbers, grid, times and versions. The "What stands
out" section is written by hand in `template.html`; check it against the new
results and edit it before publishing.

The page was published as a claude.ai artifact:
https://claude.ai/artifact/5xFfniAuWyEt1REQHVKDTg. To update it, ask Claude
Code to republish `results/apostol_comparison.html` to that URL.

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

Solved (verified) out of 175. Times are on one machine and only comparable within a run.

| Date | Julia | Change | rubi | risch | si_rules | si_risch |
|---|---|---|---|---|---|---|
| 2026-10-16 | 1.12.7 | first run | 86 (77), 37 errors | 163 (162) | 124 (117) | 97 (97) |
| 2026-10-16 | 1.13.0 | CPM: `isequal` in `different_powers`; Symbolics extension: special functions keep their arguments | 112 (103), 4 errors | 162 (161) | 124 (117) | 97 (97) |
| 2026-10-16 | 1.13.0 | sign of rule `4_1_10_1_1`, (c+dx)^m cos(e+fx) (RUBISymbolicIntegration `067a185`, CPM `dba8415`) | 112 (106), 4 errors, none wrong | 162 (161) | 124 (117) | 97 (97) |

Notes:

- RischIntegrate's one change between the first two runs is problem 165
  (∫ eᵗ log(1 + t) dt): an `expinti` answer on Julia 1.12, `NotElementary` on
  Julia 1.13, with the same code.
- SymbolicIntegration's rule-based method is wrong on problems 23–25 because
  of the same rule `4_1_10_1_1` (it adds the remaining integral where it should
  subtract it). SymbolicIntegration.jl 3.8.1 still has it.
