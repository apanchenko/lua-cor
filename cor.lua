local arr       = require 'src.lua-cor.arr'
local vec       = require 'src.lua-cor.vec'
local lay       = require 'src.lua-cor.lay'
local ass       = require 'src.lua-cor.ass'
local obj       = require 'src.lua-cor.obj'
local typ       = require 'src.lua-cor.typ'
local wrp       = require 'src.lua-cor.wrp'
local map       = require 'src.lua-cor.map'

local cor = {}

cor.arr = arr.new
cor.wrp = wrp.fn
cor.com = require 'src.lua-cor.com'
cor.env = require 'src.lua-cor.env'

return cor