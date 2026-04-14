currently the language server is fully functional in vscode
but the build failes in tests as the moonsharp changes have rewritten and overwritten 5.2

tests are not as important for now, perhaps find a way to avoid running them for now

new feature: investigate possibility updating the lualanguage server exe code to support logging to the vscode output channel, this would allow us to see logs from the .lua code in vscode, which would be massivley helpful for debugging and development.



simplify, completly strip standard Lua and external api submodules, focus purly on moonsharp, in future we may import the production version of the standard lua language server itself as a submodule, allowing for lua support without needing to maintain our own fork of the lua language server

