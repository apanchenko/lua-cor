local log   = require('src.lua-cor.log').get('lcor')
local typ   = require 'src.lua-cor.typ'
local ass   = require 'src.lua-cor.ass'
local arr   = require 'src.lua-cor.arr'

-- wrap
local wrp = {}

-- Function calling conventions. Used in opts.call
wrp.call_static   = 1 -- library function, called with '.'
wrp.call_table    = 2 -- class function, called on this table (or subtable) with ':'. (e.g. vec:new)
wrp.call_subtable = 3 -- instance function, called on subtable with ':', default (e.g. vec:length)

wrp.wrap_stc = function(flog, t, fname, ...)  wrp.fn(flog, t, fname, {...}, {call=wrp.call_static}) end
wrp.wrap_tbl = function(flog, t, fname, ...)  wrp.fn(flog, t, fname, {...}, {call=wrp.call_table}) end
wrp.wrap_sub = function(flog, t, fname, ...)  wrp.fn(flog, t, fname, {...}, {call=wrp.call_subtable}) end

-- wrap function t.fn_name
-- @param arg_info - array of argument descriptions {name, type, tstr}
-- @param opts     - {name:str, log:, call}
wrp.fn = function(flog, t, fn_name, arg_infos, opts)
  opts = opts or {}

  local t_name = tostring(t)
  if not typ.str(t_name) then
    error('wrp.fn t name is '.. tostring(t_name))
    return;
  end
  local callconv = opts.call or wrp.call_subtable

  local call = 'wrp.fn('..t_name..', '..fn_name..')'
  log.info(call)
  log.enter()

  ass.tab(t, 'first arg is not a table in '.. call)
  ass.str(fn_name, 'fn_name is not a string in '.. call)
  ass.fun(flog)
  ass.nat(callconv)

  -- prepare arg_infos array
  arg_infos = arg_infos or {}
  for i = 1, #arg_infos do
    local info = arg_infos[i]

    -- first is name of the argument
    info.name = info[1]
    ass.str(info.name)

    -- second typ.child
    info.type = (function(v) -- use anonymous function to get rid of elses
      if typ(v) then
        return v
      end
      if typ.str(v) then
        return typ.metaname(v)
      end
      if typ.tab(v) then
        return typ.meta(v)
      end
      if v == nil then
        return typ.metaname(info.name)
      end
      error(call.. ' - invalid type declaration '.. tostring(v))
    end)(info[2])
    ass(typ(info.type))

    log.info('arg '.. info.name.. ' of '.. tostring(info.type))

    -- third is tostring function
    info.tostring = info[3] or tostring 
    ass.fun(info.tostring)
  end

    -- original function
  local fn = t[fn_name]
  ass.fun(fn, call..' - no such function')

  -- 
  local function arguments(call, args)
    ass.eq(#arg_infos, #args, call..' expected '..#arg_infos..' arguments, found '..#args..' - ['..arr.join(args)..']')
    local res = ''
    for i = 1, #args do
      local arg = args[i]
      local info = arg_infos[i]
      local argstr = info.tostring(arg)
      local argtype = '['..type(arg)..']'
      --log.info(call.. ' check arg '.. tostring(i).. ': '.. info.name..'='..argstr.. ' is of '.. tostring(info.type))
      ass(info.type(arg), call..' '..info.name..'='..argstr..' is not of '.. tostring(info.type))
      if #res > 0 then
        res = res..', '
      end
      res = res.. info.name.. '='.. argstr
    end
    return res
  end

  -- define a new function
  if callconv == wrp.call_static then
    local type_fn = t_name..'.'..fn_name
    t[fn_name] = function(...)
      flog(type_fn..'('..arguments(type_fn, {...})..')').enter()

      -- check arguments before call
      local before = t[fn_name..'_wrap_before']
      if before then before(...) end

      local result = fn(...)

      -- check self state and result after call
      local after = t[fn_name..'_wrap_after']
      if after then after(...) end
      
      flog().exit()

      if result then -- log function output
        flog(fn_name..' ->', result)
      end      
      return result
    end
  else
    local type_fn = t_name..':'..fn_name
    t[fn_name] = function(...)
      local args = {...}
      local self = table.remove(args, 1)

      -- check calling convention
      if callconv == wrp.call_table then
        ass(typ.is(self, t), 'self='..tostring(self)..' is not '..t_name..' in '..type_fn)
      elseif callconv == wrp.call_subtable then
        ass(typ.extends(self, t), 'self='..tostring(self)..' is not subtable of '..t_name..' in '..type_fn)
      else
        error(call.. ' invalid opts.call '.. tostring(callconv))
      end

      local call = tostring(self)..':['..t_name..']'..fn_name
      flog(call..'('..arguments(call, args)..')').enter()

      -- check self state before call
      local fn_before = self[fn_name .. '_wrap_before']
      if fn_before then
        fn_before(...)
      end

      -- call original function
      local result = fn(...)

      -- check self state and result after call
      local fn_after = self[fn_name .. '_wrap_after']
      if fn_after then
        fn_after(...)
      end

      flog().exit()

      if result then -- log function output
        flog(fn_name..' ->', result)
      end

      return result
    end
  end
  log.exit()
end

return wrp