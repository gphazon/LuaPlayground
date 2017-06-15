-- I wonder how this will go


-- creating a sequence of tokens from text.
-- being parsed at the level of characters being tokens. lolk


-- mm tokens
local t = require("tokens")

local c = io.read(1)

-- because function defentions r so fun
-- functioncall ::= prefixexp args
local function isletter()
  return c and c:match("%a")
end

-- If control reaches the end of a function without encountering a return statement, then the function returns with no results.
-- 
local function consume()
  c = io.read(1)
end

local function NAME()
  local val = {}
  while isletter() do
    val[#val+1] = c
    consume()
  end
  return t.new(t.NAME, table.concat(val))
end

-- need a framework
-- ugh async
local function WS()
  while c == ' ' or c == "\t" or c == "\n" or c == "\r" do consume() end
end

-- Token filters read and write tokens one at a time. k
-- lol freeform langauges r kinda dope if u ask me
local function nextToken()
  while c do
    -- honestly lpeg is really stupid
    -- as bad as luvit pls fix
    if c == ' ' or c == '\t' or c == '\n' or c == '\r' then WS()
    elseif c == '+' then consume(); return t.new(t.PLUS, "+")
    elseif c == '-' then consume(); return t.new(t.MINUS, "-")
    elseif c == '=' then consume(); return t.new(t.EQUALS, "=")
    elseif c == '/' then consume(); return t.new(t.SLASH, "/")
    elseif (isletter()) then return NAME();
    else
      error("invalid character: "..c)
    end
  end
  return t.new(t.EOF, "<EOF>");
end

return nextToken
