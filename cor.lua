local arr       = require 'src.lua-cor.arr'
local wrp       = require 'src.lua-cor.wrp'

local cor = {}

cor.arr = arr.new
cor.wrp = wrp.fn
cor.com = require 'src.lua-cor.com'
cor.env = require 'src.lua-cor.env'

return cor