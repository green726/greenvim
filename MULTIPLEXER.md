# Neovim as a terminal multiplexer

Built on Neovim 0.12's native `:detach` / `:connect` / `--remote-ui`; no plugin.
Implementation: `lua/plugins/multiplexer.lua`. Shell helpers live in `~/.bashrc`.
Session sockets: `$XDG_RUNTIME_DIR/nvim-sessions/<name>.sock`.

## Usage

| Where | Key / command | What it does |
|---|---|---|
| shell | `nt` | Neovim straight into a terminal |
| shell | `nvs [name]` | Attach to session `name` (default `main`), creating it if needed. Tab-completes session names. |
| inside Neovim's terminal | `nvs [name]` | Switch the current UI to that session instead of nesting Neovim |
| shell | `nvls` | List running sessions and delete stale socket files |
| Neovim | `\d` | Detach; the session and its terminals keep running. A plain `nvim` is saved on detach as `<folder>-<pid>` so `nvs` can find it. |
| Neovim | `\D`, `:Sessions`, dashboard `s` | View Sessions: every running session with its state, cwd and terminals (preview lists terminals and files). `Enter` attaches, `Ctrl-e` renames, `+ new session` starts one. |
| Neovim | `\R`, `:SessionRename [name]` | Rename the current session (prompts if no name). A plain `nvim` gets a name this way. Terminals already open in the session keep working: the old socket path stays as a hidden alias. |
| Neovim | `Alt-h/j/k/l` | Move between windows, also from terminal mode |
| inside Neovim's terminal | `nvim file`, `git commit` | Opens in the host Neovim (flatten.nvim); `git commit` waits until the buffer is closed |

`git commit` only goes through flatten if git uses nvim: `git config --global core.editor nvim`.

## Limits

- Detached sessions survive closing the terminal, not a logout or reboot.
  persistence.nvim restores files and window layout, not terminal processes.
- In terminal mode `Alt-h/j/k/l` move between windows, so shell programs don't receive them.

## Shell helpers (`~/.bashrc`)

```bash
alias nt='nvim +terminal'
_nvs_dir="${XDG_RUNTIME_DIR:-/tmp}/nvim-sessions"
nvs() {
    local name="${1:-main}"
    local sock="$_nvs_dir/$name.sock"
    if [[ -n $NVIM ]]; then
        # handled by the TermRequest autocmd in multiplexer.lua
        printf '\e]1337;nvs=%s\a' "$name"
    elif nvim --server "$sock" --remote-expr 1 &>/dev/null; then
        nvim --remote-ui --server "$sock"
    else
        mkdir -p "$_nvs_dir" && rm -f "$sock"
        nvim --listen "$sock" +terminal
    fi
}
nvls() {
    local s
    for s in "$_nvs_dir"/*.sock; do
        [[ -e $s ]] || continue
        if ! nvim --server "$s" --remote-expr 1 &>/dev/null; then rm -f "$s"
        # symlinks back into the dir are rename aliases (see multiplexer.lua)
        elif [[ ! -L $s || $(readlink -f "$s") != "$_nvs_dir"/* ]]; then basename "$s" .sock; fi
    done
}
_nvs() { mapfile -t COMPREPLY < <(compgen -W "$(nvls)" -- "${COMP_WORDS[COMP_CWORD]}"); }
complete -F _nvs nvs
```

Also in `~/.bashrc`: skip `export TERM=xterm-kitty` and `fastfetch` when `$NVIM` is set.
