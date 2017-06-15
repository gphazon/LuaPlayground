-- Why am I doing this


-- lowkey function tables
--  apparently with __call metamethod we can allow the table to be used as though it were the function
-- in fact, we could even give it the name of the original function, making the change almost invisible wtf
-- SEXYYYYYYYYYYYYYYYYYYYYYYYYYY
lookahead = {
  __call = function(lali, i)
    lali:sync(i)
    return lali.buffer[lali.p + (i - 1)]
  end,
-- token parsing
  consume = function(lali)
    lali.p = lali.p + 1

    -- have we hit end of buffer when not backtracking?
    if lali.p > #lali.buffer and not lali:speculating() then
      -- if so, it's an opportunity to start filling at index 0 again
      lali.p, lali.buffer = 1, {}
    end

    lali:sync(1) -- get another to replace consumed token
  end,

  -- we have to  have i tokens from current position p, yE
  sync = function(lali, i)
    local n = lali.p + (i - 1) - #lali.buffer
    if n > 0 then -- out of tokens?
      local elem = lali.nextelem() -- hmm
      print("ELEM: ", elem) 
      for i = 1, n do lali.buffer[#lali.buffer + 1] = elem end -- don't end my lali :(
    end
  end,
-- choosing function?
  mark = function(lali)
    lali.markers[#lali.markers + 1] = lali.p
    return p
  end,
-- unselecting
  release = function(lali)
    lali.p = table.remove(lali.markers)
  end,

  speculating = function(lali)
    return #lali.markers > 0
  end
}
-- but what is it looking ahead off really thou, in a spiritual sense
lookahead.__index = lookahead

function lookahead.new(nextelem)
  local lali = setmetatable({
    p = 1,        -- index of current lookahead token
    buffer = {},  -- dynamically-sized lookahead buffer
    markers = {}, -- stack of index markers into lookahead buffer
    nextelem = nextelem
  }, lookahead)
-- a single token?
  lali:sync(1) -- prime buffer  

  return lali -- lali? :(
end
-- laLIiiiiiiiiiii
return lookahead -- (pls return)
