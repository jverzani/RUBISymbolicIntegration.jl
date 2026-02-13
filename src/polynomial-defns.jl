## -------- Polynomial additions

is_polynomial(x) = Base.Fix2(is_polynomial, x)
is_polynomial(ex, x, n) = false # XXX----XXX degree
function is_polynomial(ex, x)::Bool
    !is_symbol(x) && return false # need a symbol
    !contains_var(ex,x) && return true
    isequal(ex, x) && return true
    iscall(ex) || return false
    op = operation(ex)
    if op ∈ (+, -, *)
        return all(is_polynomial(x), arguments(ex))
    elseif op ∈ (/,)
        a, b = arguments(ex)
        return is_polynomial(a, x) && !contains_var(b,x)
    elseif op ∈ (^,)
        a, b = arguments(ex)
        return is_polynomial(a, x) && ige(b, 0)
    else
        return false # not constant, so must be nonliner
    end
    return false
end

# If u is a polynomial in x of degree n, poly_degree(u,x) returns n::Int,
# else nothing (not false!)
poly_degree(ex::Real, x) = 0
function poly_degree(ex, x)
    notpoly = nothing
    !contains_var(ex,x) && return 0
    Symbol(ex) == Symbol(x)  && return 1
    iscall(ex) || return 0

    op = operation(ex)
    if op ∈ (+, -)
        k = 0
        for a ∈ arguments(ex)
            j = poly_degree(a,x)
            isnothing(j) && return notpoly
            k = max(k, j)
        end
        return unwrap_const(k)
    elseif op ∈ (*,)
        k = 0
        for a ∈ arguments(ex)
            j = poly_degree(a,x)
            isnothing(j) && return notpoly
            k += j
        end
        return k
    elseif op ∈ (/,)
        a, b = arguments(ex)
        contains_var(b,x) && return notpoly
        return poly_degree(a,x)
    elseif op ∈ (^,)
        a, b = arguments(ex)
        ige(b, 0) || return  notpoly # must unwrap
        n = poly_degree(a,x)
        isnothing(n) && return notpoly
        return n*unwrap_const(b)
    end
    return notpoly
end

# Πₙ -- polys of degree n *or* less
function conv!(xs, ys)
    n,m = length(xs), length(ys)
    nz, nm = findlast.(!_iszero, (xs, ys))
    !isnothing(nz) && !isnothing(nm) && (nz-1) * (nm-1) > n && return false
    zs = Any[0 for _ in eachindex(xs)]
    for i in 0:(n-1)
        for j in 0:(m-1)
            i + j + 1 > n && continue
            aij = xs[i+1] * ys[j+1]
            zs[i+j+1] += xs[i+1] * ys[j+1]
        end
    end
    xs[:] = zs
    return true
end


function is_Πₙ(ex, x, n)
    cs = Any[zero(Int) for i in 1: unwrap_const(n)+1]
    val = is_Πₙ!(cs, ex, x, unwrap_const(n))
    (cs, val)
end
function is_Πₙ!(cs, ex, x, n::Integer)
    @assert n ≥ 0
    # mutate cs, return bool
    if !is_symbolic(ex) || !contains_var(ex,x)
        cs[0+1] = ex
        return true
    end
    if isequal(ex, x)
        cs[1 + 1] = 1
        return true
    end
    if !iscall(ex)
        cs[0 + 1] = ex
        return true
    end

    op = operation(ex)
    cs′ = Any[zero(Int) for i in 1:n+1] #zeros(typeof(x), n+1)
    if op ∈ (+, -)
        for a ∈ arguments(ex)
            cs′ .= 0
            out = is_Πₙ!(cs′, a, x, n)
            !out && return false
            if op == +
                cs[:] = cs + cs′
            else
                cs[:] = cs - cs′
            end
        end
        return true
    elseif op ∈ (*,)
        a, as... = arguments(ex)
        is_Πₙ!(cs, a, x, n) || return false
        cs′ = Any[zero(c) for c in cs]
        for aᵢ ∈ as
            cs′[:] .= 0
            is_Πₙ!(cs′, aᵢ, x, n) || return false
            conv!(cs, cs′) || return false
        end
        return true
    elseif op ∈ (/,)
        a, b = arguments(ex)
        contains_var(b,x) && return false
        cs ./= b
        return true
    elseif op ∈ (^,)
        a, b = arguments(ex)
        igt(b,0) || return false
        cs′ .= 0
        is_Πₙ!(cs′, a, x, n) || return false
        cs[:] = cs′[:]
        for i in 2:unwrap_const(b)
            conv!(cs, cs′) || return false
        end
        return true
    end
    return false
end
