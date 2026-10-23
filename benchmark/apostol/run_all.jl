# julia run_all.jl [LIMIT]
# Runs the methods one after another (a cold start each) with a limit of
# LIMIT seconds per problem (default 120), then builds the page.
const HERE = @__DIR__
const LIMIT = get(ARGS, 1, "120")
mkpath(joinpath(HERE, "results"))

# The commit of each package, found before anything is written. A package
# from a local folder records its commit and whether it has uncommitted
# changes (other than this run's results, which the run rewrites); one from a
# git repository records the commit of the branch used.
using TOML

function local_commit(dir)
    try
        c = readchomp(`git -C $dir rev-parse --short HEAD`)
        changes = readchomp(`git -C $dir status --porcelain --untracked-files=no -- . ':(exclude)benchmark/apostol/results'`)
        c * (isempty(changes) ? "" : " (with uncommitted changes)")
    catch
        "unknown"
    end
end

# where env_rubi takes a package from
function package_commit(name)
    manifest = TOML.parsefile(joinpath(HERE, "env_rubi", "Manifest.toml"))
    entry = only(manifest["deps"][name])
    if haskey(entry, "path")
        local_commit(normpath(joinpath(HERE, "env_rubi", entry["path"])))
    elseif haskey(entry, "repo-url")
        url, rev = entry["repo-url"], get(entry, "repo-rev", "HEAD")
        c = try
            first(split(readchomp(`git ls-remote $url $rev`)))[1:7]
        catch
            "unknown"
        end
        "$c ($url, $rev)"
    else
        "version " * get(entry, "version", "unknown")
    end
end

commits = [("RUBISymbolicIntegration", local_commit(joinpath(HERE, "..", ".."))),
           ("AssociativeCommutativePatternMatching", package_commit("AssociativeCommutativePatternMatching")),
           ("SymJ", package_commit("SymJ"))]
open(joinpath(HERE, "results", "commits.tsv"), "w") do io
    foreach(((name, c),) -> println(io, name, "\t", c), commits)
end

for (name, env) in (("rubi_symengine", "env_rubi"), ("rubi_symj", "env_rubi"),
                    ("rubi_symbolicutils", "env_rubi"), ("si_rules", "env_si"))
    @info "running $name"
    run(`julia $(joinpath(HERE, "supervise.jl")) $name $env $LIMIT`)
end
run(`julia $(joinpath(HERE, "build.jl"))`)
