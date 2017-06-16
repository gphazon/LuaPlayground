--// START: parser
--WS       : (' '|'\t'|'\n'|'\r')+ {skip();} ; // throw out whitespace
-- watever we did in lexer yE?



local tokens = require 'tokens'
local nextToken = require "lexer"
local lali = require "lookahead" -- local? he'd be in apex if it was local :(

local lookahead = lali.new(nextToken) -- how can you look at lali when hes so far from me :(

--  match sequences of characters
function match(kind) -- he's my perfect match
  -- returns the matched text, or nil if the pattern is not found
  -- (actually, find also returns the matched text, but it first returns the indexes; match only returns the text)
  if lookahead(1).kind == kind then
    lookahead:consume()
  else
    -- literally matching text isn't that useful
    error("expecting "..tokens[kind].." but found "..tostring(lookahead(1)))
  end
end

-- basic backtracking mechanism

function matchorbacktrack(name, func)
  lookahead:mark() -- mark this spot in input so we can rewind
  local success, msg = pcall(func)
  lookahead:release() -- either way, rewind to where we were
  if success then 
    func()  
  else
    print("Failed matching "..name.." with msg: "..msg..". Backtracked.") -- hmm.....
  end
  return success 
end

-- elements : element ('+' element)* ;
function elements()
  element()
  while lookahead(1).kind == tokens.PLUS do -- first elseif in lexer
    match(tokens.PLUS)
    element()
  end
end

-- element : NAME '=' NAME | NAME | list ; assignment, NAME or list
function element()
  if lookahead(1).kind == tokens.NAME and
     lookahead(2).kind == tokens.EQUALS then match(tokens.NAME); match(tokens.EQUALS); match(tokens.NAME)
  elseif lookahead(1).kind == tokens.NAME then match(tokens.NAME) -- 
  elseif lookahead(1).kind == tokens.EQUALS then list() 
  else error("expecting name or list; found "..tostring(lookahead(1))) -- uHHH 
  end
end

-- this is the statement needing backtrack
function stat()
 -- functions may return multiple results. Several predefined functions in Lua return multiple values
  return matched backtrack("list", function() list(); match(tokens.EOF) end) or -- i need to backtrack my decision on learning this
  -- function call as the last (or only) expression produces as many results as needed to match the variables:     
  matched backtrack("assignment", function() assign(); match(tokens.EOF) end) or
         error("expecting stat but found "..tostring(lookahead(1))) 
end
-- assign : list '=' list ; // parellelelelel
function assign()
  list()
  match(tokens.EQUALS) -- hmm
  list()
end
-- elements r tables?
-- list : '-' elements '+' ; // match signs list
function list()
  match(tokens.MINUS) -- "matched" not realy thou
  elements()
  match(tokens.PLUS)
end

-- elements : element ('/' element)* ; // match slash-separated list
function elements() -- iterator elements prob more effiecent
  element()
  while (lookahead(1).kind == tokens.SLASH) do
    match(tokens.SLASH) 
    element()
  end
end
-- element : name '=' NAME | NAME | list ; // assignment, name or list
function element()
  if lookahead(1).kind == tokens.NAME and lookahead(2).kind == tokens.EQUALS then 
    match(tokens.NAME) -- 
    match(tokens.EQUALS)
    match(tokens.NAME)
  elseif lookahead(1).kind == tokens.NAME then
    match(tokens.NAME)
  elseif lookahead(1).kind == tokens.PLUS then
    list()
  else
    error("expecting element, but found "..tostring(lookahead(1)))
  end
end
-- i see why making galaxy parser would be sIk
stat() -- initilization
