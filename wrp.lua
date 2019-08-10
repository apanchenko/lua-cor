local log = require('src.lua-cor.log').get('lcor')
local typ = require('src.lua-cor.typ')
local ass = require('src.lua-cor.ass')
local arr = require('src.lua-cor.arr')
local map = require('src.lua-cor.map')

local wrp = {}

-- private
-- wrapped funciton names
local _wrapped = {}

-- Wrap function t.fn_name
--   flog     - log function
--   t        - table with function fn
--   ...      - argument descriptions {name, type, tostr}
wrp.fn = function(flog, t, fn_name, ...)
  local tstr = tostring(t)
  local call = 'wrp.fn('..tostring(tstr)..', '..tostring(fn_name)..')'
  local indent = log.info(call)
  indent.enter()
  ass.fun(flog)
  ass.tab(t, 'first arg is not a table in '.. call)
  ass.str(tstr, 't name is not string in '.. call)
  ass.str(fn_name, 'fn_name is not a string in '.. call)

  -- prepare arg_infos array
  local arg_infos = {...}
  for i = 1, #arg_infos do
    local info = arg_infos[i]

    -- first is name of the argument
    info.name = info[1]
    ass.str(info.name)

    -- second typ.child
    info.type = (function(v) -- use anonymous function to get rid of elses
      if typ.fun(v) then
        return typ:new('?', v)
      end
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

    -- third is tostring function
    info.tostring = info[3] or tostring 
    ass.fun(info.tostring)
  end

    -- original function
  local fn = t[fn_name]
  local call = tstr..'.'..fn_name
  ass.fun(fn, call..' - no such function')

  -- check function is not wrapped yet
  local wrapped = rawget(t, _wrapped)
  if wrapped == nil then
    wrapped = {}
    rawset(t, _wrapped, wrapped)
  end
  ass.nul(wrapped[fn_name], 'function '..tstr..'.'..fn_name..' is already wrapped')
  wrapped[fn_name] = true

  -- define a new function
  t[fn_name] = function(...)
    -- ceck arguments
    local arg = {...}
    ass.eq(#arg_infos, #arg, call..' expected '..#arg_infos..' arguments, found '..#arg..' - ['..arr.join(arg)..']')
    local arguments = ''
    for i = 1, #arg do
      local a = arg[i]
      local info = arg_infos[i]
      local astr = info.tostring(a)
      ass(info.type(a), call..' '..info.name..'='..astr..' is not of '.. tostring(info.type))
      if #arguments > 0 then
        arguments = arguments..', '
      end
      arguments = arguments.. info.name.. '='.. astr
    end

    local fn_indent = flog(call..'('..arguments..')')
    fn_indent.enter()
      map.call_fn(fn_name..'_wrap_before', ...) -- check state before call
      local result = fn(...)
      map.call_fn(fn_name..'_wrap_after', ..., result) -- check self state and result after call
    fn_indent.exit()

    -- log function output
    if result then
      flog(fn_name..' ->', result)
    end
    return result
  end

  indent.exit()
end

return wrp