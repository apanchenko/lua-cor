local ass   = require 'src.core.ass'
local typ   = require 'src.core.typ'

local mt = {}
mt.__index = mt

-- add new citizen
function mt.__newindex(self, key, value)
  for k, v in pairs(self) do
    -- notify existing citizens about a new one
    if typ.tab(v) then
      local cb = v['on_'..key]
      if cb then
        cb(v, value)
      end
    end

    -- notify new citizen about existing ones
    if typ.tab(value) then
      cb = value['on_'..k]
      if cb then
        cb(value, v)
      end
    end
  end

  -- settle new citizen
  rawset(self, key, value)
end

function mt:__tostring()
  return 'env'
end

-- self test
function mt:test()
  -- create local test environment
  local env = setmetatable({}, mt)

  -- check type safety
  --ass(typ.metaname('env')(env))
  --ass(typ.meta(mt)(env))
  ass.is(env, mt)

  -- sideeffect of changing environment
  local side = 1 
  -- b listens c
  env.a = {on_b = function(self, b) side = b end}
  -- set c with sideeffect
  env.b = 9
  -- observe sideeffect
  ass.eq(side, 9)
end

-- create clean environment
return setmetatable({}, mt)