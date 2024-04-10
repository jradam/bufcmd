return {
  max_name_length = 20,
  show_extensions = false,
  compensation = 18,
  reverse_order = false,
  chars = {
    max_string = " ... ",
    left_brace = "[",
    right_brace = "]",
    modified_left = "",
    modified_right = "+",
    nameless_buffer = "-",
  },
  theme = {
    active = { fg = "", bg = "" },
    inactive = { fg = "", bg = "" },
    modified = { fg = "", bg = "" },
    active_modified = { fg = "", bg = "" },
  },
  keys = {
    next_buffer = "<Tab>",
    prev_buffer = "<S-Tab>",
    close_buffer = "<leader>x",
    close_others = "<leader>z",
    start_bufcmd = "<leader><Tab>",
    stop_bufcmd = "<leader><S-Tab>",
    run_compensation_test = "<leader>T",
  },
}
