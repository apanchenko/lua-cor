--[[
    Array.
    As you remember, indeces in Lua arrays start with 1.
    Thanks to Marcus Irven
]]--

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
  local t   = {'t', typ.tab}
  local v   = {'v', typ.any}
  local f   = {'f', typ.fun}
  local n   = {'n', typ.nat}

  --wrp.wrap_stc_inf(arr, 'join',           t, {'sep', typ.str})
  wrp.wrap_stc_inf(arr, 'is_empty',       t)
  wrp.wrap_stc_inf(arr, 'length',         t)
  wrp.wrap_stc_inf(arr, 'push',           t, v)
  wrp.wrap_stc_inf(arr, 'pop',            t)
  wrp.wrap_stc_inf(arr, 'shift',          t)
  wrp.wrap_stc_inf(arr, 'unshift',        t, v)
  wrp.wrap_stc_inf(arr, 'clear',          t)
  wrp.wrap_stc_inf(arr, 'each',           t, f)
  wrp.wrap_stc_inf(arr, 'map',            t, f)
  wrp.wrap_stc_inf(arr, 'reduce',         t, {'memo', typ.any}, f)
  wrp.wrap_stc_inf(arr, 'detect',         t, f)
  wrp.wrap_stc_inf(arr, 'select',         t, f)
  wrp.wrap_stc_inf(arr, 'reject',         t, f)
  wrp.wrap_stc_inf(arr, 'all',            t, f)
  wrp.wrap_stc_inf(arr, 'any',            t, f)
  wrp.wrap_stc_inf(arr, 'include',        t, v)
  --invoke
  wrp.wrap_stc_inf(arr, 'pluck',          t, {'name', typ.str})
  wrp.wrap_stc_inf(arr, 'min',            t, f)
  wrp.wrap_stc_inf(arr, 'max',            t, f)
  wrp.wrap_stc_inf(arr, 'reverse',        t)
  wrp.wrap_stc_inf(arr, 'first',          t, n)
  wrp.wrap_stc_inf(arr, 'rest',           t, n)
  wrp.wrap_stc_inf(arr, 'slice',          t, n, n)
  wrp.wrap_stc_inf(arr, 'flatten',        t)
  wrp.wrap_stc_inf(arr, 'random',         t)
  wrp.wrap_stc_inf(arr, 'random_sample',  t, n)
  wrp.wrap_stc_inf(arr, 'remove_random',  t)
  wrp.wrap_stc_inf(arr, 'find_index',     t, {'low', typ.nat}, {'high', typ.nat}, {'obj', typ.any}, {'is_lower', typ.fun})
end

-- Test arr
function arr:test(ass)
  local a = arr()
  local b = arr(1, 2, 3)

  -- basic manipulations
  a:push(8)
  a:push(9)
  a:unshift(7)
  ass.eq(a:pop(), 9)
  ass.eq(a:shift(), 7)
  ass.eq(a:length(), 1)
  a:clear()
  ass.eq(a:length(), 0)
  ass(a:is_empty())

  -- tostring
  ass.ts(a, '')
  ass.ts(b, '1, 2, 3')
  ass.eq(b:join('-'), '1-2-3')

  -- each
  local sum = 0
  b:each(function(v) sum = sum + v end)
  ass.eq(sum, 6)

  -- map
  b = b:map(function(v) return v * 3 end)
  ass.eq(b[1], 3)
  ass.eq(b[2], 6)
  ass.eq(b[3], 9)

  -- reduce
  sum = 0
  local fn = function(sum, v) return sum + v end
  ass.eq(a:reduce(0, fn), 0)
  ass.eq(b:reduce(sum, fn), 18)

  -- detect
  fn = function(v) return v == 6 end
  ass.eq(a:detect(fn), nil)
  ass.eq(b:detect(fn), 2)

  -- select
  fn = function(v) return v % 2 ~= 0 end
  ass.ts(a:select(fn), '')
  ass.ts(b:select(fn), '3, 9')

  -- reject
  ass.ts(a:reject(fn), '')
  ass.ts(b:reject(fn), '6')

  -- all
  ass(    a:all(function(v) return false end))
  ass(    b:all(function(v) return v % 3 == 0 end))
  ass(not b:all(function(v) return v > 4 end))

  -- any
  ass(not a:any(function(v) return true end))
  ass(    b:any(function(v) return v > 4 end))
  ass(not b:any(function(v) return v > 10 end))

  -- include
  ass(not a:include(1))
  ass(    b:include(9))
  ass(not b:include(0))

  -- invoke
  local c = arr({run=function(v) v.x = v.x + 1 end}, {run=function(v) v.x = v.x + 2 end})
  local v = {x = 0}
  c:invoke('run', v)
  ass.eq(v.x, 3)

  -- ...
  ass(c:pluck('run'):all(function(v) return type(v) == 'function' end))
  ass.eq(b:min(function(v) return v end), 3)
  ass.eq(b:max(function(v) return v end), 9)
  ass.ts(b:reverse(), '9, 6, 3')
  ass.ts(b:first(2), '3, 6')
  ass.ts(b:rest(2), '6, 9')
  ass.ts(b:slice(2, 1), '6')
  ass.ts(arr({}, {1, {2, {3, 4}}}):flatten(), '1, 2, 3, 4')

  -- random
  local r = b:random()
  ass(r==3 or r==6 or r==9)
  c = b:random_sample(2)
  ass.eq(c:length(), 2)
  ass((c:include(3) and c:include(6)) or
      (c:include(3) and c:include(9)) or
      (c:include(6) and c:include(9)))

  -- find_index
  local cmp = function(a, b) return a < b end
  ass.eq(arr.find_index({1},   1, 2, 0, cmp), 1, 'test find_index - front')
  ass.eq(arr.find_index({1},   1, 2, 2, cmp), 2, 'test find_index - back')
  ass.eq(arr.find_index({1,3}, 1, 2, 2, cmp), 2, 'test find_index - middle')
  ass.eq(arr.find_index({},    1, 1, 9, cmp), 1, 'test find_index - empty')
end

return arr