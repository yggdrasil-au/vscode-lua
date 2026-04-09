currently the language server is fully functional in vscode
but the build failes in tests as the moonsharp changes have rewritten and overwritten 5.2

tests are not as important for now, perhaps find a way to avoid running them for now

new feature: investigate possibility updating the lualanguage server exe code to support logging to the vscode output channel, this would allow us to see logs from the .lua code in vscode, which would be massivley helpful for debugging and development.

perhaps also investigate the exe's usefullness as a standalone tool for debugging and development, as it can execute lua code


