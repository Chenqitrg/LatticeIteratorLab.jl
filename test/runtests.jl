using Test, LatticeIteratorLab
include("sweep_test.jl")
include("sweep_configuration_test.jl")

@testset "traversal needs no tensor or optimization packages" begin
    loaded = Set(pkg.name for pkg in keys(Base.loaded_modules))
    for name in ("TensorKit", "PeriodicProductsLab", "PMPSLab", "ExecutionLab")
        @test !(name in loaded)
    end
end
