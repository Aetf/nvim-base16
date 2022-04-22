-- Some useful links for making your own colorscheme:
-- https://github.com/chriskempson/base16
-- https://colourco.de/
-- https://color.adobe.com/create/color-wheel
-- http://vrl.cs.brown.edu/color

local M = {}
local hex_re = vim.regex('#\\x\\x\\x\\x\\x\\x')

local HEX_DIGITS = {
    ['0'] = 0,
    ['1'] = 1,
    ['2'] = 2,
    ['3'] = 3,
    ['4'] = 4,
    ['5'] = 5,
    ['6'] = 6,
    ['7'] = 7,
    ['8'] = 8,
    ['9'] = 9,
    ['a'] = 10,
    ['b'] = 11,
    ['c'] = 12,
    ['d'] = 13,
    ['e'] = 14,
    ['f'] = 15,
    ['A'] = 10,
    ['B'] = 11,
    ['C'] = 12,
    ['D'] = 13,
    ['E'] = 14,
    ['F'] = 15,
}

local function hex_to_rgb(hex)
    return HEX_DIGITS[string.sub(hex, 1, 1)] * 16 +  HEX_DIGITS[string.sub(hex, 2, 2)],
        HEX_DIGITS[string.sub(hex, 3, 3)] * 16 +  HEX_DIGITS[string.sub(hex, 4, 4)],
        HEX_DIGITS[string.sub(hex, 5, 5)] * 16 +  HEX_DIGITS[string.sub(hex, 6, 6)]
end

local function rgb_to_hex(r, g, b)
  return bit.tohex(bit.bor(bit.lshift(r, 16), bit.lshift(g, 8), b), 6)
end

local function darken(hex, pct)
    pct = 1 - pct
    local r, g, b = hex_to_rgb(string.sub(hex, 2))
    r = math.floor(r * pct)
    g = math.floor(g * pct)
    b = math.floor(b * pct)
    return string.format("#%s", rgb_to_hex(r, g, b))
end

-- This is a bit of syntactic sugar for creating highlight groups over vim.api.nvim_set_hl.
-- Note that this currently always overrides the group rather than update the existing one.
--
-- local hi = require('ucw.utils').highlight
-- hi.Comment = { fg='#ffffff', bg='#000000', italic=true }
-- hi.LspDiagnosticsDefaultError = 'DiagnosticError' -- Link to another group
--
-- This is equivalent to the following vimscript
--
-- hi Comment guifg=#ffffff guibg=#000000 gui=italic
-- hi! link LspDiagnosticsDefaultError DiagnosticError
--
-- Or the following lua
--
-- vim.api.nvim_set_hl(0, 'Comment', { fg='#ffffff', bg='#000000', italic=true })
-- vim.api.nvim_set_hl(0, 'LspDiagnosticsDefaultError', { link='DiagnosticError'})
M.highlight = setmetatable({}, {
  __newindex = function(_, hlgroup, args)
    if ('string' == type(args)) then
      vim.api.nvim_set_hl(0, hlgroup, { link = args })
      return
    else
      vim.api.nvim_set_hl(0, hlgroup, args)
    end
  end
})

function M.with_config(config)
    M.config = vim.tbl_extend("force", {
        telescope = true,
    }, config or M.config or {})
end

--- Creates a base16 colorscheme using the colors specified.
--
-- Builtin colorschemes can be found in the M.colorschemes table.
--
-- The default Vim highlight groups (including User[1-9]), highlight groups
-- pertaining to Neovim's builtin LSP, and highlight groups pertaining to
-- Treesitter will be defined.
--
-- It's worth noting that many colorschemes will specify language specific
-- highlight groups like rubyConstant or pythonInclude. However, I don't do
-- that here since these should instead be linked to an existing highlight
-- group.
--
-- @param colors (table) table with keys 'base00', 'base01', 'base02',
--   'base03', 'base04', 'base05', 'base06', 'base07', 'base08', 'base09',
--   'base0A', 'base0B', 'base0C', 'base0D', 'base0E', 'base0F'. Each key should
--   map to a valid 6 digit hex color. If a string is provided, the
--   corresponding table specifying the colorscheme will be used.
function M.setup(colors, config)
    M.with_config(config)

    if type(colors) == 'string' then
        colors = M.colorschemes[colors]
    end

    if vim.fn.exists('syntax_on') then
        vim.cmd('syntax reset')
    end
    vim.cmd('set termguicolors')

    M.colors = colors or M.colorschemes[vim.env.BASE16_THEME] or M.colorschemes['schemer-dark']
    local hi = M.highlight

    -- Vim editor colors
    hi.Normal       = { fg = M.colors.base05, bg = M.colors.base00, sp = nil }
    hi.Bold         = { fg = nil,             bg = nil,             sp = nil, bold = true }
    hi.Debug        = { fg = M.colors.base08, bg = nil,             sp = nil }
    hi.Directory    = { fg = M.colors.base0D, bg = nil,             sp = nil }
    hi.Error        = { fg = M.colors.base00, bg = M.colors.base08, sp = nil }
    hi.ErrorMsg     = { fg = M.colors.base08, bg = M.colors.base00, sp = nil }
    hi.Exception    = { fg = M.colors.base08, bg = nil,             sp = nil }
    hi.FoldColumn   = { fg = M.colors.base0C, bg = M.colors.base00, sp = nil }
    hi.Folded       = { fg = M.colors.base03, bg = M.colors.base01, sp = nil }
    hi.IncSearch    = { fg = M.colors.base01, bg = M.colors.base09, sp = nil }
    hi.Italic       = { fg = nil,             bg = nil,             sp = nil }
    hi.Macro        = { fg = M.colors.base08, bg = nil,             sp = nil }
    hi.MatchParen   = { fg = nil,             bg = M.colors.base03, sp = nil }
    hi.ModeMsg      = { fg = M.colors.base0B, bg = nil,             sp = nil }
    hi.MoreMsg      = { fg = M.colors.base0B, bg = nil,             sp = nil }
    hi.Question     = { fg = M.colors.base0D, bg = nil,             sp = nil }
    hi.Search       = { fg = M.colors.base01, bg = M.colors.base0A, sp = nil }
    hi.Substitute   = { fg = M.colors.base01, bg = M.colors.base0A, sp = nil }
    hi.SpecialKey   = { fg = M.colors.base03, bg = nil,             sp = nil }
    hi.TooLong      = { fg = M.colors.base08, bg = nil,             sp = nil }
    hi.Underlined   = { fg = M.colors.base08, bg = nil,             sp = nil }
    hi.Visual       = { fg = nil,             bg = M.colors.base02, sp = nil }
    hi.VisualNOS    = { fg = M.colors.base08, bg = nil,             sp = nil }
    hi.WarningMsg   = { fg = M.colors.base08, bg = nil,             sp = nil }
    hi.WildMenu     = { fg = M.colors.base08, bg = M.colors.base0A, sp = nil }
    hi.Title        = { fg = M.colors.base0D, bg = nil,             sp = nil }
    hi.Conceal      = { fg = M.colors.base0D, bg = M.colors.base00, sp = nil }
    hi.Cursor       = { fg = M.colors.base00, bg = M.colors.base05, sp = nil }
    hi.NonText      = { fg = M.colors.base03, bg = nil,             sp = nil }
    hi.LineNr       = { fg = M.colors.base04, bg = M.colors.base00, sp = nil }
    hi.SignColumn   = { fg = M.colors.base04, bg = M.colors.base00, sp = nil }
    hi.StatusLine   = { fg = M.colors.base05, bg = M.colors.base02, sp = nil }
    hi.StatusLineNC = { fg = M.colors.base04, bg = M.colors.base01, sp = nil }
    hi.VertSplit    = { fg = M.colors.base05, bg = M.colors.base00, sp = nil }
    hi.ColorColumn  = { fg = nil,             bg = M.colors.base01, sp = nil }
    hi.CursorColumn = { fg = nil,             bg = M.colors.base01, sp = nil }
    hi.CursorLine   = { fg = nil,             bg = M.colors.base01, sp = nil }
    hi.CursorLineNr = { fg = M.colors.base04, bg = M.colors.base01, sp = nil }
    hi.QuickFixLine = { fg = nil,             bg = M.colors.base01, sp = nil }
    hi.PMenu        = { fg = M.colors.base05, bg = M.colors.base01, sp = nil }
    hi.PMenuSel     = { fg = M.colors.base01, bg = M.colors.base05, sp = nil }
    hi.TabLine      = { fg = M.colors.base03, bg = M.colors.base01, sp = nil }
    hi.TabLineFill  = { fg = M.colors.base03, bg = M.colors.base01, sp = nil }
    hi.TabLineSel   = { fg = M.colors.base0B, bg = M.colors.base01, sp = nil }

    -- Standard syntax highlighting
    hi.Boolean      = { fg = M.colors.base09, bg = nil,             sp = nil }
    hi.Character    = { fg = M.colors.base08, bg = nil,             sp = nil }
    hi.Comment      = { fg = M.colors.base03, bg = nil,             sp = nil }
    hi.Conditional  = { fg = M.colors.base0E, bg = nil,             sp = nil }
    hi.Constant     = { fg = M.colors.base09, bg = nil,             sp = nil }
    hi.Define       = { fg = M.colors.base0E, bg = nil,             sp = nil }
    hi.Delimiter    = { fg = M.colors.base0F, bg = nil,             sp = nil }
    hi.Float        = { fg = M.colors.base09, bg = nil,             sp = nil }
    hi.Function     = { fg = M.colors.base0D, bg = nil,             sp = nil }
    hi.Identifier   = { fg = M.colors.base08, bg = nil,             sp = nil }
    hi.Include      = { fg = M.colors.base0D, bg = nil,             sp = nil }
    hi.Keyword      = { fg = M.colors.base0E, bg = nil,             sp = nil }
    hi.Label        = { fg = M.colors.base0A, bg = nil,             sp = nil }
    hi.Number       = { fg = M.colors.base09, bg = nil,             sp = nil }
    hi.Operator     = { fg = M.colors.base05, bg = nil,             sp = nil }
    hi.PreProc      = { fg = M.colors.base0A, bg = nil,             sp = nil }
    hi.Repeat       = { fg = M.colors.base0A, bg = nil,             sp = nil }
    hi.Special      = { fg = M.colors.base0C, bg = nil,             sp = nil }
    hi.SpecialChar  = { fg = M.colors.base0F, bg = nil,             sp = nil }
    hi.Statement    = { fg = M.colors.base08, bg = nil,             sp = nil }
    hi.StorageClass = { fg = M.colors.base0A, bg = nil,             sp = nil }
    hi.String       = { fg = M.colors.base0B, bg = nil,             sp = nil }
    hi.Structure    = { fg = M.colors.base0E, bg = nil,             sp = nil }
    hi.Tag          = { fg = M.colors.base0A, bg = nil,             sp = nil }
    hi.Todo         = { fg = M.colors.base0A, bg = M.colors.base01, sp = nil }
    hi.Type         = { fg = M.colors.base0A, bg = nil,             sp = nil }
    hi.Typedef      = { fg = M.colors.base0A, bg = nil,             sp = nil }

    -- Diff highlighting
    hi.DiffAdd     = { fg = M.colors.base0B, bg = M.colors.base00, sp = nil }
    hi.DiffChange  = { fg = M.colors.base03, bg = M.colors.base00, sp = nil }
    hi.DiffDelete  = { fg = M.colors.base08, bg = M.colors.base00, sp = nil }
    hi.DiffText    = { fg = M.colors.base0D, bg = M.colors.base00, sp = nil }
    hi.DiffAdded   = { fg = M.colors.base0B, bg = M.colors.base00, sp = nil }
    hi.DiffFile    = { fg = M.colors.base08, bg = M.colors.base00, sp = nil }
    hi.DiffNewFile = { fg = M.colors.base0B, bg = M.colors.base00, sp = nil }
    hi.DiffLine    = { fg = M.colors.base0D, bg = M.colors.base00, sp = nil }
    hi.DiffRemoved = { fg = M.colors.base08, bg = M.colors.base00, sp = nil }

    -- Git highlighting
    hi.gitcommitOverflow      = { fg = M.colors.base08, bg = nil,     sp = nil }
    hi.gitcommitSummary       = { fg = M.colors.base0B, bg = nil,     sp = nil }
    hi.gitcommitComment       = { fg = M.colors.base03, bg = nil,     sp = nil }
    hi.gitcommitUntracked     = { fg = M.colors.base03, bg = nil,     sp = nil }
    hi.gitcommitDiscarded     = { fg = M.colors.base03, bg = nil,     sp = nil }
    hi.gitcommitSelected      = { fg = M.colors.base03, bg = nil,     sp = nil }
    hi.gitcommitHeader        = { fg = M.colors.base0E, bg = nil,     sp = nil }
    hi.gitcommitSelectedType  = { fg = M.colors.base0D, bg = nil,     sp = nil }
    hi.gitcommitUnmergedType  = { fg = M.colors.base0D, bg = nil,     sp = nil }
    hi.gitcommitDiscardedType = { fg = M.colors.base0D, bg = nil,     sp = nil }
    hi.gitcommitBranch        = { fg = M.colors.base09, bg = nil,     sp = nil, bold = true }
    hi.gitcommitUntrackedFile = { fg = M.colors.base0A, bg = nil,     sp = nil }
    hi.gitcommitUnmergedFile  = { fg = M.colors.base08, bg = nil,     sp = nil, bold = true }
    hi.gitcommitDiscardedFile = { fg = M.colors.base08, bg = nil,     sp = nil, bold = true }
    hi.gitcommitSelectedFile  = { fg = M.colors.base0B, bg = nil,     sp = nil, bold = true }

    -- GitGutter highlighting
    hi.GitGutterAdd          = { fg = M.colors.base0B, bg = M.colors.base00,  sp = nil }
    hi.GitGutterChange       = { fg = M.colors.base0D, bg = M.colors.base00,  sp = nil }
    hi.GitGutterDelete       = { fg = M.colors.base08, bg = M.colors.base00,  sp = nil }
    hi.GitGutterChangeDelete = { fg = M.colors.base0E, bg = M.colors.base00,  sp = nil }

    -- Spelling highlighting
    hi.SpellBad   = { fg = nil, bg = nil, sp = M.colors.base08, undercurl = true }
    hi.SpellLocal = { fg = nil, bg = nil, sp = M.colors.base0C, undercurl = true }
    hi.SpellCap   = { fg = nil, bg = nil, sp = M.colors.base0D, undercurl = true }
    hi.SpellRare  = { fg = nil, bg = nil, sp = M.colors.base0E, undercurl = true }

    hi.DiagnosticError                    = { fg = M.colors.base08, bg = nil, sp = nil }
    hi.DiagnosticWarn                     = { fg = M.colors.base0E, bg = nil, sp = nil }
    hi.DiagnosticInfo                     = { fg = M.colors.base05, bg = nil, sp = nil }
    hi.DiagnosticHint                     = { fg = M.colors.base0C, bg = nil, sp = nil }
    hi.DiagnosticUnderlineError           = { fg = nil,             bg = nil, sp = M.colors.base08, undercurl = true }
    hi.DiagnosticUnderlineWarning         = { fg = nil,             bg = nil, sp = M.colors.base0E, undercurl = true }
    hi.DiagnosticUnderlineWarn            = { fg = nil,             bg = nil, sp = M.colors.base0E, undercurl = true }
    hi.DiagnosticUnderlineInformation     = { fg = nil,             bg = nil, sp = M.colors.base0F, undercurl = true }
    hi.DiagnosticUnderlineHint            = { fg = nil,             bg = nil, sp = M.colors.base0C, undercurl = true }

    hi.LspReferenceText                   = { fg = nil,             bg = nil, sp = M.colors.base04, underline = true }
    hi.LspReferenceRead                   = { fg = nil,             bg = nil, sp = M.colors.base04, underline = true }
    hi.LspReferenceWrite                  = { fg = nil,             bg = nil, sp = M.colors.base04, underline = true }
    hi.LspDiagnosticsDefaultError         = 'DiagnosticError'
    hi.LspDiagnosticsDefaultWarning       = 'DiagnosticWarn'
    hi.LspDiagnosticsDefaultInformation   = 'DiagnosticInfo'
    hi.LspDiagnosticsDefaultHint          = 'DiagnosticHint'
    hi.LspDiagnosticsUnderlineError       = 'DiagnosticUnderlineError'
    hi.LspDiagnosticsUnderlineWarning     = 'DiagnosticUnderlineWarning'
    hi.LspDiagnosticsUnderlineInformation = 'DiagnosticUnderlineInformation'
    hi.LspDiagnosticsUnderlineHint        = 'DiagnosticUnderlineHint'

    hi.TSAnnotation         = { fg = M.colors.base0F, bg = nil,           sp = nil }
    hi.TSAttribute          = { fg = M.colors.base0A, bg = nil,           sp = nil }
    hi.TSBoolean            = { fg = M.colors.base09, bg = nil,           sp = nil }
    hi.TSCharacter          = { fg = M.colors.base08, bg = nil,           sp = nil }
    hi.TSComment            = { fg = M.colors.base03, bg = nil,           sp = nil, italic = true }
    hi.TSConstructor        = { fg = M.colors.base0D, bg = nil,           sp = nil }
    hi.TSConditional        = { fg = M.colors.base0E, bg = nil,           sp = nil }
    hi.TSConstant           = { fg = M.colors.base09, bg = nil,           sp = nil }
    hi.TSConstBuiltin       = { fg = M.colors.base09, bg = nil,           sp = nil, italic = true }
    hi.TSConstMacro         = { fg = M.colors.base08, bg = nil,           sp = nil }
    hi.TSError              = { fg = M.colors.base08, bg = nil,           sp = nil }
    hi.TSException          = { fg = M.colors.base08, bg = nil,           sp = nil }
    hi.TSField              = { fg = M.colors.base05, bg = nil,           sp = nil }
    hi.TSFloat              = { fg = M.colors.base09, bg = nil,           sp = nil }
    hi.TSFunction           = { fg = M.colors.base0D, bg = nil,           sp = nil }
    hi.TSFuncBuiltin        = { fg = M.colors.base0D, bg = nil,           sp = nil, italic = true }
    hi.TSFuncMacro          = { fg = M.colors.base08, bg = nil,           sp = nil }
    hi.TSInclude            = { fg = M.colors.base0D, bg = nil,           sp = nil }
    hi.TSKeyword            = { fg = M.colors.base0E, bg = nil,           sp = nil }
    hi.TSKeywordFunction    = { fg = M.colors.base0E, bg = nil,           sp = nil }
    hi.TSKeywordOperator    = { fg = M.colors.base0E, bg = nil,           sp = nil }
    hi.TSLabel              = { fg = M.colors.base0A, bg = nil,           sp = nil }
    hi.TSMethod             = { fg = M.colors.base0D, bg = nil,           sp = nil }
    hi.TSNamespace          = { fg = M.colors.base08, bg = nil,           sp = nil }
    hi.TSNone               = { fg = M.colors.base05, bg = nil,           sp = nil }
    hi.TSNumber             = { fg = M.colors.base09, bg = nil,           sp = nil }
    hi.TSOperator           = { fg = M.colors.base05, bg = nil,           sp = nil }
    hi.TSParameter          = { fg = M.colors.base05, bg = nil,           sp = nil }
    hi.TSParameterReference = { fg = M.colors.base05, bg = nil,           sp = nil }
    hi.TSProperty           = { fg = M.colors.base05, bg = nil,           sp = nil }
    hi.TSPunctDelimiter     = { fg = M.colors.base0F, bg = nil,           sp = nil }
    hi.TSPunctBracket       = { fg = M.colors.base05, bg = nil,           sp = nil }
    hi.TSPunctSpecial       = { fg = M.colors.base05, bg = nil,           sp = nil }
    hi.TSRepeat             = { fg = M.colors.base0A, bg = nil,           sp = nil }
    hi.TSString             = { fg = M.colors.base0B, bg = nil,           sp = nil }
    hi.TSStringRegex        = { fg = M.colors.base0C, bg = nil,           sp = nil }
    hi.TSStringEscape       = { fg = M.colors.base0C, bg = nil,           sp = nil }
    hi.TSSymbol             = { fg = M.colors.base0B, bg = nil,           sp = nil }
    hi.TSTag                = { fg = M.colors.base0A, bg = nil,           sp = nil }
    hi.TSTagDelimiter       = { fg = M.colors.base0F, bg = nil,           sp = nil }
    hi.TSText               = { fg = M.colors.base05, bg = nil,           sp = nil }
    hi.TSStrong             = { fg = nil,             bg = nil,           sp = nil, bold = true,         }
    hi.TSEmphasis           = { fg = M.colors.base09, bg = nil,           sp = nil, italic = true,       }
    hi.TSUnderline          = { fg = M.colors.base00, bg = nil,           sp = nil, underline = true,    }
    hi.TSStrike             = { fg = M.colors.base00, bg = nil,           sp = nil, strikethrough = true }
    hi.TSTitle              = { fg = M.colors.base0D, bg = nil,           sp = nil }
    hi.TSLiteral            = { fg = M.colors.base09, bg = nil,           sp = nil }
    hi.TSURI                = { fg = M.colors.base09, bg = nil,           sp = nil, underline = true     }
    hi.TSType               = { fg = M.colors.base0A, bg = nil,           sp = nil }
    hi.TSTypeBuiltin        = { fg = M.colors.base0A, bg = nil,           sp = nil, italic = true        }
    hi.TSVariable           = { fg = M.colors.base08, bg = nil,           sp = nil }
    hi.TSVariableBuiltin    = { fg = M.colors.base08, bg = nil,           sp = nil, italic = true        }

    hi.TSDefinition      = { fg = nil, bg = nil, sp = M.colors.base04, underline = true }
    hi.TSDefinitionUsage = { fg = nil, bg = nil, sp = M.colors.base04, underline = true }
    hi.TSCurrentScope    = { fg = nil, bg = nil, sp = nil,             bold = true      }

    hi.NvimInternalError = { fg = M.colors.base00, bg = M.colors.base08,  sp = nil }

    hi.NormalFloat  = { fg = M.colors.base05, bg = M.colors.base00,       sp = nil }
    hi.FloatBorder  = { fg = M.colors.base05, bg = M.colors.base00,       sp = nil }
    hi.NormalNC     = { fg = M.colors.base05, bg = M.colors.base00,       sp = nil }
    hi.TermCursor   = { fg = M.colors.base00, bg = M.colors.base05,       sp = nil }
    hi.TermCursorNC = { fg = M.colors.base00, bg = M.colors.base05,       sp = nil }

    hi.User1 = { fg = M.colors.base08, bg = M.colors.base02,  sp = nil }
    hi.User2 = { fg = M.colors.base0E, bg = M.colors.base02,  sp = nil }
    hi.User3 = { fg = M.colors.base05, bg = M.colors.base02,  sp = nil }
    hi.User4 = { fg = M.colors.base0C, bg = M.colors.base02,  sp = nil }
    hi.User5 = { fg = M.colors.base01, bg = M.colors.base02,  sp = nil }
    hi.User6 = { fg = M.colors.base05, bg = M.colors.base02,  sp = nil }
    hi.User7 = { fg = M.colors.base05, bg = M.colors.base02,  sp = nil }
    hi.User8 = { fg = M.colors.base00, bg = M.colors.base02,  sp = nil }
    hi.User9 = { fg = M.colors.base00, bg = M.colors.base02,  sp = nil }

    hi.TreesitterContext = { fg = nil, bg = M.colors.base01,  sp = nil, italic = true }

    if M.config.telescope then
        if hex_re:match_str(M.colors.base00) and hex_re:match_str(M.colors.base01) and hex_re:match_str(M.colors.base02) then
            local darkerbg = darken(M.colors.base00, 0.1)
            local darkercursorline = darken(M.colors.base01, 0.1)
            local darkerstatusline = darken(M.colors.base02, 0.1)
            hi.TelescopeBorder       = { fg = darkerbg,         bg = darkerbg,             sp = nil }
            hi.TelescopePromptBorder = { fg = darkerstatusline, bg = darkerstatusline,     sp = nil }
            hi.TelescopePromptNormal = { fg = M.colors.base05,  bg = darkerstatusline,     sp = nil }
            hi.TelescopePromptPrefix = { fg = M.colors.base08,  bg = darkerstatusline,     sp = nil }
            hi.TelescopeNormal       = { fg = nil,              bg = darkerbg,             sp = nil }
            hi.TelescopePreviewTitle = { fg = darkercursorline, bg = M.colors.base0B,      sp = nil }
            hi.TelescopePromptTitle  = { fg = darkercursorline, bg = M.colors.base08,      sp = nil }
            hi.TelescopeResultsTitle = { fg = darkerbg,         bg = darkerbg,             sp = nil }
            hi.TelescopeSelection    = { fg = nil,              bg = darkerstatusline,     sp = nil }
            hi.TelescopePreviewLine  = { fg = nil,              bg = M.colors.base01,      sp = nil }
        end
    end

    hi.NotifyERRORBorder = { fg = M.colors.base08, bg = nil,  sp = nil }
    hi.NotifyWARNBorder  = { fg = M.colors.base0E, bg = nil,  sp = nil }
    hi.NotifyINFOBorder  = { fg = M.colors.base05, bg = nil,  sp = nil }
    hi.NotifyDEBUGBorder = { fg = M.colors.base0C, bg = nil,  sp = nil }
    hi.NotifyTRACEBorder = { fg = M.colors.base0C, bg = nil,  sp = nil }
    hi.NotifyERRORIcon   = { fg = M.colors.base08, bg = nil,  sp = nil }
    hi.NotifyWARNIcon    = { fg = M.colors.base0E, bg = nil,  sp = nil }
    hi.NotifyINFOIcon    = { fg = M.colors.base05, bg = nil,  sp = nil }
    hi.NotifyDEBUGIcon   = { fg = M.colors.base0C, bg = nil,  sp = nil }
    hi.NotifyTRACEIcon   = { fg = M.colors.base0C, bg = nil,  sp = nil }
    hi.NotifyERRORTitle  = { fg = M.colors.base08, bg = nil,  sp = nil }
    hi.NotifyWARNTitle   = { fg = M.colors.base0E, bg = nil,  sp = nil }
    hi.NotifyINFOTitle   = { fg = M.colors.base05, bg = nil,  sp = nil }
    hi.NotifyDEBUGTitle  = { fg = M.colors.base0C, bg = nil,  sp = nil }
    hi.NotifyTRACETitle  = { fg = M.colors.base0C, bg = nil,  sp = nil }
    hi.NotifyERRORBody = 'Normal'
    hi.NotifyWARNBody  = 'Normal'
    hi.NotifyINFOBody  = 'Normal'
    hi.NotifyDEBUGBody = 'Normal'
    hi.NotifyTRACEBody = 'Normal'

    vim.g.terminal_color_0  = M.colors.base00
    vim.g.terminal_color_1  = M.colors.base08
    vim.g.terminal_color_2  = M.colors.base0B
    vim.g.terminal_color_3  = M.colors.base0A
    vim.g.terminal_color_4  = M.colors.base0D
    vim.g.terminal_color_5  = M.colors.base0E
    vim.g.terminal_color_6  = M.colors.base0C
    vim.g.terminal_color_7  = M.colors.base05
    vim.g.terminal_color_8  = M.colors.base03
    vim.g.terminal_color_9  = M.colors.base08
    vim.g.terminal_color_10 = M.colors.base0B
    vim.g.terminal_color_11 = M.colors.base0A
    vim.g.terminal_color_12 = M.colors.base0D
    vim.g.terminal_color_13 = M.colors.base0E
    vim.g.terminal_color_14 = M.colors.base0C
    vim.g.terminal_color_15 = M.colors.base07
end

function M.available_colorschemes()
  return vim.tbl_keys(M.colorschemes)
end

M.colorschemes = {}
setmetatable(M.colorschemes, {
    __index = function(t, key)
        t[key] = require(string.format('colors.%s', key))
        return t[key]
    end,
})

-- #16161D is called eigengrau and is kinda-ish the color your see when you
-- close your eyes. It makes for a really good background.
M.colorschemes['schemer-dark'] = {
    base00 = '#16161D', base01 = '#3e4451', base02 = '#2c313c', base03 = '#565c64',
    base04 = '#6c7891', base05 = '#abb2bf', base06 = '#9a9bb3', base07 = '#c5c8e6',
    base08 = '#e06c75', base09 = '#d19a66', base0A = '#e5c07b', base0B = '#98c379',
    base0C = '#56b6c2', base0D = '#0184bc', base0E = '#c678dd', base0F = '#a06949',
}
M.colorschemes['schemer-medium'] = {
    base00 = '#212226', base01 = '#3e4451', base02 = '#2c313c', base03 = '#565c64',
    base04 = '#6c7891', base05 = '#abb2bf', base06 = '#9a9bb3', base07 = '#c5c8e6',
    base08 = '#e06c75', base09 = '#d19a66', base0A = '#e5c07b', base0B = '#98c379',
    base0C = '#56b6c2', base0D = '#0184bc', base0E = '#c678dd', base0F = '#a06949',
}

return M
