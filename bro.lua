local obj = require 'src.lua-cor.obj'
local arr = require 'src.lua-cor.arr'

local bro = obj:extend('bro')

-- private
local _list = {}
local _name = {}

--
function bro:new(name)
  self = obj.new(self)
  self[_name] = name
  self[_list] = arr()
  return self
end

-- add listener
function bro:add(listener)
  self[_list]:push(listener)
end

-- remove listener
function bro:remove(listener)
  self[_list]:remove(listener)
end

function bro:__call(...)
  self[_list]:invoke_self(self[_name], ...)
end

-- MODULE ---------------------------------------------------------------------
function bro:wrap()
  local ass = require 'src.lua-cor.ass'
  local log = require('src.lua-cor.log').get('lcor')
  local typ = require 'src.lua-cor.typ'
  local wrp = require 'src.lua-cor.wrp'
end

return bro