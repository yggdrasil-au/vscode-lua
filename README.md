# RemakeEngine Extension Workspace

This repository is the workspace monorepo for the RemakeEngine Lua extension and language server. It combines the VS Code client, the server fork, shared settings, and build scripts used to produce the VSIX.

## What Is Here

- `submodules/client/` - the VS Code extension client.
- `submodules/server/` - the Lua language server fork and its build inputs.
- `submodules/vscode-lua-doc/` - documentation source files for the bundled server docs.
- `setting/` - generated configuration schema and localized settings metadata.
- `Build/TMP/` - active staging directory used by `build.ps1` when packaging the extension.

## Build Flow

The repository is centered around the PowerShell packaging script at `build.ps1`.

1. The server is rebuilt unless an existing binary is reused in auto mode.
2. The client is bundled with Deno using the tasks defined in `deno.json`.
3. Localization files are generated from `build-settings.lua`.
4. The extension payload is copied into `Build/TMP`.
5. The VSIX is created from the staged output.

The current build process treats `Build/TMP` as the source of truth for packaging, not a legacy publish folder.

## Prerequisites

- PowerShell for the top-level build script.
- Deno for the client bundle.
- The server toolchain required by the `submodules/server` build.

## Common Tasks

- `./build.ps1` - interactive build and package flow.
- `./build.ps1 auto` - automated build flow that skips prompting when a cached server binary is present.
- `deno task build` - builds the client bundle only.
- `deno task prod` - builds the minified client bundle only.

## Notes

- Localized `package.nls*.json` files are generated as part of the packaging workflow.
- The repository includes the source for the language server and the documentation that ships with the extension.
- The extension is tailored for the RemakeEngine Lua workflow and may differ from the upstream Lua Language Server defaults.

