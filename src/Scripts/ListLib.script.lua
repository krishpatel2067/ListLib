local oldType = type
local oldTypeof = typeof
local oldPairs = pairs
local oldIPairs = ipairs

getfenv(0)['__id'] = 'Core'

local function type(item)
	
	if oldType(item) ~= 'table' then
		
		return oldType(item)
		
	else
		
		if item.__type then
			
			return item.__type
			
		else
			
			return 'table'
			
		end
		
	end
	
end

local function typeof(item)

	if oldTypeof(item) ~= 'table' then

		return oldTypeof(item)

	else

		if item.__type then

			return item.__type

		else

			return 'table'

		end

	end

end

local function pairs(item)
	
	if type(item) == 'table' or type(item) == 'string' then
		
		return oldPairs(item)
		
	elseif type(item) == 'NumList' then
		
		return item:Pairs()
		
	end
	
end

local function ipairs(item)
	
	if type(item) == 'table' or type(item) == 'string' then

		return oldIPairs(item)

	elseif type(item) == 'NumList' then

		return item:Pairs()

	end
	
end

local function import(...)
	
	local env = getfenv(2)
	local args = {...}
	local toReturn = {}
	
	for _, v in pairs(args) do
		
		if script:FindFirstChild(v) then
			
			table.insert(toReturn, require(script[v]))
			
		end
		
	end
	
	env['type'] = type
	env['typeof'] = typeof
	env['pairs'] = pairs
	env['ipairs'] = ipairs
	
	return table.unpack(toReturn)
	
end

return import