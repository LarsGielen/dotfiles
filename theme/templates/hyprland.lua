-- {{banner}}
-- Active palette: {{label}} ({{name}})
--
-- rgb(RRGGBB) is what Hyprland's colour parser accepts; CSS-style
-- rgba(r,g,b,a) silently fails to parse.
return {
    base          = "{{base:rgb}}",
    mantle        = "{{mantle:rgb}}",
    surface       = "{{surface:rgb}}",
    surfaceAlt    = "{{surfaceAlt:rgb}}",
    overlay       = "{{overlay:rgb}}",
    border        = "{{border:rgb}}",
    text          = "{{text:rgb}}",
    subtext       = "{{subtext:rgb}}",
    accent        = "{{accent:rgb}}",
    onAccent      = "{{onAccent:rgb}}",

    -- Window borders: the accent blended toward base
    accentMuted   = "{{accent:mix30:rgb}}",
    accentDim     = "{{accent:mix72:rgb}}",

    black         = "{{black:rgb}}",
    red           = "{{red:rgb}}",
    green         = "{{green:rgb}}",
    yellow        = "{{yellow:rgb}}",
    blue          = "{{blue:rgb}}",
    magenta       = "{{magenta:rgb}}",
    cyan          = "{{cyan:rgb}}",
    white         = "{{white:rgb}}",
    brightBlack   = "{{brightBlack:rgb}}",
    brightRed     = "{{brightRed:rgb}}",
    brightGreen   = "{{brightGreen:rgb}}",
    brightYellow  = "{{brightYellow:rgb}}",
    brightBlue    = "{{brightBlue:rgb}}",
    brightMagenta = "{{brightMagenta:rgb}}",
    brightCyan    = "{{brightCyan:rgb}}",
    brightWhite   = "{{brightWhite:rgb}}",
}
