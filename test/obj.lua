local ass = require('src.lua-cor.ass')
local obj = require('src.lua-cor.obj')

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