using Accessors: @set
using ExperimentLab: @config, configtree
using Configurations: to_dict, from_dict

@testset "sweep configuration is independent of MPS" begin
    for original in (CircularSweep(max_sweeps=3), ZigzagSweep(max_sweeps=3))
        changed = @set original.max_sweeps = 2
        @test changed.max_sweeps == 2
        @test original.max_sweeps == 3
        @test from_dict(typeof(original), to_dict(original)) == original
    end
    config = @config """
    LatticeIteratorLab.CircularSweep
      max_sweeps: 2
    """
    @test length(sweep_states(config, 4)) == 8
    loaded = Set(pkg.name for pkg in keys(Base.loaded_modules))
    @test !("PMPSLab" in loaded)
    @test !("MPSKit" in loaded)
end

@testset "completed-sweep boundaries" begin
    for (sweep, boundaries) in ((CircularSweep(max_sweeps=2), [4, 8]),
                                (ZigzagSweep(max_sweeps=2), [6, 12]))
        positions = sweep_states(sweep, 4)
        current = iterate(positions)
        completed_at = Int[]
        index = 0
        while current !== nothing
            state, cursor = current
            following = iterate(positions, cursor)
            index += 1
            completes_sweep(state, following) && push!(completed_at, index)
            current = following
        end
        @test completed_at == boundaries
    end
    @test completes_sweep(SweepState{Forward}(1, 0), nothing)
end

import ExperimentLab

@testset "LatticeIteratorLab configuration identities" begin
    for config in (CircularSweep(max_sweeps=3), ZigzagSweep(max_sweeps=2)), defaults in (true, false)
        registry = ExperimentLab.config_registry(typeof(config))
        record = ExperimentLab.config_record(registry, config; include_defaults=defaults)
        @test record["type"] == "LatticeIteratorLab." * string(nameof(typeof(config)))
        @test haskey(record, "parameters")
        io = IOBuffer()
        ExperimentLab.writeconfig(io, config; include_defaults=defaults)
        text = String(take!(io))
        @test isequal(ExperimentLab.readconfig(IOBuffer(text), typeof(config)), config)
        @test isequal(ExperimentLab.readconfig(IOBuffer(text), registry), config)
    end
end
