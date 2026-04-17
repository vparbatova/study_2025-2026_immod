using DrWatson
@quickactivate "project"

include(srcdir("SIRPetri.jl"))
using .SIRPetri
using DataFrames, CSV, Plots, Random

β = 0.3
γ = 0.1
tmax = 100.0
saveat = 0.2

net, u0, states = build_sir_network(β, γ)
df = simulate_deterministic(net, u0, (0.0, tmax), saveat = saveat, rates = [β, γ])

println("Симуляция завершена. Всего кадров: ", nrow(df))

anim = @animate for i in 1:nrow(df)
    bar(
        ["S", "I", "R"],
        [df.S[i], df.I[i], df.R[i]],
        ylims = (0, 1000),
        xlabel = "Compartment",
        ylabel = "Population",
        title = "SIR dynamics at t = $(round(df.time[i], digits=1))",
        legend = false,
        color = [:green, :red, :blue],
        bar_width = 0.6,
    )
end

gif(anim, plotsdir("sir_animation.gif"), fps = 15)
println("Анимация сохранена в plots/sir_animation.gif")
