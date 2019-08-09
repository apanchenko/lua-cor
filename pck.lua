local arr = require('src.lua-cor.arr')
local map = require('src.lua-cor.map')
local obj = require('src.lua-cor.obj')
local ass = require('src.lua-cor.ass')
local log = require('src.lua-cor.log').get('lcor')
local typ = require('src.lua-cor.typ')

-- Core dependency graph:
-- typ
-- ass
-- log
-- wrp lay
-- arr
-- map
-- obj
-- env evt pck vec

local pck = obj:extend('pck')

-- private:
local path  = {}
local names = {}
local mods  = {}

-- constructor
function pck:new(pack_path)
  self = obj.new(self)
  self[path] = pack_path
  self[names] = arr() -- array of module names, keeping order
  self[mods] = {} -- map id->module
  return self
end

-- load module to package
function pck:load(...)
  log.info(self[path]..':load('..arr.join(arg)..')')
  log.enter()
  arr.each(arg, function(name)
    log.info(name)
    ass.nul(self[mods][name], 'module '.. name.. ' already loaded')
    local fullname = self[path].. '.'.. name
    local mod = require(fullname)
    ass(mod, 'failed found module '.. fullname)
    self[mods][name] = mod
    self[names]:push(name)
  end)
  log.exit()
  return self
end

-- load module to package
function pck:packs(...)
  log.info(self[path].. ':packs('.. arr.join(arg).. ')')
  log.enter()
  arr.each(arg, function(name)
    log.info(name)
    ass.nul(self[mods][name], 'module '.. name.. ' already loaded')
    local fullname = self[path].. '.'.. name.. '._pack'
    local mod = require(fullname)
    ass(mod, 'failed found module '.. fullname)
    self[mods][name] = mod
    self[names]:push(name)
  end)
  log.exit()
  return self
end

--
function pck:get(name)
  return self[mods][name]
end

-- wrap modules
function pck:wrap()
  local core = require 'src.lua-cor._pack'
  -- cannot wrap the wrapper so do logging manually
  log.trace(self[path]..':wrap() '.. tostring(self[names]))
  log.enter()
  -- for all modules
  self[names]:each(function(name)
    local mod = self[mods][name]
    if typ.tab(mod) and mod.wrap then
      log.trace(name..':wrap(core)'.. tostring(mod.wrap))
      log.enter()
      mod:wrap(core)
      log.exit()
    end
  end)
  log.exit()
  return self
end

-- get random module
function pck:random(pred)
  if pred then
    return map.select(self[mods], pred):random()
  end
  return map.random(self[mods])
end

-- test modules
function pck:test()
  self[names]:each(function(name)
    local mod = self[mods][name]
    if typ.extends(mod, pck) then
      log.trace(name..':test()').enter()
      mod:test()
      log.exit()
    else
      log.trace('test '..name).enter()
      require(self[path]..'.test.'..name)
      log.exit()
    end
  end)
  return self
end

-- module
return pck