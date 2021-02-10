local LogService = game:GetService("LogService")

local List = require(script.Parent.List)
local NumList = require(script.Parent.NumList)

local Matrix = {}

local classProp = {MaxDisplay = 5, Inline = false}
local READ_ONLY = {'Changed', 'Added', 'Removed', 'Size', 'Count'}
local NO_NIL = {'Alias'}
local OPERATIONS = {'add', 'sub', 'mul', 'div', 'mod', 'pow'}
local SELF = {'__type', '__dtype', '__classprop'}

local fakeMt = {}

local e = getfenv(0)
e['__id'] = 'Core'

local find = table.find
local insert = table.insert
local remove = table.remove

Matrix.__index = Matrix
setmetatable(Matrix, List)

----------------------------------------PRIVATE FUNCTIONS----------------------------------------
local function isAdmin()

	local env = getfenv(3)
	return env['__id'] == 'Core'

end

local function getMaxDisplay()

	return classProp.MaxDisplay

end

local function setMaxDisplay(val)

	assert(type(val) == 'number' and val % 1 == 0, 'set max display: expected int, got ' .. type(val))
	classProp.MaxDisplay = val

end

local function getInline()

	return classProp.Inline

end

local function setInline(val)

	assert(type(val) == 'boolean', 'set inline: bool expected, got ' .. type(val))
	classProp.Inline = val

end

local function fromString(str, changed, base)

	-- "1 2 3 4 5; 1 2 3 4 5"
	local t = {}
	local n = 0
	local rows = string.split(str, string.find(str, '; ') and '; ' or ';')

	for i, r in pairs(rows) do

		table.insert(t, {})

		local elements = string.split(r, ' ')

		if i == 1 then

			n = #elements

		end

		if #elements ~= n then return end

		for _, e in pairs(elements) do

			insert(t[#t], tonumber(e))

		end

		local numList = NumList.new(t[#t], base)
		numList.__event = {changed, i}
		t[#t] = numList

	end

	return t

end

local function new(create, base)

	local t = {}
	local changed = Instance.new('BindableEvent')
	base = base or 10

	if type(create) == 'string' then

		t = fromString(create, changed, base)
		assert(t, 'maxtrix creation: all rows must be of equal length')

	elseif type(create) == 'table' then

		local n = #create[1]

		for i, r in pairs(create) do

			assert(#r == n, 'matrix creation: all rows must be of equal length')
			insert(t, {})

			for _, e in pairs(r) do

				insert(t[#t], e)

			end

			local numList = NumList.new(t[#t], base)
			numList.__event = {changed, i}
			t[#t] = numList

		end

		print(t)

	else

		assert(true, 'matrix creation: only string or table accepted')

	end

	local self = List.new(t)
	
	local added = Instance.new('BindableEvent')
	local removed = Instance.new('BindableEvent')

	self.__metatable = nil
	self.__type = 'Matrix'
	self.__classprop = classProp
	self.__dtype = {'table'}

	self.Changed = changed
	self.Added = added
	self.Removed = removed

	self.Alias = 'Matrix'
	self.Length = nil
	self.Size = {#t, t[1].Length}
	self.Count = #t * t[1].Length

	local mt = getmetatable(self)

	self._new = Matrix._new
	setmetatable(self, Matrix)

	mt.__newindex = function(_, i, v)

		if type(i) == 'number' then

			if self.Table[i] then

				if v == nil then

					removed:Fire({i}, self.Table[i])
					remove(self.Table, i)

				else

					local bool = not self.__dtype or find(self.__dtype, type(v))
					assert(bool, 'change index: value must be either ' .. unpack(self.__dtype or READ_ONLY))
					assert(#v == self.Size[2], 'change index: row must be the same length')
					changed:Fire(i, self.Table[i], v)
					self.Table[i] = v

				end

			else

				assert(i == #self.Table + 1, 'add index: indices must be consecutive')
				local bool = not self.__dtype or find(self.__dtype, type(v))
				assert(bool, 'add index: value must be either ' .. unpack(self.__dtype or READ_ONLY))
				added:Fire(i, v)
				insert(self.Table, v)

			end

			self.Length = #self.Table

		else

			if i == 'Table' then

				assert(isAdmin(), 'Table should not be directly modified, use new indexing. :AddRow() or :RemoveRow()')
				self.Table = v

			elseif string.find(i, '^__') then

				assert(isAdmin(), i  .. ' is not for external use')

				if find(SELF, i) then

					self[i] = v

				else

					mt[i] = v

				end

			elseif find(READ_ONLY, i) then

				assert(isAdmin(), i  .. ' is read-only')
				self[i] = v

			else

				assert(isAdmin() or self[i], 'please use :AddProperty() or :AddFunction() to create new indicies')
				if find(NO_NIL, i) then v = not v and self[i] or v end
				self[i] = v

			end

		end

	end

	mt.__le = Matrix.__le
	mt.__le = Matrix.__lt
	mt.__eq = Matrix.__eq

	mt.__unm = Matrix.__unm
	mt.__add = Matrix.__add
	mt.__sub = Matrix.__sub
	mt.__mul = Matrix.__mul
	mt.__div = Matrix.__div
	mt.__mod = Matrix.__mod
	mt.__pow = Matrix.__pow

	mt.__tostring = Matrix.__tostring
	mt.__metatable = fakeMt

	return setmetatable({}, mt)

end

local function identity(dim)

	local index = 1
	local tab = {}

	for i = 1, dim do
		
		local row = table.create(dim, 0)
		row[index] = 1
		insert(tab, row)
		index += 1

	end

	return new(tab)

end

------------------------------------OPERATIONS & COMPARISONS-------------------------------------

local function operation(operation, self, val)

	local newTab = {}
	local wasOriginally = type(val)

	if type(val) == 'number' then

		val = table.create(self.Size[1], table.create(self.Size[2], val))

	elseif type(val) == 'table' and val.__type == 'Matrix' then

		
		val = val.Table

	end

	local s1, s2 = self.Size, {#val, val[1].Length or #val[1]}

	assert(type(val) == 'number' or type(val) == 'table', 'operation ' .. operation .. ': invalid operand type')
	assert((s1[1] == s2[1] and s1[2] == s2[2]) or (operation ~= 'mul') or (wasOriginally == 'table'), 'operation ' .. operation .. ': both tables must be of equal size')

	if operation == 'mul' and wasOriginally == 'table' then

		assert(s1[2] == s2[1], 'operation mul: the number of m1 columns must equal the number of m2 rows')

		for r in pairs(self.Table) do

			insert(newTab, {})

			for r2 in pairs(self.Table) do
				
				local sum = 0

				for c in pairs(self.Table[r2].Table) do
					
					sum += self.Table[r][c] * val[c][r2]

				end
				
				insert(newTab[r], sum)

			end

		end

	else
		
		for r in pairs(self.Table) do

			insert(newTab, {})

			for c in pairs(self.Table[r]) do

				if operation == 'add' then

					newTab[r][c] = self.Table[r][c] + val[r][c]

				elseif operation == 'sub' then

					newTab[r][c] = self.Table[r][c] - val[r][c]

				elseif operation == 'mul' then

					newTab[r][c] = self.Table[r][c] * val[r][c]

				elseif operation == 'div' then

					newTab[r][c] = self.Table[r][c] / val[r][c]

				elseif operation == 'mod' then

					newTab[r][c] = self.Table[r][c] % val[r][c]

				elseif operation == 'pow' then

					newTab[r][c] = self.Table[r][c] ^ val[r][c]

				end

			end

		end

	end

	newTab = new(newTab)
	print('something happened!')
	print(newTab)
	return newTab

end

local function comparison(mode, self, val)

	if mode == 'lessequal' then

		return self.Count <= val.Count

	elseif mode == 'less' then

		return self.Count < val.Count

	elseif mode == 'equal' then

		local s1, s2 = self.Size, val.Size
		assert(s1[1] == s2[1] and s1[2] == s2[2], 'equality evalutation: both Matricies must be of equal size')

		for _, r in pairs(self.Table) do

			for _, c in pairs(self.Table) do

				if self.Table[r][c] ~= val.Table[r][c] then

					return false

				end

			end

		end

		return true

	end

end

-------------------------------------------METAMETHODS-------------------------------------------
--comparisons & operations
Matrix.__le = function(self, val)

	return comparison('lessequal', self, val)

end

Matrix.__lt = function(self, val)

	return comparison('less', self, val)

end

Matrix.__eq = function(self, val)

	return comparison('equal', self, val)

end


Matrix.__unm = function(self)

	return self * -1

end

for _, op in pairs(OPERATIONS) do
	
	Matrix['__' .. op] = function(self, val)
	
		return new(operation(op, self, val))
	
	end

end

-- Matrix.__add = function(self, val)

-- 	return new(operation('add', self, val))

-- end

-- Matrix.__sub = function(self, val)

-- 	return new(operation('sub', self, val))

-- end

-- Matrix.__mul = function(self, val)

-- 	return new(operation('mul', self, val))

-- end

-- Matrix.__div = function(self, val)

-- 	return new(operation('div', self, val))

-- end

-- Matrix.__mod = function(self, val)

-- 	return new(operation('mod', self, val))

-- end

-- Matrix.__pow = function(self, val)

-- 	return new(operation('pow', self, val))

-- end

--other
Matrix.__tostring = function(self)

	local toPrint = self.Alias .. self.Size[1] .. 'x' .. self.Size[2] .. '('
	local space = self.__classprop.Inline and '' or table.concat(table.create(#toPrint + 2, ' '))
	local drop = self.__classprop.Inline and ' ' or '\n'

	if self.Size[1] <= self.__classprop.MaxDisplay then

		for r, v in pairs(self.Table) do

			if r > 1 then

				toPrint ..= space

			end

			toPrint ..= '[' .. table.concat(v.Table, ', ') .. ']'
			
			if r < self.Size[1] then
				
				toPrint ..= ',' .. drop

			end

		end

	else

		for r = 1, 3 do

			if r > 1 then

				toPrint ..= space

			end

			toPrint ..= '[' .. table.concat(self.Table[r].Table, ', ') .. ']'

			if r ~= 3 then

				toPrint ..= ',' .. drop

			end

		end

		if not self.__classprop.Inline then

			toPrint ..= space .. '\n' .. space .. '.\n' .. space .. '.\n' .. space .. '.\n'

		else

			toPrint ..= '...'

		end

		for i = (self.Size[1] - 2), (self.Size[1]) do

			if i > 1 then

				toPrint ..= space

			end

			toPrint ..= '[' .. table.concat(self.Table[i].Table, ', ') .. ']'

			if i ~= self.Size[1] then

				toPrint ..= ',' .. drop

			end

		end

	end

	return toPrint .. ')'

end

---------------------------------------------METHODS---------------------------------------------
--utility
function Matrix:Flatten()

	local newTab = {}

	for _, r in pairs(self.Table) do

		for _, e in pairs(r) do

			insert(newTab, e)

		end

	end

	return NumList.new(newTab)

end

--row & columns
function Matrix:GetRow(row)

	return NumList.new(self[row].Table)

end

function Matrix:GetColumn(column)

	local col = {}

	for _, r in pairs(self.Table) do
		
		insert(col, r[column])

	end

	return NumList.new(col)

end

--***admin methods*** NOT for consumer use
function Matrix._new(arr, base)

	assert(isAdmin(), 'not authorized to use this method')
	return new(arr, base)

end

local classTab = {

	new = new,
	indentity = identity

}

local classMt = {

	GetMaxDisplay = getMaxDisplay,
	SetMaxDisplay = setMaxDisplay,

	GetInline = getInline,
	SetInline = setInline

}

classMt.__index = function(_, i)

	if rawget(classMt, 'Get' .. i) then

		return classMt['Get' .. i]()
	
	end

end

classMt.__newindex = function(_, i, v)

	if rawget(classMt, 'Get' .. i) then

		classMt['Set' .. i](v)

	end

end

return setmetatable(classTab, classMt)