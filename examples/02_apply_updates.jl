# Run from LatticeIteratorLab: julia --project=. examples/02_apply_updates.jl
using LatticeIteratorLab
using Test

values = zeros(Int, 4)
positions = sweep_states(CircularSweep(max_sweeps=2), length(values))

# Constructing or traversing a schedule does not update the data.
@test collect(positions)[1] == SweepState{Forward}(1, 0)
@test values == [0, 0, 0, 0]

# The caller chooses what one local update means. No tensor package is needed.
for position in positions
    values[position.site] += 1
end
@test values == [2, 2, 2, 2]
println("Two circular sweeps updated each entry twice: ", values)
nothing
