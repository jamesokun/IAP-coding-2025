# 0. Instantiate
import Pkg
Pkg.instantiate()

# 1. Declare Constants
const T = 1000 
const N = 500
const J = 2
const α = 0.5
const δ = [2.0, 1.8]
const σ = 0.25;

out_path = ARGS[1];

# 2. Declare Packages
using Random, Distributions, Optim, NLsolve, LinearAlgebra, DataFrames, CSV

# 3. Define Functions
Random.seed!(123) # Set the seed for the pseudo-random number generator
ξ = σ .* randn(T, J)
c = exp.(0.25randn((T, J)))

function shares(p::Matrix; α=α, δ=δ, ξ=ξ)
    
    # Inputs 
    # p : A TxJ matrix of prices
    
    # Outputs 
    # s : A TxJ matrix of market shares
    
    s = zeros(Float64, T, J)
    
    for t = 1:T
        s[t, :] = exp.(δ .- α .* p[t, :] .+ ξ[t, :])./(1.0 .+ sum(exp.(δ .- α .* p[t, :] .+ ξ[t, :])))
    end
    
    return s 
end

function shares(p::Vector; α=α, δ=δ, ξ=ξ, t=1)
    
    # Inputs 
    # p : A 1xJ vector of prices
    
    # Outputs 
    # s : A TxJ vector of market shares
        
    s = exp.(δ .- α .* p .+ ξ[t, :])./(1.0 .+ sum(exp.(δ .- α .* p .+ ξ[t, :])))
end;

function profit(own_p::Float64, other_p::Float64; α=α, δ=δ, ξ=ξ, c=c, t=1, j=1) 
   p = j == 1 ? [own_p, other_p] : [other_p, own_p]
   return N * shares(p, t=t, α=α, δ=δ, ξ=ξ)[j] * (own_p - c[t, j])
end

function eq_prices_BR(; α=α, δ=δ, ξ=ξ, c=c, tol = 1e-20, max_iter = 10000)
    
    p = zeros(Float64, T, J)
    
    for t = 1:T
        p_old = [1.0, 1.0]
        p_new = [1.0, 1.0]
        error = 1000.0
        iter = 0
        
        while (error > tol) & (iter < max_iter)
            res = optimize(x -> -profit(x[1], p_old[1], α=α, δ=δ, ξ=ξ, c=c, t=t, j=2), [p_old[2]]) # Compute 2's BR
            br2 = res.minimizer[1]
            res = optimize(x -> -profit(x[1], br2, α=α, δ=δ, ξ=ξ, c=c, t=t, j=1), [p_old[1]])      # Compute 1's BR
            br1 = res.minimizer[1]
            p_new = [br1, br2]
            error = norm(p_new .- p_old)
            iter += 1
            p_old = copy(p_new)
        end
        
        p[t, :] = p_new
    end
    
    return p
end

FOC(p::Matrix{Float64}; α=α, δ=δ, ξ=ξ) = c::Matrix{Float64} .+ 1.0 ./ (α .* (1.0 .- shares(p, α=α, δ=δ, ξ=ξ)))

    function eq_prices_FOC(; α=α, δ=δ, ξ=ξ)
        res = fixedpoint(x -> FOC(x, α=α, δ=δ, ξ=ξ), ones(Float64, T, J))
        return res.zero
    end

function sim_shares(p::Matrix{Float64})
    
    s = zeros(Float64, T, J)
    
    for t = 1:T
        ϵ = rand(Gumbel(0, 1), N, J+1)
        u = (δ .- α .* p[t, :] .+ ξ[t, :]::Vector{Float64})' .+ ϵ[:, 1:2]
        s[t, 1] = mean((u[:, 1] .> u[:, 2]) .& (u[:, 1] .> ϵ[:, 3]))
        s[t, 2] = mean((u[:, 2] .> u[:, 1]) .& (u[:, 2] .> ϵ[:, 3]))
    end
    
    return s
end

# 4. Main function
function main(out_path)
    p = eq_prices_FOC()
    s = sim_shares(p)
    
    mkpath(out_path) # Create the directory for output in case it doesn't exist
    
    df = DataFrame(t = 1:T, p1 = p[:, 1], p2 = p[:, 2], s1 = s[:, 1], s2 = s[:, 2], c1 = c[:, 1], c2 = c[:, 2])

    CSV.write(out_path * "/raw.csv", df)
end

main(out_path)

# Have the file return nothing
nothing