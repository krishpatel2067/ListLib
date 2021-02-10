local import = require(script.ListLib)
local NumList, List, Matrix = import('NumList', 'List', 'Matrix')

-- local l1 = List.new({

-- 	'hello',
-- 	{1, 2, 3},
-- 	1, 
-- 	true, 
-- 	Axes.new(Enum.Axis.X, Enum.Axis.Z),
-- 	BrickColor.new(Color3.fromRGB(50, 150, 250)),
-- 	CatalogSearchParams.new(),
-- 	CFrame.new(1, 2, 3),
-- 	Color3.fromRGB(50, 100, 200),
-- 	ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.new(0.5, 0.5, 0.5))}),
-- 	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(100, 50, 25)),
-- 	DateTime.now(),
-- 	DockWidgetPluginGuiInfo.new(),
-- 	Enum,
-- 	Enum.ABTestLoadingStatus,
-- 	Enum.ABTestLoadingStatus.None,
-- 	Faces.new(Enum.NormalId.Top, Enum.NormalId.Right, Enum.NormalId.Back),
-- 	workspace, 
-- 	NumberRange.new(1, 100),
-- 	NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 1)}),
-- 	NumberSequenceKeypoint.new(0.11, 14),
-- 	PathWaypoint.new(Vector3.new(1, 2, 9), Enum.PathWaypointAction.Jump),
-- 	PhysicalProperties.new(0.5, 0.1, 10),
-- 	Random.new(tick()),
-- 	Ray.new(Vector3.new(4, 19, 2), Vector3.new(92, 18, 9)),
-- 	RaycastParams.new(),
-- 	workspace.One.Changed:Connect(function() end),
-- 	workspace.One.Changed,
-- 	Rect.new(1, 2, 3, 4),
-- 	workspace:Raycast(Vector3.new(10, 50, 10), Vector3.new(50, -50, 50), RaycastParams.new()),
-- 	Region3.new(Vector3.new(1, 20, 9), Vector3.new(9, 39, 0)),
-- 	Region3int16.new(Vector3int16.new(2, 21, 10), Vector3int16.new(10, 40, 1)),
-- 	TweenInfo.new(),
-- 	UDim.new(1, 0),
-- 	UDim2.new(1, 0, 1, 0),
-- 	Vector2.new(120, 184),
-- 	Vector2int16.new(125, 189),
-- 	Vector3.new(1, 2, 3), 
-- 	Vector3int16.new(12, 22, 39), 

-- })

-- local m1 = Matrix.new({
-- 	{1, 2, 3},
-- 	{4, 5, 6}
-- })

-- local m2 = Matrix.new({
-- 	{7, 8},
-- 	{9, 10},
-- 	{11, 12}
-- })

local MyList = NumList.new({1, 2, 3, 4, 5})

print(MyList[1]) --1

MyList:Destroy()

print(MyList[1]) --nil
print(MyList:Append(1)) --error