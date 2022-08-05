local naga = select(1, ...)

--[[
	Input callbacks handle most of the core functionality, such as substyle
	updates, dragging, and scrolling. Handling that in the callbacks means
	fewer overall functions, and leaves the element `onXYZ` functions clear
	for custom implementations.

	In effect, all styling and default element behaviour is implemented by
	the Naga internals (such as this file).
]]

local ordering = {}
local hoverInfo = {}
local activeInfo = {}
local dragInfo = {}
local scrollInfo = {}

--------------------------------------------------------------------------------
-- Tracing
--------------------------------------------------------------------------------

local function intersectPoint(x, y, element)
	return not
		(
			x < element.x or
			x > element.x + element.width or
			y < element.y or
			y > element.y + element.height
		)
end

--[[
	Point in AABB collision detection.
	Trace routine is a three-fold process:

		1. The element is checked for collision
		2. The element's scrollbars are checked
		3. The element's children are checked

	Scrollbars take highest precedence as they are always rendered last.
	Children take precedence over the element.
	The element is ignored if its style is 'none'.
]]
function naga.trace(x, y, element)
	if intersectPoint(x, y, element) then
		x = x - element.x
		y = y - element.y

		if not element.isLeaf then
			-- check scrollbars
			local bar = element.scrollbarY
			if bar and intersectPoint(x, y, bar) then
				return bar, x - bar.x, y - bar.y
			end

			-- check children
			for _, child in ipairs(element.children) do

				local hit, hitX, hitY = naga.trace(x, y, child)

				if hit then
					return hit, hitX, hitY
				end
			end
		end

		if element.style ~= naga.activeTheme.none then
			return element, x, y
		end
	end
end

--------------------------------------------------------------------------------
-- Mouse Input
--------------------------------------------------------------------------------

function naga.mouseMoved(x, y)
	-- ensure mouse is within the window
	if not intersectPoint(x, y, naga.rootElement) then
		return
	end

	-- element dragging
	if dragInfo.element then
		-- we have to use our own deltas since the ones provided by
		-- love.mousemoved cause a desync when the mouse leaves the window
		local dx = x - dragInfo.x
		local dy = y - dragInfo.y

		dragInfo.element:setPosition(dragInfo.fromX + dx, dragInfo.fromY + dy)

		if not dragInfo.started then
			dragInfo.element:onBeginDrag()
			dragInfo.started = true
		end
	end

	-- update the hover element info
	-- we do this after dragging to ensure onMouseOver info is correct
	local element, hitX, hitY = naga.trace(x, y, naga.rootElement)
	element = element or naga.rootElement
	hitX = hitX or -1
	hitY = hitY or -1
	
	local hoverElement = hoverInfo.element or naga.rootElement
	
	if element ~= hoverElement then
		local isActive = hoverElement == activeInfo.element
		hoverElement:setSubstyle(isActive and "press" or "body")
		hoverElement:onEndHover(-1, -1)

		isActive = element == activeInfo.element
		element:setSubstyle(isActive and "press" or "hover")
		element:onBeginHover(hitX, hitY)
	end

	hoverElement:onMouseOver(hitX, hitY)

	hoverInfo.element = element
	hoverInfo.x = hitX
	hoverInfo.y = hitY

	-- update the scrollbar
	if scrollInfo.element then
		local dx = x - scrollInfo.x
		local dy = y - scrollInfo.y
		scrollInfo.element:updateScrollPosition(dx, dy)
	end
end

function naga.mousePressed(x, y, btn)
	local element = hoverInfo.element
	activeInfo.element = element

	element:setSubstyle "press"
	element:onPress(hoverInfo.x, hoverInfo.y)

	if element.canDrag then
		dragInfo.element = element
		dragInfo.x = x
		dragInfo.y = y
		dragInfo.fromX = element.x
		dragInfo.fromY = element.y
		dragInfo.started = false
	end

	if element.isScrollbar then
		scrollInfo.element = element
		scrollInfo.x = x
		scrollInfo.y = y
	end
end

function naga.mouseReleased(x, y, button)
	if activeInfo.element == hoverInfo.element then
		activeInfo.element:onRelease(hoverInfo.x, hoverInfo.y, button, true)
		activeInfo.element:setSubstyle "hover"
	else
		activeInfo.element:onRelease(-1, -1, button, false)
		activeInfo.element:setSubstyle "body"
		hoverInfo.element:onRelease(hoverInfo.x, hoverInfo.y, button, false)
	end

	activeInfo.element = false

	if dragInfo.element then
		if dragInfo.started then
			dragInfo.element:onEndDrag()
		end
		
		dragInfo.element = false
	end

	if scrollInfo.element then
		scrollInfo.element = false
	end
end


--------------------------------------------------------------------------------
-- Main Callbacks
--------------------------------------------------------------------------------

function naga.draw(element)
	element = element or naga.rootElement
	element:draw()
end

function naga.resizeWindow(width, height)
	naga.rootElement.width = width
	naga.rootElement.height = height
end