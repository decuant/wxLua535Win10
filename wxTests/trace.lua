-- ----------------------------------------------------------------------------
--[[ Trace.lua

]]

-- ----------------------------------------------------------------------------
--
--

local Trace = Trace or {}

local _wrt  = io.write
local _fmt	= string.format
local _rep	= string.rep
local _len	= string.len
local _cat	= table.concat
local _clk	= os.clock

local mEnabled		= true
local mLineCounter	= 0
local mTickStart	= _clk()
local mTickTimed	= _clk()

-- ----------------------------------------------------------------------------
--
function Trace.enable(inEnable)
	
	mEnabled = inEnable
end

-- ----------------------------------------------------------------------------
--
function Trace.msg(inMessage)
	
	if not mEnabled then return end
	
	mLineCounter = mLineCounter + 1

	_wrt(_fmt("%05d: %s", mLineCounter, inMessage))  
end

-- ----------------------------------------------------------------------------
--
function Trace.append(inMessage)
	
	if not mEnabled then return end
		
	_wrt(inMessage)
end

-- ----------------------------------------------------------------------------
--
function Trace.numArray(inTable, inLabel)
	
	if not mEnabled then return end

	local tStrings = {inLabel or ""}

	for iIndex, number in ipairs(inTable) do
		
		tStrings[iIndex + 1] = _fmt("%.04f", number)
	end

	Trace.line(_cat(tStrings, " ")) 	
end

-- ----------------------------------------------------------------------------
--
function Trace.line(inMessage)
	
	if not mEnabled then return end
	
	Trace.msg(inMessage .. "\n")
	io.flush()
end

-- ----------------------------------------------------------------------------
--
function Trace.lnTime(inMessage, inReset)
	
	if not mEnabled then return end
		
	local sText
	
	if inReset then
		
		mTickStart = _clk()
		
		sText = inMessage
		
	else
	
		mTickTimed = _clk()

		sText = _fmt("%s - %.03f secs", inMessage, (mTickTimed - mTickStart))
	
		mTickStart = mTickTimed
	end

	Trace.msg(sText .. "\n")
	io.flush()	
end

--------------------------------------------------------------------------------
-- dump a buffer
--
function Trace.dump(_title, buf)
	
	if not mEnabled then return end	
  
  local blockText = "---- [" .. _title .. "] ----\n"  
  
	_wrt(blockText)

	for iByte=1, #buf, 16 do
	  
		local chunk = buf:sub(iByte, iByte + 15)

		_wrt(_fmt('%08X  ', iByte - 1))

		chunk:gsub('.', function (c) _wrt(_fmt('%02X ', string.byte(c))) end)
	 
		_wrt(_rep(' ', 3 * (16 - #chunk)))
		_wrt(' ', chunk:gsub('%c','.'), "\n") 
	end

	_wrt(blockText)
	io.flush()  
end

-- ----------------------------------------------------------------------------
--  print a table in memory
--
function Trace.table(t)
	
	if not mEnabled then return end	
  
	local print_r_cache = {}
  
	local function sub_print_r(t, indent)
    
		if (print_r_cache[tostring(t)]) then

			Trace.line(indent.."*"..tostring(t))

		else

			print_r_cache[tostring(t)] = true

			if (type(t)=="table") then
				
				for pos,val in pairs(t) do
					
					if (type(val)=="table") then

						Trace.line(indent.."["..pos.."] => "..tostring(t).." {")
						sub_print_r(val,indent.._rep(" ", _len(pos)+4))
						Trace.line(indent.._rep(" ", _len(pos)+2).."}")

					elseif (type(val)=="string") then

						Trace.line(indent.."["..pos..'] => "'..val..'"')

					else
						Trace.line(indent.."["..pos.."] => "..tostring(val))
					end
				end
			else
				
				Trace.line(indent..tostring(t))
			end
		end
	end

	if (type(t)=="table") then
		
		Trace.line(tostring(t).." {")
		sub_print_r(t,"  ")
		Trace.line("}")
	else
		
		sub_print_r(t,"  ")
	end

	io.flush()
end

-- ----------------------------------------------------------------------------
--
return Trace

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
