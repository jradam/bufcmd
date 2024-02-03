local M = {}

local h = require("bufcmd.helpers")

-- TODO:
-- What it does currently when S-Tab back:
--  ...  four  five  [six]
--  ...  three  four [five] ...
--  one  two  three [four] ...
--  one  two [three] four  ...
--  one [two] three  four  ...
-- [one] two  three  four  ...

-- What I want it to do when S-Tab back:
--  ...  four  five  [six]
--  ...  four [five]  six
--  ... [four] five   six
--  ... [three] four  five  ...
--  ... [two] three  four  ...
-- [one] two  three  four  ...

-- Simple terms: IF i am about to TAB onto a " ... ", then reveal a new tab in that direction. If, after tabbing, there are more hidden tabs in that direction, add a new " ... ".

function M.print(bufcmd_table, sets)
  local active_index = nil
  local max_length = vim.o.columns - sets.compensation
  local reserved_space = #sets.chars.max_string * 2
  local current_length = 0
  local visible_buffers = {}

  local added_left_max = false
  local added_right_max = false

  local function can_add_buffer(new_length)
    local upcoming_length = current_length + new_length
    local available_space = max_length - reserved_space
    return upcoming_length <= available_space
  end

  local function add_max_string(side)
    local max_string = { sets.chars.max_string, "BufCmdOther" }
    if side == "left" and not added_left_max then
      table.insert(visible_buffers, 1, max_string)
      added_left_max = true
    elseif side == "right" and not added_right_max then
      table.insert(visible_buffers, max_string)
      added_right_max = true
    end
  end

  local function expand_left(from)
    for index = from - 1, 1, -1 do
      if can_add_buffer(#bufcmd_table[index].name) then
        table.insert(
          visible_buffers,
          1,
          { bufcmd_table[index].name, h.get_highlight(bufcmd_table[index]) }
        )
        current_length = current_length + #bufcmd_table[index].name
      else
        add_max_string("left")
        break
      end
    end
  end

  local function expand_right(from)
    for index = from + 1, #bufcmd_table do
      if can_add_buffer(#bufcmd_table[index].name) then
        table.insert(
          visible_buffers,
          { bufcmd_table[index].name, h.get_highlight(bufcmd_table[index]) }
        )
        current_length = current_length + #bufcmd_table[index].name
      else
        add_max_string("right")
        break
      end
    end
  end

  for index, buffer in ipairs(bufcmd_table) do
    if buffer.active then
      active_index = index
      break
    end
  end

  -- If no active_index, just return
  if not active_index then return end

  -- Add active buffer first
  table.insert(visible_buffers, {
    bufcmd_table[active_index].name,
    h.get_highlight(bufcmd_table[active_index]),
  })
  current_length = current_length + #bufcmd_table[active_index].name

  expand_left(active_index)
  expand_right(active_index)

  return visible_buffers
end

return M
