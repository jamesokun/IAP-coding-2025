const J = 2

in_path = ARGS[1]
out_path = ARGS[2];

using DataFrames, CSV

function main(in_path, out_path)
    df = DataFrame(CSV.File(in_path * "/raw.csv"));
    df[!, :s0] = 1.0 .- df.s1 .- df.s2
    df[!, :log_rel_share1] = log.(df.s1./df.s0)
    df[!, :log_rel_share2] = log.(df.s2./df.s0)
    
    cols_not_to_stack = ["t", "s0"]
    cols_to_stack = ["p", "s", "c", "log_rel_share"]

    df_long = df |>
       x -> select(x, cols_not_to_stack, [cols_to_stack .* "$j" for j in 1:J] .=> ByRow(tuple) .=> ["$j" for j in 1:J]) |>
       x -> stack(x, ["$j" for j in 1:J], variable_name = :product) |>
       x -> select(x, cols_not_to_stack, :product, :value => cols_to_stack)

    df_long[!, :product] = parse.(Int, df_long.product)
    
    CSV.write(out_path * "/clean.csv", df_long)
end

main(in_path, out_path)

nothing