local naga = select(1, ...)
local insert, remove = table.insert, table.remove
local stack = {}

naga.push = setmetatable(
	{
		create = function(elementSettings)
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
				local element = naga.create[k](elementSettings)
				insert(stack, element)
				return element
			end
			return t[k]
		end
	})

function naga.pop()
	return remove(stack)
end

function naga.popAll()
	stack = {}
end

function naga.peek()
	return stack[#stack]
end