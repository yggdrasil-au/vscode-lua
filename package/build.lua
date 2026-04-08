local json = require 'json-beautify'

local VERSION = "3.17.1"

local fsu     = require 'fs-utility'
local package = json.decode(fsu.loadFile('package.json'))

package.version = VERSION

package.contributes.configuration = {
    title = 'Lua',
    type = 'object',
    properties = require 'submodules.server.tools.configuration',
}
package.contributes.semanticTokenScopes = {
    {
        language = 'lua',
        scopes = require 'package.semanticTokenScope',
    }
}

local encodeOption = {
    newline = '\r\n',
    indent  = '\t',
}
print('生成 package.json')
fsu.saveFile('../' .. 'package.json', json.beautify(package, encodeOption) .. '\r\n')
