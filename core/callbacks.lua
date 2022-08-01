local naga = select(1, ...)

local ordering = {}
local hoverInfo = {}
local activeInfo = {}
local dragInfo = {}

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

function naga.trace(x, y, element)
	if intersectPoint(x, y, element) then
		x = x - element.x
		y = y - element.y

		for _, child in ipairs(element.children) do

			local hit, hitX, hitY = naga.trace(x, y, child)

			if hit then
				return hit, hitX, hitY
			end
		end

		return element, x, y
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

	local element, hitX, hitY = naga.trace(x, y, naga.rootElement)
	local hoverElement = hoverInfo.element or naga.rootElement
	
	if element ~= hoverElement then
		local isActive = hoverElement == activeInfo.element
		hoverElement:setSubstyle(isActive and "press" or "body")
		hoverElement:onEndHover(-1, -1)

		isActive = element == activeInfo.element
		element:setSubstyle(isActive and "press" or "hover")
		element:onBeginHover(hitX, hitY)
	end

	hoverInfo.element = element
	hoverInfo.x = hitX
	hoverInfo.y = hitY
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
end

function naga.mouseReleased(x, y, button)
	if activeInfo.element == hoverInfo.element then
		activeInfo.element:onRelease(hoverInfo.x, hoverInfo.y, button, true)
		activeInfo.element:setSubstyle "hover"
	else
		activeInfo.element.onRelease(-1, -1, button, false)
		activeInfo.element:setSubstyle "body"
		hoverInfo.element.onRelease(hoverInfo.x, hoverInfo.y, button, false)
	end

	activeInfo.element = false

	if dragInfo.element then
		if dragInfo.started then
			dragInfo.element:onEndDrag()
		end
		
		dragInfo.element = false
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