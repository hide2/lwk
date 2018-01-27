# lwk - A simple and fast Wiki
lwk is based on [marked.js] and [luz]

# Usage
Put your wiki pages under wiki folder, named "xxx.md", eg: wiki/How-To-Use-lwk.md

Start server by `luvit wiki.lua`, open browser and visit http://your_host/How-To-Use-lwk

`wiki.lua`

```lua
local app = require("./luz/app").app:new()

app:get('/', function()
	return 'Hello, lwk!'
end)

local markedjs = io.open("marked.js",'r'):read("*a")
local template = io.open("template.html",'r'):read("*a")
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
```

`template.html`

```html
<!doctype html>
<html>
<head>
<meta charset="utf-8"/>
<title>Wiki</title>
<link rel="stylesheet" href="https://assets-cdn.github.com/assets/github-cffe8287ff66521c8dbcec6be3b42c1d3a96ac690a876002346fe4cff24e7a09c5416b0a7f1d7523f4873204420f0bd565d73dab259933a9c2c447215d1af94f.css">
<script src="markedjs"></script>
</head>
<body>
<div id="content" class="markdown-body"></div>
<script>
marked.setOptions({
renderer: new marked.Renderer(),
gfm: true,
tables: true,
breaks: false,
pedantic: false,
sanitize: false,
smartLists: true,
smartypants: false,
xhtml: false
});
document.getElementById('content').innerHTML = marked(@content);
</script>
</body>
</html>
```

[marked.js]: https://github.com/chjj/marked
[luz]: https://github.com/hide2/luz