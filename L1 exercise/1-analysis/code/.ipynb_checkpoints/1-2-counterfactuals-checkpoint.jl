const T = 1000
const J = 2

using DataFrames, CSV, Serialization, Econometrics, NLsolve, Plots

simulate_file = ARGS[3];

include("../../" * simulate_file) # Make the functions in simulate.jl available

in_path = ARGS[1]
out_path = ARGS[2]

df_long = DataFrame(CSV.File(in_path * "/clean.csv")) # Load Data
p = hcat(df_long.p[df_long.product .== 1], df_long.p[df_long.product .== 2])
c = hcat(df_long.c[df_long.product .== 1], df_long.c[df_long.product .== 2])

IV = deserialize(out_path * "/IVres") # Load IV results
δ_hat = coef(IV)[1:2]
α_hat = -coef(IV)[3]
ξ_hat = zeros(Float64, T, J)
ξ_hat[:, 1] = residuals(IV)[df_long.product .== 1]
ξ_hat[:, 2] = residuals(IV)[df_long.product .== 2];

function FOC_tax(p::Matrix{Float64}; tax::Float64, α=α_hat, δ=δ_hat, ξ=ξ_hat)
    tax_mult = ones(Float64, T, J)
    tax_mult[:, 1] .+= tax
    return c::Matrix{Float64} .+ 1.0 ./ (α .* tax_mult .* (1.0 .- shares(tax_mult .* p, α=α, δ=δ, ξ=ξ)))
end

function eq_prices_FOC_tax(tax; α=α_hat, δ=δ_hat, ξ=ξ_hat)
    res = fixedpoint(x -> FOC_tax(x, tax=tax, α=α, δ=δ, ξ=ξ), p)
    return res.zero
end;

CS(p::Matrix{Float64}; α=α_hat, δ=δ_hat, ξ=ξ_hat) = 1.0/α * mean(log.(1.0 .+ sum(exp.(δ' .- α .* p .+ ξ), dims = 1))) # the sum inside the log is row-wise: town by town

function CS_diff(tax::Float64, CS_no_tax::Float64; α=α_hat, δ=δ_hat, ξ=ξ_hat)
    p_tax = eq_prices_FOC_tax(tax, α=α, δ=δ, ξ=ξ)
    tax_mult = ones(Float64, T, J)
    tax_mult[:, 1] .+= tax
    return CS(tax_mult .* p_tax) - CS_no_tax
end

function profit_diff(tax::Float64, profit_no_tax::Vector{Float64}; j=1, α=α_hat, δ=δ_hat, ξ=ξ_hat)
    p_tax = eq_prices_FOC_tax(tax, α=α, δ=δ, ξ=ξ)
    tax_mult = ones(Float64, T, J)
    tax_mult[:, 1] .+= tax
    profit_tax = shares(tax_mult .* p_tax, α=α, δ=δ, ξ=ξ)[:, j] .* (p_tax[:, j] - c[:, j]::Vector{Float64})
    return mean(profit_tax .- profit_no_tax)
end

function main(p, out_path; α=α_hat, δ=δ_hat, ξ=ξ_hat)

    CS_no_tax = CS(p)

    tax_grid = 0.1:0.1:1.0
    CS_results = [CS_diff(tax, CS_no_tax) for tax in tax_grid];

    profits_results = zeros(Float64, length(tax_grid), J)

    for j = 1:J
        profit_no_tax = [profit(p[t, j], p[t, end-j+1]; α=α, δ=δ, ξ=ξ, t=t, j=j) for t = 1:T]./N
        tax_grid = 0.1:0.1:1.0
        profits_results[:, j] = [profit_diff(tax, profit_no_tax) for tax in tax_grid]; 
    end

    plot(tax_grid, profits_results, 
        markershape = [:rect :diamond], # Notice there are no commas: This is a 1x2 matrix, respecting the number of columns in the data
        label = ["Chicken Paella Profits" "Veggie Paella Profits"],
        xlabel = "Tax Rate", ylabel = "Change (EUR per Consumer)",
        legend = :outertopright)
    plot!(tax_grid, hcat(CS_results), 
        markershape = :circle,
        label = "Consumer Surplus")

    savefig(out_path * "/figure.png")

end

main(p, out_path)

nothing
    




