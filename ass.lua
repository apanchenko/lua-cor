--[[
    Library of assert functions.
    Useful for testing and validating.
]]--

local typ = require 'src.lua-cor.typ'
local m = {}

-- Assert 'v' is true
function m:__call(v, msg)   return v or error(msg or tostring(v)..' is false') end

local ass = setmetatable({}, m)

-- Assert 'v' is nil
function ass.nul(v, msg)    return v == nil or error(msg or tostring(v)..' is not nil') end
-- Assert 'v' is not nil
function ass.any(v, msg)    return v ~= nil or error(msg or 'value is nil') end
-- Assert 'v' is a number
function ass.num(v, msg)    return typ.num(v) or error(msg or tostring(v)..' is not a number') end
-- Assert 'n' is natural number
function ass.nat(v, msg)    return typ.nat(v) or error(msg or tostring(v)..' is not natural') end
-- Assert 'v' is a table
function ass.tab(v, msg)    return typ.tab(v) or error(msg or tostring(v)..' is not a table') end
-- Assert 'v' is a string
function ass.str(v)         return typ.str(v) or error(tostring(v)..' is not a string') end
-- Assert 'v' is a boolean
function ass.bool(v)        return typ.boo(v) or error(tostring(v)..' is not a boolean') end
-- Assert 'v' is a function
function ass.fun(v, msg)    return typ.fun(v) or error(msg or tostring(v)..' is not a function') end
-- Assert 't' has metatable 'mt'
function ass.is(t, mt, msg) return typ.is(t, mt) or error(msg or tostring(t)..' is not '..tostring(mt)) end
-- Assert 't' has metatable with 'name'
function ass.isname(t, name, msg) return typ.isname(t, name) or error(msg or tostring(t)..' is not '..name) end
-- Assert a equals b
function ass.eq(a, b, msg)  return a == b or error(msg or tostring(a).. ' ~= '.. tostring(b)) end
-- Assert a not equals b
function ass.ne(a, b, msg)  return a ~= b or error(msg or tostring(a).. ' == '.. tostring(b)) end
-- Assert a less or equals b
function ass.le(a, b, msg)  return a <= b or error(msg or tostring(a).. ' > ' .. tostring(b)) end
-- Assert a is greater than b
function ass.gt(a, b, msg)  return a >  b or error(msg or tostring(a).. ' <= '.. tostring(b)) end
-- Assert a is greater of equals b
function ass.ge(a, b, msg)  return a >= b or error(msg or tostring(a).. ' > ' .. tostring(b)) end
-- Compare tostring representation
function ass.ts(a, b, msg)  return tostring(a)==tostring(b) or error(msg or tostring(a)..' not '..tostring(b)) end

return ass
