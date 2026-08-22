-- Options are automatically loaded before lazy.nvim startup
-- LazyVim already sets clipboard = "unnamedplus", so the only thing needed for
-- yanks to reach other applications is a working provider for the + register.

local function have(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Mason's prebuilt tree-sitter-cli is linked against GLIBC 2.39 (Ubuntu
-- 24.04). This host is 22.04 / GLIBC 2.35, so that binary cannot run.
-- Prefer a cargo-built CLI on PATH before mason.nvim prepends its bin dir.
local cargo_bin = vim.fn.expand("~/.cargo/bin")
if vim.fn.isdirectory(cargo_bin) == 1 then
  vim.env.PATH = cargo_bin .. ":" .. vim.env.PATH
end

-- xclip, wl-copy and xsel are all detected by Neovim on their own, and under
-- WSLg the X11 clipboard is synced with the Windows clipboard, so a yank is
-- pasteable with ctrl+v anywhere. This fallback only matters on a WSL install
-- with no X11 or Wayland tool available, where clip.exe is always present.
if not (have("xclip") or have("wl-copy") or have("xsel")) and have("clip.exe") then
  -- Get-Clipboard returns CRLF, which would leave ^M at every line end.
  local paste = [==[[Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r`n","`n"))]==]
  local paste_cmd = { "powershell.exe", "-NoLogo", "-NoProfile", "-Command", paste }

  vim.g.clipboard = {
    name = "wsl-clip",
    copy = { ["+"] = { "clip.exe" }, ["*"] = { "clip.exe" } },
    paste = { ["+"] = paste_cmd, ["*"] = paste_cmd },
    -- powershell.exe start-up is slow, so avoid invoking it on every paste
    -- by trusting the cache of what Neovim last copied.
    cache_enabled = true,
  }
end
