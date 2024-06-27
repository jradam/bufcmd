local M = {}

local function start_bufcmd() vim.cmd(":BufCmdStart") end
local function stop_bufcmd() vim.cmd(":BufCmdStop") end
local function next_buffer() vim.cmd(":bn") end
local function prev_buffer() vim.cmd(":bp") end
local function close_buffer() vim.cmd(":bw") end
local function close_others()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      buf ~= vim.api.nvim_get_current_buf()
      and vim.api.nvim_buf_is_loaded(buf)
    then
      local buftype = vim.bo[buf].buftype
      if buftype ~= "terminal" then
        vim.api.nvim_buf_delete(buf, { force = false })
      end
    end
  end
end

function M.apply_commands(sets)
  local keys = sets.keys

  local bindings = {
    {
      mode = "n",
      key = keys.start_bufcmd,
      action = start_bufcmd,
      desc = "Start BufCmd",
      update = false,
    },
    {
      mode = "n",
      key = keys.stop_bufcmd,
      action = stop_bufcmd,
      desc = "Stop BufCmd",
      update = false,
    },
    {
      mode = "n",
      key = keys.next_buffer,
      action = sets.reverse_order and prev_buffer or next_buffer,
      desc = "Next buffer",
      update = true,
    },
    {
      mode = "n",
      key = keys.prev_buffer,
      action = sets.reverse_order and next_buffer or prev_buffer,
      desc = "Prev buffer",
      update = true,
    },
    {
      mode = "n",
      key = keys.close_buffer,
      action = close_buffer,
      desc = "Close buffer",
      update = true,
    },
    {
      mode = "n",
      key = keys.close_others,
      action = close_others,
      desc = "Close others",
      update = true,
    },
  }

  for _, binding in ipairs(bindings) do
    local function with_refresh()
      binding.action()
      if binding.update then vim.cmd(":BufCmdRefresh") end
    end

    vim.keymap.set(
      binding.mode,
      binding.key,
      with_refresh,
      { desc = binding.desc, silent = true }
    )
  end
end

return M
