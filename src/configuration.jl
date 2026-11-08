# Stable JSON identities live outside numerical configuration structs.
const CONFIG_REGISTRY = ExperimentLab.ConfigRegistry(
    "LatticeIteratorLab.CircularSweep" => CircularSweep,
    "LatticeIteratorLab.ZigzagSweep" => ZigzagSweep,
)

ExperimentLab.config_registry(::Type{<:AbstractUpdate}) = CONFIG_REGISTRY
