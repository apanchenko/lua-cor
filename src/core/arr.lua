-- thanks to Marcus Irven
local floor = math.floor

local arr = setmetatable({}, { __tostring = function() return 'arr' end})

-- check if array t is empty
function arr.is_empty(t)        return next(t) == nil end
-- add v at the end of array t
function arr.push(t, v)         t[#t + 1] = v end
-- remove and return last element of array t
function arr.pop(t)             return table.remove(t) end
-- remove and return first element of array t
function arr.shift(t)           return table.remove(t, 1) end
-- insert v at the front of array t
function arr.unshift(t, v)      table.insert(t, 1, v) end

--
function arr.each(t, fn)
  for i = 1, #t do
    fn(t[i])
  end
end

--
function arr.map(t, fn)
  local mapped = {}
  for i = 1, #t do
    mapped[i] = fn(t[i])
  end
  return mapped
end

--
function arr.reduce(t, memo, fn)
  for i = 1, #t do
    memo = fn(memo, t[i])
  end
  return memo
end

--
function arr.detect(t, fn)
  for i = 1, #t do
    if fn(t[i]) then
      return i
    end
  end
end

--
function arr.select(t, fn)
  local selected = {}
  for i = 1, #t do
    if fn(t[i]) then
      selected[#selected + 1] = t[i]
    end
  end
  return selected
end

--
function arr.reject(t, fn)
  local selected = {}
  for i = 1, #t do
    if not fn(t[i]) then
      selected[#selected + 1] = t[i]
    end
  end
  return selected
end

--
function arr.all(t, fn)
  for i = 1, #t do
    if not fn(t[i]) then
      return false
    end
  end
  return true
end

--
function arr.any(t, fn)
  for i = 1, #t do
    if fn(t[i]) then
      return true
    end
  end
  return false
end

--
function arr.include(t, value)
  for i = 1, #t do
    if t[i] == value then
      return true end
  end
  return false
end

--
function arr.invoke(t, fn_name, ...)
  local args = {...}
  arr.each(t, function(x) x[fn_name](unpack(args)) end)
end

--
function arr.pluck(t, name)
  return arr.map(t, function(x) return x[name] end)
end

--
function arr.min(t, fn)
  return arr.reduce(t, {}, function(min, x) 
    local value = fn(x)
    if min.item == nil then
      min.item = x
      min.value = value
    else
      if value < min.value then
        min.item = x
        min.value = value
      end
    end
    return min
  end).item
end

--
function arr.max(t, fn)
  return arr.reduce(t, {}, function(min, x) 
    local value = fn(x)
    if min.item == nil then
      min.item = x
      min.value = value
    else
      if value > min.value then
        min.item = x
        min.value = value
      end
    end
    return min
  end).item
end

--
function arr.reverse(t)
  local reversed = {}
  for i = 1, #t do
    table.insert(reversed, 1, t[i])
  end
  return reversed
end
--
function arr.first(t, n)
  if n == nil then
    return t[1]
  end
  local first = {}
  n = math.min(n, #t)
  for i = 1, n do
    first[i] = t[i]
  end
  return first
end
--
function arr.rest(t, index)
  index = index or 2
  local rest = {}
  for i = index, #t do
    rest[#rest + 1] = t[i]
  end
  return rest
end
--
function arr.slice(array, index, length)
  local sliced = {}
  index = math.max(index, 1)
  local end_index = math.min(index + length - 1, #array)
  for i = index, end_index do
    sliced[#sliced + 1] = array[i]
  end
  return sliced
end
--
function arr.flatten(array)
  local all = {}
  for i = 1, #array do
    if type(array[i]) == "table" then
      local flattened = arr.flatten(array[i])
      arr.each(flattened, function(e) all[#all + 1] = e end)
    else
      all[#all + 1] = array[i]
    end
  end
  return all
end

--
function arr.join(array, separator)
  return table.concat(array, separator)
end

-- return random element of table
function arr.random(t)
  return t[math.random(#t)]
end

-- remove and return random element
function arr.remove_random(t)
  local i = math.random(#t)
  return table.remove(t, i)
end

-- to string
function arr.tostring(t, sep)
  sep = sep or ', '
  if #t == 0 then
    return ''
  end
  local res = tostring(t[1])
  for i = 2, #t do
    res = res.. sep.. tostring(t[i])
  end
  return res
end

-- Find index to insert an object into sorted array so that array remains sorted
-- @param t        array to search
-- @param low      min search range bound
-- @param high     max search range bound
-- @param object   find place for this object
-- @param is_lower compare function (a, b) returns a < b
-- @return         number [low, high]
function arr.find_index(t, low, high, object, is_lower)
  --todo ass.le(1, low)
  --todo ass.le(low, high)
  while low < high do
    local mid = floor((low + high) * 0.5)
    if is_lower(t[mid], object) then
      low = mid + 1
    else
      if is_lower(object, t[mid]) then
        high = mid
      else
        return mid
      end
    end
  end
  return high
end

--
function arr:wrap(core)
  local typ = core:get('typ')
  local wrp = core:get('wrp')
  local t   = {'t', typ.tab}
  local v   = {'v', typ.any}
  local f   = {'f', typ.fun}

  wrp.wrap_stc_inf(arr, 'push',       t, v)
  wrp.wrap_stc_inf(arr, 'all',        t, f)
  wrp.wrap_stc_inf(arr, 'each',       t, f)
  wrp.wrap_stc_inf(arr, 'random',     t)
  wrp.wrap_stc_inf(arr, 'find_index', t, {'low', typ.num}, {'high', typ.num}, {'obj', typ.any}, {'is_lower', typ.fun})
end

--
function arr:test(ass)
  ass.eq(arr.tostring({'semana','mes','ano'}), 'semana, mes, ano')
  local compare = function(a, b) return a < b end
  ass.eq(arr.find_index({1},     1, 2, 0, compare), 1, 'test find_index - front')
  ass.eq(arr.find_index({1,3},   1, 3, 2, compare), 2, 'test find_index - middle')
  ass.eq(arr.find_index({1},     1, 2, 2, compare), 2, 'test find_index - back')
  ass.eq(arr.find_index({},      1, 1, 9, compare), 1, 'test find_index - empty')
end


return arr