-- dope yE?


-- exports: table_to_str function

local table_to_str = nil

do -- start LIB BLOCK


-- glob refs
-- local type     = type
-- local rawequal = rawequal
-- local tostring = tostring
-- local error = error

local E_TYPE_NIL     = 1 
local E_TYPE_BOOLEAN = 2
local E_TYPE_NUMBER  = 3
local E_TYPE_STRING  = 4
local E_TYPE_TABLE   = 5


local valid_types = {
	["boolean"] = E_TYPE_BOOLEAN, -- more like gaylean
	["number"]  = E_TYPE_NUMBER,
	["string"]  = E_TYPE_STRING,
	["table"]   = E_TYPE_TABLE,
	["nil"]     = E_TYPE_NIL,
}
local S_TYPE_BOOLEAN_FALSE = "false"
local S_TYPE_BOOLEAN_TRUE  = "true"
local S_TYPE_NIL           = "nil"

local types_to_string = nil 
local can_serialize_obj = function(obj)
	if obj then
		-- valid true types:
		-- boolean (true)
		-- number
		-- string
		-- table
		local xtype = valid_types[type(obj)]
		if xtype then
			return xtype
		else
			return false
		end
	else
		-- valid false types:
		-- nil
		-- boolean (false)
		if rawequal(obj, nil) then
			return E_TYPE_NIL
		elseif rawequal(obj, false) then
			return E_TYPE_BOOLEAN
		else
			return false
		end
	end
end
	--lolk
local serialize_trusted_obj = nil
do
	-- local error = error
	
	local valid_types = {
		["o"] = E_TYPE_BOOLEAN,
		["u"] = E_TYPE_NUMBER,
		["t"] = E_TYPE_STRING,
		["a"] = E_TYPE_TABLE,
		["i"] = E_TYPE_NIL,
	}
	serialize_obj = function(obj)
		if obj then
			local xtype = valid_types[type(obj):sub(2,3)]
			-- assert(type(obj) ~= "function")
			types_to_string[xtype](obj)
		elseif rawequal(obj, nil) then
			return S_TYPE_NIL
		elseif rawequal(obj, false) then
			return S_TYPE_BOOLEAN_FALSE
		else
			error()
		end
	end
end

local can_serialize_table = nil
do
	local tremove = table.remove
	local E_STATE_NEXT = 1
	local E_STATE_KEY = 2
	local E_STATE_VALUE = 3
	can_serialize_table = function(invalid_type, table_obj)
		local seen_tables = {[table_obj] = true}
		local stack = {nil, nil, nil}
		local stack_size = 3
		local key = nil
		local xtype = nil
		local value = nil
		local state = E_STATE_NEXT
		while stack_size > 0 do
			if state == E_STATE_NEXT then
				-- get key
				key = next(table_obj, key)
				if rawequal(key, nil) then
					state = tremove(stack, stack_size)
					key = tremove(stack, stack_size - 1)
					table_obj = tremove(stack, stack_size - 2)
					stack_size = stack_size - 3
				else
					state = E_STATE_KEY
				end
			elseif state == E_STATE_KEY then
				-- check key
				xtype = can_serialize_obj(key)
				if not xtype then
					invalid_type.mode = "key"
					invalid_type.str_type = type(key)
					return false
				elseif xtype == E_TYPE_TABLE and not seen_tables[key] then
					seen_tables[key] = true
					stack[stack_size + 1] = table_obj
					stack[stack_size + 2] = key
					stack_size = stack_size + 3
					stack[stack_size] = E_STATE_VALUE
					table_obj = key
					key = nil
					state = E_STATE_NEXT
				else
					state = E_STATE_VALUE
				end
			else
				-- check value
				-- assert(state == E_STATE_VALUE)
				value = table_obj[key]
				xtype = can_serialize_obj(value)
				if not xtype then
					invalid_type.mode = "value"
					invalid_type.str_type = type(value)
					return false
				elseif xtype == E_TYPE_TABLE and not seen_tables[value] then
					seen_tables[value] = true
					stack[stack_size + 1] = table_obj
					stack[stack_size + 2] = key
					stack_size = stack_size + 3
					stack[stack_size] = E_STATE_NEXT
					key = nil
					table_obj = value
				end
				state = E_STATE_NEXT
				value = nil
			end
		end
		return true
	end
end

local table_to_string = function(table_obj)
	local state = {}
	-- TODO
end

types_to_string = {
	-- type nil
	function()
		return S_TYPE_NIL
	end,
	-- type boolean
	function(obj)
		if obj then
			return S_TYPE_BOOLEAN_TRUE
		else
			return S_TYPE_BOOLEAN_FALSE
		end
	end,
	-- type number
	tostring,
	-- type string
	function(x)return x end,
	-- type table
	table_to_string,
}

table_to_str = function(obj, no_validate_tables)
	local xtype = can_serialize_obj(obj)
	if not xtype then
		return nil, "cannot serialize object of type: " .. type(obj)
	end
	local invalid_type = {}
	if xtype == E_TYPE_TABLE and not no_validate_tables and not can_serialize_table(invalid_type, obj) then
		return nil, "table contains " .. invalid_type.mode .. " of type " .. invalid_type.str_type .. " that cannot be serialized"
	end
	invalid_type = nil
	return types_to_string[xtype](obj)
end



end  -- END LIB BLOCK
