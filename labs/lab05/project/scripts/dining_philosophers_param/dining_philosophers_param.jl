using DrWatson
@quickactivate "project"

include(srcdir("DiningPhilosophers.jl"))
using .DiningPhilosophers
using DataFrames, CSV, Plots, Random
using DrWatson: dict_list
using Statistics

param_grid = Dict(
    :N => [3, 4, 5, 6],
    :tmax => [30.0, 50.0, 100.0],
    :model_type => [:classic, :arbiter],
    :run_id => [1, 2, 3]
)

all_params = dict_list(param_grid)
println("Всего экспериментов: ", length(all_params))

results = []

for (idx, params) in enumerate(all_params)
    println("[$(idx)/$(length(all_params))] N=$(params[:N]), tmax=$(params[:tmax]), модель=$(params[:model_type]), прогон=$(params[:run_id])")

    if params[:model_type] == :classic
        net, u0, _ = build_classical_network(params[:N])
    else
        net, u0, _ = build_arbiter_network(params[:N])
    end

    seed = params[:run_id] * 1000 + params[:N] * 10 + Int(params[:tmax])
    Random.seed!(seed)

    df = simulate_stochastic(net, u0, params[:tmax])
    dead = detect_deadlock(df, net)

    eat_cols = [Symbol("Eat_$i") for i = 1:params[:N]]
    eating_at_end = sum([df[end, col] for col in eat_cols])

    push!(results, Dict(
    	:N => params[:N],
    	:tmax => params[:tmax],
    	:model_type => string(params[:model_type]),
    	:run_id => params[:run_id],
    	:deadlock => dead,
    	:time_to_deadlock => dead ? df.time[end] : Inf,
    	:eating_at_end => eating_at_end
    ))
end

results_df = DataFrame(results)
CSV.write(datadir("parametric_results.csv"), results_df)
println("\nРезультаты сохранены в data/parametric_results.csv")

df_classic = filter(row -> row.model_type == "classic", results_df)
df_grouped = combine(groupby(df_classic, :N), :deadlock => mean => :probability)

p_deadlock = plot(df_grouped.N, df_grouped.probability,
    marker=:circle, xlabel="Число философов N",
    ylabel="Вероятность deadlock",
    title="Зависимость deadlock от N",
    ylims=(0,2), label="Классическая модель")
savefig(plotsdir("parametric_deadlock_analysis.png"))

println("График сохранён: plots/parametric_deadlock_analysis_param.png")
