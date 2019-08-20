local ass = require 'src.lua-cor.ass'
local log = require('src.lua-cor.log').get('lcor')
local typ = require 'src.lua-cor.typ'
local obj = require 'src.lua-cor.obj'
local wrp = require 'src.lua-cor.wrp'
local arr = require 'src.lua-cor.arr'

local evt = obj:extend('evt')

-- 
function evt:new()
  self = obj.new(self, {list = {}})

  -- register listerner
  self.add = function(com)
    self:listen(com)
    com.com_add(
    {
      com_destroy = function()
        self:remove(com)
      end
    })
  end

  return self
end

-- add listener
function evt:listen(listener)
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
  local ex    = {'exevt', typ.new_ex(evt)}
  
  wrp.fn(log.trace, evt, 'listen', ex, {'listener', typ.tab})
  wrp.fn(log.trace, evt, 'remove', ex, {'listener', typ.tab})
  --TODO ellipsis wrp.fn(evt, 'call', {{'name'}})
end

return evt