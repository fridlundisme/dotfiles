-- Follow the Omarchy desktop theme.
--
-- Every Omarchy theme ships a `neovim.lua` holding lazy.nvim specs: its
-- colorscheme plugin, plus a `LazyVim/LazyVim` entry whose `opts.colorscheme`
-- names the colorscheme to apply. This config is not LazyVim, so we read those
-- files ourselves: every installed theme contributes its plugin (lazily), and
-- the theme that is currently set decides which colorscheme is loaded.
--
-- `omarchy theme set` replaces ~/.local/state/omarchy/current/{theme,theme.name},
-- which is what `M.watch()` looks for, so a theme change lands in running
-- Neovim instances as well as new ones.
local M = {}

-- Used when Omarchy isn't installed, or names a colorscheme we can't load.
M.fallback = 'catppuccin-mocha'

local current_dir = vim.fs.joinpath(vim.env.HOME, '.local', 'state', 'omarchy', 'current')
local name_file = vim.fs.joinpath(current_dir, 'theme.name')

local theme_roots = {
  vim.fs.joinpath(vim.env.HOME, '.config', 'omarchy', 'themes'), -- user themes win
  vim.fs.joinpath(vim.env.OMARCHY_PATH or '/usr/share/omarchy', 'themes'),
}

---@return table[]|nil specs the lazy.nvim specs a theme's `neovim.lua` returns
local function read_theme(dir)
  local file = vim.fs.joinpath(dir, 'neovim.lua')
  if vim.fn.filereadable(file) == 0 then
    return nil
  end
  local ok, specs = pcall(dofile, file)
  return (ok and type(specs) == 'table') and specs or nil
end

local function colorscheme_of(specs)
  for _, spec in ipairs(specs) do
    if spec[1] == 'LazyVim/LazyVim' then
      return spec.opts and spec.opts.colorscheme
    end
  end
end

---The theme Omarchy currently has applied.
---@return string|nil name, string|nil colorscheme
function M.current()
  local name = (vim.fn.filereadable(name_file) == 1) and vim.trim(vim.fn.readfile(name_file)[1] or '') or nil
  local specs = read_theme(vim.fs.joinpath(current_dir, 'theme'))
  return name, specs and colorscheme_of(specs) or nil
end

---Colorscheme plugin specs for every Omarchy theme on this machine, so that
---switching themes never has to install anything first.
---@return table[]
function M.specs()
  local specs, seen = {}, {}

  local function add(spec, with_opts)
    if type(spec[1]) ~= 'string' or spec[1] == 'LazyVim/LazyVim' then
      return
    end
    local key = spec.name or spec[1]
    if seen[key] then
      return
    end
    seen[key] = true
    specs[#specs + 1] = {
      spec[1],
      name = spec.name,
      dependencies = spec.dependencies,
      -- A theme's `config` only runs when its plugin loads, so it is safe to
      -- keep for all of them. `opts` are merged by lazy.nvim across duplicate
      -- specs, so only the active theme's are kept (two Omarchy themes can
      -- share one plugin with different `opts`, e.g. Catppuccin's flavours).
      config = spec.config,
      opts = with_opts and spec.opts or nil,
      lazy = true,
      priority = 1000,
    }
  end

  -- The active theme first: its `opts` are the ones that should win.
  local active = read_theme(vim.fs.joinpath(current_dir, 'theme'))
  for _, spec in ipairs(active or {}) do
    add(spec, true)
  end

  for _, root in ipairs(theme_roots) do
    for name, kind in vim.fs.dir(root) do
      if kind == 'directory' or kind == 'link' then
        for _, spec in ipairs(read_theme(vim.fs.joinpath(root, name)) or {}) do
          add(spec, false)
        end
      end
    end
  end

  if vim.tbl_isempty(specs) then
    specs = { { 'catppuccin/nvim', name = 'catppuccin', lazy = true, priority = 1000 } }
  end

  return specs
end

---Load the colorscheme of the theme Omarchy currently has applied.
---@return string|nil colorscheme the name that was applied
function M.apply()
  local _, colorscheme = M.current()

  local candidates = {}
  if colorscheme then
    candidates[#candidates + 1] = colorscheme
    -- Some themes name the plugin rather than the colorscheme ("catppuccin-nvim").
    local without_suffix = (colorscheme:gsub('%-nvim$', ''))
    if without_suffix ~= colorscheme then
      candidates[#candidates + 1] = without_suffix
    end
  end
  candidates[#candidates + 1] = M.fallback

  for _, candidate in ipairs(candidates) do
    if candidate == vim.g.colors_name then
      return candidate -- already applied
    end
    if pcall(vim.cmd.colorscheme, candidate) then
      return candidate
    end
  end
end

---Re-apply whenever `omarchy theme set` swaps the current theme.
function M.watch()
  if vim.fn.isdirectory(current_dir) == 0 then
    return
  end

  local watcher = assert(vim.uv.new_fs_event())
  local applied = select(1, M.current())
  -- Several files are replaced per theme change; collapse them into one apply.
  local debounce = assert(vim.uv.new_timer())

  watcher:start(current_dir, {}, function()
    debounce:stop()
    debounce:start(
      200,
      0,
      vim.schedule_wrap(function()
        local name = select(1, M.current())
        if name and name ~= applied then
          applied = name
          M.apply()
        end
      end)
    )
  end)

  vim.api.nvim_create_autocmd('VimLeavePre', {
    desc = 'Stop watching the Omarchy theme',
    callback = function()
      debounce:stop()
      watcher:stop()
    end,
  })
end

function M.setup()
  M.apply()
  M.watch()
end

return M
