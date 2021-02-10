local List = {}

local classProp = {MaxDisplay = 10, ShowDataTypeContents = false, Inline = true}
local COMPATIBLE = {'number', 'string', 'boolean'}
local READ_ONLY = {'Changed', 'Added', 'Removed', 'Length'}
local NO_NIL = {'Alias'}
local SELF = {'__type', '__dtype', '__classprop', '__changed', '__added', '__removed', '__class', '__mt', '__self'}

local fakeMt = {}

local tostringOld = tostring
local find = table.find
local insert = table.insert
local remove = table.remove

--list it as "admin", do not add this to your scripts
local e = getfenv(0)
e['__id'] = 'Core'

List.__index = List

--------------------------------PRIVATE FUNCTIONS--------------------------------
local function isAdmin()

	local env = getfenv(3)
	return env['__id'] == 'Core'

end

local function sortDown(a, b)

	return a > b

end

local function sortDownCounts(a, b)

	return a[1] > b[1]

end

local function assert(condition, msg, level)

	if condition then return end

	error(msg, (level or 2) + 1)

end

local function tostring(val)

	if find(COMPATIBLE, typeof(val)) then

		return tostringOld(val)

	end

	if typeof(val) == 'table' then

		local str = '{'

		for i, v in pairs(val) do

			if typeof(v) ~= 'number' or typeof(val) ~= 'string' then

				str ..= tostring(v)

				if i ~= #val then

					str ..= ', '

				end

			end

		end

		str = str == '{' and str .. '...' or str

		return str .. '}'

	else

		local str = typeof(val) .. '['
		local comp = {}

		if classProp.ShowDataTypeContents then

			if string.find(typeof(val), 'Vector3') or string.find(typeof(val), 'Vector2') then

				comp[1], comp[2] = val.X, val.Y
				comp[3] = string.find(typeof(val), 'Vector3') and val.Z

			elseif typeof(val) == 'CFrame' then

				comp = table.pack(val:GetComponents())

			elseif typeof(val) == 'Region3' then

				local cf, size = val.CFrame, val.Size
				local x, y, z = cf.X, cf.Y, cf.Z
				local sX, sY, sZ = size.X, size.Y, size.Z

				local x1, y1, z1 = x - (sX / 2), y - (sY / 2), z - (sZ / 2)
				local x2, y2, z2 = x + (sX / 2), y + (sY / 2), z + (sZ / 2)

				comp = table.concat({x1, y1, z1}, ', ') .. '; '
				comp ..= table.concat({x2, y2, z2}, ', ')

			elseif typeof(val) == 'Region3int16' then

				local min, max = val.Min, val.Max

				comp = table.concat({min.X, min.Y, min.Z}, ', ') .. '; '
				comp ..= table.concat({max.X, max.Y, max.Z}, ', ')

			elseif typeof(val) == 'Color3' then

				comp[1], comp[2], comp[3] = val.R, val.G, val.B

			elseif typeof(val) == 'BrickColor' then

				comp = val.Name

			elseif typeof(val) == 'Instance' then

				str = val.ClassName .. '['
				comp = val.Name

			elseif typeof(val) == 'UDim' then

				comp[1], comp[2] = val.Scale, val.Offset

			elseif typeof(val) == 'UDim2' then

				comp[1], comp[2], comp[3], comp[4] = val.X.Scale, val.X.Offset, val.Y.Scale, val.Y.Offset

			elseif typeof(val) == 'Rect' then

				local min, max = val.Min, val.Max
				comp = table.concat({min.X, min.Y}, ', ') .. '; ' .. table.concat({max.X, max.Y}, ', ')

			elseif typeof(val) == 'Faces' then

				for _, v in pairs({'Top', 'Bottom', 'Right', 'Left', 'Front', 'Back'}) do

					insert(comp, tostringOld(val[v]))

				end

			elseif typeof(val) == 'Axes' then

				comp[1], comp[2], comp[3] = tostringOld(val.X), tostringOld(val.Y), tostringOld(val.Z)

			elseif typeof(val) == 'Ray' then

				local o = val.Origin
				local d = val.Direction

				comp = '(' .. table.concat({o.X, o.Y, o.Z}, ', ') .. ') --> '
				comp ..= '(' .. table.concat({d.X, d.Y, d.Z}, ', ') .. ')'

			elseif typeof(val) == 'NumberRange' then

				comp = val.Min .. '-' .. val.Max

			elseif typeof(val) == 'NumberSequenceKeypoint' then

				comp[1], comp[2], comp[3] = val.Time, val.Value, val.Envelope

			elseif typeof(val) == 'ColorSequenceKeypoint' then

				local color = val.Value
				comp[1] = val.Time
				comp[2], comp[3] = '(' .. color.R, color.G
				comp[4] = color.B .. ')'

			elseif typeof(val) == 'DateTime' then

				comp[1] = val.UnixTimestamp

			elseif typeof(val) == 'Enums' or typeof(val) == 'Enum'  then

				str = tostringOld(val) .. '['

			elseif typeof(val) == 'EnumItem' then

				str = 'Enum.' .. tostringOld(val.EnumType) .. '.' .. val.Name .. '['

			elseif typeof(val) == 'PathWaypoint' then

				local pos = val.Position
				comp = '(' .. pos.X .. ', ' .. pos.Y .. ', ' .. pos.Z .. '); '
				comp ..= string.split(tostringOld(val.Action), '.')[3]

			elseif typeof(val) == 'PhysicalProperties' then

				comp[1], comp[2] = val.Density, val.Friction
				comp[3], comp[4] = val.Elasticity, val.FrictionWeight
				comp[5] = val.ElasticityWeight

			elseif typeof(val) == 'TweenInfo' then

				comp[1] = val.Time
				comp[2] = string.split(tostringOld(val.EasingStyle), '.')[3]
				comp[3] = string.split(tostringOld(val.EasingDirection), '.')[3]
				comp[4], comp[5], comp[6] = val.RepeatCount, tostringOld(val.Reverses), val.DelayTime

			elseif typeof(val) == 'CatalogSearchParams' then

				comp = '"' .. val.SearchKeyword .. '", '
				comp ..= val.MinPrice .. '-' .. val.MaxPrice .. ', '
				comp ..= string.split(tostringOld(val.SortType), '.')[3] .. ', '
				comp ..= string.split(tostringOld(val.CategoryFilter), '.')[3] .. ', '
				comp ..= '{...}, {...}'

			elseif typeof(val) == 'RaycastParams' then

				comp = '{...}, '
				comp ..= string.split(tostringOld(val.FilterType), '.')[3] .. ', '
				comp ..= tostringOld(val.IgnoreWater) .. ', ' .. val.CollisionGroup

			elseif typeof(val) == 'RaycastResult' then

				local p, n = val.Position, val.Normal
				comp[1] = val.Instance.ClassName
				comp[2], comp[3], comp[4] = '(' .. p.X, p.Y, p.Z .. ')'
				comp[5] = string.split(tostringOld(val.Material), '.')[3]
				comp[6], comp[7], comp[8] = '(' .. n.X, n.Y, n.Z .. ')'

			elseif typeof(val) == 'RBXScriptConnection' then

				insert(comp, tostringOld(val.Connected))

			elseif typeof(val) == 'DockWidgetPluginGuiInfo' then

				comp[1] = tostringOld(val.InitialEnabled)
				comp[2] = tostringOld(val.InitialEnabledShouldOverrideRestore)
				comp[3], comp[4] = '(' .. val.FloatingXSize, val.FloatingYSize .. ')'
				comp[5], comp[6] = '(' .. val.MinWidth, val.MinHeight .. ')'

			else

				comp = '...'

			end

		end

		str = type(comp) == 'table' and str .. table.concat(comp, ', ') or str .. comp

		return str .. ']'

	end

end

--get/set
local function getMaxDisplay()

	return classProp.MaxDisplay

end

local function setMaxDisplay(val)

	assert(type(val) == 'number' and val % 1 == 0, 'set max display: int expected, got ' .. type(val))
	classProp.MaxDisplay = val

end

local function getShowDataTypeContents()

	return classProp.ShowDataTypeContents

end

local function setShowDataTypeContents(val)

	assert(type(val) == 'boolean', 'set show datatype contents: bool expected, got ' .. type(val))
	classProp.ShowDataTypeContents = val

end

local function getInline()

	return classProp.Inline

end

local function setInline(val)

	assert(type(val) == 'boolean', 'set inline: bool expected, got ' .. type(val))
	classProp.Inline = val

end

-----------------------------------CONSTRUCTORS-----------------------------------

local function new(arr)

	local newArr = {}

	for _, v in pairs(arr) do

		insert(newArr, v)

	end

	local changed = Instance.new('BindableEvent')
	local added = Instance.new('BindableEvent')
	local removed = Instance.new('BindableEvent')

	local self = {

		Alias = 'List',

		Table = {unpack(newArr)},
		Changed = changed.Event,
		Added = added.Event,
		Removed = removed.Event,
		Length = #newArr,

		__type = 'List',
		__class = List,
		__classprop = classProp,
		__changed = changed,
		__added = added,
		__removed = removed,

	}

	setmetatable(self, List)
	self._new = List._new

	local mt = {}
	self.__mt = mt
	self.__self = self

	mt.__index = function(_, i)

		if type(i) == 'number' then

			i = i < 0 and (1 + #self.Table + i) or i
			return self.Table[i]

		else

			if i == 'Table' then

				return isAdmin() and self.Table or nil

			elseif string.find(i, '^__') and i ~= '__type' then

				assert(isAdmin(), i .. ' is not for consumer use')
				return find(SELF, i) and self[i] or mt[i]

			else

				return self[i]

			end

		end

	end

	mt.__newindex = function(_, i, v)

		if type(i) == 'number' then

			if self.Table[i] then

				i = i < 0 and (1 + #self.Table + i) or i

				if v == nil then

					assert(not self.__event, 'cannot remove from an individual row')
					self.Length -= 1
					removed:Fire(i, self.Table[i])
					remove(self.Table, i)

				elseif v ~= self.Table[i] then

					if self.__event then

						assert(type(v) == 'number', 'cannot change to non-numerical values')
						self.__event[1]:Fire({self.__event[2], i}, self.Table[i], v)

					end

					local bool = not self.__dtype or find(self.__dtype, type(v))
					--COMPATIBLE or any other non-empty table; it doesn't matter since this won't run if __dtype isn't there
					assert(bool, 'change index: value must be either ' .. unpack(self.__dtype or COMPATIBLE))
					changed:Fire(i, self.Table[i], v)
					self.Table[i] = v

				end

			else

				assert(not self.__event, 'cannot add to an individual row')
				assert(i == #self.Table + 1, 'add index: indices must be consecutive')
				local bool = not self.__dtype or find(self.__dtype, type(v))
				assert(bool, 'add index: value must be either ' .. unpack(self.__dtype or COMPATIBLE))
				self.Length += 1
				added:Fire(i, v)
				insert(self.Table, v)

			end

		else

			if i == 'Table' then

				assert(isAdmin(), 'Table should not be directly modified, use new indexing.')
				self.Table = v

			elseif string.find(i, '^__') then

				assert(isAdmin(), i  .. ' is not for external use')

				if i == '__class' then

					setmetatable(self, v)

				end

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

	mt.__eq = List.__eq

	mt.__metatable = fakeMt
	mt.__call = List.__call
	mt.__concat = List.__concat
	mt.__tostring = List.__tostring

	return setmetatable({}, mt)

end

local function fillWith(count, val)

	return new(table.create(count, val))

end

-----------------------------------METAMETHODS-----------------------------------

List.__concat = function(self, val)

	assert(type(val) == 'table', 'concatenation: invalid datatype(s)')

	local newTab = {unpack(self.Table)}

	val = string.find(val.__type, 'List') and val.Table or val

	for _, v in pairs(val) do

		insert(newTab, v)

	end

	return self._new(newTab)

end

List.__tostring = function(self)

	local toPrint = self.Alias .. '({'
	local space = self.__classprop.Inline and '' or table.concat(table.create(#toPrint + 2, ' '))
	local drop = self.__classprop.Inline and ' ' or '\n'

	if self.Length <= self.__classprop.MaxDisplay then

		for i, v in pairs(self.Table) do

			if i > 1 then

				toPrint ..= space

			end

			toPrint = toPrint .. tostring(v)

			if i < self.Length then

				toPrint ..= ',' .. drop

			end

		end

	else

		for i = 1, 3 do

			if i > 1 then

				toPrint ..= space

			end

			toPrint = toPrint .. tostring(self.Table[i])

			if i ~= 3 then

				toPrint ..= ',' .. drop

			end

		end

		if not self.__classprop.Inline then

			toPrint ..= space .. '\n' .. space .. '.\n' .. space .. '.\n' .. space .. '.\n'

		else

			toPrint ..= '...'

		end

		for i = (self.Length - 2), (self.Length) do

			if i > 1 then

				toPrint ..= space

			end

			toPrint ..= tostring(self.Table[i])

			if i ~= self.Length then

				toPrint ..= ',' .. drop

			end

		end

	end

	return toPrint .. '})'

end

List.__call = function(self, ...)

	local args = {...}

	assert(#args >= 1, 'slicing: missing lower bound')

	local lower, upper, step = args[1], args[2] or self.Length, args[3] or 1

	assert(type(lower) == 'number' and type(upper) == 'number' and type(step) == 'number'
	and lower % 1 == 0 and upper % 1 == 0 and step % 1 == 0,
		'slicing: inputs must be integers')

	lower = lower < 0 and self.Length + (lower + 1) or lower
	upper = upper < 0 and self.Length + (upper + 1) or upper

	assert(lower > 0 and lower <= self.Length and upper > 0 and upper <= self.Length,
		'slicing: out of bounds')
	assert(step ~= 0, 'slicing: step cannot be 0')

	local newTab = {}
	local l = step > 0 and lower or upper
	local u = step > 0 and upper or lower

	for i = l, u, step do

		insert(newTab, self.Table[i])

	end

	return self._new(newTab)

end

List.__eq = function(self, val)

	assert(self.Length == val.Length, 'equality: both Lists must be of equal length')

	for i = 1, self.Length do

		if self.Table[i] ~= val.Table[i] then

			return false

		end

	end

	return true

end

-------------------------------------METHODS-------------------------------------
--manipulation

function List:Destroy()

	self.__changed:Destroy()
	self.__removed:Destroy()
	self.__added:Destroy()

	local mt = self.__mt
	local s = self.__self

	self.Table = nil
	setmetatable(s, {})

	for i in pairs(mt) do

		mt[i] = nil

	end

	for i in pairs(s) do

		self[i] = nil

	end

	mt = nil

end

function List:Clear()

	table.clear(self.Table)

end

function List:Empty()

	self.Table = {}

end

function List:Clone()

	return self._new(self.Table)

end

function List:Unpack()

	return unpack(self.Table)

end

function List:Append(item, ...)

	assert(item, 'append: missing at least one input')
	local args = {...}

	insert(args, 1, item)

	for _, v in pairs(args) do

		assert(self:_dtype(v), 'append: inputs must be type ' .. unpack(self.__dtype or COMPATIBLE))
		self.Length += 1
		self.__added:Fire(self.Length, v)
		insert(self.Table, v)

	end

end

function List:Replace(item, newItem, startingIndex, count)

	assert(self._dtype(newItem), 'replace: new value must be type ' .. unpack(self.__dtype or COMPATIBLE))

	count = count or 1
	count = count == -1 and self:Count(item) or count
	startingIndex = startingIndex or 1

	local foundCount = 0

	for i = startingIndex, self.Length do

		if foundCount >= count then return end

		if self.Table[i] == item then

			self.Table[i] = newItem
			foundCount += 1

		end

	end

end

function List:Remove(item, startingIndex, count)

	count = count or 1
	count = count == -1 and self:Count(item) or count

	startingIndex = startingIndex or 1

	local foundCount = 0
	local t = startingIndex > 1 and {unpack(self(1, startingIndex - 1).Table)} or {}
	local removed = {}

	for i = startingIndex, self.Length do

		if foundCount < count then

			if self.Table[i] == item then

				foundCount += 1
				self.Length -= 1
				self.__removed:Fire(i, self.Table[i])

			else

				insert(t, self.Table[i])

			end

		end

	end

	self.Length = #t
	self.Table = {unpack(t)}

end

function List:RemoveDuplicates(item)

	if self:Count(item) > 1 then

		self:Remove(item, find(self.Table, item) + 1, -1)

	end

end

function List:Select(selectTab)

	local newTab = {}

	for i, v in pairs(self.Table) do

		if selectTab[i] then

			insert(newTab, v)

		end

	end

	return self._new(newTab)

end

function List:Shuffle(inplace)

	local clone = {unpack(self.Table)}
	local newTab = {}

	for i = 1, #clone do

		local index = math.random(1, #clone)

		insert(newTab, clone[index])
		remove(clone, index)

	end

	clone = nil

	if not inplace then

		return self._new(newTab)

	else

		self.Table = {unpack(newTab)}

	end

end

--utility
function List:AddFunction(name, func)

	assert(not self[name], 'add function: name is conflicting with current properties/functions')
	self[name] = func

end

function List:AddProperty(prop, val)

	assert(not self[prop], 'add property: name is conflicting with current properties/functions')
	assert(type(val) ~= 'function', 'add property: type cannot be function, use :AddFunction instead')
	self[prop] = val

end

function List:Find(item, all)

	local allFound = {}

	for i = 1, self.Length do

		local index = find(self.Table, item, i)

		if not find(allFound, index) then

			insert(allFound, index)

		end

	end

	return all and allFound or allFound[1]

end

function List:Sort(descending, inplace)

	local toSort = {unpack(self.Table)}

	if descending then

		table.sort(toSort, sortDown)

	else

		table.sort(toSort)

	end

	if not inplace then

		return self._new(toSort)

	else

		self.Table = {unpack(toSort)}

	end

end

function List:Reverse(inplace)

	local toReverse = {}

	for i = self.Length, 1, -1 do

		insert(toReverse, self.Table[i])

	end

	if not inplace then

		return self._new(toReverse)

	else

		self.Table = {unpack(toReverse)}

	end

end

function List:Count(val)

	local count = 0

	for _, v in pairs(self.Table) do

		if v == val then

			count += 1

		end

	end

	return count

end

function List:CountValues()

	local values, counts = {}, {}
	local valueCounts = {}

	for _, v in pairs(self.Table) do

		local index = find(values, v)

		if index then

			counts[index] += 1

		else

			insert(values, v)
			counts[#values] = 1

		end

	end

	for i = 1, #values do

		insert(valueCounts, {values[i], counts[i]})

	end

	table.sort(valueCounts, sortDownCounts)

	return valueCounts

end

--iteration
function List:Pairs()

	return pairs(self.Table)

end

function List:Zip(...)

	local i = 0
	local args = {...}
	local cap = {self.Length}
	local tabs = {}

	for _, v in pairs(args) do

		if type(v) == 'table' then

			insert(cap, v.Length or #v)
			insert(tabs, v.Table or v)

		elseif type(v) == 'string' then

			insert(cap, #v)
			insert(tabs, string.split(v, ''))

		else

			assert(true, 'zip: all arguments must be iterable')

		end

	end

	cap = math.min(unpack(cap))

	local function iterator()

		if i < cap then

			i += 1

			local returnTab = {i, self.Table[i]}

			for t = 1, #tabs do

				insert(returnTab, tabs[t][i])

			end

			return unpack(returnTab)

		end

	end

	return iterator

end

--other
function List:GetTable()

	return self.Table

end

--***admin methods*** NOT for consumer use
function List:_dtype(v)

	assert(isAdmin(), 'not authorized to use this method')
	return not self.__dtype or find(self.__dtype, typeof(v))

end

function List._new(arr)

	assert(isAdmin(), 'not authorized to use this method')
	return new(arr)

end

----------------------------------------------------------------------------------------
local classTab = {

	new = new,
	fillWith = fillWith,

	__real = List,

}

local classMt = {

	GetMaxDisplay = getMaxDisplay,
	SetMaxDisplay = setMaxDisplay,

	GetShowDataTypeContents = getShowDataTypeContents,
	SetShowDataTypeContents = setShowDataTypeContents,

	GetInline = getInline,
	SetInline = setInline

}

classMt.__index = function(_, i)

	if rawget(classMt, 'Get' .. i) then

		assert(not string.find(i, '^__') or isAdmin(), i .. ' is not for external use')
		return classMt['Get' .. i]()

	end

end

classMt.__newindex = function(_, i, v)

	if rawget(classMt, 'Get' .. i) then

		assert(not string.find(i, '^__') or isAdmin(), i .. ' is not for external use')
		classMt['Set' .. i](v)

	end

end

return setmetatable(classTab, classMt)