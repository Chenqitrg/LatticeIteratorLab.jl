import AlgorithmConfigLab: config_codecs

config_codecs(::Type{<:AbstractSweep}) = (
    "UpdateLab.CircularSweep" => CircularSweep,
    "UpdateLab.ZigzagSweep" => ZigzagSweep,
)
