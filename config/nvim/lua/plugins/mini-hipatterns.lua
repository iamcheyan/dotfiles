return {
  {
    "echasnovski/mini.hipatterns",
    event = "LazyFile",
    opts = function()
      local hi = require("mini.hipatterns")
      return {
        highlighters = {
          hex_color = hi.gen_highlighter.hex_color(),
        },
      }
    end,
  },
}
