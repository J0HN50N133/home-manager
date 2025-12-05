return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      -- NOTE: The log_level is in `opts.opts`
      opts = {
        log_level = "DEBUG", -- or "TRACE"
        language = "中文",
      },
      strategies = {
        chat = {
          adapter = "gemini_cli",
        },
      },

      ---@type CodeCompanion.AdapterArgs
      adapters = {
        acp = {
          gemini_cli = function()
            return require("codecompanion.adapters").extend("gemini_cli", {
              defaults = {
                timeout = 120000, -- 2 minutes
                ---@type string
                oauth_credentials_path = vim.fs.abspath("~/.gemini/oauth_creds.json"),
              },
              parameters = {
                protocolVersion = 1,
                clientCapabilities = {
                  fs = { readTextFile = true, writeTextFile = true },
                  terminal = true,
                },
              },
              handlers = {
                auth = function(self)
                  ---@type string|nil
                  local oauth_credentials_path = self.defaults.oauth_credentials_path
                  return (oauth_credentials_path and vim.fn.filereadable(oauth_credentials_path)) == 1
                end,
              },
            })
          end,
          claude_code = function()
            return require("codecompanion.adapters").extend("claude_code", {
              defaults = {
                timeout = 120000, -- 2 minutes
              },
            })
          end,
        },
      },
    },
  },
}
