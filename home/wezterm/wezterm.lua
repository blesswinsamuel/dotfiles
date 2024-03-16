-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- https://github.com/wez/wezterm/discussions/3426
---cycle through builtin dark schemes in dark mode, 
---and through light schemes in light mode
local function themeCycler(window, _)
    local allSchemes = wezterm.color.get_builtin_schemes()
    local currentMode = wezterm.gui.get_appearance()
    local currentScheme = window:effective_config().color_scheme

    local schemesToSearch = {}
    for name, _ in pairs(allSchemes) do
        table.insert(schemesToSearch, name)
    end

    for i = 1, #schemesToSearch, 1 do
        if schemesToSearch[i] == currentScheme then
            local overrides = window:get_config_overrides() or {}
            overrides.color_scheme = schemesToSearch[i + 1]
            wezterm.log_info("Switched to: " .. schemesToSearch[i + 1])
            window:set_config_overrides(overrides)
            return
        end
    end
end


-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.font = wezterm.font 'JetBrains Mono'
config.color_scheme = 'Guezwhoz'

config.enable_scroll_bar = true

config.keys = {
    {
        key = 'd',
        mods = 'SUPER',
        action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }
    },
    {
        key = 'd',
        mods = 'SUPER|SHIFT',
        action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }
    },
    -- Theme Cycler
    {
        key = "t",
        mods = "SUPER|CTRL",
        action = wezterm.action_callback(themeCycler)
    },
    -- Look up Scheme you switched to
    {
        key = "Escape",
        mods = "CTRL",
        action = wezterm.action.ShowDebugOverlay
    },
}

-- and finally, return the configuration to wezterm
return config
