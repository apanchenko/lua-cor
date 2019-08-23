-- Library of helper functions to create and layout Corona display objects.

local cfg = require 'src.cfg'
local ass = require 'src.lua-cor.ass'
local typ = require('src.lua-cor.typ')
local wrp = require('src.lua-cor.wrp')
local map = require 'src.lua-cor.map'
local arr = require 'src.lua-cor.arr'
local log = require('src.lua-cor.log').get(' lay')
local widget = require 'widget'

--local lay = obj:extend('spt')
local lay = setmetatable({}, { __tostring = function() return 'lay' end})

-- Wrap functions to add checks and logs
function lay:wrap()
  local group =  typ.tab
  local obj    = typ.tab
  local param  = typ.tab
  local pos    = typ.tab
  local space  = typ.num

  wrp.fn(log.info, lay, 'insert',       group,   obj, param)
  wrp.fn(log.info, lay, 'to',           obj,     pos, param)
  wrp.fn(log.info, lay, 'new_image',    group,   param)
  wrp.fn(log.info, lay, 'new_text',     group,   param)
  wrp.fn(log.info, lay, 'new_sheet',    group,   param)
  wrp.fn(log.info, lay, 'new_button',   group,   param)
  wrp.fn(log.info, lay, 'column',       obj,     space)
  wrp.fn(log.info, lay, 'rows',         obj,     param)
  wrp.fn(log.info, lay, 'new_layout')
end

local cmp_z = function(a, b)
  return a._z < b._z
end

-- Insert obj into target with layout param
-- @param target          display group insert in
-- @param obj             object to render
-- @param opts.w          width in pixels
-- @param opts.vw         or width in vw
-- @param opts.h          height in pixels
-- @param opts.hw         or height in vh
-- @param opts.ratio      or height relative to width
-- @param opts.vx         defaults to 0
-- @param opts.vy         defaults to 0
-- @param opts.z          render order, 1 renders first, larger renders later
lay.insert_wrap_before = function(group, obj, param)
  --TODO: check all args in lay.wrap
  ass(group)
  ass.fun(group.remove)
  ass.fun(group.insert)

  ass(obj)
  ass.nul(obj._z)
  ass.fun(obj.removeSelf)

  ass.num(param.z)
  ass(param.x or param.vx, 'lay.insert - set param x or vx')
  ass(param.y or param.vy, 'lay.insert - set param y or vy')
end
lay.insert = function(group, obj, param)
  obj.anchorX = param.anchorX or 0
  obj.anchorY = param.anchorY or 0
  obj.x = param.x or (cfg.view.vw * param.vx)
  obj.y = param.y or (cfg.view.vh * param.vy)
  if param.vw then
    local scale = cfg.view.vw * param.vw / obj.width
    obj:scale(scale, scale)
  end

  obj._z = param.z

  local index = arr.find_index(group, 1, group.numChildren + 1, obj, cmp_z)
  --log.trace('insert', map.tostring(param), 'at', index)
  group:insert(index, obj)
end

-- Animate x,y coordinates
lay.to = function(obj, pos, params)
  params.x = pos.x
  params.y = pos.y
  transition.to(obj, params)
end

-- Arrange children in column
lay.column = function(group, space)
  local y = group[1].y
  for i = 1, group.numChildren do
    local child = group[i]
    child.y = y
    y = y + child.height + space
  end
end

-- Arrange children in rows. Children should be of same height.
-- @param opts:
--    length        maximum length or each row
--    space_x       horizontal space between elements in a row
--    space_y       vertical space between rows
lay.rows = function(obj, opts)
  local view = obj.view or obj
  local space_x = opts.space_x or (cfg.view.vw * opts.space_px)
  local space_y = opts.space_y or (cfg.view.vw * opts.space_py)
  local x = 0
  local y = 0
  local count = 0
  for i = 1, view.numChildren do
    local child = view[i]
    child.x = x
    child.y = y
    x = x + child.width + space_x
    count = count + 1
    if count == opts.length then
      count = 0
      x = 0
      y = y + child.height + space_y
    end
  end
end 

-- Create image
lay.new_image = function(group, param)
  ass(group)
  ass(param)
  ass.nat(param.z)

  local w = param.w or (cfg.view.vw * param.vw)
  local h;
  if param.h then
    h = param.h
  elseif param.vh then
    h = cfg.view.vh * param.vh
  else
    h = w / (param.ratio or 1)
  end
  log.trace('lay.new_image', param.path)
  local img = display.newImageRect(param.path, w, h)
  lay.insert(group, img, param)
  return img
end

-- Display text
-- @param group   display group insert in
-- @param opts = {text, vx, vy, x, y, width, height, font, fontSize}
-- @see https://docs.coronalabs.com/api/library/display/newText.html
lay.new_text = function(group, param)
  ass(group)
  ass(param)
  ass.nat(param.z)
  
  if param.w then
    param.width = param.w
  elseif param.vw then
    param.width = param.vw * cfg.view.vw
  end

  local text = display.newText(param)
  lay.insert(group, text, param)
  return text
end

-- Create button
-- @see https://docs.coronalabs.com/api/library/widget/newButton.html
-- @param opts:
--    label         optional String. Text label that will appear on top of the button.
--    labelAlign    optional String. Alignment of the button label. Valid
--                    values are left, right, or center. Default is center.
--    labelColor    optional Table. Table of two RGBA color settings,
--                    one each for the default and over states. {default={1, 1, 1}, over={0, 0, 0, 0.5}}
--    labelXOffset  optional Number. x offset for the button label.
--    labelYOffset  optional Number. y offset for the button label.
--    font          optional String. Font used for the button label. Default is native.systemFont.
--    fontSize      optional Number. Font size (in pixels) for the button label. Default is 14.
--    emboss        optional Boolean. If set to true, the button label will appear embossed (inset effect).
--    textOnly      optional Boolean. If set to true, the button will be
--                    constructed via a text object only (no background element). Default is false.
--
--    shape         required String. "rect" | "roundedRect" | "circle" | "polygon"
--    fillColor     optional Table. Table of two RGBA color settings, one each
--                    for the default and over states. These colors define the
--                    fill color of the shape. {default={1, 0.2, 0.5, 0.7}, over={ 1, 0.2, 0.5, 1}}
--    strokeColor   optional Table. Table of two RGBA color settings, one each
--                    for the default and over states. These colors define the stroke color of the shape.
--                    {default={ 0, 0, 0 }, over={0.4, 0.1, 0.2}}
--    strokeWidth   optional Number. The width of the stroke around the shape
--                    object. Applies only if strokeColor is defined.
--    width, height optional Numbers. The width and height of the button shape.
--                    Only applies to "rect" or "roundedRect" shapes.
--    cornerRadius  optional Number. Radius of the curved corners for
--                    a "roundedRect" shape. This value is ignored for all other shapes.
--    radius        optional Number. Radius for a "circle" shape.
--                    This value is ignored for all other shapes.
--    vertices      optional Array. An array of x and y coordinates to define a "polygon" shape.
--                    These coordinates will automatically be re-centered about
--                    the center of the polygon, and the polygon will be centered
--                    in relation to the button label. This property is ignored for
--                    all other shapes. {-20, -25, 40, 0, -20, 25}
lay.new_button = function(group, param)
  ass(group)
  ass.fun(group.remove)
  ass.fun(group.insert)

  if param.width == nil then
    param.width = cfg.view.vw * param.vw
  end

  if param.height == nil then
    if param.vh then
      param.height = cfg.view.vh * param.vh
    else
      param.height = param.width / (param.ratio or 1)
    end
  end

  local button = widget.newButton(param)
  ass(button)
  lay.insert(group, button, param)
  return button
end

--
lay.new_sheet = function(group, param)
  assert(param.sheet)
  assert(param.frame)
  assert(param.w and param.h)
  local img = display.newImageRect(param.sheet, param.frame, param.w, param.h)
  lay.insert(group, img, param)
  return img
end

local _ = {}

-- iterate group childs if any
_.each_child = function(obj, fn)
  if typ.num(obj.numChildren) then
    for index = 1, obj.numChildren do
      local child = obj[index]
      if child then
        fn(index, child)
      end
    end
  end
end

-- log layout tree
_.walk_tree = function(index, obj)
  local indent = log.trace(index, obj._id, '[', obj.x, obj.y, obj.width, obj.height, ']', obj.numChildren)
  indent.enter()
  _.each_child(obj, _.walk_tree)
  indent.exit()
end


-- Create new layout.
-- Layout represents a reusable visual design of UI element:
--   .add         add parameterised childs
--   .new_group   create view with this layout
function lay.new_layout_wrap_before()
  ass.eq(3,4)
end
function lay.new_layout()
  local layout = {} -- interface .add, .new_group
  local params = {} -- layout id:param container

  layout.add = function(id, param)
    ass(param)
    ass.nat(param.z)
    ass.fun(param.fn)
    params[id] = param
    return layout
  end

  layout.new_group = function(view)
    local group  = view or display.newGroup()
    local layers = {}

    group.show = function(id)
      ass.str(id)
      local p = params[id]
      local o = layers[p.z]
      log.trace('group.show', id, 'on z', p.z)
      if o then
        o:removeSelf()
      end
      o = p.fn(group, p)
      o._id = id
      layers[p.z] = o
      return group
    end

    group.hide = function(id)
      local p = params[id]
      local o = layers[p.z]
      log.trace('group.hide', id, 'on z', p.z)
      if o then
        o:removeSelf()
        layers[p.z] = nil
      end
      return group
    end

    group.column = function(space)
      local y = group[1].y
      for i = 1, group.numChildren do
        local child = group[i]
        child.y = y
        y = y + child.height + space
      end
      return group
    end

    group.walk_tree = function()
      log.trace('----------walk_tree {', group._id)
      _.walk_tree(0, group)
      log.trace('--------------------}')
    end

    group.com_destroy = function()
      map.each(layers, function(o) o:removeSelf() end)
    end

    return group
  end

  return layout
end

lay.new_layout_wrap_after = function(layout)
  ass(layout)
  ass.fun(layout.add)
  ass.fun(layout.new_group)
  ass(false)
end

return lay