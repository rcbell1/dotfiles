-- Headless helper used by setup.sh. Reads mason.nvim ensure_installed (this
-- config plus LazyVim extras), installs anything missing at the latest
-- registry version, and blocks until every package is present.
--
-- Not loaded during a normal editor session.

local M = {}

local SKIP = {
  ["tree-sitter-cli"] = true,
}

local function tools()
  local opts = {}
  if LazyVim and type(LazyVim.opts) == "function" then
    opts = LazyVim.opts("mason.nvim") or {}
  else
    local ok, util = pcall(require, "lazyvim.util")
    if ok and util.opts then
      opts = util.opts("mason.nvim") or {}
    end
  end

  local names = {}
  local seen = {}
  for _, name in ipairs(opts.ensure_installed or {}) do
    if not SKIP[name] and not seen[name] then
      seen[name] = true
      names[#names + 1] = name
    end
  end
  return names
end

local function refresh(registry)
  local done = false
  registry.refresh(function()
    done = true
  end)
  vim.wait(120000, function()
    return done
  end, 50)
end

local function start_install(pkg)
  if pkg:is_installed() or pkg:is_installing() then
    return false
  end
  local ok = pcall(function()
    pkg:install()
  end)
  if not ok then
    pcall(function()
      pkg:install({}, function() end)
    end)
  end
  return true
end

function M.sync()
  require("lazy").load({ plugins = { "mason.nvim" } })
  local registry = require("mason-registry")
  refresh(registry)

  local wanted = tools()
  if #wanted == 0 then
    print("DOTFILES_MASON:FAILED unknown= empty ensure_installed")
    vim.cmd("cquit 1")
    return
  end

  local unknown = {}
  local started = 0
  for _, name in ipairs(wanted) do
    if not registry.has_package(name) then
      unknown[#unknown + 1] = name
    else
      local pkg = registry.get_package(name)
      if pkg:is_installing() then
        started = started + 1
      elseif start_install(pkg) then
        started = started + 1
      end
    end
  end

  local ready = vim.wait(600000, function()
    for _, name in ipairs(wanted) do
      if registry.has_package(name) then
        if not registry.get_package(name):is_installed() then
          return false
        end
      end
    end
    return true
  end, 200)

  local missing = {}
  for _, name in ipairs(wanted) do
    if registry.has_package(name) then
      if not registry.get_package(name):is_installed() then
        missing[#missing + 1] = name
      end
    end
  end

  local status
  if #unknown > 0 or #missing > 0 or not ready then
    status = "FAILED"
  elseif started == 0 then
    status = "UP-TO-DATE"
  else
    status = "UPDATED"
  end

  -- Parsed by setup.sh. Keep this prefix stable.
  print(
    ("DOTFILES_MASON:%s unknown=%s missing=%s"):format(
      status,
      table.concat(unknown, ","),
      table.concat(missing, ",")
    )
  )

  if status == "FAILED" then
    vim.cmd("cquit 1")
  end
end

return M
