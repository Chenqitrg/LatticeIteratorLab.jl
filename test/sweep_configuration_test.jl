using AlgorithmConfigLab: @config, @setconfig, config_registry, configspec, construct_config

@testset "sweep configuration is independent of MPS" begin
    for original in (CircularSweep(max_sweeps=3), ZigzagSweep(max_sweeps=3))
        changed = @setconfig original max_sweeps = 2
        @test changed.max_sweeps == 2
        @test original.max_sweeps == 3
        registry = config_registry(typeof(original))
        @test construct_config(configspec(original; registry); registry) == original
    end
    config = @config """
    UpdateLab.CircularSweep
      max_sweeps: 2
    """
    @test length(sweep_states(config, 4)) == 8
    loaded = Set(pkg.name for pkg in keys(Base.loaded_modules))
    @test !("MPSSplitLab" in loaded)
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
