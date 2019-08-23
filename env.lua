local typ   = require('src.lua-cor.typ')

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
      local cb = value['on_'..k]
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

-- create clean environment
return setmetatable({}, mt)