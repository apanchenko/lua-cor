-- Log system.
-- Have output functions for messages of different severity: info, trace, warning, error.
-- Active severity is selected by cfg.build setting.

-- modules cache
local mods = {}

-- stack depth represented as messages indentation
local depth = 0

-- raw output
local out = function(...)
  if #arg == 0 then
    return
  end
  local str = string.rep('. ', depth)
  for i = 1, #arg do
    str = str.. tostring(arg[i]).. ' '
  end
  print(str)
end

-- global trace/info configuration
local enable_info = true
local enable_trace = true
local log = {}

-- configure log
log.on_cfg = function(me, cfg)
  enable_info = (cfg.build == 'debug')
  enable_trace = (cfg.build == 'debug' or cfg.build == 'develop')
  print('log.on_cfg '.. cfg.build)
end

-- create log module
log.get = function(id)
  local mod = mods[id]
  if mod == nil then
    local enabled = false
    mod = {}
    
    if enable_info then
      mod.info = function(...) if enabled then out(...) end return mod end
    else
      mod.info = function() return mod end
    end

    if enable_trace then
      mod.trace = function(...) if enabled then out(...) end return mod end
    else
      mod.trace = function() return mod end
    end
  
    mod.warning = function(...) out('Warning', ...) return mod end
    mod.error   = function(...) out('Error', ...)   return mod end
    mod.enable  = function() enabled = true return mod end
    mod.enter   = function() if enabled then depth = depth + 1 end end
    mod.exit    = function() if enabled then depth = depth - 1 end end

    mods[id] = mod
  end
  return mod
end

return log