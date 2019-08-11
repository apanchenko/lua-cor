local arr = require('src.lua-cor.arr')
local ass = require('src.lua-cor.ass')

-- Test arr
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

ass.nul(arr():random())

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