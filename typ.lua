--[[
    Library for type checking.
    Contains checkers returning true if argument meets certain conditions.
    For example to check x is a string, call typ.str(x).
    Other checkers:
        typ.any(v)          - v is anything not nil
        typ.boo(v)          - v is boolean
        typ.tab(v)          - v is table
        typ.num(v)          - v is number
        typ.str(v)          - v is string
        typ.fun(v)          - v is function
        typ.nat(v)          - v is natural number

    Also you may create new checkers:
        typ.meta(mt)        - t equals mt or extends mt
        typ.metaname(name)  - t is a table or extends table so that tostring(table)==name
--]]

-- Typ metatable
local mt = {}

-- Support tostring(typ)
function mt:__tostring()
  return 'typ'
end

-- Create typ
local typ = setmetatable({}, mt)
typ.__index = typ

-- Check if 't' extends 'mt'
function typ.extends(t, mt)
  if mt == nil then
    return false
  end
  repeat t = getmetatable(t)
    if t == mt then
      return true
    end
  until t == nil
  return false
end

-- Check if 't' is or extends 'mt'
function typ.is(t, mt)
  return t == mt or typ.extends(t, mt)
end

-- Check if 't' has metatable with 'name'
function typ.isname(t, name)
  while tostring(t) ~= name do
    if t == nil then
      return false
    end
    t = getmetatable(t)
  end
  return true
end

-- typ(x) tells if x is typ
function mt:__call(v)
  return typ.is(v, typ)
end

-- Describe type by name and checking function
function typ:new(name, check)
  -- validate arguments
  if self ~= typ then
    error('typ:new - self is not typ')
    return
  end
  if type(name) ~= 'string' or type(check) ~= 'function' then
    error('tip('..tostring(name)..', '..tostring(check)..')')
    return
  end
  -- save name and check for typ instance
  return setmetatable({name=name, check=check, tostr=tostring}, self)
end

function typ:__tostring() return self.name end
function typ:__call(v) return self.check(v) end

function typ:add_tostr(fn)
  local t = typ:new(self.name, self.check)
  t.tostr = fn
  return t
end

-- Simple types
typ.any = typ:new('typ.any', function(v) return v ~= nil end)
typ.boo = typ:new('typ.boo', function(v) return type(v) == 'boolean' end)
typ.tab = typ:new('typ.tab', function(v) return type(v) == 'table' end)
typ.num = typ:new('typ.num', function(v) return type(v) == 'number' end)
typ.str = typ:new('typ.str', function(v) return type(v) == 'string' end)
typ.fun = typ:new('typ.fun', function(v) return type(v) == 'function' end)
typ.nat = typ:new('typ.nat', function(v) return type(v) == 'number' and v >= 0 and math.floor(v) == v end)

-- Create type that has metatable mt
function typ.meta(mt)
  if mt == nil then
    error('typ.meta(nil)')
  end
  local res = typ:new('typ_'..tostring(mt), function(v) return typ.is(v, mt) end)
  --print('typ.meta('..tostring(mt)..') -> '.. tostring(res))
  return res
end

-- Create typ
function typ.new_is(t)
  return typ:new('is_'..tostring(t), function(v) return typ.is(v, t) end)
end
-- Create typ
function typ.new_ex(t)
  return typ:new('ex_'..tostring(t), function(v) return typ.extends(v, t) end)
end

-- Create type that has named metatable
function typ.metaname(name)
  local res = typ:new('typ_'..name, function(v) return typ.isname(v, name) end)
  --print('typ.metaname('..name..') -> '.. tostring(res))
  return res
end

return typ