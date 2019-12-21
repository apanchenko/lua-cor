local arr = require('src.lua-cor.arr')
local map = require('src.lua-cor.map')
local obj = require('src.lua-cor.obj')
local ass = require('src.lua-cor.ass')
local log = require('src.lua-cor.log').get('lcor')
local typ = require('src.lua-cor.typ')

local pack = obj:extend('pack')

-- private:
local path  = {}
local names = {}
local mods  = {}

-- constructor
function pack:new(pack_path)
  self = obj.new(self)
  self[path] = pack_path
  self[names] = arr() -- array of module names, keeping order
  self[mods] = {} -- map id->module
  return self
end

-- load module to package
function pack:modules(...)
  local indent = log.info(self[path]..':load('..arr.join(arg)..')')
  indent.enter()
  arr.each(arg, function(name)
    log.info(name)
    ass.nul(self[mods][name], 'module '.. name.. ' already loaded')
    local fullname = self[path].. '.'.. name
    local mod = require(fullname)
    ass(mod, 'failed found module '.. fullname)
    self[mods][name] = mod
    self[names]:push(name)
  end)
  indent.exit()
  return self
end

-- load module to package
function pack:packs(...)
  local indent = log.info(self[path].. ':packs('.. arr.join(arg).. ')')
  indent.enter()
  arr.each(arg, function(name)
    log.info(name)
    ass.nul(self[mods][name], 'module '.. name.. ' already loaded')
    local fullname = self[path].. '.'.. name.. '._pack'
    local mod = require(fullname)
    ass(mod, 'failed found module '.. fullname)
    self[mods][name] = mod
    self[names]:push(name)
  end)
  indent.exit()
  return self
end

--
function pack:get(name)
  return self[mods][name]
end

-- wrap modules
function pack:wrap()
  local core = require 'src.lua-cor._pack'
  -- cannot wrap the wrapper so do logging manually
  local indent = log.trace(self[path]..':wrap() '.. tostring(self[names]))
  indent.enter()
  -- for all modules
  self[names]:each(function(name)
    local mod = self[mods][name]
    if typ.tab(mod) and mod.wrap then
      local indent_mod = log.trace(name..':wrap()'.. tostring(mod.wrap))
      indent_mod.enter()
        mod:wrap(core)
      indent_mod.exit()
    end
  end)
  indent.exit()
  return self
end

-- get random module
function pack:random(pred)
  if pred then
    return map.select(self[mods], pred):random()
  end
  return map.random(self[mods])
end

-- test modules
function pack:test()
  self[names]:each(function(name)
    local mod = self[mods][name]
    if typ.extends(mod, pack) then
      local indent = log.trace(name..':test()')
      indent.enter()
      mod:test()
      indent.exit()
    else
      local indent = log.trace('test '..name)
      indent.enter()
      require(self[path]..'.test.'..name) -- run module test
      indent.exit()
    end
  end)
  return self
end

-- module
return pack