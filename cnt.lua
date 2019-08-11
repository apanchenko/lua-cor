local ass   = require 'src.lua-cor.ass'
local typ   = require 'src.lua-cor.typ'
local wrp   = require 'src.lua-cor.wrp'
local log   = require('src.lua-cor.log').get('lcor')
local map   = require 'src.lua-cor.map'
local obj   = require 'src.lua-cor.obj'

-- Map id->object
-- where object have
--   .count     - optional number counts objects with same id
--   .id        - equal ids mean equal objects
--   :copy()    - create a copy of the object
local cnt = obj:extend('cnt')

-- interface
function cnt:wrap()
  local is    = {'cnt', typ.new_is(cnt)}
  local ex    = {'excnt', typ.new_ex(cnt)}
  local id    = {'id', typ.any}
  local tab   = {'obj', typ.tab}
  local count = {'count', typ.num}
  local fn    = {'fn', typ.fun}

  wrp.fn(log.info, cnt, 'new',      is)
  wrp.fn(log.info, cnt, 'is_empty', ex)
  wrp.fn(log.info, cnt, 'push',     ex, tab)
  wrp.fn(log.info, cnt, 'pull',     ex, id, count)
  wrp.fn(log.info, cnt, 'remove',   ex, id)
  wrp.fn(log.info, cnt, 'count',    ex, id)
  wrp.fn(log.info, cnt, 'keys',     ex)
  wrp.fn(log.info, cnt, 'any',      ex, fn)
  wrp.fn(log.info, cnt, 'each',     ex, fn)
  wrp.fn(log.info, cnt, 'random',   ex)
  wrp.fn(log.info, cnt, 'clear',    ex)
end

-- private:
local data = {}

-- Create cnt instance
function cnt:new()
  self = obj.new(self)
  self[data] = {}
  return self
end

--
function cnt:__tostring()
  return 'cnt['.. tostring(map.count(self[data])).. ']'
end

-- Test if container has no objects
function cnt:is_empty()
  return next(self[data]) == nil
end

-- Add object to container
-- @param obj   - object to add
-- @return      - resulting number of objects in container
function cnt:push_wrap_before(obj)
  ass(obj.id)
end
function cnt:push(obj)
  local my = self[data][obj.id] -- exisitng object in container
  if my then
    if obj.count then -- if countable
      my.count = my.count + obj.count -- add count
      return my.count
    end
    return 1 -- non-countable, always 1
  end
  self[data][obj.id] = obj -- add new object to container
  return obj.count or 1
end

-- Try return requested count of objects
-- @param id    - object identifier
-- @param count - number of objects to return
-- @return      - object copy with count
function cnt:pull(id, count)
  local my = self[data][id] -- identify existing object in container
  if my == nil then -- nothing found
    return nil -- so return nothing
  end
  if my.count == nil or my.count <= count then -- non-countable or have few
    self[data][id] = nil -- wipe out
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
  local my = self[data][id] -- identify existing object in container
  self[data][id] = nil -- wipe out
  return my -- give up all
end

-- Get number of objects by id
-- @param id    - object identifier
-- @return      - number of objects in container
function cnt:count(id)
  local my = self[data][id]
  if my == nil then
    return 0
  end
  return my.count or 1
end

--
function cnt:keys()
  return map.keys(self[data])
end

-- all are true
function cnt:all(fn)
  return map.all(self[data], fn)
end

-- any
function cnt:any(fn)
  return map.any(self[data], fn)
end

--
function cnt:each(fn)
  return map.each(self[data], fn)
end

--
function cnt:random()
  return map.random(self[data])
end

--
function cnt:max(fn)
  return map.max(self[data], fn)
end

--
function cnt:clear()
  self[data] = {}
end

return cnt