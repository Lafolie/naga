local naga, modulePath = select(1, ...)

local mkScrollbar = require(modulePath .. ".etc.scrollbar")

local insert, remove = table.insert, table.remove
local min, max = math.min, math.max
local floor = math.floor

local function lerp(t, a, b)
	return (1 - t) * a + t * b
end

local function clamp(x, minx, maxx)
	return min(max(x, minx), maxx)
end

local baseElement = 
{
	-- geometry
	x = 0,
	y = 0,

	-- content & scrolling
	layout = naga.layout.free,
	contentWidth = 0,
	contentHeight =  0,
	scrollX = 0,
	scrollY = 0,
	canScrollX = true,
	canScrollY = true,

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
		name = "rootElement",
		width = love.graphics.getWidth(),
		height = love.graphics.getHeight(),
		minWidth = love.graphics.getWidth(),
		maxWidth = love.graphics.getWidth(),
		minHeight = love.graphics.getHeight(),
		maxHeight = love.graphics.getHeight(),
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
	local i = i or #self.children + 1
	insert(self.children, i, element)
	element.parent = self
end

function baseElement:removeElement(element)
	for k, v in ipairs(self.children) do
		if v == element then
			element.parent = false
			return remove(self.children, k)
		end
	end
	self:resize()
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

function baseElement:setPositionClamped(x, y)
	-- TODO: write this thingy
end

--------------------------------------------------------------------------------
-- Resize
--------------------------------------------------------------------------------

function baseElement:resize(w, h)
	local oldW, oldH = self.width, self.height

	self.width = clamp(w, self.minWidth, self.maxWidth)
	self.height = clamp(h, self.minHeight, self.maxHeight)

	self.contentWidth = w
	self.contentHeight = h

	print(self.width, self.height, self.maxWidth, self.name)
	self:regenScrollbars()

	if oldW ~= self.width or oldH ~= self.height then
		-- print "size changed"
		-- return self.parent.layout.one(self.parent, self, )
	end
end

--------------------------------------------------------------------------------
-- Scrolling
--------------------------------------------------------------------------------

function baseElement:regenScrollbars()
	print "regen"
	if self.isLeaf then
		return
	end

	local needsX = self.canScrollX and self.contentWidth > self.width
	local needsY = self.canScrollY and self.contentHeight > self.height

	if needsX then
		local scrollbar = self.scrollbarX or mkScrollbar {parent = self, isHorizontal = true}
		local barWidth = (needsY or self.reserveCorner) and self.width - 16 or self.width
		scrollbar.width = barWidth
		scrollbar.gripWidth = floor(lerp(self.width / self.contentWidth, 16, barWidth))

		scrollbar:updateGripPos(0)
		scrollbar.hidden = false
		self.scrollbarX = scrollbar

	elseif self.scrollbarX then
		self.scrollbarX.hidden = true
	end

	if needsY then
		-- print(self.name, "has a scrollbar")
		local scrollbar = self.scrollbarY or mkScrollbar {parent = self, isVertical = true}
		local barHeight = (needsX or self.reserveCorner) and self.height - 16 or self.height
		scrollbar.height = barHeight
		scrollbar.gripHeight = floor(lerp(self.height / self.contentHeight, 16, barHeight))
		-- print("gripHeight:", scrollbar.gripHeight, "ratio", self.height / self.contentHeight)
		
		local area = self.height - scrollbar.gripHeight
		-- scrollbar.gripY = lerp(self.scrollY / self.contentHeight, 0, area)
		scrollbar:updateGripPos(0)
		scrollbar.hidden = false
		self.scrollbarY = scrollbar

	elseif self.scrollbarY then
		self.scrollbarY.hidden = true
	end
end


--[[
	Set the scrollX/Y values.
	Values passed to panTo are expected to be relative to the
	element's size (contentWdith / contentHeight)
]]

function baseElement:panTo(x, y)
	y = clamp(y, 0, self.contentHeight)

end

--[[
	Set the scrollX/Y values.
	Values passed to scrollTo are expected to be normalised
	in the range 0 .. 1
]]
function baseElement:scrollTo(x, y)
	if x then
		x = clamp(x, 0, 1)
		local area = self.contentWidth - self.width
		self.scrollX = floor(lerp(x, 0, area))
		self.scrollbarX:updateGripPos(x)
	end

	if y then
		y = clamp(y, 0, 1)
		local area = self.contentHeight - self.height
		self.scrollY = floor(lerp(y, 0, area))
		self.scrollbarY:updateGripPos(y)
		-- print("scrollY:", self.scrollY)
		-- print("contentHeight:", self.contentHeight, "height:", self.height, "area:", area)
		-- print("in y:", y)
		-- print "-------"
	end
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

function baseElement:draw(id)
	love.graphics.push "all"
	love.graphics.translate(self.x, self.y)
	local x, y = love.graphics.transformPoint(0, 0)
	love.graphics.intersectScissor(x, y, self.width, self.height)

	-- don't items with the special 'none' style
	local isNone = self.style == naga.themes.Naga.none
	if not isNone then
		love.graphics.setColor(self.substyle.color)
		love.graphics.rectangle("fill", 0, 0, self.width, self.height)
	end

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(id or "?", 0, 0)

	if not self.isLeaf then
		-- draw contents at scroll offset
		love.graphics.push()
		love.graphics.translate(-self.scrollX, -self.scrollY)
		for _, child in ipairs(self.children) do
			child:draw(_)
		end
		love.graphics.pop()

		-- scroll bars
		if self.scrollbarY then
			local bar = self.scrollbarY
			love.graphics.setColor(1, 1, 1, 0.8)
			love.graphics.rectangle("fill", bar.x + bar.gripX, bar.y + bar.gripY, bar.gripWidth, bar.gripHeight)
		end

		if self.scrollbarX then
			local bar = self.scrollbarX
			love.graphics.setColor(1, 1, 1, 0.8)
			love.graphics.rectangle("fill", bar.x + bar.gripX, bar.y + bar.gripY, bar.gripWidth, bar.gripHeight)
		end
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

function baseElement:onMouseOver(x, y)

end

function baseElement:onPress(x, y, button)
	
end

function baseElement:onRelease(x, y, button, wasPressed)
	print(self.name, wasPressed and "I was pressed :D" or "I wasn't pressed :(")
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

			local w = element.width
			local h = element.height
			element.width = w or 16
			element.minWidth = element.minWidth or w or 0
			element.maxWidth = element.maxWidth or w or math.huge
			element.height = h or 16
			element.minHeight = element.minHeight or h or 0
			element.maxHeight = element.maxHeight or h or math.huge

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