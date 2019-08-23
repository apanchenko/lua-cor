-- Inheritance implementation. The obj is a base type to extend.
-- Call 'extend' to inherit new type and 'new' to create instance of a type.
--
-- While there is no semantic difference between type and instance in Lua
-- and so it is not a problem to inherit any table, classic OOP does not
-- defines this. Should we prohibit extending instances?


local log = require('src.lua-cor.log').get('lcor')

-- private members
local tname = {}

-- Create obj
local mt        = {__tostring = function(self) return self[tname] end}
local obj       = setmetatable({[tname] = 'obj'}, mt)
obj.__index     = obj

-- Create new type extending obj
obj.extend = function(self, typename)
  local sub = setmetatable({[tname] = typename}, self)
  sub.__index = sub
  sub.__tostring = function(self) return self[tname] end
  return sub
end

-- Construct instance object
obj.new = function(self, inst) return setmetatable(inst or {}, self) end

-- Helper for faster call new
obj.__call = function(t, ...) return t:new(...) end

-- Support tostring for ancestors
obj.__tostring  = function(self) return self[tname] end

-- Typename getter
obj.get_typename = function(self) return self[tname] end

-- Wrap obj functions with logs and checks 
function obj:wrap()
  local wrp = require('src.lua-cor.wrp')
  local typ = require('src.lua-cor.typ')
  local is    = typ.new_is(obj)
  wrp.fn(log.info, obj, 'extend', is, typ.str)
end

return obj