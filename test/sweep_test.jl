using Test, LatticeIteratorLab

@testset "ZigzagSweep — round-trip order" begin
    # Each round trip visits 1, ..., N, N-1, ..., 2.
    @test collect(st.site for st in sweep_states(ZigzagSweep(; max_sweeps=1), 4)) == [1, 2, 3, 4, 3, 2]
    @test collect(st.site for st in sweep_states(ZigzagSweep(; max_sweeps=1), 5)) == [1, 2, 3, 4, 5, 4, 3, 2]
    # The scan turns backward at the last site.
    states = collect(sweep_states(ZigzagSweep(; max_sweeps=1), 4))
    @test map(st -> st isa SweepState{Forward}, states) ==
          [true, true, true, false, false, false]
    # Repeat two complete round trips.
    @test collect(st.site for st in sweep_states(ZigzagSweep(; max_sweeps=2), 3)) ==
          [1, 2, 3, 2, 1, 2, 3, 2]
    @test collect(st.site for st in sweep_states(ZigzagSweep(; max_sweeps=2), 2)) ==
          [1, 2, 1, 2]
end

@testset "CircularSweep — laps and maximum sweeps" begin
    cs = sweep_states(CircularSweep(; max_sweeps=2), 4)
    @test collect(st.site for st in cs) == [1, 2, 3, 4, 1, 2, 3, 4]
    # Circular scans always move forward.
    @test all(st isa SweepState{Forward} for st in sweep_states(CircularSweep(; max_sweeps=2), 4))
    # One sweep visits each site once.
    @test length(collect(sweep_states(CircularSweep(; max_sweeps=1), 3))) == 3
    @test length(collect(sweep_states(CircularSweep(; max_sweeps=3), 1))) == 3
end

@testset "sweep constructors validate their configuration" begin
    @test_throws ArgumentError sweep_states(ZigzagSweep(; max_sweeps=1), 0)
    @test_throws ArgumentError sweep_states(ZigzagSweep(; max_sweeps=1), 1)
    @test_throws ArgumentError sweep_states(CircularSweep(; max_sweeps=1), 0)
    for Sweep in (ZigzagSweep, CircularSweep)
        @test_throws ArgumentError sweep_states(Sweep(; max_sweeps=-1), 2)
        @test isempty(collect(sweep_states(Sweep(; max_sweeps=0), 2)))
    end
end
