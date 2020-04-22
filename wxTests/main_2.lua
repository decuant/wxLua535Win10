--[[
*	Test GDI drawing
*
*	Display the sinc function.
*	Uses 2 back-buffers, 1 for the background and 1 for the actual drawing.
*	Yet can be optimized further knowing the minimum bounding rectangle for
*	the drawing, actually the min, max for the sinc samples.
*
*	Uses a Windows' timer for generating random values and refreshing.
*   You can play with max samples, time interval between samples, Y zoom.
*	Eventually try compiling different sinc implementations, note that
*	calculation grows expensive in Normalized and even more in Windowed.
*
]]

local wx		= require("wx")
local random	= require("random")
local sincTable	= require("sincTable")
local palette	= require("wxX11Palette")
local trace 	= require("trace")	
local ptFactory	= require("point")	

local _format	= string.format
local _floor	= math.floor
local _remove	= table.remove

-- ----------------------------------------------------------------------------
-- window's private members
--
local m_Frame =
{
	hWindow		= nil,		-- main frame
	rcClientW	= 0,		-- client area	width
	rcClientH	= 0,		--	"		"	height
	
	hBackDC		= nil,		-- background device context
	hMemoryDC	= nil,		-- device context for the window
	
	hTickTimer	= nil,		-- frame's ticktimer
	iTickFrame	= 100,		-- timer frequency
	
	tSamples	= { },		-- list of samples
	iMaxSamples	= 100,		-- max list size
	iTimeIntrvl	= 10,		-- time between 2 readings

	fnText		= nil, 		-- font for legenda
	sFontName	= "",		-- selected font name
	iFontSize	= 10,		-- selected font size
	
	iRndCycles	= 2,		-- for the rnd generator
	
}

-- ----------------------------------------------------------------------------
-- preallocated GDI objects
--
local m_penNULL  = wx.wxPen(palette.Black, 0, wx.wxTRANSPARENT)
local m_brNULL   = wx.wxBrush(palette.White, wx.wxTRANSPARENT)

local m_penRect  = wx.wxPen(palette.White, 3, wx.wxDOT)
local m_brBack   = wx.wxBrush(palette.Black, wx.wxSOLID)
local m_clrFore  = palette.White
local m_clrExtra = palette.OrangeRed

-- ----------------------------------------------------------------------------
-- allocate single instance of objects
--
local m_Random  = random.new()
local m_SincTbl = sincTable.new()

-- ----------------------------------------------------------------------------
-- generate a unique new wxWindowID
--
local iRCEntry = wx.wxID_HIGHEST + 1

local function UniqueID()

	iRCEntry = iRCEntry + 1
	return iRCEntry
end

-- ----------------------------------------------------------------------------
-- remap a point from absolute to client coords
--
local DEFAULT_ZOOM_Y  = 5000.00

local m_2DOriginX	  = 0
local m_2DOriginY	  = 0

local function MapToOriginEx(inX, inY)

	local _x = inX
	local _y = inY
       
	--	get the number of points in the drawing
	---
	local dMaxCount = m_Frame.iMaxSamples * m_Frame.iTimeIntrvl ;

	-- set zoom
	-- 
	_x = _x * (m_Frame.rcClientW / dMaxCount)
	_y = _y * DEFAULT_ZOOM_Y
	
	-- offset origin
	--
	_x = _floor(m_2DOriginX + _x)
	_y = _floor(m_2DOriginY - _y)
	
	return _x, _y
end
-- ----------------------------------------------------------------------------
-- add new values to the readings list
--
local function AddRandomPoint()
	trace.line("AddRandomPoint")

	local tSamples= m_Frame.tSamples
	local aPoint
	local timedAt = 0
	local iIntrvl = m_Frame.iTimeIntrvl
	
	-- add a number of readings
	--
	for i=1, m_Frame.iRndCycles do
		
		aPoint = ptFactory.new()
		
		-- get last time in queue
		--
		if 0 < #tSamples then 
			
			timedAt = tSamples[#tSamples].x
		
			-- advance time by a time interval
			--
			timedAt = timedAt + iIntrvl
		end
		
		-- make the point and add it to the list
		--
		aPoint:set(timedAt, m_Random:get())
		tSamples[#tSamples + 1] = aPoint
	end
	
	local iShift = #tSamples - m_Frame.iMaxSamples
	
	-- if too many samples then purge exceeding
	-- shift all the readings to the left
	--
	if 0 < iShift then
		
		for i=1, iShift do _remove(tSamples, 1) end
		
		timedAt = 0
		
		for i=1, #tSamples do
			
			tSamples[i].x = timedAt
			
			timedAt = timedAt + iIntrvl
		end
	end

end

-- ----------------------------------------------------------------------------
-- for each sample point create a list of drawing points
--
local function DrawSync(inDc)
	trace.line("DrawSync")
	
	if not inDc then return end
	
	local tSamples = m_Frame.tSamples
	
	if 0 == #tSamples then return end

	local penOdd  = wx.wxPen(palette.LightYellow, 1, wx.wxSOLID)
	local penEven = wx.wxPen(palette.SkyBlue1, 1, wx.wxSOLID)

	local iMaxElements	= m_Frame.iMaxSamples
	local iTimeIncrement= m_Frame.iTimeIntrvl
	local iLimit 		= iTimeIncrement * iMaxElements

	local iIndex
	local iTimedAt
	local vPoints = { }		-- list of computed sinc points
	local _x, _y
	local dCurValue
	local iDifference
	local iTableIndex

	
	for iCurSample=1, #tSamples do
	
		vPoints		= { }		-- clean up and restart
		iIndex		= 1
		iTimedAt	= 0
		_x			= tSamples[iCurSample].x
		_y			= tSamples[iCurSample].y

		--	fill in all points for the drawing
		--	starts from 0, counts the x difference between the current point and the generated point
		--
		while (iTimedAt <= iLimit) and (iIndex <= iMaxElements) do
			
			iDifference = iTimedAt - _x
			dCurValue	= 0.0
			
			if 0 ~= iDifference then

				iTableIndex = iDifference / iTimeIncrement
				
				if 0 > iDifference then
					
					dCurValue = - m_SincTbl:at( - iTableIndex )
					
				else
					
					dCurValue = m_SincTbl:at( iTableIndex )
				end
				
				dCurValue = dCurValue * _y
			end
			
			-- allocate a new sinc point
			--
			local ptSinc = ptFactory.new()
			
			ptSinc:set(iTimedAt, dCurValue)
			
			vPoints[ iIndex ] = ptSinc
			
			-- move next
			--
			iTimedAt = iTimedAt + iTimeIncrement
			iIndex = iIndex + 1
		end
		
		--	----------------
		--	do the draw here
		--
		if 0 == iCurSample % 2 then inDc:SetPen(penEven) else inDc:SetPen(penOdd) end
		
		if 0 < iIndex then
			
			local xA, yA
			local xB, yB

			--	move to the first, has x always 0 and y moving
			--
			xA, yA = MapToOriginEx(vPoints[ 1 ].x, vPoints[ 1 ].y)
			
			for iIndex=2, #vPoints do
				
				xB, yB = MapToOriginEx(vPoints[ iIndex ].x, vPoints[ iIndex ].y)
				
				inDc:DrawLine(xA, yA, xB, yB)
				
				-- get next
				--
				xA, yA = xB, yB
			end
		end
	end	
	
end

-- ----------------------------------------------------------------------------
--
local function NewMemDC()
	trace.line("NewMemDC")
	
	-- check for valid arguments when creating the bitmap
	--
	if 0 >= m_Frame.rcClientW or 0 >= m_Frame.rcClientH then return nil end	

	-- create a bitmap wide as the client area
	--
	local memDC = m_Frame.hMemoryDC

	if not memDC then

		local bitmap = wx.wxBitmap(m_Frame.rcClientW, m_Frame.rcClientH)
		
		memDC  = wx.wxMemoryDC()
		memDC:SelectObject(bitmap)
	end

	-- draw the background
	--
	if not m_Frame.hBackDC then return end
	memDC:Blit(0, 0, m_Frame.rcClientW, m_Frame.rcClientH, m_Frame.hBackDC, 0, 0, wx.wxCOPY)

	-- draw the sinc function
	--
	DrawSync(memDC)

	return memDC
end

-- ----------------------------------------------------------------------------
-- create a legenda and a grid
--
local function NewBackground()
	trace.line("NewBackground")
	
	-- check for valid arguments when creating the bitmap
	--
	if 0 >= m_Frame.rcClientW or 0 >= m_Frame.rcClientH then return nil end
	
	-- create a bitmap wide as the client area
	--
	local memDC  = wx.wxMemoryDC()
 	local bitmap = wx.wxBitmap(m_Frame.rcClientW, m_Frame.rcClientH)
	memDC:SelectObject(bitmap)
	
	-- draw a grid
	--
	local iXPos, iXInc = 0, 150
	local iYPos, iYInc = 0, 250
	
	memDC:SetPen(wx.wxPen(m_clrExtra, 1, wx.wxDOT))
	memDC:SetBrush(m_brBack)	

	for i = iXPos, m_Frame.rcClientW, iXInc do
		memDC:DrawLine(i, iYPos, i, m_Frame.rcClientH)
	end
	
	for i = iYPos, m_Frame.rcClientH, iYInc do
		memDC:DrawLine(iXPos, i, m_Frame.rcClientW, i)
	end	

	-- draw the legend
	--
	if not m_Frame.fnText then return memDC end
		
	memDC:SetPen(m_penRect)
	memDC:SetBrush(m_brBack)	

	local iRcLeft = m_Frame.rcClientW - 300
	local iRcTop  = m_Frame.rcClientH - 100

	memDC:DrawRectangle(iRcLeft - 6, iRcTop - 12, 300, 110)
	
	-- draw the legenda
	--
	local tStrings = { }
	
	tStrings[1] = _format("Max Samples [%d]", m_Frame.iMaxSamples)
	tStrings[2] = _format("Interval    [%d]", m_Frame.iTimeIntrvl)
	if m_Frame.hTickTimer then 
		tStrings[3] = "Generator Running"
	else
		tStrings[3] = "Generator Idle"
	end
	
	-- select font and draw the text
	---
	memDC:SetFont(m_Frame.fnText)
	memDC:SetTextForeground(m_clrFore)
	
	-- get the height of text as per the selected font name & size
	-- (add some extra pixels for paragraph spacing)
	--
	local _, iExtY = memDC:GetTextExtent(m_Frame.sFontName)
	
	for i=1, #tStrings do
		
		memDC:DrawText(tStrings[i], iRcLeft, iRcTop)
		iRcTop = iRcTop + iExtY + 6
	end
	
	return memDC
end

-- ----------------------------------------------------------------------------
--
local function RefreshBackground()
	trace.line("RefreshBackground")

	if m_Frame.hBackDC then
		m_Frame.hBackDC:delete()
		m_Frame.hBackDC = nil
	end

	m_Frame.hBackDC = NewBackground()
end

-- ----------------------------------------------------------------------------
--
local function RefreshDrawing()
	trace.line("RefreshDrawing")

	m_Frame.hMemoryDC = NewMemDC()

	if m_Frame.hWindow then
		m_Frame.hWindow:Refresh(false)
	end
end

-- ----------------------------------------------------------------------------
-- regenerate both the offscreen buffers
--
local function RefreshAll()
	trace.line("RefreshAll")

	RefreshBackground()
	RefreshDrawing()
end

-- ----------------------------------------------------------------------------
-- we just splat the off screen dc over the current dc
--
local function OnPaint()
	trace.line("OnPaint")

	if not m_Frame.hWindow then return end

	local dc = wx.wxPaintDC(m_Frame.hWindow)

	dc:Blit(0, 0, m_Frame.rcClientW, m_Frame.rcClientH, m_Frame.hMemoryDC, 0, 0, wx.wxCOPY)
	dc:delete()
end

-- ----------------------------------------------------------------------------
--
local function OnSize(event)
	trace.line("OnSize")

	local size = m_Frame.hWindow:GetClientSize()
	
	m_Frame.rcClientW = size:GetWidth()
	m_Frame.rcClientH = size:GetHeight()
	
	-- here should shift the x0 point a bit to the right
	-- to account for the wasted space remaining at the far right
	--
--	m_2DOriginX	= m_Frame.rcClientW / 2.0
	m_2DOriginY = m_Frame.rcClientH / 2.0
	
	if m_Frame.hMemoryDC then
		m_Frame.hMemoryDC:delete()
		m_Frame.hMemoryDC = nil
	end

	RefreshAll()
end

-- ----------------------------------------------------------------------------
--
local function IsWindowVisible()
	trace.line("IsWindowVisible")

	local wFrame = m_Frame.hWindow
	if not wFrame then return false end

	return wFrame:IsShown()
end

-- ----------------------------------------------------------------------------
-- handle the show window event, starts the timer
--
local function OnShow(event)
	trace.line("OnShow")

	if not m_Frame.hWindow then return end

	-- GetShow() deprecated use IsShown()
	--
	if event:IsShown() then	RefreshAll() end
end

-- ----------------------------------------------------------------------------
--
local function OnClose()
	trace.line("OnClose")

	local wFrame = m_Frame.hWindow
	if not wFrame then return end
	
	-- stop the timer
	--
	if m_Frame.hTickTimer then m_Frame.hTickTimer:Stop() end

	-- finally destroy the window
	--
	wFrame:Destroy(wFrame)
	m_Frame.hWindow = nil
end

-- ----------------------------------------------------------------------------
-- add new values to the readings list
--
local function OnTimer()
	trace.line("OnTimer")

	AddRandomPoint()

	-- refresh only the drawing
	--
	RefreshDrawing()
end

-- ----------------------------------------------------------------------------
-- set the font properties
--
local function SetupFont(inFontSize, inFontName)
	trace.line("SetupFont")  

	-- allocate the requested font name with specified font size
	--
	local fnText = wx.wxFont(inFontSize, wx.wxFONTFAMILY_DEFAULT, wx.wxFONTFLAG_ANTIALIASED,
							wx.wxFONTWEIGHT_NORMAL, false, inFontName, wx.wxFONTENCODING_SYSTEM)

	m_Frame.fnText	  = fnText
	m_Frame.sFontName = inFontName		-- selected font name
	m_Frame.iFontSize = inFontSize		-- selected font size

	if IsWindowVisible() then RefreshAll() end
end

-- ----------------------------------------------------------------------------
-- set the colour properties
--
local function SetupColour(inBack, inFront, inExtra)
	trace.line("SetupColour")

	m_brBack   = wx.wxBrush(inBack, wx.wxSOLID)
	m_clrFore  = inFront
	m_clrExtra = inExtra

	-- this is the colour used for the bounding rectangle
	--
	local colour = wx.wxColour(0xff - inBack:Red(),
							   0xff - inBack:Green(),
							   0xff - inBack:Blue())

	m_penRect = wx.wxPen(colour, 3, wx.wxDOT)

	if IsWindowVisible() then RefreshAll() end
end

-- ----------------------------------------------------------------------------
-- one time initialization of frame's timer
-- toggle the run status if already active
--
local function InstallTimers(inTimeAt)
	trace.line("InstallTimers")

	if not m_Frame.hWindow then return false end
	
	-- check status
	--
	if m_Frame.hTickTimer then
		trace.line("Stop Timer")
			
		m_Frame.hTickTimer:Stop()
		m_Frame.hTickTimer = nil
		return true 
	end

	trace.line("Start Timer")
		
	-- use defult timer interval if interval is too small
	--
	if 50 > inTimeAt then inTimeAt = m_Frame.iTickFrame end
	m_Frame.iTickFrame = inTimeAt
	
	-- create and start a timer object
	--
	m_Frame.hTickTimer = wx.wxTimer(m_Frame.hWindow, wx.wxID_ANY)
	m_Frame.hTickTimer:Start(inTimeAt, false)

	return true
end

-------------------------------------------------------------------------------
--
local function OnRunGenerator()
	trace.line("OnRunGenerator")
	
	-- use default interval
	--
	InstallTimers(m_Frame.iTickFrame)
	
	-- do refresh both the Dcs for displaying the timer status
	--
	RefreshAll()	
end

-------------------------------------------------------------------------------
--
local function CreateFrame()
	trace.line("CreateFrame")
	
	-- create the frame
	--
	local dwMainFlags = wx.wxDEFAULT_FRAME_STYLE | wx.wxCAPTION | wx.wxCLIP_CHILDREN | wx.wxSYSTEM_MENU | wx.wxCLOSE_BOX
	local frame = wx.wxFrame(wx.NULL, wx.wxID_ANY, "Testing GDI drawing",
							 wx.wxPoint(25, 25), 
							 wx.wxSize(2400, 600),
							 dwMainFlags)
						
	-- creta the menu entries
	--
	local rcMnuRandom = UniqueID()

	local mnuFile = wx.wxMenu("", wx.wxMENU_TEAROFF)
	mnuFile:Append(rcMnuRandom,"Simulate readings\tCtrl-G", "Start/Stop samples pump")
	mnuFile:AppendSeparator()	
	mnuFile:Append(wx.wxID_EXIT, "E&xit\tCtrl-X", "Quit the application")

	local mnuHelp = wx.wxMenu("", wx.wxMENU_TEAROFF)
	mnuHelp:Append(wx.wxID_ABOUT, "&About\tCtrl-A", "About the application")

	-- attach the menu
	--
	local menuBar = wx.wxMenuBar()
	menuBar:Append(mnuFile, "&File")
	menuBar:Append(mnuHelp, "&Help")

	-- assign the menubar to this frame
	--
	frame:SetMenuBar(menuBar)

	-- create a statusbar with only 1 pane
	--
	frame:CreateStatusBar(1)

	-- assign event handlers for this frame
	--
	frame:Connect(rcMnuRandom, wx.wxEVT_COMMAND_MENU_SELECTED, OnRunGenerator)
	frame:Connect(wx.wxID_EXIT, wx.wxEVT_COMMAND_MENU_SELECTED, OnClose)

	frame:Connect(wx.wxID_ABOUT, wx.wxEVT_COMMAND_MENU_SELECTED,
		function ()
			wx.wxMessageBox('This is the "About" dialog of the sample.\n'..
							wxlua.wxLUA_VERSION_STRING.." built with "..wx.wxVERSION_STRING,
							"About the sample",
							wx.wxOK + wx.wxICON_INFORMATION,
							frame )
		end)

	-- standard event handlers
	--
--	frame:Connect(wx.wxEVT_SHOW,			OnShow)
	frame:Connect(wx.wxEVT_PAINT,			OnPaint)
	frame:Connect(wx.wxEVT_SIZE,			OnSize)
	frame:Connect(wx.wxEVT_CLOSE_WINDOW,	OnClose)
	frame:Connect(wx.wxEVT_TIMER,			OnTimer)

	-- this is necessary to avoid flickering
	-- wxBG_STYLE_CUSTOM deprecated use wxBG_STYLE_PAINT
	--
	frame:SetBackgroundStyle(wx.wxBG_STYLE_PAINT)
	
	-- assign an icon
	--
	local icon = wx.wxIcon("test.ico", wx.wxBITMAP_TYPE_ICO)
	frame:SetIcon(icon)
	
	return frame
end

-------------------------------------------------------------------------------
--
local function RunApplication()
	trace.line("RunApplication")
	
	-- one time random seed initialization
	--
	m_Random:initialize()
	
	-- compile the sinc table
	-- (if any parameter changes then you must recompile the table)
	--
	m_SincTbl:setup(SincType.eSinc_Fx_Sinc, m_Frame.iMaxSamples, m_Frame.iTimeIntrvl)
	trace.table(m_SincTbl)
	
	-- choose how many values are added at each generator cycle
	-- (for better display use an even value, ie 2 4 12 etc...)
	--
	m_Frame.iRndCycles = 4 -- m_Frame.iTickFrame / m_Frame.iTimeIntrvl
	
	m_Frame.hWindow = CreateFrame()
	if m_Frame.hWindow then
		
		SetupColour(palette.CornflowerBlue, palette.Khaki, palette.LightPink)
		SetupFont(10, "DejaVu Sans Mono")
		
		m_Frame.hWindow:Show(true)
		wx.wxGetApp():MainLoop()
	end

end

-------------------------------------------------------------------------------
-- redirect logging
--
io.output("main_2.log")
trace.enable(false)
	
-- run
--
RunApplication()

-- end
--
io.output():close()

-------------------------------------------------------------------------------
---------------------------------------------------------------------------------



