if true then
  return {}
end

return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    provider = "gemini-cli",
    acp_providers = {
      ["gemini-cli"] = {
        auth_method = "",
      },
    },
  },
}
