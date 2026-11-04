# ------------------------------------------------------------------------------
# SweepState — one typed step's position in a sweep
#
#   site — the position to update
#   D    — the scan direction, encoded in the state type
#   completed_sweeps — completed period count
# ------------------------------------------------------------------------------

abstract type SweepDirection end
struct Forward <: SweepDirection end
struct Backward <: SweepDirection end

struct SweepState{D<:SweepDirection}
    site::Int
    completed_sweeps::Int
end
