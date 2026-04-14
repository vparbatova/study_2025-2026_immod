using DrWatson
@quickactivate "project"

using DataFrames, CSV, Plots
using Statistics

param_file = datadir("parametric_results.csv")
if isfile(param_file)
    df_param = CSV.read(param_file, DataFrame)
    println("Загружено $(nrow(df_param)) записей из parametric_results.csv")

    df_classic_param = filter(row -> row.model_type == "classic", df_param)
    df_prob = combine(groupby(df_classic_param, :N),
        :deadlock => mean => :probability,
        nrow => :count)

    p_prob = plot(df_prob.N, df_prob.probability,
        marker = :circle, markersize = 8,
        xlabel = "Число философов N",
        ylabel = "Вероятность deadlock",
        title = "Вероятность deadlock (классическая модель)",
        ylims = (0, 1.1),
        label = "Эксперимент",
        linewidth = 2)

    plot!(p_prob, [2.5, 6.5], [1.0, 1.0],
        label = "Теория",
        linestyle = :dash,
        linecolor = :red,
        linewidth = 1.5)

    savefig(plotsdir("param_deadlock_probability.png"))
    println("✓ График сохранён: plots/param_deadlock_probability.png")

    df_deadlock = filter(row -> row.deadlock == true, df_classic_param)

    if nrow(df_deadlock) > 0
        df_time = combine(groupby(df_deadlock, :N),
            :time_to_deadlock => mean => :mean_time,
            :time_to_deadlock => std => :std_time)

        p_time = plot(df_time.N, df_time.mean_time,
            yerr = df_time.std_time,
            marker = :square, markersize = 8,
            xlabel = "Число философов N",
            ylabel = "Среднее время до deadlock",
            title = "Время до тупика (классическая модель)",
            label = "mean ± std",
            linewidth = 2)

        savefig(plotsdir("param_time_to_deadlock.png"))
        println("✓ График сохранён: plots/param_time_to_deadlock.png")
    end

    df_classic_eating = combine(groupby(df_classic_param, :N),
        :eating_at_end => mean => :classic_eating)

    df_arbiter_param = filter(row -> row.model_type == "arbiter", df_param)
    df_arbiter_eating = combine(groupby(df_arbiter_param, :N),
        :eating_at_end => mean => :arbiter_eating)

    p_eating = plot(df_classic_eating.N, df_classic_eating.classic_eating,
        marker = :circle, label = "Классическая модель",
        xlabel = "Число философов N",
        ylabel = "Среднее число едящих (в конце)",
        title = "Сравнение моделей",
        linewidth = 2)

    plot!(p_eating, df_arbiter_eating.N, df_arbiter_eating.arbiter_eating,
        marker = :square, label = "Модель с арбитром",
        linewidth = 2)

    savefig(plotsdir("param_models_comparison.png"))
    println("✓ График сохранён: plots/param_models_comparison.png")

    for N_val in [3, 4, 5, 6]
        sub = filter(row -> row.N == N_val, df_classic_param)
        dead_count = 0
        for row in eachrow(sub)
            if row.deadlock == true
                dead_count += 1
            end
        end
        total = nrow(sub)
        println("  N=$N_val: deadlock в $dead_count/$total прогонах ($(round(dead_count/total*100, digits=1))%)")
    end

    println("\n" * "-"^40)
    println("СТАТИСТИКА ПО МОДЕЛИ С АРБИТРОМ:")
    println("-"^40)

    for N_val in [3, 4, 5, 6]
        sub = filter(row -> row.N == N_val, df_arbiter_param)
        dead_count = 0
        for row in eachrow(sub)
            if row.deadlock == true
                dead_count += 1
            end
        end
        total = nrow(sub)
        println("  N=$N_val: deadlock в $dead_count/$total прогонах ($(round(dead_count/total*100, digits=1))%)")
    end

else
    println("Файл parametric_results.csv не найден.")
    println("Сначала запустите dining_philosophers.jl для выполнения параметрического сканирования.")
end
