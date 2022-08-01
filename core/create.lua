local naga = select(1, ...)
local insert, remove = table.insert, table.remove

local baseElement = 
{
	-- geometry
	x = 0,
	y = 0,
	width = 0,
	height = 0,

	-- layout

	-- style
	style = naga.activeTheme.element
}

local elementMeta =
{
	__index = baseElement
}


--------------------------------------------------------------------------------
-- Root Element
--------------------------------------------------------------------------------

-- This element has some special overrides
naga.rootElement = setmetatable({
		width = love.graphics.getWidth(),
		height = love.graphics.getHeight(),
		style = naga.activeTheme.none,
		substyle = naga.activeTheme.none.body,
		children = {}
	}, elementMeta)

function naga.rootElement:getSubstyle(name)
	return self.style[name]
end

--------------------------------------------------------------------------------
-- Parenting
--------------------------------------------------------------------------------

function baseElement:addElement(element, i)
	insert(self.children, i or #self.children + 1, element)
	element.parent = self
end

function baseElement:removeElement(element)
	for k, v in ipairs(self.children) do
		if v == element then
			element.parent = false
			return remove(self.children, k)
		end
	end
end

function baseElement:removeFromParent()
	self.parent:removeElement(self)
end

--------------------------------------------------------------------------------
-- Positioning
--------------------------------------------------------------------------------

function baseElement:setPosition(x, y)
	self.x = x
	self.y = y
end

--------------------------------------------------------------------------------
-- Styling
--------------------------------------------------------------------------------

function baseElement:getSubstyle(name)
	if self.style[name] then
		return self.style[name]
	end

	return self.parent:getSubstyle(name)
end

function baseElement:setSubstyle(name)
	self.substyle = self:getSubstyle(name) or self.style.body
end

--------------------------------------------------------------------------------
-- Drawing
--------------------------------------------------------------------------------

function baseElement:draw()
	love.graphics.push "all"
	love.graphics.translate(self.x, self.y)
	local x, y = love.graphics.transformPoint(0, 0)
	love.graphics.intersectScissor(x, y, self.width, self.height)

	-- don't items with the special 'none' style
	if self.style ~= naga.themes.Naga.none then
		love.graphics.setColor(self.substyle.color)
		love.graphics.rectangle("fill", 0, 0, self.width, self.height)
	end

	for _, child in ipairs(self.children) do
		child:draw()
	end

	love.graphics.pop()
end

--------------------------------------------------------------------------------
-- Interaction
--------------------------------------------------------------------------------

-- Basics ----------------------------------------------------------------------

function baseElement:onBeginHover(x, y)
	
end

function baseElement:onEndHover(x, y)
	
end

function baseElement:onPress(x, y, button)
	
end

function baseElement:onRelease(x, y, button, wasPressed)
	print(wasPressed and "I was pressed :D" or "I wasn't pressed :(")
end

-- Drag & Drop -----------------------------------------------------------------

function baseElement:onBeginDrag(x, y)

end

function baseElement:onEndDrag(x, y)
	
end

function baseElement:onDrop(x, y)

end

function baseElement:onElementDropped(x, y, element)

end

--------------------------------------------------------------------------------
-- Exported API
--------------------------------------------------------------------------------

naga.create = setmetatable({},
	{
		__call = function(t, elementSettings)
			local element = setmetatable(elementSettings, elementMeta)
			element.children = {}

			local parent = naga.peek() or naga.rootElement
			parent:addElement(element)

			--[[
				Use the provided style, or inherit the parent style.
				The rootElement uses the special 'none' style, so if the parent is
				the rootElement, use the activeTheme.element style instead
			]]
			local styleName = element.style
			element.style = naga.activeTheme[styleName] or (parent == naga.rootElement and naga.activeTheme.element or parent.style)
			element:setSubstyle "body"

			return element
		end
	})