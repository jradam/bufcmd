-- Sets the highlight for a given highlight group with specified colors
local function set_highlight(group_name, fg, bg)
  local parts = { "highlight", group_name }

  if fg and fg ~= "" then table.insert(parts, "guifg=" .. fg) end
  if bg and bg ~= "" then table.insert(parts, "guibg=" .. bg) end

  vim.cmd(table.concat(parts, " "))
end

-- Applies a given color table to a highlight group (if highlight group is not already set)
local function apply(color_table, group_name, fallback)
  -- If the user (or colorscheme) has set this highlight group already, do nothing
  if vim.fn.hlexists(group_name) > 0 then return end

  -- If the user has set some custom colors in their BufCmd options, apply them
  if color_table.fg ~= "" or color_table.bg ~= "" then
    set_highlight(group_name, color_table.fg, color_table.bg)
    return
  end

  -- Otherwise use the fallback highlight group hardcoded below
  vim.cmd("highlight link " .. group_name .. " " .. fallback)
end

---Sets the BufCmd theme based on the 'theme' table from the plugin's options.
---@param theme table<string, {fg: string, bg: string}> The colors for each highlight group.
return function(theme)
  apply(theme.current, "BufCmdActive", "Normal")
  apply(theme.other, "BufCmdOther", "Comment")
  apply(theme.modified, "BufCmdModified", "String")
  apply(theme.current_modified, "BufCmdActiveModified", "Function")
end
