-- Arbitrary two-digit number that should be well above what's necessary
local COMPENSATION_MAX = 80

-- This test determines the correct `compensation` value for the BufCmd options table.
-- It works by sending messages of increasing length to the command line.
-- When the prompt is triggered ("Press ENTER to continue") the user has their compensation value.
return function()
  local function test(number)
    if number < 0 then return end

    -- Plus one, since we want the value before the prompt was triggered
    local compensation = number + 1

    -- Add a character when we get into single digits to keep message length consistent
    local adjusted = compensation < 10 and " " .. compensation or compensation

    local description = "DO NOT press ENTER. You should set COMPENSATION to: "
      .. adjusted
      .. ". Press ESC to close."

    -- Starting at full width minus some big number, decrease size of number until prompt triggers
    local characters = string.rep(" ", vim.o.columns - number - #description)
    vim.api.nvim_echo({ { (description .. characters) } }, false, {})

    test(number - 1)
  end

  test(COMPENSATION_MAX)
end
