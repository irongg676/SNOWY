-- SNOWY Game Adapter — Steal a Brainrot Edition v2.6
-- Detect the full Roblox experience (including its sub-places) through UniverseId.
-- This is game recognition only; it does not falsely activate unfinished features.
local Adapter = {}

Adapter.TARGET_UNIVERSE_ID = 7709344486
Adapter.ROOT_PLACE_ID = 109983668079237
Adapter.GAME_NAME = "Steal a Brainrot"

function Adapter.getStatus(placeId, universeId)
    local place = tonumber(placeId) or 0
    local universe = tonumber(universeId) or 0

    -- UniverseId remains the same across places belonging to this experience.
    -- Root PlaceId is kept as a fallback for environments that do not expose GameId.
    local matched = universe == Adapter.TARGET_UNIVERSE_ID
        or place == Adapter.ROOT_PLACE_ID

    if matched then
        return {
            supported = true,
            detected = true,
            game = Adapter.GAME_NAME,
            placeId = place,
            universeId = universe,
            message = "تم التعرف على Steal a Brainrot — التوافق مع اللعبة مؤكد.",
            features = {
                sessionInfo = true,
                carryAutomation = false,
                deliveryDetection = false,
                autoExit = false,
                playerESP = false,
                serverValueFinder = false,
            },
        }
    end

    return {
        supported = false,
        detected = false,
        game = Adapter.GAME_NAME,
        placeId = place,
        universeId = universe,
        message = "هذه النسخة مخصصة لـ Steal a Brainrot. ادخل التجربة الأصلية ثم أعد تشغيل SNOWY.",
        features = {
            sessionInfo = true,
            carryAutomation = false,
            deliveryDetection = false,
            autoExit = false,
            playerESP = false,
            serverValueFinder = false,
        },
    }
end

return Adapter
