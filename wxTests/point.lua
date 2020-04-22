--[[
*	Container for a generic point type.
*
]]

-------------------------------------------------------------------------------
--
local Point		= { }
Point.__index	= Point

local m_Size	= 4					-- shared drawing size for a point

-- ----------------------------------------------------------------------------
--
local _format = string.format
local _len	  = string.len
local _match  = string.match

-- ----------------------------------------------------------------------------
--
function Point.new(self)

	local t =
	{
		--	default values
		--	
		x     = 0,
		y     = 0,
		label = "",
	}

	return setmetatable(t, Point)
end

-- ----------------------------------------------------------------------------
-- set values
--
function Point.set(self, x, y, label)
	
	self.x = x
	self.y = y
	
	if label then self.label = label end
end

-- ----------------------------------------------------------------------------
-- copy values from a given point
--
function Point.copy(self, inPoint)
	
	self.x     = inPoint.x
	self.y     = inPoint.y
	self.label = inPoint.label
end

-- ----------------------------------------------------------------------------
-- pretty format a point values
--
function Point.toString(self) 
	
	local ret = _format("[%03d, %03d]", self.x, self.y)

	if self.label and 0 < _len(self.label) then ret = _format("%s {%s}", ret, self.label) end

	return ret
end

-- ----------------------------------------------------------------------------
-- parse a string a set new values
--
function Point.fromString(self, inString)

	local x1, y1, lbl = _match(inString, "(%-?%d+) (%-?%d+) (%a+)")

	if x1 and y1 then

		self.x = tonumber(x1)
		self.y = tonumber(y1)

		if lbl then self.label = lbl end

		return true
	end

	return false
end

-- ----------------------------------------------------------------------------
-- check if coordinates are equal
--
function Point.equals(self, inPoint)
	
	if inPoint.x >= self.x and inPoint.x < (self.x + mSize) then
		
		if inPoint.y >= self.y and inPoint.y < (self.y + mSize) then
			
			return true
		end
	end
  
	return false
end

-- ----------------------------------------------------------------------------
-- changes size for all points
--
function Point.setPointSize(inSize)
	
	if not inSize or 1 > inSize then inSize = 4 end

	m_Size = inSize
end

-- ----------------------------------------------------------------------------
-- changes size for all points
--
function Point.pointSize()

	return m_Size
end
-- ----------------------------------------------------------------------------
--
return Point

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
