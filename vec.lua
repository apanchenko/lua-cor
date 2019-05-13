--[[
    Vector or two elements. Extremely useful for 2D math.
]]--

local obj   = require 'src.luacor.obj'
local typ   = require 'src.luacor.typ'
local ass   = require 'src.luacor.ass'
local wrp   = require 'src.luacor.wrp'

-- Define 2d vector type
local vec = obj:extend('vec')
vec.x = 0
vec.y = 0

-- Static copy vector value from one table to another
function vec.copy(from, to)
  to.x = from.x
  to.y = from.y
end

-- Static initialize table to screen center
function vec.center(obj)
  obj.x = display.contentWidth / 2
  obj.y = display.contentHeight / 2
end

-- Math operators
function vec.__add(l, r) return vec:new(l.x + r.x, l.y + r.y) end
function vec.__sub(l, r) return vec:new(l.x - r.x, l.y - r.y) end
function vec.__div(l, r) return vec:new(l.x / r.x, l.y / r.y) end
function vec.__mul(l, r) return vec:new(l.x * r.x, l.y * r.y) end
function vec.__eq (l, r) return (l.x == r.x) and (l.y == r.y) end
function vec.__lt (l, r) return (l.x < r.x) and (l.y < r.y) end
function vec.__le (l, r) return (l.x <= r.x) and (l.y <= r.y) end

-- Create a new vector
function vec:new(x, y)
  return obj.new(self, {x = x, y = y})
end

-- Create a random vector in range
function vec:random(min, max)
  return setmetatable({x = math.random(min.x, max.x), y = math.random(min.y, max.y)}, vec)
end

-- Create vector as a copy
function vec:from(obj)
  return vec(obj.x, obj.y)
end

-- Convert to log friendly string
function vec:__tostring()
  return '{'..self.x.. ",".. self.y..'}'
end

-- Compute square length
function vec:length2()
  return (self.x * self.x) + (self.y * self.y)
end

-- Create new vector rounding x,y to closest integer values
function vec:round()
  return vec:new(math.floor(self.x + 0.5), math.floor(self.y + 0.5))
end

-- Copy x,y into obj
function vec:to(obj)
  obj.x = self.x
  obj.y = self.y
end

-- Create positive vector
function vec:abs()
  return vec:new(math.abs(self.x), math.abs(self.y))
end

-- Constant zero vector
vec.zero = vec(0, 0)

-- Constant ones vector
vec.one = vec(1, 1)

-- Wrap vector functions
function vec:wrap()
  wrp.wrap_stc_inf(vec, 'copy',   {'from', typ.tab}, {'to', typ.tab})
  wrp.wrap_stc_inf(vec, 'center', {'obj', typ.tab})
  
  wrp.wrap_tbl_inf(vec, 'new',    {'x', typ.num}, {'y', typ.num})
  wrp.wrap_tbl_inf(vec, 'random', {'min', vec}, {'max', vec})
  wrp.wrap_tbl_inf(vec, 'from',   {'obj', typ.tab})
  
  wrp.wrap_sub_inf(vec, 'length2')
  wrp.wrap_sub_inf(vec, 'round')
  wrp.wrap_sub_inf(vec, 'to',     {'obj', typ.tab})
  wrp.wrap_sub_inf(vec, 'abs')
end

-- Self test
function vec:test()
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
end

return vec
