# UpdateLab

Position and ordering policies for iterative local updates. A sweep is one such
policy. This small package currently provides circular and zigzag traversal,
direction types, and the position of one update. It does not depend on tensors,
product caches, optimization algorithms, or execution sessions.

## Review order

1. [01_sweep_order.jl](examples/01_sweep_order.jl): positions, directions, and completed sweep counts.
2. [02_apply_updates.jl](examples/02_apply_updates.jl): apply a schedule to an ordinary vector.
3. [src/state.jl](src/state.jl), then [src/sweep.jl](src/sweep.jl): the complete scheduling implementation.

Each example runs independently with `julia --project=. examples/<file>`.

## Interface

```julia
using UpdateLab

positions = sweep_states(CircularSweep(max_sweeps=2), 4)
for position in positions
    # Perform the application's local update at position.site.
    println(position)
end
```

For four sites, a circular sweep visits `1, 2, 3, 4`; a zigzag sweep visits
`1, 2, 3, 4, 3, 2`. The zigzag endpoint at site 4 carries `Backward` direction.
`SweepState{D}(site, completed_sweeps)` describes one position. The counter is
zero during the first sweep. The iterator does not mutate application data or
maintain caches; consumers decide what to do at each position.

`completes_sweep(position, following_iteration)` checks whether the current
update ends its sweep. Pass the next `iterate` result, or `nothing` at the end.
For custom sweep policies, implement `UpdateLab.sweep_states` for a subtype of
`UpdateLab.AbstractSweep`. The current protocol uses integer iterator cursors.

The configuration hierarchy is
`AbstractSweep <: AbstractUpdate <: AbstractAlgorithmConfig`.
`UpdateLab.AbstractUpdate` is the common base for update policies;
`UpdateLab.AbstractSweep` specializes it for sweep-based traversal.
Both abstract types are public and accessed with qualified names.

The package name allows other update schedules in the future. This extraction
introduces no generic tensor-update engine or additional scheduling strategies.

## Configuration and setup

Sweep policies are immutable ExperimentLab configurations, supporting
construction trees, parameter updates, and data interchange under `UpdateLab`
constructor names. Configurations defines the options; ExperimentLab provides tree construction,
display and JSON files.
Keep it beside this repository, then run:

```sh
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.test()'
```

The existing sweep implementation was extracted from MPSSplitLab; the direction
and position types follow the existing traversal convention. PeriodicProductsLab
retains its reviewed cache API unchanged. MPSSplitLab translates scheduling
positions to cache states at the call boundary; neither lower-level package
depends on the other.
