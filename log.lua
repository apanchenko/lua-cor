--[[
    Log system.
    Have output funcitons for messages of different severity: info, trace, warning, error.
    Active severity is selected by cfg.build setting.
]]--

local bld = require 'src.lua-cor.bld'

-- Create log
local log = setmetatable({ depth = 0, modules = {} }, { __tostring = function() return 'log' end })

--
local function out(...)
  local str = string.rep('. ', log.depth)
  for i = 1, #arg do
    str = str.. tostring(arg[i]).. ' '
  end
  print(str)
end

-- Configure log
function log:on_cfg(cfg)
  -- dumb is always silent
  dumb = function(me) return me end

  -- info for debug configuration only
  if cfg.build.id <= bld.debug.id then
    self.info  = function(me, ...) out(...) return me end
  else
    self.info  = dumb
  end

  -- trace for debug and develop configurations
  if cfg.build.id <= bld.develop.id then
    self.trace = function(me, ...) out(...) return me end
  else
    self.trace = dumb
  end

  -- error and warning for all configurations
  self.error   = function(me, ...) out('Error', ...) return me end
  self.warning = function(me, ...) out('Warning', ...) return me end

  self:trace('log:on_cfg '..cfg.build.name)
end

-- Increase stack depth
function log:enter()
  self.depth = self.depth + 1
end

-- Decrease stack depth
function log:exit()
  self.depth = self.depth - 1
end

--
local _add_fn = function(target, id, fn)
  target[fn] = function(me, ...)
    if log.modules[id] then
      log[fn](log, ...)
    end
    return me
  end
end

-- Create log subsystem
log._get_module = function(id)
  local subsystem = {}

  _add_fn(subsystem, id, 'info')
  _add_fn(subsystem, id, 'trace')
  _add_fn(subsystem, id, 'warning')
  _add_fn(subsystem, id, 'error')
  _add_fn(subsystem, id, 'enter')
  _add_fn(subsystem, id, 'exit')

  subsystem.enable = function()
    log.modules[id] = true
    return subsystem
  end

  subsystem.on_cfg = function(me, cfg)
    log:on_cfg(cfg)
  end

  subsystem.get_module = function(id)
    return log._get_module(id)
  end
  
  return subsystem
end

return log._get_module('')
