return {
  "vlime/vlime",
  ft = { "lisp" },
  config = function()
    vim.g.vlime_leader = "<Space>"

    _G.vlime_build_cmd_lua = function(loader, eval)
      -- 直接返回 Lua Table，Neovim 会自动把它转换成 Vimscript List
      return {
        "sbcl",
        "--load",
        vim.api.nvim_get_runtime_file("lisp/start-vlime.lisp", false)[1],
      }
    end

    -- 3. 设置实现名称
    vim.g.vlime_cl_impl = "lua_proxy"

    -- 4. 建立极简桥接 (这是无法避免的唯一一行 Vimscript)
    -- 它的作用仅仅是：收到 Vlime 的调用 -> 转发给 Lua -> 返回结果
    vim.cmd([[
            function! VlimeBuildServerCommandFor_lua_proxy(loader, eval)
                return v:lua.vlime_build_cmd_lua(a:loader, a:eval)
            endfunction
        ]])
  end,
}
