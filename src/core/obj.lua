--[[
    Inheritance implementation. The obj is a base type to extend.
    Call 'extend' to inherit new type and 'new' to create instance of a type.

    While there is no semantic difference between type and instance in Lua
    and so it is not a problem to inherit any table, classic OOP does not
    defines this. Should we prohibit extending instances?
]]--

-- Create obj
local mt        = {__tostring = function(self) return self.tname end}
local obj       = setmetatable({tname = 'obj'}, mt)
obj.__index     = obj

-- Create library table for static functions
obj.create_lib = function(typename)
  local lib = setmetatable({tname = typename}, mt)
  lib.__index = lib 
  return lib
end 

-- Create new type extending obj
obj.extend = function(self, typename)
  local sub = setmetatable({tname = typename}, self)
  sub.__index = sub
  sub.__tostring = function(self) return self.tname end
  return sub
end

-- Construct instance object
obj.new = function(self, inst) return setmetatable(inst or {}, self) end

-- Helper for faster call new
obj.__call = function(t, ...) return t:new(...) end

-- Support tostring for ancestors
obj.__tostring  = function(self) return self.tname end

-- Typename getter
obj.get_typename = function(self) return self.tname end

-- Wrap obj functions with logs and checks 
function obj:wrap()
  local wrp = require 'src.core.wrp'
  local typ = require 'src.core.typ'
  local ass = require 'src.core.ass'
  local typename = {'typename', typ.str}
  wrp.wrap_stc_inf(obj, 'create_lib', typename)
  wrp.wrap_tbl_inf(obj, 'extend',     typename)
end

-- test obj
function obj:test(ass) 
  ass.eq(tostring(obj), 'obj')

  -- account extends obj
  local account = obj:extend('account')
  -- add account constructor
  account.new = function(self, inst)
    inst.balance = 0
    return obj.new(self, inst)
  end
  -- add function deposit to account
  account.deposit = function(self, v) self.balance = self.balance + v end
  account.get_balance = function(self) return self.balance end

  -- extended type of account
  local limited = account:extend('limited')
  -- add limit property
  limited.new = function(self, inst, limit)
    inst.limit = limit
    return account.new(self, inst)
  end
  -- overload deposit
  limited.deposit = function(self, v) account.deposit(self, math.min(v, self.limit)) end

  local bob = limited:new({}, 100)
  bob:deposit(120)

  ass.eq(bob:get_balance(), 100)
  ass.eq(tostring(bob), 'limited')
  ass.is(account, obj)
  ass.is(bob, account)
end

return obj