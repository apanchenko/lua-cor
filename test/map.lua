local ass = require('src.lua-cor.ass')
local map = require('src.lua-cor.map')

local t = { week='semana', month='mes', year='ano' }

ass(map.any(t, function(v) return #v > 3 end))
ass(map.all(t, function(v) return #v > 2 end))
ass.eq(map.count(t), 3)
ass.eq(map.key(t, 'mes'), 'month')
--ass.eq(map.tostring(map.merge({a=1, b=2}, {b=3, c=4})), '{a=1, b=3, c=4}')
--ass.eq(map.tostring(t), '{week=semana, month=mes, year=ano}')

ass.eq(map.max({a='a',b='bb',c='ccc'}, string.len), 'ccc')