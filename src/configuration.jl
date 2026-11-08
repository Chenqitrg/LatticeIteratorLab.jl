# Stable JSON identities live outside numerical configuration structs.
const CONFIG_REGISTRY = ExperimentLab.ConfigRegistry(
    "UpdateLab.CircularSweep" => CircularSweep,
    "UpdateLab.ZigzagSweep" => ZigzagSweep,
)

ExperimentLab.config_registry(::Type{<:AbstractUpdate}) = CONFIG_REGISTRY
