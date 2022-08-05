local modulePath = select(1, ...)
local slashedPath = modulePath:gsub("%.", "/")

local naga = {}

local function implement(name)
	local path = string.format("core/%s/%s.lua", slashedPath, name)
	love.filesystem.load(path)(naga, modulePath)
end

-- implementation order matters, do not rearrange
implement "theme"
implement "layout"
implement "create"
implement "stack"
implement "callbacks"
implement "extension"

naga.loadExtensions(string.format("%s/elements", slashedPath))

return naga