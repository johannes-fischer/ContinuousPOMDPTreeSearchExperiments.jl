using ContinuousPOMDPTreeSearchExperiments
using ParticleFilters
using ARDESPOT
using BasicPOMCP
using POMCPOW
using POMDPs
using QMDP
using MCTS
using DiscreteValueIteration
using POMDPToolbox
using DataFrames
using CSV

using Entropy
using MyLightDark

@show max_time = 1.0
@show max_depth = 20
pomdp = MySimpleLightDark(big_step=3)

file_contents = readstring(@__FILE__())

solvers = Dict{String, Union{Solver,Policy}}(

    # "pomcpow" => begin
    #     rng = MersenneTwister(13)
    #     ro = ValueIterationSolver()
    #     solver = POMCPOWSolver(tree_queries=10_000_000,
    #                            criterion=MaxUCB(90.0),
    #                            # final_criterion=MaxTries(),
    #                            max_depth=max_depth,
    #                            max_time=max_time,
    #                            enable_action_pw=false,
    #                            k_observation=5.0,
    #                            alpha_observation=1/15.0,
    #                            estimate_value=FOValue(ro),
    #                            check_repeat_obs=false,
    #                            tree_in_info=false,
    #                            # default_action=ReportWhenUsed(-1),
    #                            rng=rng
    #                           )
    # end,
    #
    # "pomcp" => begin
    #     rng = MersenneTwister(13)
    #     ro = ValueIterationSolver()
    #     POMCPSolver(max_depth=max_depth,
    #                 max_time=max_time,
    #                 c=100.0,
    #                 tree_queries=typemax(Int),
    #                 # default_action=ro,
    #                 estimate_value=FOValue(ro),
    #                 tree_in_info=false,
    #                 rng=rng
    #                )
    # end,
    #
    # "despot" => begin
    #     rng = MersenneTwister(13)
    #     ro = QMDPSolver()
    #     b = IndependentBounds(DefaultPolicyLB(ro), 100.0, check_terminal=true)
    #     DESPOTSolver(lambda=0.01,
    #                  epsilon_0=0.0,
    #                  K=500,
    #                  D=max_depth,
    #                  max_trials=1_000_000,
    #                  T_max=max_time,
    #                  bounds=b,
    #                  # default_action=ReportWhenUsed(solve(ro, pomdp)),
    #                  default_action=solve(ro, pomdp),
    #                  rng=rng)
    # end,
    #
    # "pomcpdpw" => begin
    #     rng = MersenneTwister(13)
    #     ro = ValueIterationSolver()
    #     solver = PDPWSolver(tree_queries=10_000_000,
    #                         c=100.0,
    #                         max_depth=max_depth,
    #                         max_time=max_time,
    #                         enable_action_pw=false,
    #                         k_observation=4.0,
    #                         alpha_observation=1/10,
    #                         estimate_value=FOValue(ro),
    #                         check_repeat_obs=false,
    #                         # default_action=ReportWhenUsed(-1),
    #                         rng=rng
    #                        )
    # end,
    #
    # "pft" => begin
    #     rng = MersenneTwister(13)
    #     m = 20
    #     ro = solve(QMDPSolver(), pomdp)
    #     solver = DPWSolver(n_iterations=typemax(Int),
    #                        exploration_constant=100.0,
    #                        depth=max_depth,
    #                        max_time=max_time,
    #                        k_state=4.0,
    #                        alpha_state=1/10,
    #                        check_repeat_state=false,
    #                        check_repeat_action=false,
    #                        estimate_value=RolloutEstimator(ro),
    #                        enable_action_pw=false,
    #                        tree_in_info=false,
    #                        # default_action=ReportWhenUsed(qp),
    #                        rng=rng
    #                       )
    #
    #     # node_updater = ObsAdaptiveParticleFilter(deepcopy(pomdp),
    #     #                                    LowVarianceResampler(m),
    #     #                                    0.05, rng)
    #     # belief_mdp = GenerativeBeliefMDP(deepcopy(pomdp), node_updater)
    #
    #     belief_mdp = MeanRewardBeliefMDP(pomdp,
    #                                      LowVarianceResampler(m),
    #                                      0.05
    #                                     )
    #
    #     solve(solver, belief_mdp)
    # end,

    "epft" => begin
        rng = MersenneTwister(13)
        m = 100
        # ro = solve(QMDPSolver(), pomdp)
        solver = EDPWSolver(n_iterations=typemax(Int),
                           exploration_constant=100.0,
                           depth=max_depth,
                           max_time=max_time,
                           k_state=4.0,
                           alpha_state=1/10,
                           lambda=50.0,
                           entropy_resample=LowVarianceResampler(1000),
                           entropy_n=10000,
                           entropy_sigma=1/sqrt(2*π*exp(1)),
                           check_repeat_state=false,
                           check_repeat_action=false,
                           # estimate_value=RolloutEstimator(ro),
                           enable_action_pw=false,
                           tree_in_info=true,
                           # default_action=ReportWhenUsed(qp),
                           rng=rng
                          )
        # node_updater = ObsAdaptiveParticleFilter(deepcopy(pomdp),
        #                                    LowVarianceResampler(m),
        #                                    0.05, rng)
        # belief_mdp = GenerativeBeliefMDP(deepcopy(pomdp), node_updater)

        # belief_mdp = MeanRewardBeliefMDP(pomdp,
        #                                  LowVarianceResampler(m),
        #                                  0.05
        #                                 )
        belief_mdp = EntropyRewardBeliefMDP(pomdp,
                                         LowVarianceResampler(m),
                                         0.05
                                        )
        # println(state_type(belief_mdp))
        solve(solver, belief_mdp)
    end,

    # "d_pomcp" => begin
    #     rng = MersenneTwister(13)
    #     ro = ValueIterationSolver()
    #     sol = POMCPSolver(max_depth=max_depth,
    #                 max_time=max_time,
    #                 c=100.0,
    #                 tree_queries=typemax(Int),
    #                 # default_action=ro,
    #                 tree_in_info=false,
    #                 estimate_value=FOValue(ro),
    #                 rng=rng
    #                )
    #     dpomdp = DSimpleLightDark(pomdp, 0.05)
    #     solve(sol, dpomdp)
    # end,
    #
    # "d_despot" => begin
    #     rng = MersenneTwister(13)
    #     ro = QMDPSolver()
    #     b = IndependentBounds(-100.0, 100.0, check_terminal=true)
    #     sol = DESPOTSolver(lambda=0.01,
    #                  epsilon_0=0.0,
    #                  K=5000,
    #                  D=max_depth,
    #                  max_trials=1_000_000,
    #                  T_max=max_time,
    #                  bounds=b,
    #                  default_action=ReportWhenUsed(solve(ro, pomdp)),
    #                  rng=rng)
    #     dpomdp = DSimpleLightDark(pomdp, 1.0)
    #     solve(sol, dpomdp)
    # end,
    #
    # "qmdp" => QMDPSolver(),
    # "heuristic_1" => LDHSolver(std_thresh=0.1),
    # "heuristic_01" => LDHSolver(std_thresh=0.01),
    # "side" => LDSide()
)

@show N=100

alldata = DataFrame()
for (k, solver) in solvers
# test = ["pft"]
# for (k, solver) in [(k, solvers[k]) for k in test]
    @show k
    if isa(solver, Solver)
        planner = solve(solver, pomdp)
    else
        planner = solver
    end
    sims = []
    for i in 1:N
        srand(planner, i+50_000)

        filter = SIRParticleFilter(pomdp, 10000)
        # filter = ObsAdaptiveParticleFilter(deepcopy(pomdp),
        #                                    LowVarianceResampler(10_000),
        #                                    0.05, MersenneTwister(i+90_000))

        sim = Sim(deepcopy(pomdp),
                  planner,
                  filter,
                  rng=MersenneTwister(i+70_000),
                  max_steps=100,
                  metadata=Dict(:solver=>k, :i=>i)
                 )

        push!(sims, sim)
    end

    data = run_parallel(sims)
    # data = run(sims)

    rs = data[:reward]
    println(@sprintf("reward: %6.3f ± %6.3f", mean(rs), std(rs)/sqrt(length(rs))))
    if isempty(alldata)
        alldata = data
    else
        alldata = vcat(alldata, data)
    end
end

datestring = Dates.format(now(), "E_d_u_HH_MM")
copyname = Pkg.dir("ContinuousPOMDPTreeSearchExperiments", "icaps_2018", "data", "simpleld_table_$(datestring).jl")
write(copyname, file_contents)
filename = Pkg.dir("ContinuousPOMDPTreeSearchExperiments", "icaps_2018", "data", "simpleld_$(datestring).csv")
println("saving to $filename...")
CSV.write(filename, alldata)
println("done.")
