local loaded_defaults = false

local default_scanner_range -- 300
-- I do this so that the points aren't massive and all clumped close together
local default_lower_bound   -- around 0.075
local default_upper_bound   -- around 0.10

local config = require("config")

RegisterHook("/Script/Subnautica2.SN2BaseScannerStation:GetActiveFilter", function(Context)
    -- For anyone reading this, I find these type annotations to be INCREDIBLY useful with VS Code + plugins + lua bindings
    ---@type ASN2BaseScannerStation
    local scanner = Context:get()

    if loaded_defaults == false then
        default_scanner_range = scanner.ScannerRadius
        default_lower_bound = scanner.PointScale.LowerBound.Value
        default_upper_bound = scanner.PointScale.UpperBound.Value
        loaded_defaults = true
    end

    local new_radius = config.CustomScannerRadius * 100

    scanner.ScannerRadius = new_radius

    local scale_multiplier = math.sqrt(default_scanner_range / new_radius)

    scanner.PointScale.LowerBound.Value = default_lower_bound * scale_multiplier
    scanner.PointScale.UpperBound.Value = default_upper_bound * scale_multiplier
end)