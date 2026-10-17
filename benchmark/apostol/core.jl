# Shared by the four workers. Before including, a worker defines:
#   VAR::Dict{Symbol,Any}   the symbolic variables
#   INTEGRATE(f, x)          the method being compared
#   SOLVED(out)::Bool        did it return an antiderivative?
#   TOSU(ex)                 a SymbolicUtils term, for checking; or instead
#   EVAL(ex, vals)           the value of `ex` with each variable `v` replaced by
#                            `vals[v]`, as a number, or `nothing`
# Usage: julia --project=ENV worker_X.jl START OUTFILE (run by supervise.jl)
using SymbolicUtils
const T_LOADED = time()

⨸(a::Integer, b::Integer) = a // b
⨸(a, b) = a / b
const I = im

const PROBLEMS = include(joinpath(@__DIR__, "problems.jl"))
const ALLVARS = (:w, :x, :y, :z, :t, :d, :n, :m, :a, :b, :c, :h, :k, :l, :p, :q, :r, :s,
                 :alpha, :epsilon, :e, :mc, :A, :B, :H, :K, :b1, :c1)

# the integrand, built with this worker's variables
function build(ex)
    m = Module()
    Core.eval(m, :(const ⨸ = $⨸; const I = $I))
    for v in ALLVARS
        Core.eval(m, :(const $v = $(VAR[v])))
    end
    Core.eval(m, ex)
end

# ---- numeric check: d/dx F == f at two points, parameters fixed
const PARAMS = Dict(v => 1.0 + 0.137 * i for (i, v) in enumerate(ALLVARS))

# the default EVAL, through SymbolicUtils
function su_eval(ex, vals)
    d = Dict{Any,Any}(TOSU(VAR[v]) => p for (v, p) in vals)
    r = SymbolicUtils.substitute(TOSU(ex), d; fold = Val(true))
    u = SymbolicUtils.unwrap_const(r)
    isa(u, Number) ? complex(u) : nothing
end
isdefined(@__MODULE__, :EVAL) || (EVAL(ex, vals) = su_eval(ex, vals))

function evalat(e, xs, x0, cplx)
    vals = Dict{Symbol,Number}()
    for v in ALLVARS
        p = v === xs ? x0 : PARAMS[v]
        vals[v] = cplx ? complex(p) : p
    end
    EVAL(e, vals)
end

function check(f, F, xs)
    fsu, Fsu = f, F
    for x0 in (0.31, 0.57)
        h = 1e-5
        ok = nothing
        for cplx in (false, true)
            vals = try
                (evalat(fsu, xs, x0, cplx), evalat(Fsu, xs, x0 + h, cplx), evalat(Fsu, xs, x0 - h, cplx))
            catch
                nothing
            end
            vals === nothing && continue
            any(isnothing, vals) && return :unverified
            fv, Fp, Fm = vals
            (isfinite(fv) && isfinite(Fp) && isfinite(Fm)) || continue
            dF = (Fp - Fm) / (2h)
            ok = abs(dF - fv) <= 1e-4 * max(1, abs(fv))
            break
        end
        ok === nothing && return :unverified
        ok || return :wrong
    end
    return :verified
end

clean(s) = replace(s, r"\s+" => " ")[1:min(end, 400)]

function run_one(io, i)
    ex, xs = PROBLEMS[i]
    println(io, "S\t$i\t", time()); flush(io)
    f = build(ex)
    x = VAR[xs]
    t0 = time()
    out = try
        INTEGRATE(f, x)
    catch err
        err
    end
    dt = time() - t0
    if out isa Exception
        status, ver, s = :error, :none, sprint(showerror, out)
    elseif SOLVED(out)
        status, s = :solved, string(out)
        ver = try check(f, out, xs) catch; :unverified end
    else
        status, ver, s = :unsolved, :none, string(out)
    end
    println(io, "R\t$i\t$status\t$ver\t$dt\t", clean(s)); flush(io)
    dt
end

let start = parse(Int, ARGS[1]), outfile = ARGS[2]
    open(outfile, "a") do io
        println(io, "L\t", T_LOADED - T_START, "\t", start); flush(io)
        start == 1 && for (k, m) in Base.loaded_modules
            k.name in ("RUBISymbolicIntegration", "CommutativePatternMatching", "SymEngine",
                       "SymbolicIntegration", "Symbolics", "SymbolicUtils", "SimpleExpressions") || continue
            println(io, "V\t", k.name, "\t", pkgversion(m))
        end
        foreach(i -> run_one(io, i), start:length(PROBLEMS))
        println(io, "D"); flush(io)
    end
end
