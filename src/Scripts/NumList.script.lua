local List = require(script.Parent.List)

local NumList = {}

local classProp = {MaxDisplay = 10, Inline = true}
local OPERATIONS = {'add', 'sub', 'mul', 'div', 'mod', 'pow'}
local HEX = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'}

local fakeMt = {}

local find = table.find
local insert = table.insert

--list it as "admin", do not add this to your scripts
local e = getfenv(0)
e['__id'] = 'Core'

NumList.__index = NumList
setmetatable(NumList, List.__real)

-----------------------------------PRIVATE FUNFCTIONS-----------------------------------
local function isAdmin()

	local env = getfenv(3)
	return env['__id'] == 'Core'

end

local function assert(condition, msg, level)

	if condition then return end

	error(msg, (level or 2) + 1)

end

local function median(tab)

	if #tab % 2 == 0 then

		local i1 = #tab / 2
		local i2 = i1 + 1
				
		return (tab[i1] + tab[i2]) / 2

	else

		return tab[(#tab + 1) / 2]

	end

end

local function precision(arr)
	
	local mostPrecise = 0
	
	for _, v in pairs(arr) do
		
		local deci = string.split(tostring(v), '.')[2]
		
		if deci and #deci > mostPrecise then
			
			mostPrecise = #deci
			
		end
		
	end
	
	return mostPrecise
	
end

local function toDecimal(num, base)
	
	if base == 10 then return num end

	num = tostring(num)
	num = string.upper(num)
	num = string.split(num, '.')
	
	local int, deci = num[1], num[2]
	
	int = string.split(int, '')
	deci = deci and string.split(deci, '')
	
	local sum = 0
	local power = 0
	
	if int ~= '0' then
	
		for i = #int, 1, -1 do
			
			local digit = int[i]		
			local pos = find(HEX, digit)
			
			if not pos then return end
			
			pos -= 1
			sum += pos * (base ^ power)
			power += 1
			
		end
	
	end
	
	if deci then
		
		power = -1
		
		local sumDeci = 0
		
		for i = 1, #deci do
			
			local digit = deci[i]
			local pos = find(HEX, digit)
			
			if not pos then return end
			
			pos -= 1
			sumDeci += pos * (base ^ power)
			power -= 1
			
		end
		
		sum += sumDeci
		
	end
		
	return sum
	
end

--get and set
local function setMaxDisplay(val)

	assert(type(val) == 'number' and val % 1 == 0, 'set class property failed: int expected, got ' .. type(val))

	classProp.MaxDisplay = val

end

local function getMaxDisplay()

	return classProp.MaxDisplay

end

local function getInline()

	return classProp.Inline

end

local function setInline(val)

	assert(type(val) == 'boolean', 'set inline: bool expected, got ' .. type(val))
	classProp.Inline = val

end

-------------------------------------CONSTRUCTORS--------------------------------------

local function new(arr, base)

	local newArr = {}
	base = base or 10
		
	assert(base <= 16, 'NumList creation: only up to base 16 is accepted')
	base = math.clamp(base, 2, base)

	for _, v in pairs(arr) do
		
		local decimal = toDecimal(v, base)
		assert(decimal, 'NumList creation: an error occurred')
		insert(newArr, decimal)

	end

	local self = List.new(newArr)
	
	self.__metatable = nil
	self.__classprop = classProp
	self.__dtype = {'number'}
	self.__type = 'NumList'
	self.__class = NumList
	self._new = NumList._new

	self.Alias = 'NumList'
	
	local mt = getmetatable(self)
	
	mt.__le = NumList.__le
	mt.__lt = NumList.__lt

	mt.__unm = NumList.__unm
	mt.__add = NumList.__add
	mt.__sub = NumList.__sub
	mt.__mul = NumList.__mul
	mt.__div = NumList.__div
	mt.__mod = NumList.__mod
	mt.__pow = NumList.__pow

	mt.__metatable = fakeMt
	
	return self

end

local function fromRange(min, max, step, base)

	local arr = {}
	step = step or 1
	base = base or 10

	min = toDecimal(min, base)
	max = toDecimal(max, base)
	step = toDecimal(step, base)
	
	assert(min and max and step, 'fromRange: only up to base 16 is accepted')

	for i = min, max, step do

		insert(arr, i)

	end
	
	return new(arr)

end

local function linspace(min, max, count)
	
	if count == 1 then
		
		return min
		
	end
	
	local inc = (max - min) / (count - 1)
	local arr = {}
	
	for i = min, max, inc do
		
		insert(arr, i)
		
	end
	
	return new(arr)
	
end

local function fillWith(count, val)

	return new(table.create(count, val))

end

local function fromRandom(min, max, count)
	
	local arr = {}
	local p = precision({min, max})
	
	for _ = 1, count do
		
		insert(arr, math.random(min * (10 ^ p), max * (10 ^ p)) / (10 ^ p))
		
	end
	
	return new(arr)
	
end

local function fromNormal(count, avg, std)
	
	local arr = {}
	
	for _ = 1, count do
		
		insert(arr, math.random(1, 100000) / 100000)
		
	end
	
	arr = new(arr)
	arr *= (std / arr:GetStd())
	arr += (avg - arr:GetAvg())
	
	return arr
	
end

-------------------------------OPERATIONS & COMPARISONS-------------------------------

local function doOperation(operation, self, val)

	local newTab = {}

	if type(val) == 'number' then

		val = table.create(self.Length, val)

	elseif type(val) == 'table' and val.__type == 'NumList' then
		
		val = val.Table

	end

	assert(type(val) == 'number' or type(val) == 'table', 'operation ' .. operation .. ': invalid operand type')
	assert(self.Length == #val, 'operation ' .. operation .. ': both tables must be of equal length')

	for i, v in pairs(self.Table) do

		if operation == 'add' then

			insert(newTab, v + val[i])

		elseif operation == 'sub' then

			insert(newTab, v - val[i])

		elseif operation == 'mul' then

			insert(newTab, v * val[i])

		elseif operation == 'div' then

			insert(newTab, v / val[i])

		elseif operation == 'mod' then

			insert(newTab, v % val[i])

		elseif operation == 'pow' then

			insert(newTab, v ^ val[i])

		end

	end
	
	return new(newTab)

end

local function comparison(mode, self, val)

	local objSum = self:GetSum()
	local valSum = val:GetSum()

	if mode == 'lessequal' then

		return objSum <= valSum

	elseif mode == 'less' then

		return objSum < valSum

	elseif mode == 'equal' then

		assert(self.Length == val.Length, 'equality: both NumLists must be of equal length')

		for i = 1, self.Length do

			if self.Table[i] ~= val.Table[i] then
				
				return false

			end

		end

		return true

	end

end

--------------------------------------METAMETHODS--------------------------------------

NumList.__le = function(self, val)

	return comparison('lessequal', self, val)

end

NumList.__lt = function(self, val)

	return comparison('less', self, val)

end

NumList.__eq = function(self, val)

	return comparison('equal', self, val)

end



NumList.__unm = function(self)

	return self * -1

end

for _, op in pairs(OPERATIONS) do
	
	NumList['__' .. op] = function(self, val)
		
		return doOperation(op, self, val)

	end

end

----------------------------------------METHODS----------------------------------------

--calculation

function NumList:GetSum()

	local sum = 0

	for _, v in pairs(self.Table) do

		sum += v

	end

	return sum

end

function NumList:GetProduct()
	
	local product = 1
	
	for _, v in pairs(self.Table) do
		
		product *= v
		
	end
	
	return product
	
end

--stats

function NumList:GetAvg()

	return self:GetSum() / self.Length

end

function NumList:GetStd()
	
	assert(self.Length > 1, 'Standard deviation failed: list length must be greater than 1')
	
	local sum = 0
	local avg = self:GetAvg()
	
	for _, v in pairs(self.Table) do
		
		sum += (v - avg) ^ 2
		
	end
	
	return math.sqrt(sum / self.Length)
	
end

function NumList:GetMAD()
	
	assert(self.Length > 0, 'Average deviation failed: list length must be greater than 0')
	
	local sum = 0
	local avg = self:GetAvg()
	
	for _, v in pairs(self.Table) do
		
		sum += math.abs(v - avg)
		
	end
	
	return sum / self.Length
	
end

function NumList:GetMode()
	
	local vc = self:CountValues()
	local count = vc[1][2]
	local values = {}
	
	for _, v in pairs(vc) do
		
		if v[2] ~= count then
			
			break
			
		end
		
		table.insert(values, v[1])
		
	end
	
	if count > 1 then
		
		return values
		
	end
	
end

function NumList:GetMin()

	return math.min(unpack(self.Table))

end

function NumList:GetMax()

	return math.max(unpack(self.Table))

end

function NumList:GetMedian()
	
	return median(self:Sort().Table)
	
end

function NumList:GetQ1()
	
	local tab = self:Sort()
	return median(tab(1, math.floor(tab.Length / 2)).Table)
	
end

function NumList:GetQ3()
	
	local tab = self:Sort()
	return median(tab(math.ceil(tab.Length / 2) + 1).Table)
	
end

function NumList:GetRange()
	
	return self:GetMax() - self:GetMin()
	
end

function NumList:GetFivePointSummary()
	
	return {
		
		Min = self:GetMin(), 
		Q1 = self:GetQ1(), 
		Median = self:GetMedian(), 
		Q3 = self:GetQ3(), 
		Max = self:GetMax()
		
	}
	
end

function NumList:GetStats()
	
	return {
		
		Min = self:GetMin(),
		Q1 = self:GetQ1(),
		Median = self:GetMedian(),
		Q3 = self:GetQ3(), 
		Max = self:GetMax(),
		Range = self:GetRange(),
		Sum = self:GetSum(),
		Product = self:GetProduct(),
		Avg = self:GetAvg(),
		Std = self:GetStd(),
		MAD = self:GetMAD(),
		Mode = self:GetMode() or 'None'
		
	}
	
end

--other

function NumList:ToBase(base)
	
	assert(type(base) == 'number' and base % 1 == 0, 'base convertion: invalid base')
	assert(base <= 16, 'base convertion: base 16 is the maximum')
	
	local converted = {}
	
	for _, v in pairs(self.Table) do
		
		local newNum = ''
		local int, deci = math.modf(v)
		
		local remainders = {}
		local remaindersReverse = {}
		local digits = 1 + math.floor(math.log(int, 10) / math.log(base, 10))
		
		if int ~= 0 then
		
			for _ = 1, digits do
				
				table.insert(remainders, HEX[(int % base) + 1])
				int = math.floor(int / base)
				
			end
					
			for i = #remainders, 1, -1 do

				table.insert(remaindersReverse, remainders[i])

			end
			
			remainders = nil
			newNum = newNum .. table.concat(remaindersReverse)
			
		else
			
			newNum = newNum .. '0'
		
		end
		
		if deci > 0 then
			
			newNum = newNum .. '.'
			
			local oldDeci = {}
			local sequence = {}
			
			while wait() do
				
				local product = deci * base
				local p = precision(self.Table)
				product = tonumber(string.sub(tostring(product), 1, p + 2))
				table.insert(sequence, math.floor(product))
				deci = product % 1
				
				if find(oldDeci, product % 1) or product % 1 == 0 then
					
					break
					
				end
				
				table.insert(oldDeci, product % 1)
				
			end
			
			oldDeci = nil
			newNum = newNum .. table.concat(sequence)
			
		end
		
		table.insert(converted, newNum)
	
	end	
	
	return converted
	
end

--***admin methods*** NOT for consumer use
function NumList._new(arr, base)
	
	assert(isAdmin(), 'not authorized to use this method')
	return new(arr, base)
	
end

----------------------------------------------------------------------------------------

local classTab = {

	new = new,
	fromRange = fromRange,
	linspace = linspace,
	fillWith = fillWith,
	fromRandom = fromRandom,
	fromNormal = fromNormal,

}

local classMt = {

	GetMaxDisplay = getMaxDisplay,
	SetMaxDisplay = setMaxDisplay,
	
	GetInline = getInline,
	SetInline = setInline,

}

classMt.__index = function(_, i)

	if classMt['Get' .. i] then

		return classMt['Get' .. i]()

	end

end

classMt.__newindex = function(_, i, v)

	if classMt['Set' .. i] then

		classMt['Set' .. i](v)

	end

end

return setmetatable(classTab, classMt)