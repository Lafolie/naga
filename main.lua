local times = {init = love.timer.getTime()}
local naga = require "."
times.nagaLoad = love.timer.getTime()

naga.push.create {x = 64, y = 64, width = 64, height = 64, canDrag = true, name = "drag square"}
	naga.create {}
naga.pop()

naga.push.create {x = 0, y = 0, height = 32, canDrag = true, name = "parent"}
	naga.create {x = 16, y = 16, width = 16, height = 16, style = "button", name = "button"}
	naga.create {x = 32, y = 16, width = 16, height = 16, style = "button"}
	naga.create {y = 48, style = "button"}
naga.pop()

local container = naga.create {x = 150, y = 16, layout = naga.layout.vertical, canDrag = true, name = "list"}
naga.push(container)
	naga.create {style = "none"}
	for n = 1, 5 do
		naga.create {width = 64, style = "button"}
	end
naga.pop()

local scrollTest = naga.push.create {x = 256, y = 256, width = 120, height = 120, name = "scroll test"}
	naga.create {style = "none"}
	for n = 1, 5 do
		naga.create {y = n * 32, width = 64, style = "button"}
	end
naga.pop()

local hscrollTest = naga.push.create {x = 512, y = 256, width = 120, height = 120, name = "htest"}
	for n = 1, 5 do
		naga.create {x = n * 64, width = 64, style = "button"}
	end
	naga.create {y = 200, height = 64, style = "button"}
naga.pop()

local stats = {}
function love.load()
	print(string.format("Took %f seconds to load Naga", times.nagaLoad - times.init))
end

function love.update(dt)
	stats.fps = love.timer.getFPS()
end

function love.draw()
	naga.draw()
	love.graphics.print(#naga.rootElement.children, 1, 1)
	
	love.graphics.print(stats.fps, love.graphics.getWidth() - 128, 1)

	love.graphics.setColor(1, 1, 0, 1)
	love.graphics.push()
	love.graphics.translate(love.graphics.getWidth() - 256, 1)
	love.graphics.print(scrollTest.scrollY, 0, 0)
	love.graphics.print(scrollTest.scrollbarY.gripY, 0, 20)
	love.graphics.print(scrollTest.scrollbarY.gripHeight, 0, 40)
	love.graphics.print(scrollTest.scrollbarY.scrollOffset or 0, 0, 60)
	love.graphics.pop()
end

function love.resize(w, h)
	naga.resizeWindow(w, h)
end

function love.keypressed(key)
	if key == "escape" or key == "capslock" then
		love.event.push "quit"
	end
end

function love.mousemoved(x, y)
	naga.mouseMoved(x, y)
end

function love.mousepressed(x, y, btn)
	naga.mousePressed(x, y, btn)
end

function love.mousereleased(x, y, btn)
	naga.mouseReleased(x, y, btn)
end