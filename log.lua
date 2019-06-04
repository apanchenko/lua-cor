-- Log system.
-- Have output functions for messages of different severity: info, trace, warning, error.
-- Active severity is selected by cfg.build setting.

-- modules cache
local mods = {}

-- stack depth represented as messages indentation
local depth = 0

-- raw output
local out = function(prefix, ...)
  if #arg == 0 then
    return
  end
  local str = prefix.. string.rep('. ', depth)
  for i = 1, #arg do
    str = str.. tostring(arg[i]).. ' '
  end
  print(str)
end

-- 
local get_method = function(enable_method, id, letter, mod_enabled, mod)
  if enable_method then
    local pre = '['..id..'.'..letter..'] '
    return function(...) if mod_enabled then out(pre, ...) end return mod end
  end
  return function() return mod end
end

-- global trace/info configuration
local enable_info = true
local enable_trace = true
local log = {}
local log_log

-- configure log one of: 'debug', 'develop', 'release'
log.set_configuration = function(cfg)
  enable_info = (cfg == 'debug')
  enable_trace = (cfg == 'debug' or cfg == 'dev')
  log_log = log.get('log')
  log_log.trace('set_configuration('..cfg..')', 'Info:', enable_info, 'Trace:', enable_trace)
end

-- create log module
log.get = function(id)
  local mod = mods[id]
  if mod == nil then
    local enabled = true
    mod = {}
    
    mod.info    = get_method(enable_info,  id, 'i', enabled, mod)
    mod.trace   = get_method(enable_trace, id, 't', enabled, mod)
    mod.warning = get_method(true,         id, 'w', enabled, mod)
    mod.error   = get_method(true,         id, 'e', enabled, mod)
    mod.disable = function(   ) enabled = false return mod end
    mod.enter   = function(   ) if enabled then depth = depth + 1 end end
    mod.exit    = function(   ) if enabled then depth = depth - 1 end end

    if log_log then
      log_log.info('get('..id..')', 'Info:', enable_info, 'Trace:', enable_trace)
    end

    mods[id] = mod
  end
  return mod
end

return log