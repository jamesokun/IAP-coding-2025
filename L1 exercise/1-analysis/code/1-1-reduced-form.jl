in_path = ARGS[1]
out_path = ARGS[2];

using DataFrames, CSV, Econometrics, Serialization, RegressionTables

function main(in_path, out_path)
    df_long = DataFrame(CSV.File(in_path * "/clean.csv"))
    
    OLS = fit(EconometricModel, @formula(log_rel_share ~ 0 + product + p), df_long, contrasts = Dict(:product => DummyCoding()), vce = HC3)
    
    IV = fit(EconometricModel, @formula(log_rel_share ~ 0 + product + (p ~ c)), df_long, contrasts = Dict(:product => DummyCoding()), vce = HC3)
    
    labels = Dict("product: 1" => "Product 1", "product: 2" => "Product 2", "p" => "Price", "log_rel_share" => "log Relative Share")

    serialize(out_path * "/IVres", IV) # Store IV results as Julia object

    regtable(OLS, IV, regression_statistics = [:nobs], labels = labels, groups = ["OLS", "IV"], 
                   print_estimator_section = false, renderSettings = latexOutput(out_path * "/table.tex"), print_result = false)
end

main(in_path, out_path)

nothing