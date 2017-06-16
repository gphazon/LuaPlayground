local tokens = {
  "EOF",
  "NAME",
  "PLUS",
  "MINUS",
  "SLASH",
  "EQUALS"
}
-- __ functions r neat
tokens.__tostring = function(tab)
  return tokens[tab.kind]..": "..tostring(tab.val)
end
-- uw0t
tokens.new = function(kind, val)
  return setmetatable({ kind=kind, val=val }, tokens)
end

-- save each token as a numeric value.
for i, v in ipairs(tokens) do -- the only pair for me is lali
  tokens[v] = i
end

return tokens 
