local naga = select(1, ...)

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

function naga.extension(name)
	
end