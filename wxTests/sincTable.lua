--[[
*	SincTable - create a sinc table
*
*	3 different types of implementation are available.
*
*	Note that the Normalized and Blackman funtions use forward setup.
]]

-------------------------------------------------------------------------------
--
local SincTable		= { }
SincTable.__index	= SincTable

-- ----------------------------------------------------------------------------
-- can be compiled in 3 different ways
--
SincType = 
{  
	eSinc_Fx_Invalid 	= -1,
	eSinc_Fx_Sinc		= 0,
	eSinc_Fx_Normalized	= 1,
	eSinc_Fx_Windowed	= 2
}

-- ----------------------------------------------------------------------------
--
local _abs	= math.abs
local _sin 	= math.sin
local _cos 	= math.cos

local PIGRECO		= math.pi
local DUE_PIGRECO	= 2.0 * PIGRECO

-- ----------------------------------------------------------------------------
-- instance creator
--
function SincTable.new()

	local t =
	{
		m_SincType		= SincType.eSinc_Fx_Invalid,
		m_SincTable		= { 0.0 },
		m_MaxElements	= 0,
		m_TimeInterval	= 0,
	}

	return setmetatable(t, SincTable)
end

-- ----------------------------------------------------------------------------
-- invalidate contents
--
function SincTable.reset(self)

	self.m_SincType		= SincType.eSinc_Fx_Invalid
	self.m_SincTable	= { 0.0 }
	self.m_MaxElements	= 0
	self.m_TimeInterval	= 0
end

-- ----------------------------------------------------------------------------
-- get at index
--
function SincTable.at(self, inIndex)
	
	if 0 < inIndex and inIndex <= self.m_MaxElements then
		
		return self.m_SincTable[inIndex]
	end
	
	-- this is safe, max can be 0 but at least 1 is created
	--
	return self.m_SincTable[1]	
end

-- ----------------------------------------------------------------------------
-- standard sinc function
--
local function __SincFunction(x)

	if 0.1 > _abs(x) then return 1.0 end			-- note: 1.0

	return _sin(x) / x
end

-- ----------------------------------------------------------------------------
-- normalized sinc function
--
local function __NormSincFunction(inSincTable, x)
	
	if 0.1 > _abs(x) then return 0.0 end			-- note: 0.0
	
	local index = x / inSincTable.m_TimeInterval
	local tau   = inSincTable.m_MaxElements - 1
	
	return __SincFunction(PIGRECO * index / tau) / x
end

-- ----------------------------------------------------------------------------
-- Blackman windowed sinc function
--
local function __WindowedSincFunction(inSincTable, x)
	
	if 0.0001 > _abs(x) then return 0.0 end			-- note: 0.0001 and ret 0.0
	
	local index = x / inSincTable.m_TimeInterval
	local tau   = inSincTable.m_MaxElements - 1
	local alpha = 0.500
	local beta  = 0.420
	local gamma = 0.080
	
	local add1 = ( 1.0 - alpha ) * _cos( ( PIGRECO * index ) / tau )
	local add2 = gamma * _cos( ( DUE_PIGRECO * index ) / tau )
	local add3 = beta + add1 + add2
	
	return add3 / x
end

-- ----------------------------------------------------------------------------
-- create the table
--
function SincTable.setup(self, inSincType, inMaxElements, inTimeInterval)
	
	local timesAt = inTimeInterval
	
	if SincType.eSinc_Fx_Invalid >= inSincType or SincType.eSinc_Fx_Windowed < inSincType then 
		inSincType = SincType.eSinc_Fx_Sinc
	end
	
	-- store settings
	--
	self:reset()

	self.m_SincType		= inSincType
	self.m_MaxElements	= inMaxElements
	self.m_TimeInterval	= inTimeInterval	
	
	-- calculate
	--
	for k=1, inMaxElements do
		
		if SincType.eSinc_Fx_Normalized == inSincType then
			
			self.m_SincTable[ k ] = __NormSincFunction(self, timesAt)
			
		elseif SincType.eSinc_Fx_Windowed == inSincType then
			
			self.m_SincTable[ k ] = __WindowedSincFunction(self, timesAt)
			
		else	-- default
			
			self.m_SincTable[ k ] = __SincFunction(timesAt)
		end
		
		timesAt = timesAt + inTimeInterval
	end

end
	
-------------------------------------------------------------------------------
--
return SincTable

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

