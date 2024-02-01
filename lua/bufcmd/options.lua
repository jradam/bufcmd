return {
  max_name_length = 20,
  show_extensions = false,
  compensation = 12,
  chars = {
    max_string = " ... ",
    left_brace = "[",
    right_brace = "]",
    modified_left_char = "",
    modified_right_char = "+",
    nameless_buffer_char = "-",
  },
  theme = {
    active = { fg = "", bg = "" },
    other = { fg = "", bg = "" },
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
