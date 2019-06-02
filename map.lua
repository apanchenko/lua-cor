local ass = require 'src.lua-cor.ass'
local typ = require 'src.lua-cor.typ'
local wrp = require 'src.lua-cor.wrp'
local arr = require 'src.lua-cor.arr'

-- name to value
local map = setmetatable({}, {__tostring=function() return 'map' end})

-- or
function map.any(t, fn)
  for k, v in pairs(t) do
    if fn(v, k) then
      return true
    end
  end
  return false
end

-- and
function map.all(t, fn)
  for k, v in pairs(t) do
    if not fn(v) then
      return false
    end
  end
  return true
end

-- call fn with every element
function map.each(t, fn)
  for k, v in pairs(t) do
    fn(v, k)
  end
end

-- return array of values selected by predicate function
function map.select(t, pred)
  local result = arr()
  for k, v in pairs(t) do
    if pred(v, k) then
      result:push(v)
    end
  end
  return result
end

-- number of elements
function map.count(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end

-- random element of table
function map.random(t)
  local count = map.count(t)
  if count == 0 then
    return nil
  end

  local i = math.random(count) -- 1..count
  for k, v in pairs(t) do
    i = i - 1
    if i == 0 then
      return v
    end
  end
end

-- map to map
function map.map(t, fn)
  local mapped = {}
  for k, v in pairs(t) do
    mapped[k] = fn(v)
  end
  return mapped
end

-- reduce map to single value
function map.reduce(t, memo, fn)
  for k, v in pairs(t) do
    memo = fn(memo, v, k)
  end
  return memo
end

-- find key by value
function map.key(t, value)
  for k, v in pairs(t) do
    if value == v then
      return k
    end
  end
end

-- return array of keys
function map.keys(t)
  local keys = arr()
  for k, v in pairs(t) do
    keys:push(k)
  end
  return keys
end

-- Call member function by name on all elements of t
-- TODO: rename each_call
function map.invoke(t, fn_name, ...)
  local args = {...}
  map.each(t, function(x) x[fn_name](unpack(args)) end)
end

-- Call member function by name on all elements of t
-- TODO: rename each_call_colon
function map.invoke_colon(t, fn_name, ...)
  local args = {...}
  map.each(t, function(x) x[fn_name](x, unpack(args)) end)
end

-- call member function if it exists
function map.call_fn(t, name, ...)
  local fn = t[name]
  if typ.fun(fn) then
    fn(...)
  end
end

-- map to string
function map.tostring(t, sep)
  sep = sep or ', '
  local prefix = ''
  return map.reduce(t, '{', function(memo, v, k)
    memo = memo.. prefix.. tostring(k).. '='.. tostring(v)
    prefix = sep
    return memo
  end).. '}'
end

-- make a new map joining arguments
function map.merge(...)
  local result = {}
  local args = {...}
  map.each(args, function(arg)
    map.each(arg, function(v, k)
      result[k] = v
    end)
  end)
  return result
end

-- add rest arguments to first
function map.add(receiver, ...)
  local args = {...}
  map.each(args, function(arg)
    map.each(arg, function(v, k)
      receiver[k] = v
    end)
  end)  
end

-- MODULE ---------------------------------------------------------------------
function map:wrap()
  wrp.wrap_stc_inf(map, 'all',    {'t', typ.tab}, {'fn', typ.fun})
  wrp.wrap_stc_inf(map, 'each',   {'t', typ.tab}, {'fn', typ.fun})
  wrp.wrap_stc_inf(map, 'select', {'t', typ.tab}, {'pred', typ.fun})
  wrp.wrap_stc_inf(map, 'count',  {'t', typ.tab})
  wrp.wrap_stc_inf(map, 'random', {'t', typ.tab})
end

--
function map:test()
  local t = { week='semana', month='mes', year='ano' }

  ass(map.any(t, function(v) return #v > 3 end))
  ass(map.all(t, function(v) return #v > 2 end))
  ass.eq(map.count(t), 3)
  ass.eq(map.key(t, 'mes'), 'month')
  --ass.eq(map.tostring(map.merge({a=1, b=2}, {b=3, c=4})), '{a=1, b=3, c=4}')
  --ass.eq(map.tostring(t), '{week=semana, month=mes, year=ano}')
end


return map