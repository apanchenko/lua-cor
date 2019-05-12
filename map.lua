local ass   = require 'src.core.ass'
local typ   = require 'src.core.typ'
local wrp   = require 'src.core.wrp'
local log   = require 'src.core.log'

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
  local arr = {}
  for k, v in pairs(t) do
    if pred(v, k) then
      arr[#arr + 1] = v
    end
  end
  return arr
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
  local keys = {}
  for k, v in pairs(t) do
    keys[#keys + 1] = k
  end
  return keys
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
  --ass.eq(map.tostring(t), '{week=semana, month=mes, year=ano}')
end


return map