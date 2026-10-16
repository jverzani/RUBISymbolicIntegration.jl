# julia run_all.jl [LIMIT]
# Runs the four methods one after another (a cold start each) with a limit of
# LIMIT seconds per problem (default 120), then builds the page.
const HERE = @__DIR__
const LIMIT = get(ARGS, 1, "120")
mkpath(joinpath(HERE, "results"))

# the git commit of each package used from a local folder
open(joinpath(HERE, "results", "commits.tsv"), "w") do io
    for (name, dir) in (("RUBISymbolicIntegration", joinpath(HERE, "..", "..")),
                        ("CommutativePatternMatching", joinpath(HERE, "..", "..", "..", "CommutativePatternMatching")),
                        ("RischIntegrate", joinpath(HERE, "..", "..", "..", "RischIntegrate")))
        commit = try
            c = readchomp(`git -C $dir rev-parse --short HEAD`)
            dirty = !isempty(readchomp(`git -C $dir status --porcelain --untracked-files=no`))
            c * (dirty ? " (with uncommitted changes)" : "")
        catch
            "unknown"
        end
        println(io, name, "\t", commit)
    end
end

for (name, env) in (("rubi", "env_su"), ("risch", "env_su"), ("si_rules", "env_si"), ("si_risch", "env_si"))
    @info "running $name"
    run(`julia $(joinpath(HERE, "supervise.jl")) $name $env $LIMIT`)
end
run(`julia $(joinpath(HERE, "build.jl"))`)
