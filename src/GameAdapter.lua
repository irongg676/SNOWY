-- SNOWY Game Adapter API v1
-- Safe compatibility layer. A game-specific adapter must be explicitly implemented
-- against documented/authorized game interfaces; no remotes are guessed or fired.
local Adapter = {}

function Adapter.getStatus(placeId)
    return {
        supported = false,
        placeId = tonumber(placeId) or 0,
        message = "لا يوجد Game Adapter موثّق لهذه اللعبة حالياً.",
    }
end

-- Contract for future authorized adapters:
-- getStatus(placeId) -> { supported = boolean, message = string }
-- findCarryTarget() -> target or nil
-- carry(target) -> success, reason
-- isDeliveryComplete() -> boolean
-- onDeliveryComplete(callback) -> connection
-- ESP and server discovery must use documented, permitted data sources.

return Adapter
