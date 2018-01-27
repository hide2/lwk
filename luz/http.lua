local uv = require('uv')
local Object = require('core').Object
local encode = require('http-codec').encoder()
local decode = require('http-codec').decoder()

local Http = Object:extend()

local function httpDecoder(emit)
	local input
	return function(err, chunk)
		if err then return emit(err) end
		input = (input and chunk) and (input .. chunk) or chunk
		repeat
			local event, extra = decode(input)
			if event then
				input = extra
				emit(nil, event)
			end
		until not event
	end
end

local function process(client, cb)
	local req, res, body
	client:read_start(httpDecoder(function(err, event)
		if err then return end
		assert(not err, err)
		local typ = type(event)
		if typ == "table" then
			req = event
			local httpClient = Http:new({ handle = client })
			res, body = cb(httpClient, req)
			if not req.keepAlive then
				client:close()
			end
		elseif typ == "string" and req.onbody then
			req.onbody(event)
		elseif not event then
			client:close()
		end
	end))
end

function Http:initialize(options)
	self._ip = options and options.ip or '0.0.0.0'
	self._port = tonumber(options and options.port or 8080)
	if options and options.handle then
		self._handle = options.handle
	else
		self._handle = uv.new_tcp()
	end
end

function Http:listen(options, cb)
	self._ip = options and options.ip or '0.0.0.0'
	self._port = tonumber(options and options.port or 8080)
	if options and options.handle then
		self._handle = options.handle
	else
		self._handle = self._handle or uv.new_tcp()
	end
	uv.tcp_bind(self._handle, self._ip, self._port)
	local ret = uv.listen(self._handle, 128, function()
		local client = uv.new_tcp()
		self._handle:accept(client)
		process(client, cb)
	end)
	assert(ret >= 0, 'listen error:'..ret)
end

function Http:respond(header, body)
	if header and body then
		self._handle:write(encode(header) .. encode(body))
	end
end

function Http:request(options, cb)
	self._ip = options and options.ip or '127.0.0.1'
	self._port = tonumber(options and options.port or 8080)
	if options and options.handle then
		self._handle = options.handle
	else
		self._handle = self._handle or uv.new_tcp()
	end

	local client = self._handle
	uv.getaddrinfo(self._ip, self._port, { socktype = "stream" }, function(err, res)
		if err then
			if not self._handle:is_closing() then
				self._handle:close()
			end
		end
		self._ip = res[1].addr
		self._port = res[1].port

		client:connect(self._ip, self._port, function(err)
			if err then error(err) end

			-- send request
			local header = {}
			header.method = options and options.method or 'GET'
			header.path = options and options.path or '/'
			local connection = options and options.connection or "Close"
			table.insert(header, {"User-Agent", options and options.agent or "X"})
			table.insert(header, {"Host", options and options.ip or self._ip})
			table.insert(header, {"Connection", options and options.connection or "Close"})
			local body = options and options.body
			if body then
				self._handle:write(encode(header) .. encode(body))
			else
				self._handle:write(encode(header))
			end

			-- read data back
			local _buffer = ''
			client:read_start(function(err, data)
				if err then
					if not client:is_closing() then
						client:close()
					end
				end
				if data then
					_buffer = _buffer..data
				else
					cb(_buffer)
					if not client:is_closing() then
						client:close()
					end
				end
			end)
		end)
	end)
end

return {
	Http = Http,
}
