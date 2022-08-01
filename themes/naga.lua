---@diagnostic disable: undefined-global
theme "Naga"

style "element"
	body
	{
		color     = {1, 0, 1, 1},
		textColor = {1, 1, 1, 1}
	}


style "button"
	body
	{
		color = {0.5, 0.5, 0.5, 1}
	}

	hover
	{
		color     = {0, 1, 1, 0.5},
	}

	press
	{
		color     = {1, 0.5, 0.1, 1},
	}