# lwk - A simple and fast Wiki
lwk is based on [marked.js] and [luz]

# Usage
Put your wiki pages under wiki folder, named "xxx.md", eg: wiki\How-To-Use-lwk.md

Start server by `luvit wiki.lua`, open browser and visit http://your_host/How-To-Use-lwk

`wiki.lua`

```lua
local app = require("./luz/app").app:new()

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
			p(wiki)
			wiki = string.gsub(wiki, '\r\n', '\n')
			p(wiki)
			wiki = string.gsub(template, '@content', '"'..wiki..'"')
			return wiki
		else
			return msg
		end
	end
end)
app:listen({port=5555})

p("Http Server listening at http://0.0.0.0:5555/")
```

[marked.js]: https://github.com/chjj/marked
[luz]: https://github.com/hide2/luz