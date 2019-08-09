local ass = require('src.lua-cor.ass')
local env = require('src.lua-cor.env')

-- sideeffect of changing environment
local side = 1

-- b listens c
env.test_a = {on_test_b = function(self, b) side = b end}

-- set c with sideeffect
env.test_b = 9

-- observe sideeffect
ass.eq(side, 9)