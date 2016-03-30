if SERVER then return end

local tauntMenu
local currentPage = 1
local TBHoldTime = 0.25
local maxPagesToCreate = 20

-- Colours
local colour_outline = Color(0, 0, 0)
local colour_title = Color(255, 255, 255)
local colour_window = Color(180, 170, 150)
local colour_button = Color(77, 72, 63)
local colour_text = Color(196, 185, 164)
local colour_nav = Color(255, 180, 50)

local font_title = "DermaLarge"

local tableSortMode = 0

local PANEL = {}
local Custom_Button = {}
local tableCopied
local HUNTER_TAUNTS_ORIG
local PROP_TAUNTS_ORIG

if !tableCopied then 
	HUNTER_TAUNTS_ORIG = table.Copy(HUNTER_TAUNTS)
	PROP_TAUNTS_ORIG = table.Copy(PROP_TAUNTS)
	tableCopied = true
end

local tablesSorted = false
local PROP_TAUNTS_NAME = {}
local HUNTER_TAUNTS_NAME = {}
local PROP_TAUNTS_LENGTH = {}
local HUNTER_TAUNTS_LENGTH = {}

local function InSort(tab)

	local tabCount = #tab
    local j
	
	for j = 2, tabCount do
		local k = tab[j]
		local i = j - 1
		while i > 0 and tonumber(tab[i][3]) > tonumber(k[3]) do
			tab[i + 1] = tab[i]
			i = i - 1
		end
		tab[i + 1] = k
	end
	
    return tab
end

local function ForceRebuild(forced)

	if !tablesSorted then
		PROP_TAUNTS_NAME = table.Copy(PROP_TAUNTS_ORIG)
		table.sort(PROP_TAUNTS_NAME, function(a,b) return a[2] > b[2] end)
		HUNTER_TAUNTS_NAME = table.Copy(HUNTER_TAUNTS_ORIG)
		table.sort(HUNTER_TAUNTS_NAME, function(a,b) return a[2] > b[2] end)
		
		PROP_TAUNTS_LENGTH = table.Copy(PROP_TAUNTS_ORIG)
		HUNTER_TAUNTS_LENGTH = table.Copy(HUNTER_TAUNTS_ORIG)
		PROP_TAUNTS_LENGTH = InSort(PROP_TAUNTS_LENGTH)
		HUNTER_TAUNTS_LENGTH = InSort(HUNTER_TAUNTS_LENGTH)
		tablesSorted = true
	end
	if !tauntMenu then tauntMenu = vgui.Create("Taunt_Menu") end
	if forced then
		tauntMenu:RefreshTaunts()
	elseif !timer.Exists("RebuildTauntMenu") then
		timer.Create( "RebuildTauntMenu", 1, 1, function() tauntMenu:RefreshTaunts() end)
	end
	
end
net.Receive("BuildTauntMenu", function() ForceRebuild(false) end)

function PANEL:Init()

	self:SetTall(590 * (ScrH() / 1080))
	self:SetWide(180)
	self:SetPos(ScrW()-180, (ScrH()*0.5) - (self:GetTall()*0.7))
	
	self:DoClose()
	
	self.ForeGround = vgui.Create("DPanel", self)
	self.ForeGround:StretchToParent(3,3,3,3)
	self.ForeGround.Paint = function()
		surface.SetDrawColor(colour_window)
		surface.DrawRect(0, 0, self:GetWide(),self:GetTall())
	end

	self.Title = vgui.Create("DLabel", self.ForeGround)
	self.Title:SetFont(font_title)
	self.Title:SetTextColor(colour_title)
	self.Title:SetText("Taunts")
	self.Title:SizeToContents()
	self.Title:CenterHorizontal()
	self.Title:SetPos(self.Title.x, 10)
	
	
	self.LeftButton = vgui.Create("DButton", self.ForeGround)
	self.LeftButton:SetZPos(0)
	self.LeftButton:SetText("Prev")
	self.LeftButton:SetWide(45)
	self.LeftButton:SetTall(30 * (ScrH() / 1080))
	self.LeftButton:SetTextColor(colour_nav)
	self.LeftButton.Paint = function()
		surface.SetDrawColor(colour_button)
		surface.DrawRect(0, 0, self:GetWide(),self:GetTall())
	end
	self.LeftButton:InvalidateLayout()
	
	self.RightButton = vgui.Create("DButton", self.ForeGround)
	self.RightButton:SetZPos(0)
	self.RightButton:SetText("Next")
	self.RightButton:SetWide(45)
	self.RightButton:SetTall(30 * (ScrH() / 1080))
	self.RightButton:SetTextColor(colour_nav)
	self.RightButton.Paint = function()
		surface.SetDrawColor(colour_button)
		surface.DrawRect(0, 0, self:GetWide(),self:GetTall())
	end
	self.RightButton:InvalidateLayout()

	self.CloseButton = vgui.Create("DButton", self.ForeGround)
	self.CloseButton:SetZPos(0)
	self.CloseButton:SetText("Close")
	self.CloseButton:SetWide(45)
	self.CloseButton:SetTall(30 * (ScrH() / 1080))
	self.CloseButton:SetTextColor(colour_nav)
	self.CloseButton.Paint = function()
		surface.SetDrawColor(colour_button)
		surface.DrawRect(0, 0, self:GetWide(),self:GetTall())
	end
	self.CloseButton:InvalidateLayout()
	
	self.PageLabel = vgui.Create("DLabel", self.ForeGround)
	self.PageLabel:SetZPos(0)
	self.PageLabel:SetFont("DermaDefault")
	self.PageLabel:SetTextColor(colour_title)
	
	self.PageLabel:SetText("Page: 0/0")
	self.PageLabel:SetWide(60)
	self.PageLabel:SetTall(20 * (ScrH() / 1080))
	self.PageLabel.Think = function()
		if self.tauntPages and #self.tauntPages > 0 then
			self.PageLabel:SetText("Page: ".. tostring(currentPage) .. "/" .. tostring(#self.tauntPages) )
		else
			self.PageLabel:SetText("Page: ")
		end
	end
	
	
	self.SortButton =  vgui.Create("DButton", self.ForeGround)
	self.SortButton:SetZPos(0)
	self.SortButton:SetText("Sort")
	self.SortButton:SetWide(90)
	self.SortButton:SetTall(30 * (ScrH() / 1080))
	self.SortButton:SetTextColor(colour_nav)
	self.SortButton.Paint = function()
		surface.SetDrawColor(colour_button)
		surface.DrawRect(0, 0, self:GetWide(),self:GetTall())
	end
	self.SortButton.Think = function()
		local sortText = (tableSortMode == 0 and "Sorted by Date") or (tableSortMode == 1 and "Sorted by Name") or (tableSortMode == 2 and "Sorted by Length") or "Sort"
		self.SortButton:SetText(sortText)
	end
	self.SortButton:InvalidateLayout()
	
	self.ReverseSortButton =  vgui.Create("DButton", self.ForeGround)
	self.ReverseSortButton:SetZPos(0)
	self.ReverseSortButton:SetText("Reverse List")
	self.ReverseSortButton:SetWide(70)
	self.ReverseSortButton:SetTall(30 * (ScrH() / 1080))
	self.ReverseSortButton:SetTextColor(colour_nav)
	self.ReverseSortButton.Paint = function()
		surface.SetDrawColor(colour_button)
		surface.DrawRect(0, 0, self:GetWide(),self:GetTall())
	end
	self.ReverseSortButton:InvalidateLayout()
	
end

--[[
function PANEL:Think()
	local sortText = (tableSortMode == 0 and "Sorted by Date") or (tableSortMode == 1 and "Sorted by Name") or (tableSortMode == 2 and "Sorted by Points") or "Sort"
	self.SortButton:SetText(sortText)
end
--]]

function PANEL:Paint()
	surface.SetDrawColor(colour_button)
	surface.DrawRect(0, 0, self:GetWide(),self:GetTall())
end

function PANEL:DoOpen()
	self.menuOpened = true
	self:SetVisible(true)
	gui.EnableScreenClicker(true)
end

function PANEL:DoClose()
	self.menuOpened = false
	self:SetVisible(false)
	gui.EnableScreenClicker(false)
end

function PANEL:GetVisible()
	return self.menuOpened
end

local numberOfTaunts 
local tauntsPerPage = 11

function PANEL:RefreshTaunts()

	if self:GetVisible() then
	--	self:DoClose()
	end
	
	-- Loop through team's taunts and look for "true" flag, add to taunt table if set.
	local taunts = {}
	if LocalPlayer():Team() == TEAM_HUNTERS then
		for k,v in pairs(HUNTER_TAUNTS) do
			if v[4] == true then
				table.insert(taunts, v)
			end
		end
	elseif LocalPlayer():Team() == TEAM_PROPS then
		for k,v in pairs(PROP_TAUNTS) do
			if v[4] == true then
				table.insert(taunts, v)
			end
		end	
	end

	numberOfTaunts = #taunts

	if numberOfTaunts < 1 then return end

	if self.tauntPages then 
		for k, v in pairs(self.tauntPages) do
			v:Remove()
		end
		table.Empty(self.tauntPages)
	else
		self.tauntPages = {}
	end
	
	local numberOfPages = math.Clamp( math.ceil( numberOfTaunts / tauntsPerPage ), 1, maxPagesToCreate )
	local remainingTaunts = numberOfTaunts - tauntsPerPage + 1 
	currentPage = (numberOfPages >= currentPage and currentPage) or 1
	for i = 1, numberOfPages do
	
		self.tauntPages[i] = vgui.Create("DPanelList", self)
		self.tauntPages[i]:SetWide(150)
		self.tauntPages[i]:SetPos(0, 60)
		self.tauntPages[i]:SetSpacing(5 * (ScrH() / 1080))
		self.tauntPages[i]:SetTall(400 * (ScrH() / 1080))
		self.tauntPages[i]:CenterHorizontal()

		for i2 = numberOfTaunts, remainingTaunts, -1 do
		
			if i2 < 1 then break end
			local currentButton = vgui.Create("Taunt_Button", self)
			currentButton:PopulateButton(taunts[i2])
			self.tauntPages[i]:AddItem(currentButton)
			
		end
		
		numberOfTaunts = numberOfTaunts - tauntsPerPage
		remainingTaunts = math.Clamp(remainingTaunts - tauntsPerPage, 1, 999999) 

		self.tauntPages[i]:SetVisible(i == currentPage)
		
	end

	
	self.CloseButton:CenterHorizontal()
	self.CloseButton:SetPos(self.CloseButton.x, self.tauntPages[1]:GetTall() + (self.LeftButton:GetTall()*2) + 15)
	self.CloseButton.DoClick = function()
		self:DoClose()
	end

	self.LeftButton:SetPos(self.CloseButton.x, self.CloseButton.y)
	self.LeftButton:MoveLeftOf(self.CloseButton, 10)
	self.LeftButton.DoClick = function()

		if currentPage - 1 < 1 then return end

		self.tauntPages[currentPage]:SetVisible(false)
		self.tauntPages[currentPage-1]:SetVisible(true)
		currentPage = currentPage - 1
		
	end

	self.RightButton:SetPos(self.CloseButton.x, self.CloseButton.y)
	self.RightButton:MoveRightOf(self.CloseButton,10)
	self.RightButton.DoClick = function()

		if currentPage + 1 > numberOfPages then return end

		self.tauntPages[currentPage]:SetVisible(false)
		self.tauntPages[currentPage+1]:SetVisible(true)
		currentPage = currentPage +1
		
	end
	
	self.PageLabel:MoveBelow(self.CloseButton, 5)
	self.PageLabel:SetPos( (self:GetWide() / 2) - (self.PageLabel:GetWide() / 2), self.PageLabel.y)
	
	self.SortButton:MoveBelow(self.PageLabel, 5)
	self.SortButton:SetPos(5, self.SortButton.y)
	self.SortButton.DoClick = function()
		SortTaunts()
	end
	
	self.ReverseSortButton:SetPos(self.SortButton.x, self.SortButton.y)
	self.ReverseSortButton:MoveRightOf(self.SortButton, 5)
	self.ReverseSortButton.DoClick = function()
		PROP_TAUNTS = table.Reverse(PROP_TAUNTS)
		HUNTER_TAUNTS = table.Reverse(HUNTER_TAUNTS)
		ForceRebuild(true)
	end
	
end
vgui.Register("Taunt_Menu",PANEL,"DPanel")

function Custom_Button:Init()

	self:SetTall(32 * (ScrH() / 1080))
	self:SetWide(150)
	
end

function Custom_Button:Paint()

	surface.SetDrawColor(colour_button)
	surface.DrawRect(0, 0, self:GetWide(),self:GetTall())
	
end

function Custom_Button:PopulateButton(tauntTable)

	local tText = tauntTable[2] or "???"
	self:SetTextColor(colour_text)
	self:SetText(tText)
	self.DoClick = function()
	
		local ValidTable
		local ValidTaunt = false
		
		if LocalPlayer():Team() == TEAM_HUNTERS then
			ValidTable = HUNTER_TAUNTS
		elseif LocalPlayer():Team() == TEAM_PROPS then
			ValidTable = PROP_TAUNTS
		else
			chat.AddText("You're not even on a team, how did you find this button?")
			self:DoClose()
			return
		end

		for k,v in pairs(ValidTable) do
		
			if table.HasValue(v, tauntTable[1]) then
			
				ValidTaunt = true
				break
				
			end
			
		end
		
		if ValidTaunt then
			net.Start("PlayTaunt")
				net.WriteString(tauntTable[1])
				net.WriteString(tauntTable[3])
			net.SendToServer()
			LocalPlayer().lastTaunt = tauntTable
		else
			chat.AddText("This taunt is not for your team to use!")
			ForceRebuild()
		end
		
		tauntMenu:DoClose()
	end
end
vgui.Register("Taunt_Button",Custom_Button,"DButton")

function SortTaunts()
	tableSortMode = tableSortMode + 1
	if tableSortMode > 2 then tableSortMode = 0 end

	if tableSortMode == 0 then
		PROP_TAUNTS = table.Copy(PROP_TAUNTS_ORIG)
		HUNTER_TAUNTS = table.Copy(HUNTER_TAUNTS_ORIG)
	elseif tableSortMode == 1 then
		PROP_TAUNTS = table.Copy(PROP_TAUNTS_NAME)
		HUNTER_TAUNTS = table.Copy(HUNTER_TAUNTS_NAME)
	elseif tableSortMode == 2 then
		PROP_TAUNTS = table.Copy(PROP_TAUNTS_LENGTH)
		HUNTER_TAUNTS = table.Copy(HUNTER_TAUNTS_LENGTH)
	end
	ForceRebuild(true)
end

hook.Add("Initialize", "InitTauntMenu", function()

	tauntMenu = vgui.Create("Taunt_Menu")
	
end)

local function TauntMenuKey(ply, bind, press)
	if string.find(bind, "+menu_context") then
		if !tauntMenu then ForceRebuild() end
		if (ply:Team() == TEAM_HUNTERS || ply:Team() == TEAM_PROPS) && ply:Alive() then
			if tauntMenu:GetVisible() then
				tauntMenu:DoClose()
			else
				tauntMenu:DoOpen()
			end
		elseif tauntMenu:GetVisible() then
			tauntMenu:DoClose()
		end
	end

end
hook.Add("PlayerBindPress", "HandleTauntMenu", TauntMenuKey)

local function CheckTauntButton()

	if input.IsKeyDown( KEY_F3 ) then
		LocalPlayer().TBReleaseTime = LocalPlayer().TBReleaseTime or 0
		if CurTime() - LocalPlayer().TBReleaseTime < 0.4 then return end
		
		if !tauntMenu then ForceRebuild() end
		
		LocalPlayer().TBPressed = LocalPlayer().TBPressed or 0
					
		if LocalPlayer().TBPressed == 0 then
			LocalPlayer().TBPressTime = LocalPlayer().TBPressTime or CurTime()
			LocalPlayer().TBPressed = 1
		end
		
		if (CurTime() - LocalPlayer().TBPressTime >= TBHoldTime) && !LocalPlayer().TBActivated then
			LocalPlayer().TBActivated = true
			
			if tauntMenu:GetVisible() == false && (LocalPlayer():Team() == TEAM_HUNTERS || LocalPlayer():Team() == TEAM_PROPS) && LocalPlayer():Alive() then
				tauntMenu:DoOpen()
			else
				tauntMenu:DoClose()
			end
			
		end
		
	elseif LocalPlayer().TBPressed == 1 then
		if CurTime() - LocalPlayer().TBPressTime < TBHoldTime then
			if tauntMenu:GetVisible() then
				tauntMenu:DoClose()
			end
			net.Start("RandomTaunt")
			net.SendToServer()
		end
		LocalPlayer().TBPressed = 0
		LocalPlayer().TBActivated = nil
		LocalPlayer().TBPressTime = nil
		LocalPlayer().TBReleaseTime = CurTime()
	end
	
end
hook.Add("Think","TauntPress",CheckTauntButton)

local function TryToClose()
	if tauntMenu then
		if tauntMenu:GetVisible() then
			tauntMenu:DoClose()
		end
	end
end
net.Receive("CloseTauntMenu", TryToClose)

concommand.Add( "lasttaunt",function( ply )

	if !LocalPlayer():Alive() then return end
	
	local tauntTable = LocalPlayer().lastTaunt
	
	if !tauntTable then return end
	
	local ValidTable
	local ValidTaunt = false
	
	if LocalPlayer():Team() == TEAM_HUNTERS then
		ValidTable = HUNTER_TAUNTS
	elseif LocalPlayer():Team() == TEAM_PROPS then
		ValidTable = PROP_TAUNTS
	else
		return
	end

	for k,v in pairs(ValidTable) do
	
		if table.HasValue(v, tauntTable[1]) then
		
			net.Start("PlayTaunt")
				net.WriteString(tauntTable[1])
				net.WriteString(tauntTable[3])
			net.SendToServer()
			
			break
			
		end
		
	end

end)