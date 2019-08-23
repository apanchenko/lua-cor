-- Array.
-- As you remember, indeces in Lua arrays start with 1.
-- Thanks to Marcus Irven

local log = require('src.lua-cor.log').get('lcor')

local mfloor  = math.floor
local mrandom = math.random
local mmax    = math.max
local mmin    = math.min

-- Setup
local mt = {__tostring = function() return 'arr' end}
local arr = setmetatable({}, mt)
arr.__index = arr

-- Create instance
mt.__call = function(t, ...)    return setmetatable({...}, t) end
arr.new   = function(...)       return setmetatable({...}, arr) end

-- Convert to string
arr.__tostring = function(t, sep) return arr.join(t, sep) end

-- Convert array to string
function arr:join(sep)
  sep = sep or ', '
  if #self == 0 then
    return ''
  end
  local res = tostring(self[1])
  for i = 2, #self do
    res = res.. sep.. tostring(self[i])
  end
  return res
end

-- Check emptyness
function arr:is_empty()         return next(self) == nil end

-- Number of elements
function arr:length()           return #self end

-- Add v at the end
function arr:push(v)            self[#self + 1] = v end

-- Add elements from another array
function arr:pusha(a)
  for i = 1, #a do
    self:push(a[i])
  end
end

-- Remove element
function arr:remove(v)
  for i = 1, #self do
    if self[i] == v then
      table.remove(self, i)
      break
    end
  end
end

-- Remove and return last element
function arr:pop()              return table.remove(self) end

-- Remove and return first element
function arr:shift()            return table.remove(self, 1) end

-- Insert v at the front
function arr:unshift(v)         table.insert(self, 1, v) end

-- Remove all emenets. O(N)
function arr:clear()
  while #self > 0 do
    table.remove(self)
  end
end

-- Iterate calling function fn for each element
function arr:each(fn)
  for i = 1, #self do
    fn(self[i])
  end
end

-- Create a new array transforming each element with funciton fn
function arr:map(fn)
  local mapped = arr()
  for i = 1, #self do
    mapped[i] = fn(self[i])
  end
  return mapped
end

-- Reduce all elements into single value with function fn
function arr:reduce(memo, fn)
  for i = 1, #self do
    memo = fn(memo, self[i])
  end
  return memo
end

-- Find index of first element of t, where fn(t[i]) is true
function arr:detect(fn)
  for i = 1, #self do
    if fn(self[i]) then
      return i
    end
  end
end

-- Create new array with all elements of t, where fn(ti) is true
function arr:select(fn)
  local selected = arr()
  for i = 1, #self do
    if fn(self[i]) then
      selected[#selected + 1] = self[i]
    end
  end
  return selected
end

-- Create new array with all elements of t, where fn(ti) is false. Complemtary to select
function arr:reject(fn)
  local selected = arr()
  for i = 1, #self do
    if not fn(self[i]) then
      selected[#selected + 1] = self[i]
    end
  end
  return selected
end

-- True if fn is true for all elements. Logical AND.
function arr:all(fn)
  for i = 1, #self do
    if not fn(self[i]) then
      return false
    end
  end
  return true
end

-- True if fn is true for any element. Logical OR.
function arr:any(fn)
  for i = 1, #self do
    if fn(self[i]) then
      return true
    end
  end
  return false
end

-- True if value equals any element
function arr:include(v)
  for i = 1, #self do
    if self[i] == v then
      return true
    end
  end
  return false
end

-- Call member function by name on all elements of t
function arr:invoke(fn_name, ...)
  local args = {...}
  arr.each(self, function(x) x[fn_name](unpack(args)) end)
end
function arr:invoke_self(fn_name, ...)
  local args = {...}
  arr.each(self, function(x) x[fn_name](x, unpack(args)) end)
end

-- Create array of members by name of all elements of t
function arr:pluck(name)
  return arr.map(self, function(x) return x[name] end)
end

-- Minimize fn
function arr:min(fn)
  return arr.reduce(self, {}, function(min, x) 
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

-- Maximize fn
function arr:max(fn)
  return arr.reduce(self, {}, function(max, x) 
    local value = fn(x)
    if max.item == nil then
      max.item = x
      max.value = value
    else
      if value > max.value then
        max.item = x
        max.value = value
      end
    end
    return max
  end).item
end

-- Create reversed array
function arr:reverse()
  local reversed = arr()
  for i = 1, #self do
    table.insert(reversed, 1, self[i])
  end
  return reversed
end

-- Create array with n first elements of t
function arr:first(n)
  if n == nil then
    return self[1]
  end
  local first = arr()
  n = math.min(n, #self)
  for i = 1, n do
    first[i] = self[i]
  end
  return first
end

-- Create array with elements of t starting from index
function arr:rest(index)
  index = index or 2
  local rest = arr()
  for i = index, #self do
    rest[#rest + 1] = self[i]
  end
  return rest
end

-- Create subarray of t
function arr:slice(index, length)
  local sliced = arr()
  index = mmax(index, 1)
  local end_index = mmin(index + length - 1, #self)
  for i = index, end_index do
    sliced[#sliced + 1] = self[i]
  end
  return sliced
end

-- Create array with flat structure - no tables
function arr:flatten()
  local all = arr()
  for i = 1, #self do
    if type(self[i]) == "table" then
      arr.flatten(self[i]):each(function(e) all:push(e) end)
    else
      all:push(self[i])
    end
  end
  return all
end

-- Return random element
function arr:random()
  if #self == 0 then
    return nil
  end
  return self[mrandom(#self)]
end

-- Return array of n random elements of t
function arr:random_sample(n)
  if n >= #self then
    return self
  end
  local indices = {}
  local result = arr()
  for i = 1, n do
    local j = mfloor(mrandom(#self - i) + i);
    result[i] = self[indices[j] and indices[j] or j];
    indices[j] = indices[i] and indices[i] or i;
  end
  return result;
end

-- Remove and return random element
function arr:remove_random()
  local i = mrandom(#self)
  return table.remove(self, i)
end

-- Find index to insert an object into sorted array so that array remains sorted
--   low      min search range bound
--   high     max search range bound
--   v        find place for this object
--   lower    compare function (a, b) returns a < b
-- return         index
function arr:find_index(low, high, v, lower)
  while low < high do
    local mid = mfloor((low + high) * 0.5)
    if lower(self[mid], v) then
      low = mid + 1
    else
      if lower(v, self[mid]) then
        high = mid
      else
        return mid
      end
    end
  end
  return high
end

-- Wrap arr functions to add type checks and logs
function arr:wrap(core)
  local typ = core:get('typ')
  local wrp = core:get('wrp')
  local t   = typ.tab
  local v   = typ.any
  local f   = typ.fun
  local n   = typ.nat

  --wrp.fn(log.info, arr, 'join',           t, {'sep', typ.str})
  wrp.fn(log.info, arr, 'is_empty',       t)
  wrp.fn(log.info, arr, 'length',         t)
  wrp.fn(log.info, arr, 'push',           t, v)
  wrp.fn(log.info, arr, 'pop',            t)
  wrp.fn(log.info, arr, 'shift',          t)
  wrp.fn(log.info, arr, 'unshift',        t, v)
  wrp.fn(log.info, arr, 'clear',          t)
  wrp.fn(log.info, arr, 'each',           t, f)
  wrp.fn(log.info, arr, 'map',            t, f)
  wrp.fn(log.info, arr, 'reduce',         t, typ.any, f)
  wrp.fn(log.info, arr, 'detect',         t, f)
  wrp.fn(log.info, arr, 'select',         t, f)
  wrp.fn(log.info, arr, 'reject',         t, f)
  wrp.fn(log.info, arr, 'all',            t, f)
  wrp.fn(log.info, arr, 'any',            t, f)
  wrp.fn(log.info, arr, 'include',        t, v)
  --invoke
  wrp.fn(log.info, arr, 'pluck',          t, typ.str)
  wrp.fn(log.info, arr, 'min',            t, f)
  wrp.fn(log.info, arr, 'max',            t, f)
  wrp.fn(log.info, arr, 'reverse',        t)
  wrp.fn(log.info, arr, 'first',          t, n)
  wrp.fn(log.info, arr, 'rest',           t, n)
  wrp.fn(log.info, arr, 'slice',          t, n, n)
  wrp.fn(log.info, arr, 'flatten',        t)
  wrp.fn(log.info, arr, 'random',         t)
  wrp.fn(log.info, arr, 'random_sample',  t, n)
  wrp.fn(log.info, arr, 'remove_random',  t)
  wrp.fn(log.info, arr, 'find_index',     t, typ.nat, typ.nat, typ.any, typ.fun)
end

return arr