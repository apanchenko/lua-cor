local ass = require 'src.lua-cor.ass'
local log = require('src.lua-cor.log').get('lcor')
local typ = require 'src.lua-cor.typ'
local obj = require 'src.lua-cor.obj'
local wrp = require 'src.lua-cor.wrp'

local evt = obj:extend('evt')

-- 
function evt:new()
  return obj.new(self, {list = {}})
end

-- add listener
function evt:add(listener)
  table.insert(self.list, listener)
end

-- remove listener
function evt:remove(listener)
  for k,v in ipairs(self.list) do
    if v == listener then
      table.remove(self.list, k)
    end
  end
end

--
function evt:call(name, ...)
  ass.str(name)
  for k,v in ipairs(self.list) do
    if v[name] then
      v[name](v, ...)
    end
  end
end

-- MODULE ---------------------------------------------------------------------
function evt:wrap()
  ass.eq(tostring(evt), 'evt')
  wrp.wrap_sub(log.trace, evt, 'add',    {'listener', typ.tab})
  wrp.wrap_sub(log.trace, evt, 'remove', {'listener', typ.tab})
  --TODO ellipsis wrp.fn(evt, 'call', {{'name'}})
end

return evt