@with_kw immutable SymmetricNormalResampler
    n::Int
    std::Float64
end

function ParticleFilters.resample(r::SymmetricNormalResampler, b::WeightedParticleBelief, rng::AbstractRNG)
    collection = resample(LowVarianceResampler(r.n), b, rng)
    ps = particles(collection)
    for i in 1:r.n 
        ps[i] += r.std*randn(rng, 2)
    end
    return collection
end

@with_kw immutable MinPopResampler
    n::Int
    min_pop::Int
    std::Float64
end

function ParticleFilters.resample(r::MinPopResampler, b, rng::AbstractRNG)
    collection = resample(LowVarianceResampler(r.n), b, rng)
    ps = particles(collection)
    nu = length(unique(ps))
    if r.min_pop > nu
        is = rand(rng, 1:r.n, r.min_pop - nu)
        for i in is
            ps[i] += r.std*randn(rng, 2)
        end
    end
    @show length(unique(ps))
    @show length(ps)
    return collection
end


immutable ObsAdaptiveParticleFilter{S} <: Updater{ParticleFilters.ParticleCollection}
    pomdp::POMDP{S}
    resample::Any
    max_frac_replaced::Float64
    rng::AbstractRNG
end

POMDPs.initialize_belief{S}(up::ObsAdaptiveParticleFilter{S}, d::Any) = resample(up.resample, d, up.rng)
POMDPs.update(up::ObsAdaptiveParticleFilter, b, a, o) = update(up, resample(up.resample, b, up.rng), a, o)

function POMDPs.update{S}(up::ObsAdaptiveParticleFilter{S}, b::ParticleFilters.ParticleCollection, a, o)
    ps = particles(b)
    pm = Array(S, 0)
    wm = Array(Float64, 0)
    sizehint!(pm, n_particles(b))
    sizehint!(wm, n_particles(b))
    all_terminal = true
    for i in 1:n_particles(b)
        s = ps[i]
        if !isterminal(up.pomdp, s)
            all_terminal = false
            sp = generate_s(up.pomdp, s, a, up.rng)
            push!(pm, sp)
            od = observation(up.pomdp, s, a, sp)
            push!(wm, pdf(od, o))
        end
    end
    if all_terminal
        # warn("All states in particle collection were terminal.")
        return initialize_belief(up, initial_state_distribution(up.pomdp))
    end

    pc = resample(up.resample, WeightedParticleBelief{S}(pm, wm, sum(wm), nothing), up.rng)
    ps = particles(pc)
    for i in 1:length(ps)
        ps[i] += 0.001*randn(up.rng, 2)
    end

    od = observation(up.pomdp, a, o) # will only work for LightDark
    frac_replaced = up.max_frac_replaced*max(0.0, 1.0 - maximum(wm)/pdf(od, o))
    n_replaced = floor(Int, frac_replaced*length(ps))
    is = randperm(up.rng, length(ps))[1:n_replaced]
    for i in is
        ps[i] = o + LightDarkPOMDPs.obs_std(up.pomdp, o[1])*randn(up.rng, 2)
    end
    return pc
end

POMCPOW.belief_type(::Type{ObsAdaptiveParticleFilter{Vec2}}, ::Type{LightDark2DTarget}) = POWNodeBelief{Vec2, Vec2, Vec2, LightDark2DTarget}

function POMCPOW.init_node_belief(::ObsAdaptiveParticleFilter, p::LightDark2DTarget, s::Vec2, a::Vec2, o::Vec2, sp::Vec2)
    POWNodeBelief(p, s, a, o, sp)
end

function POMCPOW.push_weighted!(b::POWNodeBelief, up::ObsAdaptiveParticleFilter, s::Vec2, sp::Vec2)
    od = observation(b.model, s, b.a, sp)
    w = pdf(od, b.o)
    ood = observation(b.model, b.a, b.o)
    frac_replaced = up.max_frac_replaced*max(0.0, 1.0 - w/pdf(ood, b.o))
    insert!(b.dist, sp, w*(1.0-frac_replaced))
    sp2 = rand(up.rng, ood)
    insert!(b.dist, sp2, w*frac_replaced)
end