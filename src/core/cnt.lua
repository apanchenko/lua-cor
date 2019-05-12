local ass   = require 'src.core.ass'
local typ   = require 'src.core.typ'
local wrp   = require 'src.core.wrp'
local log   = require 'src.core.log'
local map   = require 'src.core.map'
local obj   = require 'src.core.obj'

-- Map id->object
-- where object have
--   .count     - optional number counts objects with same id
--   .id        - equal ids mean equal objects
--   :copy()    - create a copy of the object
local cnt = obj.create_lib('cnt')

-- interface
function cnt:wrap()
  local id    = {'id', typ.any}
  local obj   = {'obj', typ.tab}
  local count = {'count', typ.num}
  local fn    = {'fn', typ.fun}

  wrp.wrap_tbl_inf(cnt, 'new')
  wrp.wrap_sub_inf(cnt, 'is_empty')
  wrp.wrap_sub_inf(cnt, 'push',     obj)
  wrp.wrap_sub_inf(cnt, 'pull',     id, count)
  wrp.wrap_sub_inf(cnt, 'remove',   id)
  wrp.wrap_sub_inf(cnt, 'count',    id)
  wrp.wrap_sub_inf(cnt, 'any',      fn)
  wrp.wrap_sub_inf(cnt, 'each',     fn)
  wrp.wrap_sub_inf(cnt, 'random')
end

-- Create cnt instance
function cnt:new()
  return setmetatable({data={}}, self)
end

--
function cnt:__tostring()
  return 'cnt['.. tostring(map.count(self.data)).. ']'
end

-- Test if container has no objects
function cnt:is_empty()
  return next(self.data) == nil
end

-- Add object to container
-- @param obj   - object to add
-- @return      - resulting number of objects in container
function cnt:push_wrap_before(obj)
  ass(obj.id)
end
function cnt:push(obj)
  local my = self.data[obj.id] -- exisitng object in container
  if my then
    if obj.count then -- if countable
      my.count = my.count + obj.count -- add count
      return my.count
    end
    return 1 -- non-countable, always 1
  end
  self.data[obj.id] = obj -- add new object to container
  return obj.count or 1
end

-- Try return requested count of objects
-- @param id    - object identifier
-- @param count - number of objects to return
-- @return      - object copy with count
function cnt:pull(id, count)
  local my = self.data[id] -- identify existing object in container
  if my == nil then -- nothing found
    return nil -- so return nothing
  end
  if my.count == nil or my.count <= count then -- non-countable or have few
    self.data[id] = nil -- wipe out
    return my -- give up all
  end
  my.count = my.count - count -- have enough to left
  local copy = my:copy() -- make a copy to return
  copy.count = count -- return requested count
  return copy
end

-- Completely remove object by id
-- @param id    - object identifier
-- @return      - object removed
function cnt:remove(id)
  local my = self.data[id] -- identify existing object in container
  self.data[id] = nil -- wipe out
  return my -- give up all
end

-- Get number of objects by id
-- @param id    - object identifier
-- @return      - number of objects in container
function cnt:count(id)
  local my = self.data[id]
  if my == nil then
    return 0
  end
  return my.count or 1
end

-- all are true
function cnt:all(fn)
  return map.all(self.data, fn)
end

-- any
function cnt:any(fn)
  return map.any(self.data, fn)
end

--
function cnt:each(fn)
  return map.each(self.data, fn)
end

--
function cnt:random()
  return map.random(self.data)
end

-- MODULE ---------------------------------------------------------------------
--
function cnt:test()
  local copy = function(self)
    return {id=self.id, count=self.count, copy=self.copy}
  end

  local i = cnt:new()
  ass(i:is_empty())

  i:push({id='a', copy=copy})
  i:push({id='a', copy=copy})
  ass.eq(i:count('a'), 1)

  res = i:push({id='b', count=2, copy=copy})
  res = i:push({id='b', count=3, copy=copy})
  ass.eq(res, 5)
  log:trace('cnttest - '.. tostring(i))

  b = i:pull('b', 4)
  ass.eq(b.count, 4)
  ass.eq(i:count('b'), 1)

  res = i:pull('b', 4)
  ass.eq(res.count, 1)
  ass.eq(i:count('b'), 0)

  res = i:pull('a', 1)
  ass.eq(i:count('a'), 0)
end

return cnt