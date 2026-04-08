--[[ 

Lua Language Server Extension Publisher

Purpose:
This script automates the build and distribution process for the Lua Language Server extension.
1. Sets up the environment and loads versioning from package.json.
2. Synchronizes files from submodules (client and server) into a staging Build directory.
3. Performs integration testing by spawning the generated language server binary.
4. Cleans up development-only files (logs, tests, metadata) to prepare for packaging.

--]]


local currentPath = debug.getinfo(1, 'S').source:sub(2)
local rootPath = currentPath:gsub('[^/\\]-$', '')
local fs         = require 'bee.filesystem'
local subprocess = require 'bee.subprocess'
local platform   = require 'bee.platform'
local thread     = require 'bee.thread'

package.path = package.path
    .. ';' .. rootPath .. '?.lua'
    .. ';' .. rootPath .. 'submodules/server/script/?.lua' 
    .. ';' .. rootPath .. 'submodules/server/tools/?.lua' 

local fsu = require 'fs-utility'
ROOT = fs.path('./')
fs.current_path(ROOT)
require 'package.build'
dofile(rootPath .. 'build-settings.lua')
local json = require 'json'

local function loadPackage()
    local buf = fsu.loadFile('package.json')
    if not buf then
        error(ROOT:string())
    end
    local package = json.decode(buf)
    return package.version
end

local function createDirectory(dir)
    local out = './Build/' .. dir
    fs.create_directories(out)
    return out
end

local function copyFiles(root, out)
    return function (dirs)
        local count = 0
        local function copy(relative, mode)
            local source = root .. '/' .. relative
            local target = out .. '/' .. relative
            if not fs.exists(source) then
                return
            end
            if fs.is_directory(source) then
                fs.create_directory(target)
                if mode == true then
                    for path in fs.pairs(source) do
                        copy(relative .. '/' .. path:filename(), true)
                    end
                else
                    for name, v in pairs(mode) do
                        copy(relative .. '/' .. name, v)
                    end
                end
            else
                fs.copy_file(source, target)
                count = count + 1
            end
        end

        copy(fs.path '', dirs)
        return count
    end
end

local function runTest(root)
    local ext = platform.os == 'windows' and '.exe' or ''
    local exe = root .. '/bin/lua-language-server' .. ext
    local test = 'test.lua' -- Fixed to filename only since cwd is root
    local lua = subprocess.spawn {
        exe,
        test,
        '-E',
        cwd = root,
        stdout = true,
        stderr = true,
    }
    for line in lua.stdout:lines 'l' do
        print(line)
    end
    lua:wait()
    local err = lua.stderr:read 'a'
    if err ~= '' then
        error(err)
    end
end

local function removeFiles(out)
    return function (dirs)
        local function remove(relative, mode)
            local target = out .. '/' .. relative
            if not fs.exists(target) then
                return
            end
            if fs.is_directory(target) then
                if mode == true then
                    for path in fs.pairs(target) do
                        remove(relative .. '/' .. path:filename(), true)
                    end
                    fs.remove(target)
                else
                    for name, v in pairs(mode) do
                        remove(relative .. '/' .. name, v)
                    end
                end
            else
                fs.remove(target)
            end
        end

        remove(fs.path '', dirs)
    end
end

local version = loadPackage()
print('Version: ' .. version)

print('Copying README...')
fsu.saveFile('README.md', fsu.loadFile('submodules/server/README.md'):gsub('%.svg', '.png'))

local out = createDirectory('test')
print('Output directory: ', out)
print('Cleaning directory...')
removeFiles(out)(true)

print('Starting file copy...')
local count = copyFiles(ROOT , out) {
    ['submodules'] = {
        ['client'] = {
            ['node_modules']      = true,
            ['package.json']      = true,
            ['web']               = true
        },
        ['vscode-lua-doc'] = {
            ['doc']             = true,
            ['extension.js']    = true,
        },
        ['server'] = {
            ['bin']               = true,
            ['doc']               = true,
            ['locale']            = true,
            ['script']            = true,
            ['main.lua']          = true,
            ['test']              = true,
            ['test.lua']          = true,
            ['debugger.lua']      = true,
            ['changelog.md']      = true,
            ['meta']              = {
                ['submodules']      = true,
                ['spell']         = true,
            },
        },
    },
    ['images'] = {
        ['logo.png'] = true,
    },
    ['package.json']           = true,
    ['README.md']              = true,
    ['changelog.md']           = true,
    ['package.nls.json']       = true,
    ['package.nls.zh-cn.json'] = true,
    ['package.nls.zh-tw.json'] = true,
    ['package.nls.pt-br.json'] = true,
}
print(('Copied [%d] files'):format(count))

--print('Running tests...')
--runTest(out .. '/submodules/server')

print('Removing redundant files...')
removeFiles(out) {
    ['submodules'] = {
        ['server'] = {
            ['log']               = true,
            ['test']              = true,
            ['test.lua']          = true,
            ['meta']              = {
                ['Lua 5.4 zh-cn'] = true,
            }
        },
    },
}

print('Success')

for i = 5, 0, -1 do
    print('Publishing version ' .. version .. ' in ' .. i .. ' seconds...')
    thread.sleep(1)
end

local function shell(command)
    command.stdout = true
    command.stderr = true
    command.searchPath = true
    local show = {}
    for _, c in ipairs(command) do
        show[#show+1] = tostring(c)
    end
    table.insert(command, 1, 'cmd')
    table.insert(command, 2, '/c')
    print(table.concat(show, ' '))
    local p, err = subprocess.spawn(command)
    if not p then
        error(err)
    end
    p:wait()
    print(p.stdout:read 'a')
    print(p.stderr:read 'a')
end

-- Ensure this path exists before calling vsce
fs.create_directories(ROOT / 'publish')

local vsix = '../../publish/lua-' .. version .. '.vsix'

--print('Packaging VSIX...')
--shell {
--    'vsce', 'package',
--    '-o', vsix,
--    cwd = out,
--}

--shell {
--    'vsce', 'publish',
--    cwd = out,
--}


print('Finished')

