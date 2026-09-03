# This config: keymaps and where things live

A reference for the choices in this config. Everything here is also
discoverable from inside Neovim — see [Finding this out yourself](#finding-this-out-yourself).

The guiding rule: **use each plugin's own default/recommended keymaps.** Where a
binding replaced an older kickstart one, the old line is kept next to it in the
config as a `-- was: ...` comment, so reverting is uncommenting one line.

## Finding this out yourself

| Command                   | Shows                                                      |
| ------------------------- | ---------------------------------------------------------- |
| `<leader>sk`              | **Every keymap**, fuzzy-searchable (snacks.picker)         |
| press `<leader>` and wait | which-key menu for that prefix (also `g`, `]`, `[`, `z`)   |
| `:verbose map ]m`         | what a key does **and which file mapped it**               |
| `:Lazy`                   | installed plugins, load times, `?` for help                |
| `:Mason`                  | installed LSP servers, formatters, linters, debug adapters |
| `:ConformInfo`            | which formatter runs for this buffer                       |
| `:checkhealth`            | everything, including `vim.deprecated` and `vim.lsp`       |
| `:help lsp-defaults`      | Neovim's built-in LSP keymaps and options                  |
| `<leader>sp`              | this config's plugin specs                                 |
| `:lua Snacks.picker()`    | every available picker source                              |

**Check keymaps from a real file buffer, not the startup screen.** Plugins
declared with lazy.nvim `keys = {...}` (the pickers, the debug keys) are
registered at startup, but the treesitter textobject/movement maps are created
when that plugin loads on the first file you open — before that,
`:verbose map ]m` correctly reports "No mapping found".

Two `:verbose map` quirks: it matches from the start of the lhs
(`:verbose map m` will not find `]m`), and `<leader>` maps are looked up by the
resolved key (`:verbose map <space>ff`).

## Pickers (snacks.picker)

These are snacks.picker's [own recommended
keymaps](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md), used
verbatim. It also takes over `vim.ui.select`.

| Key                                                                      | Does                                                                            | (was)                        |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------------------- | ---------------------------- |
| `<leader><space>`                                                        | smart find files                                                                | `<leader><leader>` buffers   |
| `<leader>,`                                                              | buffers                                                                         |                              |
| `<leader>/`                                                              | grep                                                                            | `<leader>/` buffer lines     |
| `<leader>:`                                                              | command history                                                                 |                              |
| `<leader>ff` / `<leader>fr` / `<leader>fb`                               | files / recent / buffers                                                        | `<leader>sf` / `<leader>s.`  |
| `<leader>fc`                                                             | files in the Neovim config                                                      | `<leader>sn`                 |
| `<leader>fg` / `<leader>fp`                                              | git files / projects                                                            |                              |
| `<leader>sg` / `<leader>sw`                                              | grep / grep word under cursor (also visual)                                     | unchanged                    |
| `<leader>sb` / `<leader>sB`                                              | buffer lines / grep open buffers                                                | `<leader>/` and `<leader>s/` |
| `<leader>sd` / `<leader>sD`                                              | diagnostics / buffer diagnostics                                                |                              |
| `<leader>sh` / `<leader>sk` / `<leader>sR`                               | help / keymaps / resume                                                         | `<leader>sr` was resume      |
| `<leader>s"` / `<leader>sj` / `<leader>sm` / `<leader>su`                | registers / jumps / marks / undo history                                        |                              |
| `<leader>sc` / `<leader>sC` / `<leader>s/`                               | command history / commands / search history                                     |                              |
| `<leader>sq` / `<leader>sl`                                              | quickfix / location list                                                        |                              |
| `<leader>sa` / `<leader>sp` / `<leader>sH` / `<leader>si` / `<leader>sM` | autocmds / plugin specs / highlights / icons / man pages                        |                              |
| `<leader>uC`                                                             | colorschemes                                                                    | `<leader>st`                 |
| `<leader>g*`                                                             | git: `b`ranches, `l`og, `L`og line, `s`tatus, `S`tash, `d`iff hunks, `f`ile log |                              |
| `<leader>gi` `<leader>gI` `<leader>gp` `<leader>gP`                      | GitHub issues/PRs (needs the `gh` CLI)                                          |                              |

Two entries from snacks' list are deliberately left commented in `init.lua`:
`<leader>e` (Neo-tree owns file browsing, on `\`) and `<leader>n` (needs
snacks.notifier, which is not enabled).

## LSP

Mostly **Neovim's built-in defaults** now — the per-buffer `map(...)` calls in
the `LspAttach` handler in `init.lua` are commented out. Uncomment any one to
route that key through a picker again.

| Key                         | Does                                                          | Source                          |
| --------------------------- | ------------------------------------------------------------- | ------------------------------- |
| `grn` / `gra`               | rename / code action                                          | Neovim default                  |
| `grr` / `gri` / `grt`       | references / implementation / type definition                 | Neovim default (quickfix list)  |
| `grx`                       | run codelens                                                  | Neovim default                  |
| `gO`                        | document symbols                                              | Neovim default                  |
| `K`                         | hover                                                         | Neovim default                  |
| `<C-]>`, `<C-w>]`, `:tjump` | goto definition, via `'tagfunc'`                              | Neovim default                  |
| `<C-s>` (insert)            | signature help                                                | Neovim default                  |
| `]d` / `[d` / `]D` / `[D`   | next / prev / last / first diagnostic                         | Neovim default                  |
| `<C-w>d`                    | show diagnostic under cursor in a float                       | Neovim default                  |
| `gq`                        | format via LSP `'formatexpr'`                                 | Neovim default                  |
| `gd` / `gD`                 | definition / declaration **in a picker**                      | snacks.picker                   |
| `gr` / `gI` / `gy`          | references / implementation / type definition **in a picker** | snacks.picker                   |
| `gai` / `gao`               | incoming / outgoing calls                                     | snacks.picker                   |
| `<leader>ss` / `<leader>sS` | document / workspace symbols                                  | snacks.picker                   |
| `<leader>th`                | toggle inlay hints                                            | this config (no default exists) |
| `<leader>q`                 | diagnostics to the quickfix list                              | this config                     |

Note: `gr` is a prefix of Neovim's `gr*` maps, so pressing `gr` alone pauses for
`timeoutlen` (300ms) before firing. `grr` does the same job with no pause. Delete
the `gr` entry from the snacks `keys` table if the pause annoys you.

## Treesitter textobjects and movements

The plugin ships no keymaps; these are its README's recommended ones.

| Key                       | Does                                |
| ------------------------- | ----------------------------------- |
| `am` / `im`               | around / inside function            |
| `ac` / `ic`               | around / inside class               |
| `aa` / `ia`               | around / inside parameter           |
| `]m` / `[m`, `]M` / `[M`  | next / prev function start, end     |
| `]]` / `[[`, `][` / `[]`  | next / prev class start, end        |
| `]o` / `[o`               | next / prev loop                    |
| `]z` / `[z`               | next / prev fold                    |
| `<leader>a` / `<leader>A` | swap parameter with next / previous |

`]f`/`]t` (the previous, conflict-free set) are commented in the same block.

`]m` and `]]` are also mapped buffer-locally by Neovim's built-in ftplugins,
which would win, so the spec's `init` sets `no_go_maps`, `no_python_maps`,
`no_ruby_maps`, `no_rust_maps`, `no_php_maps` and `no_vim_maps`. The README's
blunter `vim.g.no_plugin_maps = true` is commented above it — it would also drop
markdown's `]]`/`[[` header jumps and man pages' `q`, `gO`, `j`/`k`.

Also from mini.nvim: `a`/`i` + `b q f t ...` (mini.ai), `an`/`al` for
next/last textobject, `sa`/`sd`/`sr` surround (mini.surround — which is why `s`
and `S` are mapped to `<nop>`), `gc` comment.

## Debugging, formatting, files

No defaults exist for nvim-dap, nvim-dap-view or nvim-lint, so these are this
config's own:

| Key                               | Does                                                                         |
| --------------------------------- | ---------------------------------------------------------------------------- |
| `<F5>` / `<F1>` / `<F2>` / `<F3>` | continue / step into / over / out                                            |
| `<F7>`                            | toggle the dap-view UI (`g?` inside it lists its own keys)                   |
| `<leader>b` / `<leader>B`         | toggle breakpoint / conditional breakpoint                                   |
| `<leader>cf`                      | format buffer (conform) — moved off `<leader>f`, which is now the find group |
| `\`                               | Neo-tree reveal                                                              |
| `<C-h/j/k/l>`                     | move between windows                                                         |
| `<Esc>`                           | clear search highlight                                                       |
| `<Esc><Esc>` (terminal)           | leave terminal mode                                                          |

## Where things live

| Path                                   | What                                                                              |
| -------------------------------------- | --------------------------------------------------------------------------------- |
| `init.lua`                             | options, base keymaps, and every plugin spec                                      |
| `lua/custom/plugins/*.lua`             | extra plugin specs (auto-imported)                                                |
| `lua/custom/plugins/omarchy-theme.lua` | colorscheme plugin for every installed Omarchy theme                              |
| `lua/omarchy/theme.lua`                | reads the current Omarchy theme and follows it live                               |
| `lua/kickstart/plugins/*.lua`          | opt-in kickstart modules; enabled ones are `require`d at the bottom of `init.lua` |
| `lua/config/remote_clipboard.lua`      | OSC 52 clipboard, active only under tmux/ssh                                      |
| `plugin/after/transparency.lua`        | clears background highlights, re-applied on every `ColorScheme`                   |
| `lazy-lock.json`                       | pinned plugin versions — tracked in git; update with `:Lazy update`               |

## Theming

The colorscheme is **not** set in `init.lua`; it follows the desktop theme.
`omarchy theme set <name>` rewrites `~/.local/state/omarchy/current/`, and
`lua/omarchy/theme.lua` watches that directory, so running Neovim instances
retint too. Check with `:lua print(vim.g.colors_name)` and
`omarchy theme current`. To pin a colorscheme instead, delete
`lua/custom/plugins/omarchy-theme.lua` plus the `require('omarchy.theme').setup()`
call at the end of `init.lua`, and set one there.

Colorscheme plugin `opts` (e.g. a Catppuccin flavour) only apply on the next
start when switching themes at runtime; the colorscheme name itself switches
immediately.
