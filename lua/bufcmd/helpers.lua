local M = {}

function M.fetch_all_buffers(sets)
  local bufs = vim.api.nvim_list_bufs()
  local bufcmd_table = {}
  local name_modifier = sets.show_extensions and ":t" or ":t:r"

  for _, number in ipairs(bufs) do
    if vim.bo[number].buflisted then
      local path = vim.api.nvim_buf_get_name(number)
      local name = vim.fn.fnamemodify(path, name_modifier)

      -- Handle nameless buffers
      name = name == "" and sets.chars.nameless_buffer or name

      -- Restrict name length
      if name and #name > sets.max_name_length then
        name = string.sub(name, 1, sets.max_name_length - 1)
        name = name .. "…"
      end

      local active = number == vim.api.nvim_get_current_buf()
      local modified = vim.bo[number].modified

      table.insert(bufcmd_table, {
        number = number,
        name = name,
        active = active,
        modified = modified,
        path = path,
      })
    end
  end

  return bufcmd_table
end

function M.get_highlight(bufcmd_buffer)
  local highlight = "BufCmdOther"

  if bufcmd_buffer.active and bufcmd_buffer.modified then
    highlight = "BufCmdActiveModified"
  elseif bufcmd_buffer.active then
    highlight = "BufCmdActive"
  elseif bufcmd_buffer.modified then
    highlight = "BufCmdModified"
  end

  return highlight
end

local function shallow_copy(table)
  local copy = {}
  for key, value in pairs(table) do
    copy[key] = value
  end
  return copy
end

local function count_names(bufcmd_table)
  local name_counts = {}
  for _, each in ipairs(bufcmd_table) do
    name_counts[each.name] = (name_counts[each.name] or 0) + 1
  end
  return name_counts
end

local function modify_duplicates(bufcmd_table, modification)
  local name_counts = count_names(bufcmd_table)
  local modified_table = shallow_copy(bufcmd_table)

  for _, item in ipairs(modified_table) do
    if name_counts[item.name] > 1 then item.name = modification(item) end
  end

  return modified_table
end

function M.add_path_to_duplicates(bufcmd_table)
  local function modify(each)
    local path_fragment = vim.fn.fnamemodify(each.path, ":p:h:t")
    return path_fragment .. "/" .. each.name
  end
  return modify_duplicates(bufcmd_table, modify)
end

function M.add_extension_to_duplicates(bufcmd_table)
  local function modify(each) return vim.fn.fnamemodify(each.path, ":t") end
  return modify_duplicates(bufcmd_table, modify)
end

function M.add_characters(bufcmd_table, chars)
  local modified_table = shallow_copy(bufcmd_table)

  for _, each in ipairs(modified_table) do
    if each.modified then
      each.name = chars.modified_left .. each.name .. chars.modified_right
    end

    if each.active then
      each.name = chars.left_brace .. each.name .. chars.right_brace
    else
      each.name = string.rep(" ", #chars.left_brace)
        .. each.name
        .. string.rep(" ", #chars.right_brace)
    end
  end

  return modified_table
end

return M
