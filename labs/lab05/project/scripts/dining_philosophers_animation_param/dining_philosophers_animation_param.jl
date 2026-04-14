using DrWatson
@quickactivate "project"
include(srcdir("DiningPhilosophers.jl"))
using .DiningPhilosophers
using Plots, Random
using DrWatson
@quickactivate "project"

N_values = [4, 5]                    # количество философов
model_types = [:classic, :arbiter]   # типы моделей
fps = 5                               # кадров в секунду
tmax = 30.0                           # время симуляции

for N in N_values
    for model_type in model_types
        println("Создание анимации: N=$N, модель=$model_type")

        if model_type == :classic
            net, u0, names = build_classical_network(N)
            suffix = "classic"
        else
            net, u0, names = build_arbiter_network(N)
            suffix = "arbiter"
        end

        Random.seed!(123)

        df = simulate_stochastic(net, u0, tmax)

        anim = @animate for row in eachrow(df)
            u = [row[col] for col in propertynames(row) if col != :time]
            bar(1:length(u), u,
                legend = false,
                ylims = (0, maximum(u0) + 1),
                xlabel = "Позиция",
                ylabel = "Фишки",
                title = "N=$N, модель=$model_type\nВремя = $(round(row.time, digits=2))",
                color = model_type == :classic ? :steelblue : :coral
            )
            xticks!(1:length(u), string.(names), rotation = 45, fontsize = 8)
        end

        filename = plotsdir("philosophers_N$(N)_$(suffix).gif")
        gif(anim, filename, fps = fps)
        println("  ✓ Сохранено: $filename")
    end
end
