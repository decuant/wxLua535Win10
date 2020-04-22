--[[
*	routine for a very-long-cycle random-number sequences
*
*	this random number generator was proved to generate random sequences
*	between 0 to 1 which if 100 numbers were calculated every second, it
*	would NOT repeat itself for over 220 years.
*
*	reference:
*
*	Wichmann B.A. and I.D. Hill. "Building A Random Number Generator."
*	Byte Magazine. March 1987. pp.127.
]]

-- ----------------------------------------------------------------------------
--
local Random = { }

Random.__index = Random

-- ----------------------------------------------------------------------------
-- instance creator
-- (tell Lua 5.3 that numbers are floating point)
--
function Random.new()

	local t =
	{
		--	default seed values
		--
		_x 	= 1.0,
		_y 	= 10000.0,
		_z 	= 3000.0,
		_last = 0.0,
	}

	return setmetatable(t, Random)
end

-- ----------------------------------------------------------------------------
--	seed generator
--
function Random.initialize(self)

	local INT_MAX = 0x7fffffff

	self._x = os.time() % INT_MAX
	self._y = (self._x ^ 2)  % INT_MAX
	self._z = (self._y ^ 2)  % INT_MAX

	-- load a proper value into _last
	--
	self:get()
end

-- ----------------------------------------------------------------------------
-- return the _last computed value
--
function Random.last(self)

	return self._last
end

-- ----------------------------------------------------------------------------
-- produce a new value and store it in _last
--
function Random.get(self)

	local _x = self._x
	local _y = self._y
	local _z = self._z

	_x = 171 * (_x % 177) - 2 * (_x / 177)
	if 0 > _x then _x = _x + 30269 end

	_y = 172 * (_y % 176) - 35 * (_y / 176)
	if 0 > _y then _y = _y + 30307 end

	_z = 170 * (_z % 178) - 63 * (_z / 178)
	if 0 > _z then _z = _z + 30323 end

	local _last = _x / 30269.0 + _y / 30307.0 + _z / 30323.0

	-- remove the integral part
	--
	self._last = _last - math.floor(_last)

	-- store computed values
	--
	self._x = _x
	self._y = _y
	self._z = _z

	return self._last
end

-- ----------------------------------------------------------------------------
-- produce a new value inside the given interval
--
function Random.getBoxed(self, inMin, inMax)

	self._last = ((inMax - inMin) * self:get()) + inMin

	return self._last
end

-- ----------------------------------------------------------------------------
--
return Random

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
