# lua-moonsharp (VS Code Extension)

Fork of LuaLS for Remake Engine (Moonsharp) Lua development in VS Code.

This repository packages three main pieces:
- A VS Code client extension (TypeScript, in `submodules/client`).
- A Lua language server backend (in `submodules/server`).
- Embedded Lua/Moonsharp documentation content (in `submodules/vscode-lua-doc`).

## Folder Purpose (Root)

- `submodules/`: Core runtime components (client, server, documentation).
- `setting/`: Generated VS Code configuration schemas.
- `package/`: Build-time Lua scripts that transform `package.json` metadata.
- `make/`: Utility scripts for local copy/deploy tasks.
- `.vscode/`: Local development launch/task settings.
- `Build/`: Temporary packaging output (`Build/TMP`) used during VSIX creation.

## Provided Files And Why They Exist

| File | Purpose in this folder |
| --- | --- |
| `package.json` | Extension identity, VS Code contributions, activation events, and entrypoint (`submodules/client/out/src/extension`). |
| `tsconfig.json` | Root TypeScript configuration and project reference to the client package. |
| `pnpm-workspace.yaml` | Declares workspace packages for pnpm monorepo behavior (`client`). |
| `build.ps1` | End-to-end build script: builds server/client, generates localization/schema files, stages package contents into `Build/TMP`, and creates the VSIX. |
| `build-settings.lua` | Generates `setting/schema*.json` and `package.nls*.json` from server locale/configuration sources. |
| `.vscodeignore` | Defines the exact file set included in extension packaging when using `vsce`. |
| `.gitmodules` | Declares git submodules used by this extension (`submodules/server`, `submodules/client`, `submodules/vscode-lua-doc`). |
| `.gitignore` | Excludes generated artifacts, staging outputs, and large submodule content from normal git tracking. |
| `.vscode/launch.json` | Debug profiles for extension host and configuration export workflow. |
| `.vscode/tasks.json` | Workspace build task definitions (notably client build task). |
| `.vscode/settings.json` | Local Lua extension defaults for developing this repository. |

# unused, from sumenko lsp
| `package/build.lua` | Build-time script that updates `package.json` version/contributions from Lua-side sources. |
| `package/semanticTokenScope.lua` | Semantic token scope mapping consumed when generating package metadata. |
| `make/copy.lua` | Utility script to copy compiled server binaries into an installed extension directory for local testing. |


## Build And Packaging Summary

1. Build server dependencies and server binaries from `submodules/server`.
2. Build the client from `submodules/client`.
3. Generate localization and schema artifacts via `build-settings.lua`.
4. Copy runtime files into `Build/TMP` staging directory.
5. Package VSIX from staging output.

