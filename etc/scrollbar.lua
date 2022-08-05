--[[
	Scrollbars are 'pseudo elements' - they are duck types that are
	compatible with most element callbacks, but have a simplified
	implementation since they have a niche purpose and don't need to
	pushed to the stack
]]

--[[
	On click:
		- try to centre the grip on the cursor
		- clamp the grip to the bounds
		- calc offset on the now clamped grip
		- when dragging, use the given offset
]]

local scrollbar = {isLeaf = true, isScrollbar = true, scrollX = 0, scrollY = 0}
local mt = {__index = scrollbar}

local function isPointInLine(x, pos, length)
	return not (x < pos or x > pos + length)
end

--------------------------------------------------------------------------------
-- Scrollbar Methods
--------------------------------------------------------------------------------

function scrollbar:normaliseScrollPos(pos)
	if self.isVertical then
		--  return (pos - self.gripHeight) / (self.height - self.gripHeight * 2)
		-- return pos / self.height
		return pos / (self.height - self.gripHeight)
	end
end

function scrollbar:resize()
	if self.isVertical then
		
	end
end

function scrollbar:updateGripPos(t)
	if self.isVertical then
		self.gripY = (self.height - self.gripHeight) * t
		self.scrollT = t
		-- print(self.height, self.gripY, t)
	end
end

--------------------------------------------------------------------------------
-- Pseudo Compatibility
--------------------------------------------------------------------------------

function scrollbar:setSubstyle()
	
end

--------------------------------------------------------------------------------
-- Interaction
--------------------------------------------------------------------------------

function scrollbar:onBeginHover()
	
end

function scrollbar:onEndHover()

end

function scrollbar:onPress(x, y, button)
	self.pressed = true

	if not isPointInLine(y, self.gripY, self.gripHeight) then
		-- clicked the gutter, so jump immediately
		local pos = self:normaliseScrollPos(y - self.gripHeight / 2)
		self.parent:scrollTo(false, pos)
	end

	local gripOffset = y - self.gripY
	self.scrollOffset = y - gripOffset
end

function scrollbar:onRelease(x, y, button, wasPressed)
	self.pressed = false
end

function scrollbar:onMouseOver(x, y)
end

function scrollbar:updateScrollPosition(x, y)
	if self.pressed then
		if self.isVertical then
			local pos = self:normaliseScrollPos(self.scrollOffset + y)
			self.parent:scrollTo(false, pos)
		end
	end
end

return function(settings)
	local bar = setmetatable(settings, mt)
	if bar.isVertical then
		bar.x = bar.parent.width - 16
		bar.y = 0
		bar.width = 16
		bar.height = bar.parent.height
		bar.gripWidth = 16
		bar.gripX = 0
	end
	return bar
end