local M = {}
local default_options = require("bufcmd.options")
local apply_theme = require("bufcmd.theme")
local c = require("bufcmd.commands")
local h = require("bufcmd.helpers")

-- TODO:
-- if autocmd_id is false, should also stop commands from working
-- how to fully expose keys so that user can choose mode/binding/function etc?
-- add diagnostic colors
-- make ESC also trigger buf_cmd
-- optional make new buffers insert in the left of list
-- add shortcuts for moving selected buffer left or right in list
-- optional sorting (alphabetically, time open)
-- use some default highlight groups so the user doesn't have to set up themselves
-- find a programmatic way to determine command line available characters
-- add a "show messages" command

local function bufcmd(sets)
  local bufcmd_table = h.fetch_all_buffers(sets)

  -- Handle duplicate names, add characters, restrict length so fits in cmd line
  local with_paths = h.add_path_to_duplicates(bufcmd_table)
  local with_extensions = h.add_extension_to_duplicates(with_paths)
  local with_characters = h.add_characters(with_extensions, sets.chars)
  local with_visible = h.calculate_visible(with_characters, sets)

  local name_list = {}

  -- TODO: Buffer looping
  -----------------------------------
  -- when tabbing to a buffer past "...", it should move along and add a "..." to the start

  local test_list
  table.insert(test_list, { sets.chars.max_string, "BufCmdOther" })
  for _, each in ipairs(with_visible) do
    table.insert(test_list, { each.name, h.get_highlight(each) })
  end
  table.insert(test_list, { sets.chars.max_string, "BufCmdOther" })
  -----------------------------------

  for _, each in ipairs(with_visible) do
    if each.visible then
      table.insert(name_list, { each.name, h.get_highlight(each) })
    else
      table.insert(name_list, { sets.chars.max_string, "BufCmdOther" })
      break
    end
  end

  -- Print the list
  vim.api.nvim_echo(name_list, false, {})
end

local autocmd_id = nil

-- Run BufCmd when the user performs actions
local function enable_autocmd(sets)
  if autocmd_id then return end

  autocmd_id = vim.api.nvim_create_autocmd({
    "CursorMoved",
    "InsertCharPre",
  }, { pattern = "*", callback = function() bufcmd(sets) end })
end

local function stop_bufcmd()
  if autocmd_id then
    vim.api.nvim_del_autocmd(autocmd_id)
    autocmd_id = nil
  end
end

function M.setup(opts)
  opts = opts or {}
  local sets = {}

  -- Override defaults with user opts where provided
  for key, value in pairs(default_options) do
    sets[key] = opts[key] or value
  end

  apply_theme(sets.theme)

  -- Only refresh when the autocmd is running, otherwise user has turned BufCmd off
  local function refresh_bufcmd()
    if autocmd_id then bufcmd(sets) end
  end

  local function start_bufcmd()
    enable_autocmd(sets)
    bufcmd(sets)
  end

  vim.api.nvim_create_user_command("BufCmdStart", start_bufcmd, {})
  vim.api.nvim_create_user_command("BufCmdStop", stop_bufcmd, {})
  vim.api.nvim_create_user_command("BufCmdRefresh", refresh_bufcmd, {})

  c.apply_commands(sets.keys)
  start_bufcmd()
end

return M
