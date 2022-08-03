local naga = select(1, ...)
local min, max = math.min, math.max

naga.layout = {}

--------------------------------------------------------------------------------
-- Free Layout
--------------------------------------------------------------------------------

-- naga.layout.free = {}

-- function naga.layout.free.one(element, child, i)
-- 	print("layout:", element.name, child.name)
-- 	local x = child.x + child.width
-- 	local y = child.y + child.height
-- 	element:resize(x, y)
-- end

function naga.layout.free(element)
	local x, y = 0, 0

	for _, child in ipairs(element.children) do
		x = max(x, child.x + child.width)
		y = max(y, child.y + child.height)
	end

	element:resize(x, y)
end

--------------------------------------------------------------------------------
-- Vertical List Layout
--------------------------------------------------------------------------------

-- naga.layout.vertical = {}

-- function naga.layout.vertical.one(element, child, i)
-- 	local x = element.width

-- 	local oneBefore = element.children[i - 1]
-- 	local y = oneBefore and oneBefore.y + oneBefore.height or 0

-- 	for n = i, #element.children do
-- 		local child = element.children[n]
-- 		x = max(child.x + child.width)
-- 		child.y = y
-- 		y = y + child.height
-- 	end

-- 	element:resize(x, y)
-- end

function naga.layout.vertical(element)
	local x, y = 0, 0
	for _, child in ipairs(element.children) do
		x = max(x, child.x + child.width)

		child.y = y
		y = y + child.height
	end
	element:resize(x, y)
end

--------------------------------------------------------------------------------
-- Horizontal List Layout
--------------------------------------------------------------------------------

function naga.layout.horizontal(element)
	local x, y = 0, 0
	for _, child in ipairs(element.children) do
		child.x = x
		x = x + child.width

		y = max(y, child.y + child.height)
	end
	element:resize(x, y)
end