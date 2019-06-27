local arr = require 'src.lua-cor.arr'
local ass = require 'src.lua-cor.ass'
local log = require('src.lua-cor.log').get('lcor')

--
return function(base)
  local com = base or {}
  ass.nul(com.com_add)
  ass.nul(com.com_destroy)

  -- private:
  local _com_children = arr()

  -- public:
  com.com_add = function(t)
    ass.fun(t.com_destroy)
    _com_children:push(t)
    return t
  end
  
  com.com_destroy = function()
    _com_children:invoke('com_destroy')
    _com_children:clear()
    _com_children = nil
  end
  
  return com
end