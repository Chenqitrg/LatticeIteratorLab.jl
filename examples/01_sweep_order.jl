# Run from UpdateLab: julia --project=. examples/01_sweep_order.jl
using UpdateLab
using Test

# A sweep is a traversal policy. Binding N makes an iterator of positions.
# Iteration does not touch any factors or caches.
circular = sweep_states(CircularSweep(max_sweeps=2), 4)
zigzag = sweep_states(ZigzagSweep(max_sweeps=2), 4)

display(circular)  # CircularSweep: 4 sites, 2 sweeps (8 updates)
display(zigzag)    # ZigzagSweep: 4 sites, 2 sweeps (12 updates)

@test [s.site for s in circular] == [1, 2, 3, 4, 1, 2, 3, 4]
@test [s.site for s in zigzag] == [1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2]
@test [s.completed_sweeps for s in circular] == [0, 0, 0, 0, 1, 1, 1, 1]
@test collect(zigzag)[4] isa SweepState{Backward}  # Turn at the right endpoint.

# iterate returns (position, cursor); the cursor is for the next iterate call.
position, cursor = iterate(circular)
following = iterate(circular, cursor)
@test position == SweepState{Forward}(1, 0)
@test !completes_sweep(position, following)
@test completes_sweep(SweepState{Forward}(4, 1), nothing)
println("Circular: ", [s.site for s in circular])
println("Zigzag:   ", [s.site for s in zigzag])
nothing
