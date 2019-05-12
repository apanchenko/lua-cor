--[[


--]]

-- typ metatable
local mt = {}

-- support tostring(typ)
function mt:__tostring()
  return 'typ'
end

-- create typ
local typ = setmetatable({}, mt)

-- check if 't' extends 'mt'
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

-- check if 't' is or extends 'mt'
function typ.is(t, mt)
  return t == mt or typ.extends(t, mt)
end

-- check if 't' has metatable with 'name'
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

-- describe type by name and checking function
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
  return setmetatable({name=name, check=check}, self)
end

function typ:__tostring() return self.name end
function typ:__call(v) return self.check(v) end

-- tab or smth
--function tab.__add(l, r)
--  local name = tostring(l)..'|'..tostring(r),
--  local is = function(v) return l(v) or r(v) end
--  return make_type(name, is)
--end

-- get checker function type(v)
local get_istype = function(typename)
  return function(v) return type(v) == typename end
end

-- simple types
typ.any = typ:new('typ.any', function(v) return v ~= nil end, typ)
typ.boo = typ:new('typ.boo', get_istype('boolean'))
typ.tab = typ:new('typ.tab', get_istype('table'))
typ.num = typ:new('typ.num', get_istype('number'))
typ.str = typ:new('typ.str', get_istype('string'))
typ.fun = typ:new('typ.fun', get_istype('function'))
typ.nat = typ:new('typ.nat', function(v) return type(v) == 'number' and v >= 0 and math.floor(v) == v end, typ)

-- create type that has metatable mt
function typ.meta(mt)
  if mt == nil then
    error('typ.meta(nil)')
  end
  local res = typ:new('typ_'..tostring(mt), function(v) return typ.is(v, mt) end)
  --print('typ.meta('..tostring(mt)..') -> '.. tostring(res))
  return res
end

-- create type that has named metatable
function typ.metaname(name)
  local res = typ:new('typ_'..name, function(v) return typ.isname(v, name) end)
  --print('typ.metaname('..name..') -> '.. tostring(res))
  return res
end

--
function typ:test(ass)
  -- typ
  ass(tostring(typ)=='typ',  'invalid typ name')
  ass(typ(typ),              'typ is not typ')
  ass(typ({})==false,        '{} is typ')
  -- any
  ass(tostring(typ.any)=='typ.any', 'invalid any name')
  ass(typ(typ.any),          'any is not typ')
  ass(typ.any({}),           '{} is not any')
  ass(typ.any(nil)==false,   'nil is any')
  -- boo
  ass(typ(typ.boo),          'boo is not typ')
  ass(typ.boo(true),         'true is not bool')
  ass(typ.boo(false),        'false is not bool')
  -- tab
  ass(typ(typ.tab),          'tab is not typ')
  ass(typ.tab({}),           '{} is not table')
  -- num
  ass(typ(typ.num),          'num is not typ')
  -- str
  ass(typ(typ.str),          'str is not typ')
  ass(typ.str(''),           'empty string is not str')
  ass(typ.str(1)==false,     '1 is not str')
  ass(typ.str(nil)==false,   'nil is not str')

  ass(typ(typ.fun),          'fun is not typ')
  ass(typ(typ.nat),          'nat is not typ')

    --and (typ.meta())
end

return typ