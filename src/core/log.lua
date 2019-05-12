local ass = require 'src.core.ass'
local bld = require 'src.core.bld'

-- Create log
local log = setmetatable({ depth = 0 }, { __tostring = function() return 'log' end})

--
local function out(...)
  local str = string.rep('. ', log.depth)
  for i = 1, #arg do
    str = str.. tostring(arg[i]).. ' '
  end
  print(str)
end

-- configure log
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

-- increase stack depth
function log:enter()
  self.depth = self.depth + 1
end

-- decrease stack depth
function log:exit()
  self.depth = self.depth - 1
end

--
function log:test()
end

return log