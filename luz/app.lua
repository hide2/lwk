local Object = require('core').Object
local Http = require("./http").Http
local router = require("./router")

local app = Object:extend()

function app:initialize()
	self._server = Http:new()
	self._router = router.new()
end

function app:get(path, cb)
	self._router:get(path, function(params)
		return cb(params)
	end)
end
function app:post(path, cb)
	self._router:post(path, function(params)
		return cb(params)
	end)
end
function app:any(path, cb)
	self._router:any(path, function(params)
		return cb(params)
	end)
end

local function prepareHeader(req, body)
	body = body or ''
	local header = {
		code = 200,
		{ "Server", "Luz" },
		{ "Content-Type", "text/html" },
		{ "Content-Length", #body },
	}
	if req.keepAlive then
		header[#header + 1] = { "Connection", "Keep-Alive" }
	end
	return header
end
function app:listen(options)
	self._server:listen(options, function(client, req)
		local _, body = self._router:execute(req.method, req.path)
		local header = prepareHeader(req, body)
		client:respond(header, body)
	end)
end

return {
	app = app,
}