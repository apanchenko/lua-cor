local ass = require('src.lua-cor.ass')
local vec = require('src.lua-cor.vec')

assert(tostring(vec.one) == '{1,1}')
  
local a = vec(2, 2)
local b = vec(3, 4)
local c = b - a

assert(a.x == 2 and a.y == 2)
assert(a:length2() == 8)
assert(c.x == 1 and c.y == 2)
assert(vec(2.3, 4.5):round().x == 2)

local d = vec(-1.5, -0.5)
ass(d:abs().x == 1.5)

ass.eq(vec(3,4):to_index_in_grid(vec(10,10)), 34)