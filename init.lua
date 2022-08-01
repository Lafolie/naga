local modulePath = select(1, ...):gsub("%.", "/")

local naga = {}

local function implement(name)
	local path = string.format("core/%s/%s.lua", modulePath, name)
	love.filesystem.load(path)(naga, modulePath)
end

function naga.loadExtensions(path)
	assert(love.filesystem.getInfo(path, "directory"), string.format("Naga Fatal Error: Could not find extensions dir '%s'", path))
	local count = 0
	for _, file in ipairs(love.filesystem.getDirectoryItems(path)) do
		if file:match ".+%.lua$" then
			love.filesystem.load(path .. "/" .. file)(naga)
		end
		count = count + 1
	end
	print(string.format("Naga: loaded %i extensions from %s", count, path))
end

-- implementation order matters, do not rearrange
implement "theme"
implement "resize"
implement "layout"
implement "create"
implement "stack"
implement "callbacks"

naga.loadExtensions(string.format("%s/elements", modulePath))

return naga