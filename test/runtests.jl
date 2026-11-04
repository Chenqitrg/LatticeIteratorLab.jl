using Test, UpdateLab
include("sweep_test.jl")
include("sweep_configuration_test.jl")

@testset "scheduling needs no tensor or algorithm runtime" begin
    loaded = Set(pkg.name for pkg in keys(Base.loaded_modules))
    for name in ("TensorKit", "PeriodicProductsLab", "MPSSplitLab", "ExecutionLab")
        @test !(name in loaded)
    end
end
