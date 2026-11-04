module UpdateLab

using AlgorithmConfigLab: AbstractAlgorithmConfig

"""Base configuration type for update policies."""
abstract type AbstractUpdate <: AbstractAlgorithmConfig end

export SweepDirection, Forward, Backward, SweepState
export CircularSweep, ZigzagSweep, sweep_states, completes_sweep
public AbstractUpdate, AbstractSweep

include("state.jl")
include("sweep.jl")
include("configuration.jl")

end
