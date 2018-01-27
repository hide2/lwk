local app = require("./luz/app").app:new()
local JSON = require("json")

app:get('/', function()
	return 'Hello, lwk!'
end)

local markedjs = io.open("wiki/marked.js",'r'):read("*a")
local template = io.open("wiki/template.html",'r'):read("*a")
app:get('/:wiki', function(params)
	if string.find(params.wiki, "markedjs") then
		return markedjs
	else
		local wiki, msg = io.open("wiki/"..params.wiki..".md", 'r')
		if wiki then
			wiki = wiki:read("*a")
			wiki = string.gsub(wiki, '\r\n', '\\n')
			wiki = '"'..string.gsub(wiki, '"', '\\"')..'"'
			wiki = string.gsub(template, '@content', wiki)
			return wiki
		else
			return msg
		end
	end
end)
app:listen({port=5555})

p("Http Server listening at http://0.0.0.0:5555/")