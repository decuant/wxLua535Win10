-------------------------------------------------------------------------------
--
-- Test the random number generator
--

local wx		= require("wx")
local random	= require("random")
local palette	= require("wxX11Palette")

local _format	= string.format

-------------------------------------------------------------------------------
--
local frMainWindow	= nil
local grRandom		= nil
local randomizer	= random.new()
local iMaxCols		= 10
local iMaxRows		= 30

-- ----------------------------------------------------------------------------
-- Generate a unique new wxWindowID
--
local iRCEntry = wx.wxID_HIGHEST + 1

local function UniqueID()

	iRCEntry = iRCEntry + 1
	return iRCEntry
end

-------------------------------------------------------------------------------
--
local function OnRunGenerator()
	
	for iRow=0, iMaxRows - 1 do
		for iCol=0, iMaxCols - 1 do
			grRandom:SetCellValue(iRow, iCol, _format("%.3f", randomizer:get()))
		end
	end
	
end

-------------------------------------------------------------------------------
--
local function CreateFrame()

	-- create the frame
	--
	local frame = wx.wxFrame(wx.NULL, wx.wxID_ANY, "Testing the Grid control",
							 wx.wxPoint(25, 25), 
							 wx.wxSize(1550, 1100))
						
	-- creta the menu entries
	--
	local rcMnuRandom = UniqueID()

	local mnuFile = wx.wxMenu("", wx.wxMENU_TEAROFF)
	mnuFile:Append(rcMnuRandom,"Generator\tCtrl-G", "Generate random numbers")
	mnuFile:AppendSeparator()	
	mnuFile:Append(wx.wxID_EXIT, "E&xit\tCtrl-X", "Quit the application")

	local mnuHelp = wx.wxMenu("", wx.wxMENU_TEAROFF)
	mnuHelp:Append(wx.wxID_ABOUT, "&About\tCtrl-A", "About the application")

	-- attach the menu
	--
	local menuBar = wx.wxMenuBar()
	menuBar:Append(mnuFile, "&File")
	menuBar:Append(mnuHelp, "&Help")

	-- assign the menubar to this frame)
	--
	frame:SetMenuBar(menuBar)

	-- create a statusbar with only 1 pane
	--
	frame:CreateStatusBar(1)

	-- assign event handlers for this frame
	--
	frame:Connect(rcMnuRandom, wx.wxEVT_COMMAND_MENU_SELECTED, OnRunGenerator)
	frame:Connect(wx.wxID_EXIT, wx.wxEVT_COMMAND_MENU_SELECTED, function(event) frame:Close() end)

	frame:Connect(wx.wxID_ABOUT, wx.wxEVT_COMMAND_MENU_SELECTED,
		function (event)
			wx.wxMessageBox('This is the "About" dialog of the sample.\n'..
							wxlua.wxLUA_VERSION_STRING.." built with "..wx.wxVERSION_STRING,
							"About the sample",
							wx.wxOK + wx.wxICON_INFORMATION,
							frame )
		end)

	-- create the grid and set common properties
	-- (size specified won't matter, the grid will fill all the client area)
	--
	local grid = wx.wxGrid(frame, wx.wxID_ANY, wx.wxDefaultPosition, wx.wxSize(80, 140))

	grid:CreateGrid(iMaxRows, iMaxCols)
	grid:SetMargins(5, 5)
	grid:SetLabelTextColour(palette.DarkSlateGray4)
	grid:SetGridLineColour(palette.Red4)
	grid:SetDefaultColSize(140, false)
	
	-- create attributes for cells
	--
	local fntCol = wx.wxFont( 10, wx.wxFONTFAMILY_MODERN, wx.wxFONTFLAG_ANTIALIASED,
							  wx.wxFONTWEIGHT_LIGHT, false, "Lucida Sans Unicode")

	local attrOdd  = wx.wxGridCellAttr(palette.Gray0, palette.Gray94, fntCol, wx.wxALIGN_CENTRE, wx.wxALIGN_CENTRE)
	local attrEven = wx.wxGridCellAttr(palette.Gray0, palette.Gray98, fntCol, wx.wxALIGN_CENTRE, wx.wxALIGN_CENTRE)
	
	-- make alternating colors for all columns
	--
	for i=0, iMaxCols, 2 do
		grid:SetColAttr(i, attrOdd)
		grid:SetColAttr(i + 1, attrEven)
	end
	
	-- store grid handle
	--
	grRandom = grid

	-- assign an icon
	--
	local icon = wx.wxIcon("test.ico", wx.wxBITMAP_TYPE_ICO)
	frame:SetIcon(icon)
	
	return frame
end

-------------------------------------------------------------------------------
--
local function RunApplication()
	
	randomizer:initialize()

	frMainWindow = CreateFrame()
	if frMainWindow then
		
		frMainWindow:Show(true)
		wx.wxGetApp():MainLoop()
	end
end

-------------------------------------------------------------------------------
--
RunApplication()

-------------------------------------------------------------------------------
---------------------------------------------------------------------------------



