describe("jiejie startup", function()
  local tmpdirs = {}

  after_each(function()
    for _, tmpdir in ipairs(tmpdirs) do
      vim.fn.delete(tmpdir, "rf")
    end
    tmpdirs = {}
  end)

  it("opens the default log in a jj repo without reporting a startup error", function()
    local repo_root = vim.uv.cwd()
    local tmpdir = vim.fn.tempname()

    vim.fn.mkdir(tmpdir, "p")
    table.insert(tmpdirs, tmpdir)

    local init = vim.system({ "jj", "git", "init", tmpdir }, { text = true }):wait()
    if init.code ~= 0 then
      error((init.stdout or "") .. (init.stderr or ""))
    end

    vim.fn.writefile({ "hello" }, vim.fs.joinpath(tmpdir, "file.txt"))

    local startup = vim
      .system({
        "nvim",
        "--headless",
        "--clean",
        "-n",
        "--cmd",
        "lua vim.opt.runtimepath:append(" .. string.format("%q", repo_root) .. ")",
        "-c",
        "lua require('jiejie').setup()",
        "-c",
        "J",
        "-c",
        "sleep 1000m",
        "-c",
        "qa!",
      }, {
        cwd = tmpdir,
        text = true,
      })
      :wait()

    local output = (startup.stdout or "") .. (startup.stderr or "")
    if startup.code ~= 0 then
      error(output)
    end
    if output:match("E%d%d%d%d:") or output:match("Error in command line") or output:match("stack traceback") or output:match("Error getting log") then
      error(output)
    end
  end)
end)
