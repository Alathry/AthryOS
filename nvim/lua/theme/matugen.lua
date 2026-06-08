local M = {}
function M.parse_matugen()
    local home = os.getenv("HOME")
    local file_path = home .. "/.cache/colors/colors.css"
    local colors = {}
    local f = io.open(file_path, "r")
    if not f then
        return { background = "#12131a", primary = "#9cd594", on_background = "#e3e1ec" }
    end
    for line in f:lines() do
        local name, hex = line:match("@define%-color%s+([%w_]+)%s+(#[%da-fA-F]+);")
        if name and hex then
            colors[name] = hex
        end
    end
    f:close()
    return colors
end
function M.apply_theme()
    local c = M.parse_matugen()
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end
    vim.g.colors_name = "matugen_dynamic"
    local highlights = {
        Normal         = { fg = c.on_background, bg = c.background },
        NormalFloat    = { fg = c.on_surface, bg = c.surface_container },
        FloatBorder    = { fg = c.outline, bg = c.surface_container },
        CursorLine     = { bg = c.surface_container_low },
        LineNr         = { fg = c.outline_variant },
        CursorLineNr   = { fg = c.primary, bold = true },
        Visual         = { bg = c.secondary_container, fg = c.on_secondary_container },
        Search         = { bg = c.tertiary_container, fg = c.on_tertiary_container },
        Comment        = { fg = c.outline, italic = true },
        Constant       = { fg = c.tertiary },
        String         = { fg = c.secondary },
        Identifier     = { fg = c.on_background },
        Function       = { fg = c.primary, bold = true },
        Statement      = { fg = c.primary },
        Type           = { fg = c.inverse_primary },
        Special        = { fg = c.tertiary_fixed_dim },
        DiagnosticError = { fg = c.error },
        DiagnosticWarn  = { fg = c.tertiary },
        DiagnosticInfo  = { fg = c.outline },
        DiagnosticHint  = { fg = c.primary_fixed_dim },
    }
    for group, opts in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, opts)
    end
end
return M
