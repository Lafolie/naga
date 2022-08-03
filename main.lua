local times = {init = love.timer.getTime()}
local naga = require "."
times.nagaLoad = love.timer.getTime()

naga.create {x = 64, y = 64, width = 64, height = 64, canDrag = true, name = "drag square"}
naga.push.create {x = 0, y = 0, height = 32, canDrag = true, name = "parent"}
	naga.create {x = 16, y = 16, width = 16, height = 16, style = "button", name = "button"}
	naga.create {x = 32, y = 16, width = 16, height = 16, style = "button"}
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