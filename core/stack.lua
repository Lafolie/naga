local naga = select(1, ...)
local insert, remove = table.insert, table.remove
local stack = {}

naga.push = setmetatable(
	{
		create = function(elementSettings)
			assert(not elementSettings.isLeaf, "Naga Fatal Error: Can't push leaf elements to the stack!")
			local element = naga.create(elementSettings)
			insert(stack, element)
			return element
		end
	}, 
	{
		__call = function(t, element)
			insert(stack, element)
		end,
		__index = function(t, k)
			t[k] = function(elementSettings)
				assert(not elementSettings.isLeaf, "Naga Fatal Error: Can't push leaf elements to the stack!")
				local element = naga.create[k](elementSettings)
				insert(stack, element)
				return element
			end
			return t[k]
		end
	})

function naga.pop()
	local element = remove(stack)
	element:layout()
	return element
end

function naga.popAll()
	for n = #stack, 1, -1 do
		naga.pop()
	end
end

function naga.peek()
	return stack[#stack]
end