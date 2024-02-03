local M = {}

local h = require("bufcmd.helpers")

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

  local function can_add_buffer_test(new_length, current_length)
    print("-------------------------")
    print("New length: " .. new_length)
    print("Current length: " .. current_length)
    local upcoming_length = current_length + new_length
    print("Upcoming length: " .. upcoming_length)
    print("Max length: " .. (max_length - reserved_space))
    print(
      "Can add: "
        .. (
          upcoming_length <= (max_length - reserved_space) and "true"
          or "false"
        )
    )
    return upcoming_length <= (max_length - reserved_space)
  end

  local function test_left(from)
    local test_buffers = {}
    local length = 0
    local hit_left = false

    for index = from - 1, 1, -1 do
      if can_add_buffer_test(#bufcmd_table[index].name, length) then
        table.insert(
          test_buffers,
          1,
          { bufcmd_table[index].name, h.get_highlight(bufcmd_table[index]) }
        )
        length = length + #bufcmd_table[index].name
      else
        hit_left = true
      end
    end
    return hit_left
  end

  local function test_right(from)
    local test_buffers = {}
    local length = 0
    local hit_right

    for index = from + 1, #bufcmd_table do
      if can_add_buffer(#bufcmd_table[index].name, length) then
        table.insert(
          test_buffers,
          { bufcmd_table[index].name, h.get_highlight(bufcmd_table[index]) }
        )
        length = length + #bufcmd_table[index].name
      else
        hit_right = true
      end
    end
    return hit_right
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

  local hit_left_max = test_left(active_index)
  -- local hit_right_max = test_right(active_index)

  print("Hit left max: " .. (hit_left_max and "true" or "false"))

  expand_left(active_index)
  expand_right(active_index)

  showing_left_max = false
  showing_right_max = false

  return visible_buffers
end

return M
