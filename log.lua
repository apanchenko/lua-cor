-- Log system.
-- Have output functions for messages of different severity: info, trace, warning, error.
-- Active severity by set_debug, set_dev or set_release.

-- created modules
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

-- global trace/info configuration
local enable_info = true
local enable_trace = true
local log = {}
local log_log

-- set debug configuration
log.set_debug = function(cfg)
  enable_info = true
  enable_trace = true
  log_log = log.get(' log')
  log_log.trace('set_debug')
end

-- set development configuration
log.set_dev = function(cfg)
  enable_info = false
  enable_trace = true
  log_log = log.get(' log')
  log_log.trace('set_dev')
end

-- set release configuration
log.set_release = function(cfg)
  enable_info = false
  enable_trace = false
  log_log = log.get(' log')
  log_log.trace('set_release')
end

-- create log module
-- it is convenient to use ids of same length
log.get = function(id)
  local mod = mods[id]
  if mod == nil then
    local enabled = true
    mod = {}

    local indent = {}
    indent.enter = function() if enabled then depth = depth + 1 end end
    indent.exit  = function() if enabled then depth = depth - 1 end end

    local skip = {}
    skip.enter = function() end
    skip.exit  = function() end

    if enable_info then
      local pre_i = '['..id..'.i] '
      mod.info = function(...) if enabled then out(pre_i, ...) end return indent end
    else
      mod.info = function() return skip end
    end

    if enable_trace then
      local pre_t = '['..id..'.t] '
      mod.trace = function(...) if enabled then out(pre_t, ...) end return indent  end
    else
      mod.trace = function() return skip end
    end

    mod.warning = function(...) out('['..id..'.w] ', ...) end
    mod.error   = function(...) out('['..id..'.e] ', ...) end
    mod.disable = function(   ) enabled = false return mod end

    mods[id] = mod
  end
  return mod
end

return log