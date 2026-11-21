#!/usr/bin/env bash
# Headless checks for the Neovim config: syntax, module loading, both themes.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v nvim >/dev/null 2>&1; then
  echo "nvim not found; skipping" >&2
  exit 0
fi

config="user/dotfiles/.config/nvim"

nvim --headless -u NONE -i NONE -n \
  --cmd "set runtimepath^=$PWD/$config" \
  +'lua for _, m in ipairs({"pack","core.options","core.syntax","core.indent","core.keymap","core.repeat-o","core.diagnostic","core.completion","core.python","core.project","core.neovide","core.lsp","core.treesitter","plugins","plugins.lualine","plugins.dependencies","plugins.vim-nix","plugins.toggleterm","plugins.code-runner","plugins.run","flat.theme","flat.cursor","flat.strings","flat.lualine","flat.black","flat.white","autocmds.templates"}) do local ok, err = pcall(require, m); if not ok then error(m .. ": " .. tostring(err)) end end' \
  +'lua assert(vim.g.indent_guides_selection == "hide")' \
  +'lua assert(vim.fn.exists(":IndentGuidesSelection") == 2)' \
  +'lua vim.cmd("IndentGuidesSelection invert"); assert(vim.g.indent_guides_selection == "invert")' \
  +'lua vim.cmd("IndentGuidesSelection hide"); assert(vim.g.indent_guides_selection == "hide")' \
  +qa

for theme in flatblack flatwhite; do
  nvim --headless -u NONE -i NONE -n \
    --cmd "set runtimepath^=$PWD/$config" \
    +"colorscheme $theme" \
    +"lua assert(vim.g.colors_name == '$theme')" \
    +qa
done

echo "nvim checks passed"
