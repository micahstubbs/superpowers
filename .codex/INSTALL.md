# Installing Superpowers for Codex

Two install paths, depending on your Codex CLI version.

## Option A — Native Codex plugin (Codex CLI ≥ 0.117.0, recommended)

Codex CLI v0.117.0 (released March 2026) added a first-class plugin system. This repo ships a `.codex-plugin/plugin.json` manifest, so it can be installed as a native plugin.

### Install via the plugin browser

From any Codex CLI session:

```
/plugins
```

This opens the interactive plugin directory. Add this repo as a marketplace and install:

```
codex plugin marketplace add micahstubbs/superpowers
```

Then enable `superpowers` from the `/plugins` browser (Space toggles enabled state on a selected plugin).

### What you get

- All `skills/*/SKILL.md` are auto-discovered (Codex looks at `"skills": "./skills/"` in the manifest).
- No bootstrap script required — Codex handles skill loading natively.
- Updates flow through `git pull` on the marketplace repo plus `/plugins` refresh.

### Verify

```
/plugins
```

`superpowers` should appear and toggle to enabled. Skills become available to the agent immediately.

## Option B — Manual bootstrap (older Codex CLI, or no plugin system)

If your Codex CLI predates the plugin system or you prefer manual setup, use the bootstrap script:

1. **Clone this repo:**

   ```bash
   mkdir -p ~/.codex/superpowers
   cd ~/.codex/superpowers
   git clone https://github.com/obra/superpowers.git .
   ```

2. **Create a personal skills directory:**

   ```bash
   mkdir -p ~/.codex/skills
   ```

3. **Add this section to `~/.codex/AGENTS.md`:**

   ```markdown
   ## Superpowers System

   <EXTREMELY_IMPORTANT>
   You have superpowers. Superpowers teach you new skills and capabilities. RIGHT NOW run: `~/.codex/superpowers/.codex/superpowers-codex bootstrap` and follow the instructions it returns.
   </EXTREMELY_IMPORTANT>
   ```

4. **Verify:**

   ```bash
   ~/.codex/superpowers/.codex/superpowers-codex bootstrap
   ```

   You should see skill listings and bootstrap instructions.

## Which option should I use?

| Codex CLI version | Recommended path     |
|-------------------|----------------------|
| ≥ 0.117.0         | Option A (native)    |
| < 0.117.0         | Option B (bootstrap) |
| Unsure            | Try Option A first; fall back to B if `/plugins` is missing |

Check your version with `codex --version`.
