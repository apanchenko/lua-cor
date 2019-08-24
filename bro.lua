local obj = require('src.lua-cor.obj')
local arr = require('src.lua-cor.arr')
local ass = require('src.lua-cor.ass')

local broadcast = obj:extend('broadcast')

-- private
local _list = {}
local _name = {}

--
function broadcast:new(name)
  self = obj.new(self)
  self[_name] = name
  self[_list] = arr()
  return self
end

-- add or remove listener
function broadcast:listen_wrap_before(listener, subscribe)
  ass.fun(listener[self[_name]], 'Broadcast listener has no function '..self[_name])
end
function broadcast:listen(listener, subscribe)
  if subscribe then
    self[_list]:push(listener)
  else
    self[_list]:remove(listener)
  end
end

--
function broadcast:__call(...)
  self[_list]:invoke_self(self[_name], ...)
end

-- MODULE ---------------------------------------------------------------------
function broadcast:wrap()
  local log = require('src.lua-cor.log').get('lcor')
  local typ = require('src.lua-cor.typ')
  local wrp = require('src.lua-cor.wrp')

  wrp.fn(log.info, broadcast, 'new', broadcast, typ.str)
  wrp.fn(log.info, broadcast, 'listen', typ.new_ex(broadcast), typ.tab, typ.boo)
end

return broadcast