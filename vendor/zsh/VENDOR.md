# vendor/zsh

Vendored zsh dependencies for the personal config. They are sourced through
`user/dotfiles/.config/zsh/vendor`, a symlink to this directory.

| Directory | Upstream | Version | License |
|---|---|---|---|
| `antidote` | https://github.com/mattmc3/antidote | 2.3.0 | MIT |

Update procedure: replace `antidote/` with the upstream release, update the
version above, then run `zsh -n` on `.zshenv`, `.zshrc`, `manifest.zsh`,
`rc/*.zsh` and start an isolated shell. Do not run `antidote update` against
the live cache without checking the resulting plugin revisions.
