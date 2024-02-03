local M = {}

local h = require("bufcmd.helpers")

local last_active = nil
local showing_left_max = false
local showing_right_max = false

function M.print(bufcmd_table, sets)
  local active_index = nil
  local max_length = vim.o.columns - sets.compensation
  local reserved_space = #sets.chars.max_string * 2

  local function can_add_buffer(new_length, current_length)
    local upcoming_length = current_length + new_length
    return upcoming_length <= (max_length - reserved_space)
  end

  local current_length = 0
  local visible_buffers = {}

  local function expand_left(from) -- Expand to the left of the active buffer
    for index = from - 1, 1, -1 do
      if can_add_buffer(#bufcmd_table[index].name, current_length) then
        table.insert(
          visible_buffers,
          1,
          { bufcmd_table[index].name, h.get_highlight(bufcmd_table[index]) }
        )
        current_length = current_length + #bufcmd_table[index].name
      else
        if not showing_left_max then
          table.insert(
            visible_buffers,
            1,
            { sets.chars.max_string, "BufCmdOther" }
          )
        end
        showing_left_max = true
        break
      end
    end
  end

  local function expand_right(from) -- Expand to the right of the active buffer
    for index = from + 1, #bufcmd_table do
      if can_add_buffer(#bufcmd_table[index].name, current_length) then
        table.insert(
          visible_buffers,
          { bufcmd_table[index].name, h.get_highlight(bufcmd_table[index]) }
        )
        current_length = current_length + #bufcmd_table[index].name
      else
        if not showing_right_max then
          table.insert(
            visible_buffers,
            { sets.chars.max_string, "BufCmdOther" }
          )
        end
        showing_right_max = true
        break
      end
    end
  end

  for index, buffer in ipairs(bufcmd_table) do
    if buffer.active then active_index = index end
  end

  -- If no active_index, just return
  if not active_index then return end

  -- Add active buffer first
  table.insert(visible_buffers, {
    bufcmd_table[active_index].name,
    h.get_highlight(bufcmd_table[active_index]),
  })
  current_length = #bufcmd_table[active_index].name

  if showing_left_max then
    -- FIXME: this never happens since showing_left_max happens within this loop
    -- But I need it to be that if showing_left_max WOULD be true, this happens
    print("right first")
    expand_right(active_index)
    expand_left(active_index)
  else -- Default behavior is same as showing_right_max
    print("left first")
    expand_left(active_index)
    expand_right(active_index)
  end

  showing_left_max = false
  showing_right_max = false

  return visible_buffers
end

return M
