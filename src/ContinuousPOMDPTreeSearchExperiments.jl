__precompile__(true)
module ContinuousPOMDPTreeSearchExperiments

importall POMDPs
using BasicPOMCP
using POMCPOW
using Parameters
using LightDarkPOMDPs
using StaticArrays
using POMDPToolbox
using ParticleFilters
using ControlSystems
using Distributions
using LaserTag
# import DESPOT
using ARDESPOT
using QMDP
using MCTS
using DiscreteValueIteration
using RecipesBase
using SubHunt

using DataFrames
using DataArrays
using ProgressMeter
using CPUTime

# using VDPTag
using VDPTag2
const VDPTag = VDPTag2 # yikes!!


# import DESPOT: bounds, init_bounds
import ARDESPOT: bounds, init_bounds
import POMCPOW.n_children

export
    RadiusRandom,
    AdaptiveRadiusRandom,
    SimpleFeedback,
    SymmetricNormalResampler,
    MinPopResampler,
    ObsAdaptiveParticleFilter,
    ObsAdaptiveSRFilter,
    LightDarkLQRSolver,
    LightDarkLQRPolicy,
    ModeAugmentedBelief,
    InfoGatherHeur,
    InfoGatherUpdater,
    OneStepValue,
    LaserBounds,
    InevitableInit,
    RootToNextMLFirst,
    NoGapTag,
    ModeMDP,
    ModeMDPSolver,
    nogap_tag,
    VDPUpper,
    SampleRollout,
    MeanRewardBeliefMDP,

    Sim,
    # SimQueue,
    run_parallel,
    run,
    metadata_as_pairs,
    Staged,
    LQG1D,
    LinearFeedback,
    Kalman1D,

    SimpleLightDark,
    DSimpleLightDark,
    LDHeuristic,
    LDHSolver,
    LDSide,
    LDSidePolicy,

    PDPWSolver,

    GBMDPSolver,

    reset_distribution

    # EDPWSolver,
    # EntropyRewardBeliefMDP,
    # pf_entropy,


include("simple_lightdark.jl")
include("lqg_example.jl")

include("policies.jl")
include("updaters.jl")
include("belief_mdp.jl")
include("action_gen.jl")

include("sr_filter.jl")
include("bounds_and_heuristics.jl")

# include("simulations.jl")
include("integration.jl")
include("pomcpdpw.jl")

# include("johannes/edpw_types.jl")
# include("johannes/edpw.jl")
# include("johannes/entropy_mdp.jl")
# include("johannes/entropy_estimation.jl")

n_children(h::BeliefNode) = length(h.children)

immutable OneStepValue end
BasicPOMCP.estimate_value(o::OneStepValue, pomdp::POMDP, s, h, steps) = reward(pomdp, s)

Base.srand(p::AlphaVectorPolicy, i::Int) = p

end # module
