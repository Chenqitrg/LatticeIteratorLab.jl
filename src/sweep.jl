abstract type AbstractSweep <: AbstractUpdate end

"""
    CircularSweep(; max_sweeps)

Visit every site from left to right on each sweep. Bind the period length
with `sweep_states(sweep, site_count)`; constructing the iterator changes no factors.
"""
struct CircularSweep <: AbstractSweep
    max_sweeps::Int
    function CircularSweep(max_sweeps::Integer)
        max_sweeps >= 0 || throw(ArgumentError("max_sweeps must be non-negative"))
        return new(Int(max_sweeps))
    end
end
CircularSweep(; max_sweeps::Integer) = CircularSweep(max_sweeps)

"""
    ZigzagSweep(; max_sweeps)

Visit `1, 2, …, N, N-1, …, 2` on each round trip. Requires at least two sites.
Bind N with `sweep_states(sweep, N)`.
"""
struct ZigzagSweep <: AbstractSweep
    max_sweeps::Int
    function ZigzagSweep(max_sweeps::Integer)
        max_sweeps >= 0 || throw(ArgumentError("max_sweeps must be non-negative"))
        return new(Int(max_sweeps))
    end
end
ZigzagSweep(; max_sweeps::Integer) = ZigzagSweep(max_sweeps)

struct SweepStates{S<:AbstractSweep}
    sweep::S
    site_count::Int
end

"""
    sweep_states(sweep, site_count)

Bind a traversal configuration to a site domain. Custom sweeps implement this
method and return an iterator of `SweepState` values with integer cursor state.
"""
sweep_states(sweep::AbstractSweep, ::Integer) =
    throw(ArgumentError("$(typeof(sweep)) must implement UpdateLab.sweep_states"))

function sweep_states(sweep::Union{CircularSweep,ZigzagSweep}, site_count::Integer)
    minimum = sweep isa ZigzagSweep ? 2 : 1
    site_count >= minimum || throw(ArgumentError("$(typeof(sweep)) requires at least $minimum sites"))
    return SweepStates(sweep, Int(site_count))
end

Base.IteratorSize(::Type{<:SweepStates}) = Base.HasLength()
Base.IteratorEltype(::Type{<:SweepStates}) = Base.HasEltype()
Base.eltype(::Type{<:SweepStates}) = SweepState
_steps_per_sweep(s::SweepStates{CircularSweep}) = s.site_count
_steps_per_sweep(s::SweepStates{ZigzagSweep}) = 2s.site_count - 2
Base.length(s::SweepStates) = _steps_per_sweep(s) * s.sweep.max_sweeps

function Base.show(io::IO, s::SweepStates)
    sweeps = s.sweep.max_sweeps
    updates = length(s)
    print(io, nameof(typeof(s.sweep)), ": ", s.site_count,
        s.site_count == 1 ? " site, " : " sites, ", sweeps,
        sweeps == 1 ? " sweep (" : " sweeps (", updates,
        updates == 1 ? " update)" : " updates)")
end

Base.show(io::IO, ::MIME"text/plain", s::SweepStates) = show(io, s)

Base.iterate(s::SweepStates) = iterate(s, 0)

function Base.iterate(s::SweepStates{CircularSweep}, cursor::Int)
    cursor >= length(s) && return nothing
    completed, phase = divrem(cursor, s.site_count)
    return SweepState{Forward}(phase + 1, completed), cursor + 1
end

function Base.iterate(s::SweepStates{ZigzagSweep}, cursor::Int)
    cursor >= length(s) && return nothing
    period = _steps_per_sweep(s)
    completed, phase = divrem(cursor, period)
    state = phase < s.site_count - 1 ?
        SweepState{Forward}(phase + 1, completed) :
        SweepState{Backward}(period - phase + 1, completed)
    return state, cursor + 1
end

"""
    completes_sweep(state, following_iteration)

Whether a completed update at `state` ends its sweep. `following_iteration` is
what `iterate` returns for the next step, or `nothing` after the last step.
This query does not advance the iterator or change a cache.
"""
function completes_sweep(
        state::SweepState,
        following_iteration::Union{Nothing,Tuple{SweepState,Int}},
    )
    return isnothing(following_iteration) ||
           first(following_iteration).completed_sweeps > state.completed_sweeps
end
