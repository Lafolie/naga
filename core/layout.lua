local naga = select(1, ...)
local min, max = math.min, math.max

naga.layout = {}

--------------------------------------------------------------------------------
-- Free Layout
--------------------------------------------------------------------------------

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