# Repository Guidelines

## Project Structure & Module Organization
- Root `flake.nix` defines the home-manager flake and pins inputs via `flake.lock`; `home.nix` is the primary module wiring packages, shell settings, and imported modules.
- Secrets are declared in `age.nix` and stored as encrypted files under `secrets/*.age`; decryption keys live at `~/.ssh/age`.
- Custom shell tooling lives in `fzf-pushd.nix`; extend it with additional modules by adding them to `home.nix` imports.
- Neovim configuration resides in `nvim/` (`init.lua`, `lua/` modules, `lazy-lock.json` lockfile, `stylua.toml` formatter config).

## Build, Test, and Development Commands
- `home-manager switch --flake .#johnsonlee` — build and apply the full configuration.
- `home-manager build --flake .#johnsonlee` — dry-run build to validate without activating.
- `nix flake check` — evaluate the flake inputs/outputs for sanity before pushing.
- For Neovim Lua changes, run `stylua nvim` to format according to `nvim/stylua.toml`.

## Coding Style & Naming Conventions
- Nix: 2-space indentation, trailing commas on list/map entries, prefer descriptive attribute names, and keep modules small and composable.
- Lua: follow `stylua` defaults in `nvim/stylua.toml` (2-space indent, 120-column width); use `snake_case` for locals/functions and descriptive module filenames.
- Shell snippets: favor POSIX sh-compatible constructs; keep helper scripts in `pkgs.writeShellScriptBin` blocks with clear variable names.

## Testing Guidelines
- No automated tests here; rely on Nix evaluation and home-manager builds as the safety net.
- Before committing, run `home-manager build --flake .#johnsonlee` to catch syntax or missing options; when changing secrets, ensure corresponding `secrets/*.age` files exist and can decrypt with the configured key.
- If modifying Neovim plugins or lockfiles, launch `nvim` to confirm startup is clean (no lazy.nvim errors).

## Commit & Pull Request Guidelines
- Use concise, conventional prefixes seen in history (`feat:`, `chore:`, `fix:`, `docs:`); scope optional but helpful (e.g., `feat: fzf pushd binding`).
- PRs should note affected modules (`home.nix`, `age.nix`, `nvim/...`), include any required secrets or environment changes, and attach before/after notes for shell bindings or editor behavior.
- Include command outputs for validation (`home-manager build`, `nix flake check`) and mention if a full `switch` was run on a live system.

## Security & Configuration Tips
- Never commit decrypted secrets; use `agenix` to edit (`agenix -e secrets/name.age`) and keep private keys outside the repo.
- When adding new keys, update `age.nix` and regenerate the encrypted files before switching.
- Avoid hardcoding tokens; surface paths via `config.age.secrets` and load through `home.sessionVariables` as done for API keys.
