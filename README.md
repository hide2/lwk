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
			wiki = string.gsub(wiki, '<', '\\<')
			wiki = string.gsub(wiki, '>', '\\>')
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
<link rel="stylesheet" href="https://assets-cdn.github.com/assets/frameworks-98cac35b43fab8341490a2623fdaa7b696bbaea87bccf8f485fd5cdb4996cd9b52bdb24709fb3bab0a0dcff4a29187d65028ee693d609ce5c0c3283c77a247a9.css">
<link rel="stylesheet" href="https://assets-cdn.github.com/assets/github-cffe8287ff66521c8dbcec6be3b42c1d3a96ac690a876002346fe4cff24e7a09c5416b0a7f1d7523f4873204420f0bd565d73dab259933a9c2c447215d1af94f.css">
<style type="text/css">
/**
 * GitHub Gist Theme
 * Author : Louis Barranqueiro - https://github.com/LouisBarranqueiro
 */
.hljs {
  display: block;
  background: white;
  padding: 0.5em;
  color: #333333;
  overflow-x: auto;
}
.comment,
.meta {
  color: #969896;
}
.string,
.variable,
.template-variable,
.strong,
.emphasis,
.quote {
  color: #df5000;
}
.keyword,
.selector-tag,
.type {
  color: #a71d5d;
}
.literal,
.symbol,
.bullet,
.attribute {
  color: #0086b3;
}
.section,
.name {
  color: #63a35c;
}
.tag {
  color: #333333;
}
.title,
.attr,
.selector-id,
.selector-class,
.selector-attr,
.selector-pseudo {
  color: #795da3;
}
.addition {
  color: #55a532;
  background-color: #eaffea;
}
.deletion {
  color: #bd2c00;
  background-color: #ffecec;
}
.link {
  text-decoration: underline;
}
</style> 
<script src="markedjs"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js"></script>
</head>
<body>
<div id="content" class="markdown-body"></div>
<script>
marked.setOptions({
renderer: new marked.Renderer(),
});
document.getElementById('content').innerHTML = marked(@content);
hljs.configure({
  tabReplace: '    ',
  classPrefix: ''
})
hljs.initHighlighting();
</script>
</body>
</html>
```

[marked.js]: https://github.com/chjj/marked
[luz]: https://github.com/hide2/luz