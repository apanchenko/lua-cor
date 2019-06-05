local arr         = require 'src.lua-cor.arr'
local map         = require 'src.lua-cor.map'
local obj         = require 'src.lua-cor.obj'
local ass         = require 'src.lua-cor.ass'
local log         = require('src.lua-cor.log').get('lcor')

-- Core dependency graph:
-- typ bld
-- ass
-- log
-- wrp lay
-- arr
-- map
-- obj
-- env evt pkg vec

--
local pkg = obj:extend('pkg')

-- constructor
function pkg:new(path)
  return obj.new(self,
  {
    path = path,
    names = arr(), -- array of module names, keeping order
    modules = {} -- map id->module
  })
end

-- load module to package
function pkg:load(...)
  self.names = arr(...)
  log.info(self.path..':load('..tostring(self.names)..')')
  log.enter()
  self.names:each(function(name)
    log.info(name)
    local fullname = self.path.. '.'.. name
    local mod = require(fullname)
    ass(mod, 'failed found module '.. fullname)
    ass.nul(self.modules[name], 'module '.. name.. ' already loaded')
    self.modules[name] = mod
  end)
  log.exit()
  return self
end

--
function pkg:get(name)
  return self.modules[name]
end

-- deprecated
pkg.find = pkg.get

-- wrap modules
function pkg:wrap()
  local core = require 'src.lua-cor.package'
  -- cannot wrap the wrapper so do logging manually
  log.trace(self.path..':wrap() '.. tostring(self.names))
  log.enter()
  -- for all modules
  self.names:each(function(name)
    local mod = self.modules[name]
    if mod.wrap then
      log.trace(name..':wrap(core)')
      mod:wrap(core)
    end
  end)
  log.exit()
end

-- get random module
function pkg:random(pred)
  if pred then
    return map.select(self.modules, pred):random()
  end
  return map.random(self.modules)
end

-- test modules
function pkg:test()
  self.names:each(function(name)
    local mod = self.modules[name]
    if mod.test then
      log.trace(name..':test(ass)')
      log.enter()
      mod:test(ass)
      log.exit()
    end
  end)
end

-- module
return pkg