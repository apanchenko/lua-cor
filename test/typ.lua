local ass = require('src.lua-cor.ass')
local typ = require('src.lua-cor.typ')

-- typ
ass(tostring(typ)=='typ',  'invalid typ name')
ass(typ(typ),              'typ is not typ')
ass(typ({})==false,        '{} is typ')

-- any
ass(tostring(typ.any)=='typ.any', 'invalid any name')
ass(typ(typ.any),          'any is not typ')
ass(typ.any({}),           '{} is not any')
ass(typ.any(nil)==false,   'nil is any')

-- boo
ass(typ(typ.boo),          'boo is not typ')
ass(typ.boo(true),         'true is not bool')
ass(typ.boo(false),        'false is not bool')

-- tab
ass(typ(typ.tab),          'tab is not typ')
ass(typ.tab({}),           '{} is not table')

-- num
ass(typ(typ.num),          'num is not typ')

-- str
ass(typ(typ.str),          'str is not typ')
ass(typ.str(''),           'empty string is not str')
ass(typ.str(1)==false,     '1 is not str')
ass(typ.str(nil)==false,   'nil is not str')

ass(typ(typ.fun),          'fun is not typ')
ass(typ(typ.nat),          'nat is not typ')