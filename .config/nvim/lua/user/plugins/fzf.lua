local actions = require "fzf-lua.actions"
require "fzf-lua".setup {
    -- ignore all '.lua' and '.vim' files
    file_ignore_patterns = { "%.png$", "%.exe$", "%.tex$", "%.uasset$", "%.eps$", "%.pdf$", "%.sty$", "Documentation/", "Content/" },
    winopts = {
        fullscreen = true,
        preview = {
            vertical = "down:40%",
            layout = "vertical",
        },
    },
}
