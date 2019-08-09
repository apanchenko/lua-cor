local ass = require('src.lua-cor.ass')
local cnt = require('src.lua-cor.cnt')
local log = require('src.lua-cor.log').get('test')

local copy = function(self)
  return {id=self.id, count=self.count, copy=self.copy}
end

local i = cnt:new()
ass(i:is_empty())

i:push({id='a', copy=copy})
i:push({id='a', copy=copy})
ass.eq(i:count('a'), 1)

local res
res = i:push({id='b', count=2, copy=copy})
res = i:push({id='b', count=3, copy=copy})
ass.eq(res, 5)
log.trace('cnttest - '.. tostring(i))

local b = i:pull('b', 4)
ass.eq(b.count, 4)
ass.eq(i:count('b'), 1)

res = i:pull('b', 4)
ass.eq(res.count, 1)
ass.eq(i:count('b'), 0)

res = i:pull('a', 1)
ass.eq(i:count('a'), 0)