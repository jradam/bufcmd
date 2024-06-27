local M = {}
local default_options = require("bufcmd.options")
local apply_theme = require("bufcmd.theme")
local c = require("bufcmd.commands")
local h = require("bufcmd.helpers")
local p = require("bufcmd.print")

-- TODO:
-- if autocmd_id is false, should also stop commands from working
-- how to fully expose keys so that user can choose mode/binding/function etc?
-- add diagnostic colors
-- make ESC also trigger buf_cmd
-- add shortcuts for moving selected buffer left or right in list
-- optional sorting (alphabetically, time open)
-- find a programmatic way to determine command line available characters
-- add a "show messages" command
-- Add notes to options in the readme

local function bufcmd(sets)
  local bufcmd_table = h.fetch_all_buffers(sets)

  -- Handle duplicate names, add characters, restrict length so fits in cmd line
  local with_paths = h.add_path_to_duplicates(bufcmd_table)
  local with_extensions = h.add_extension_to_duplicates(with_paths)
  local with_characters = h.add_characters(with_extensions, sets.chars)
  local with_reversed = h.reverse(with_characters, sets.reverse_order)

  local list = p.print(with_reversed, sets)

  if list then vim.api.nvim_echo(list, false, {}) end
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

local function test_bufcmd()
  -- Enter normal mode
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
    "n",
    true
  )
  -- Small delay to ensure normal mode
  vim.defer_fn(require("bufcmd.testing"), 500)
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
  vim.api.nvim_create_user_command("BufCmdTest", test_bufcmd, {})
  vim.api.nvim_create_user_command("BufCmdRefresh", refresh_bufcmd, {})

  c.apply_commands(sets)
  start_bufcmd()
end

return M
