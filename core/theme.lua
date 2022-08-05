local naga, modulePath = select(1, ...)

naga.themes = {}
naga.activeTheme = false

--------------------------------------------------------------------------------
-- Theme Parsing
--------------------------------------------------------------------------------

local fallBackTheme = {}
local thememt = {__index = fallBackTheme}--function(t, k) print("fallback:", fallBackTheme) return fallBackTheme[k] end}

-- fenv use by the theme loader
local themeEnv = {}

local envmt = 
{
	__index = function(t, k)
		return function(tbl) themeEnv._def(k, tbl) end
	end
}

themeEnv = setmetatable(themeEnv, envmt)

-- loader state
local constructTheme
local constructStyle

function themeEnv.theme(name)
	if fallBackTheme then
		naga.themes[name] = setmetatable({}, thememt)
	else
		naga.themes[name] = fallBackTheme
	end
	constructTheme = naga.themes[name]
end

function themeEnv.style(name)
	assert(name ~= "none", "Naga Fatal Error: Can not create a style named 'none' (reserved by Naga)")
	constructTheme[name] = {}
	constructStyle = constructTheme[name]
end

function themeEnv._def(name, props)
	constructStyle[name] = props
end

--------------------------------------------------------------------------------
-- Theme API
--------------------------------------------------------------------------------

-- Load a theme file and add it to naga.themes
function naga.loadTheme(path)
	local thm = love.filesystem.load(path)
	assert(thm, string.format("Naga Fatal Error: Could not locate theme file '%s'", path))
	setfenv(thm, themeEnv)
	thm()
end

-- Set the theme to be used by new elements
function naga.theme(name)
	local theme = naga.themes[name]
	assert(theme, string.format("Naga Fatal Error: Could not find theme '%s'. Did you forget to load it?", name))
	naga.activeTheme = theme
end

naga.loadTheme(modulePath:gsub("%.", "/") .. "themes/naga.lua")
naga.theme "Naga"
naga.activeTheme.none = {body = {}}