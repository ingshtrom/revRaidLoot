revRaidLootAccount = { raids = {} }
revRaidLoot = {}

function revRaidLoot.ClearRaidMembers()
	for i=1,20 do
		revRaidLoot.mainList.names[i]:SetText('N/A')
		revRaidLoot.mainList.values[i]:SetText('N/A')
	end
	for j=1,30 do
		revRaidLoot.subList.names[j]:SetText('N/A')
		revRaidLoot.subList.values[j]:SetText('N/A')
	end
end

-- through SafesRaidManager import raid members
function revRaidLoot.GetRaidFromParty()
	local raidId = revRaidLoot.raidSelect:GetSelectedItem()
	local groupCount = LibSRM.GroupCount()
	local counter = 1
	if groupCount > 0 then
		for i=1,20 do
			local unitID = LibSRM.Group.Inspect(i)
			local currentMember = Inspect.Unit.Detail(unitID)
			if currentMember ~= nil then
				revRaidLoot.mainList.names[counter]:SetText(currentMember.name)
				revRaidLoot.mainList.values[counter]:SetText('0')
				counter = counter + 1
			end
		end
	else
		print("Could not find anyone in your group/raid!")
	end
end

function revRaidLoot.LoadRaid()
  local raidId = revRaidLoot.raidSelect:GetSelectedItem()
	local i, j = 1, 1
	if raidId ~= nil then
		revRaidLoot.currentRaid = raidId
		for key, value in pairs(revRaidLootAccount.raids[raidId].main) do
			revRaidLoot.mainList.names[i]:SetText(key)
			revRaidLoot.mainList.values[i]:SetText(value)
			i = i + 1
		end
		for key, value in pairs(revRaidLootAccount.raids[raidId].sub) do
			revRaidLoot.subList.names[j]:SetText(key)
			revRaidLoot.subList.values[j]:SetText(value)
			j = j + 1
		end
		while i <= 20 do
			revRaidLoot.mainList.names[i]:SetText('N/A')
			revRaidLoot.mainList.values[i]:SetText('N/A')
			i = i + 1
		end
		while j <= 30 do
			revRaidLoot.subList.names[j]:SetText('N/A')
			revRaidLoot.subList.values[j]:SetText('N/A')
			j = j + 1
		end
		--print("Raid Loaded: " .. raidId)
	else
		print("There is no raid to load!!")
	end
end

function revRaidLoot.DeleteRaid()
	local raidId = revRaidLoot.raidSelect:GetSelectedItem()
	if raidId ~= nil and raidId ~= 'Select...' and raidId ~= '' then
		revRaidLootAccount.raids[raidId] = nil
		print("Raid Deleted: " .. raidId)
		revRaidLoot.currentRaid = nil
		revRaidLoot.UpdateRaidSelect()
	else
		print('You must first select a raid to delete!')
	end
	revRaidLoot.ClearRaidMembers()
end

function revRaidLoot.UpdateRaidSelect()
	local localRaidNames = {}
	if next(revRaidLootAccount) ~= nil and next(revRaidLootAccount) ~= nil then
		for k,v in pairs(revRaidLootAccount.raids) do
			table.insert(localRaidNames, k)
		end
	else
		revRaidLootAccount = { raids = {} }
	end
	revRaidLoot.raidSelect:SetItems(localRaidNames)
	revRaidLoot.raidSelect:SetSelectedItem(revRaidLoot.currentRaid)
end

function revRaidLoot.NewRaid()
	local raidId = revRaidLoot.newRaidTextfield:GetText()
	if revRaidLootAccount.raids ~= nil then
		revRaidLootAccount.raids[raidId] = { main = {}, sub = {} }
		revRaidLoot.currentRaid = raidId
		print("New Raid Created: " .. raidId)
	else
		revRaidLootAccount.raids = {}
		revRaidLootAccount.raids[raidId] = { main = {}, sub = {} }
		revRaidLoot.currentRaid = raidId
		print("New Raid Created: " .. raidId)
	end
	revRaidLoot.UpdateRaidSelect()
	revRaidLoot.LoadRaid()
end

function revRaidLoot.UpdateMembers()
	revRaidLoot.raidSelect:SetSelectedItem(revRaidLoot.currentRaid)
	local raidId = revRaidLoot.raidSelect:GetSelectedItem()
	for i=1,20 do
		local memberName = revRaidLoot.mainList.names[i]:GetText()
		local memberValue = revRaidLoot.mainList.values[i]:GetText()
		if memberName ~= nil and memberName ~= 'N/A' and revRaidLoot.mainList.checkboxes[i]:GetChecked() then
			revRaidLootAccount.raids[raidId].main[memberName] = memberValue
		end
	end
	for i=1,30 do
		local memberName = revRaidLoot.subList.names[i]:GetText()
		local memberValue = revRaidLoot.subList.values[i]:GetText()
		if memberName ~= nil and memberName ~= 'N/A' and revRaidLoot.subList.checkboxes[i]:GetChecked() then
			revRaidLootAccount.raids[raidId].sub[memberName] = memberValue
		end
	end
	revRaidLoot.LoadRaid()
end

function revRaidLoot.DeleteMembers()
	revRaidLoot.raidSelect:SetSelectedItem(revRaidLoot.currentRaid)
	local raidId = revRaidLoot.raidSelect:GetSelectedItem()
	for i=1,20 do
		local memberName = revRaidLoot.mainList.names[i]:GetText()
		local memberValue = revRaidLoot.mainList.values[i]:GetText()
		if memberName ~= nil and memberName ~= '' and revRaidLoot.mainList.checkboxes[i]:GetChecked() then
			revRaidLootAccount.raids[raidId].main[memberName] = nil
			print("Deleted: " .. memberName)
		end
	end
	for i=1,30 do
		local memberName = revRaidLoot.subList.names[i]:GetText()
		local memberValue = revRaidLoot.subList.values[i]:GetText()
		if memberName ~= nil and memberName ~= '' and revRaidLoot.subList.checkboxes[i]:GetChecked() then
			revRaidLootAccount.raids[raidId].sub[memberName] = nil
			print("Deleted: " .. memberName)
		end
	end
	revRaidLoot.LoadRaid()
end

--[[
	@param string list_name : "main" or "sub" to represent the list type
	@param boolean select : true => select all, false => deselect all
]]--
function revRaidLoot.BatchSelect(list_name, select)
	for key,value in pairs(revRaidLoot[list_name.."List"].checkboxes) do
		value:SetChecked(select)
	end
end

--[[
	@param string list_name : "main" or "sub" to represent the list type
]]--
function revRaidLoot.BatchUpdate(list_name)
	local updateValue = revRaidLoot.batchUpdateTextfield:GetText()
	for key,value in pairs(revRaidLoot[list_name.."List"].values) do
		local currentValue = value:GetText()
		if currentValue ~= nil and currentValue ~= 'N/A' then
			currentValue = currentValue + updateValue
			value:SetText(tostring(currentValue))
		end
	end
end

-- init the main window
function revRaidLoot.initMain()
	-- begin : init local vars
	local X = 50
	local Y = 60
	-- end : init local vars

  -- begin : initialize the main window
  revRaidLoot.window:SetVisible(false)
  revRaidLoot.window:SetCloseButtonVisible(true)
  revRaidLoot.window:SetWidth(revRaidLoot.config.width)
  revRaidLoot.window:SetHeight(revRaidLoot.config.height)
  revRaidLoot.window:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	revRaidLoot.window:SetTitle("revRaidLoot")
	revRaidLoot.window:SetLayer(1)
	revRaidLoot.window:SetAlpha(1)
	-- end : init revRaidLoot.main

  -- BEGIN row 1
  -- init the raidDropdown menu
  revRaidLoot.raidSelect:SetVisible(true)
	revRaidLoot.raidSelect:SetBackgroundColor(0.0, 0.0, 0.0, 1.0)
  revRaidLoot.raidSelect:SetLayer(3)
  revRaidLoot.raidSelect:SetAlpha(1)
  revRaidLoot.raidSelect:SetWidth(150)
  revRaidLoot.raidSelect:SetHeight(20)
  revRaidLoot.raidSelect:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)
  X = X + 165

  -- init the loadRaid button
  revRaidLoot.loadRaidButton:SetVisible(true)
  revRaidLoot.loadRaidButton:SetText('Load Raid')
  revRaidLoot.loadRaidButton:SetLayer(2)
  revRaidLoot.loadRaidButton:SetAlpha(1)
  revRaidLoot.loadRaidButton:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)
	function revRaidLoot.loadRaidButton.Event:LeftClick()
		revRaidLoot.LoadRaid()
	end
  X = X + 130

  -- init the saveRaid button
  revRaidLoot.saveRaidButton:SetVisible(true)
  revRaidLoot.saveRaidButton:SetText('Save Raid')
  revRaidLoot.saveRaidButton:SetLayer(2)
  revRaidLoot.saveRaidButton:SetAlpha(1)
  revRaidLoot.saveRaidButton:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)
	function revRaidLoot.saveRaidButton.Event:LeftClick()
		-- select all of the members, and then update them all
		revRaidLoot.BatchSelect("main", true)
		revRaidLoot.BatchSelect("sub", true)
		revRaidLoot.UpdateMembers()
	end
  X = X + 130

  -- init the deleteRaid button
  revRaidLoot.deleteRaidButton:SetVisible(true)
  revRaidLoot.deleteRaidButton:SetText('Delete Raid')
  revRaidLoot.deleteRaidButton:SetLayer(2)
  revRaidLoot.deleteRaidButton:SetAlpha(1)
  revRaidLoot.deleteRaidButton:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)
	function revRaidLoot.deleteRaidButton.Event:LeftClick()
		revRaidLoot.DeleteRaid()
	end
  -- END row 1
  X = 50
  Y = Y + revRaidLoot.config.rowSize

  -- BEGIN row 2
  -- init the NewRaidTextfield
  revRaidLoot.newRaidTextfield:SetVisible(true)
  revRaidLoot.newRaidTextfield:SetText('Enter new raid name here...')
  revRaidLoot.newRaidTextfield:SetLayer(2)
  revRaidLoot.newRaidTextfield:SetAlpha(1)
  revRaidLoot.newRaidTextfield:SetWidth(150)
	revRaidLoot.newRaidTextfield:SetBackgroundColor(0.0, 0.0, 0.0, 0.4)
  revRaidLoot.newRaidTextfield:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)
  X = X + revRaidLoot.config.colSize

  -- init the NewRaidButton
  revRaidLoot.newRaidButton:SetVisible(true)
	revRaidLoot.newRaidButton:SetText('New Raid')
  revRaidLoot.newRaidButton:SetLayer(2)
  revRaidLoot.newRaidButton:SetAlpha(1)
  revRaidLoot.newRaidButton:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)
	function revRaidLoot.newRaidButton.Event:LeftClick()
		revRaidLoot.NewRaid()
	end
	X = X + revRaidLoot.config.colSize

	-- init the importRaidButton
	revRaidLoot.importRaidButton:SetVisible(true)
	revRaidLoot.importRaidButton:SetText("Import Raid")
	revRaidLoot.importRaidButton:SetLayer(2)
	revRaidLoot.importRaidButton:SetAlpha(1)
	revRaidLoot.importRaidButton:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)
	function revRaidLoot.importRaidButton.Event:LeftClick()
		revRaidLoot.GetRaidFromParty()
	end
	function revRaidLoot.importRaidButton.Event:RightClick()
		revLibImport.DisplayImporter()
	end
  -- ROW 2 end
  X = 120
  Y = Y + revRaidLoot.config.rowSize + revRaidLoot.config.rowSize

	-- BEGIN mainScrollView
	-- config the headers
	revRaidLoot.listHeaders[1] = UI.CreateFrame('Text', 'revRaidLoot_mainListHeader', revRaidLoot.window)
	revRaidLoot.listHeaders[1]:SetVisible(true)
	revRaidLoot.listHeaders[1]:SetFontSize(revRaidLoot.config.fontSize)
	revRaidLoot.listHeaders[1]:SetText("Main Raid Members")
	revRaidLoot.listHeaders[1]:ResizeToText()
	revRaidLoot.listHeaders[1]:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)

	X = X + revRaidLoot.config.scrollWidth

	revRaidLoot.listHeaders[2] = UI.CreateFrame('Text', 'revRaidLoot_subListHeader', revRaidLoot.window)
	revRaidLoot.listHeaders[2]:SetVisible(true)
	revRaidLoot.listHeaders[2]:SetFontSize(revRaidLoot.config.fontSize)
	revRaidLoot.listHeaders[2]:SetText("Substitute Raid Members")
	revRaidLoot.listHeaders[2]:ResizeToText()
	revRaidLoot.listHeaders[2]:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)

	X = 52.5
	Y = Y + revRaidLoot.config.rowSize + 10

	-- config the frame that will hold the members of the raid
	revRaidLoot.mainList.frame = UI.CreateFrame('Frame', 'revRaidLoot_mainListFrame', revRaidLoot.mainScrollView)
	revRaidLoot.mainList.frame:SetVisible(true)
	revRaidLoot.mainList.frame:SetLayer(2)
	revRaidLoot.mainList.frame:SetAlpha(1)
	revRaidLoot.mainList.frame:SetHeight(610)

	-- config the mainScrollView
	revRaidLoot.mainScrollView:SetShowScrollbar(true)
	revRaidLoot.mainScrollView:SetHeight(revRaidLoot.config.scrollHeight)
	revRaidLoot.mainScrollView:SetWidth(revRaidLoot.config.scrollWidth)
	revRaidLoot.mainScrollView:SetBorder(2, 1, 1, 1, 1)
	revRaidLoot.mainScrollView:SetContent(revRaidLoot.mainList.frame)
	revRaidLoot.mainScrollView:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)

	for i=1,20 do
		innerY = i * 30 - 20
		innerX = 10

		revRaidLoot.mainList.checkboxes[i] = UI.CreateFrame('SimpleCheckbox', 'DKPTmemberCheckbox.main'..i, revRaidLoot.mainList.frame)
		revRaidLoot.mainList.checkboxes[i]:SetVisible(true)
		revRaidLoot.mainList.checkboxes[i]:SetLabelPos('right')
		revRaidLoot.mainList.checkboxes[i]:SetText('')
		revRaidLoot.mainList.checkboxes[i]:SetWidth(150)
		revRaidLoot.mainList.checkboxes[i]:SetPoint("TOPLEFT", revRaidLoot.mainList.frame, "TOPLEFT", innerX, innerY)

		innerX = innerX + 15

		revRaidLoot.mainList.names[i] = UI.CreateFrame('RiftTextfield', 'DKPTmemberName.main'..i, revRaidLoot.mainList.frame)
		revRaidLoot.mainList.names[i]:SetVisible(true)
		revRaidLoot.mainList.names[i]:SetText('N/A')
		revRaidLoot.mainList.names[i]:SetWidth(140)
		revRaidLoot.mainList.names[i]:SetBackgroundColor(0.0, 0.0, 0.0, 0.3)
		revRaidLoot.mainList.names[i]:SetPoint("TOPLEFT", revRaidLoot.mainList.frame, "TOPLEFT", innerX, innerY)

		innerX = innerX + 155

		revRaidLoot.mainList.values[i] = UI.CreateFrame('RiftTextfield', 'DKPTmemberValue.main'..i, revRaidLoot.mainList.frame)
		revRaidLoot.mainList.values[i]:SetVisible(true)
		revRaidLoot.mainList.values[i]:SetLayer(2)
		revRaidLoot.mainList.values[i]:SetAlpha(1)
		revRaidLoot.mainList.values[i]:SetBackgroundColor(0.0, 0.0, 0.0, 0.3)
		revRaidLoot.mainList.values[i]:SetText('N/A')
		revRaidLoot.mainList.values[i]:SetWidth(50)
		revRaidLoot.mainList.values[i]:SetPoint("TOPLEFT", revRaidLoot.mainList.frame, "TOPLEFT", innerX, innerY)
	end
	-- END mainScrollView

	X = X + revRaidLoot.config.scrollWidth + 20

	-- BEGIN subScrollView
	-- config the frame that holds the substitute raid members
	revRaidLoot.subList.frame = UI.CreateFrame('Frame', 'revRaidLoot_subListFrame', revRaidLoot.subScrollView)
	revRaidLoot.subList.frame:SetVisible(true)
	revRaidLoot.subList.frame:SetLayer(2)
	revRaidLoot.subList.frame:SetAlpha(1)
	revRaidLoot.subList.frame:SetHeight(910)

	-- config the scroll view
	revRaidLoot.subScrollView:SetShowScrollbar(true)
	revRaidLoot.subScrollView:SetHeight(revRaidLoot.config.scrollHeight)
	revRaidLoot.subScrollView:SetWidth(revRaidLoot.config.scrollWidth)
	revRaidLoot.subScrollView:SetBorder(2, 1, 1, 1, 1)
	revRaidLoot.subScrollView:SetContent(revRaidLoot.subList.frame)
	revRaidLoot.subScrollView:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)

	for i=1,30 do
		innerY = i * 30 - 20
		innerX = 10

		revRaidLoot.subList.checkboxes[i] = UI.CreateFrame('SimpleCheckbox', 'DKPTmemberCheckbox.sub'..i, revRaidLoot.subList.frame)
		revRaidLoot.subList.checkboxes[i]:SetVisible(true)
		revRaidLoot.subList.checkboxes[i]:SetLabelPos('right')
		revRaidLoot.subList.checkboxes[i]:SetText('')
		revRaidLoot.subList.checkboxes[i]:SetWidth(10)
		revRaidLoot.subList.checkboxes[i]:SetPoint("TOPLEFT", revRaidLoot.subList.frame, "TOPLEFT", innerX, innerY)

		innerX = innerX + 15

		revRaidLoot.subList.names[i] = UI.CreateFrame('RiftTextfield', 'DKPTmemberName.sub'..i, revRaidLoot.subList.frame)
		revRaidLoot.subList.names[i]:SetVisible(true)
		revRaidLoot.subList.names[i]:SetText('N/A')
		revRaidLoot.subList.names[i]:SetWidth(140)
		revRaidLoot.subList.names[i]:SetBackgroundColor(0.0, 0.0, 0.0, 0.3)
		revRaidLoot.subList.names[i]:SetPoint("TOPLEFT", revRaidLoot.subList.frame, "TOPLEFT", innerX, innerY)

		innerX = innerX + 155

		revRaidLoot.subList.values[i] = UI.CreateFrame('RiftTextfield', 'DKPTmemberValue.sub'..i, revRaidLoot.subList.frame)
		revRaidLoot.subList.values[i]:SetVisible(true)
		revRaidLoot.subList.values[i]:SetLayer(2)
		revRaidLoot.subList.values[i]:SetAlpha(1)
		revRaidLoot.subList.values[i]:SetBackgroundColor(0.0, 0.0, 0.0, 0.3)
		revRaidLoot.subList.values[i]:SetText('N/A')
		revRaidLoot.subList.values[i]:SetWidth(50)
		revRaidLoot.subList.values[i]:SetPoint("TOPLEFT", revRaidLoot.subList.frame, "TOPLEFT", innerX, innerY)
	end
	-- END subScrollView

	X = 140
	Y = Y + revRaidLoot.config.scrollHeight + revRaidLoot.config.rowSize

	-- BEGIN batch select buttons
	revRaidLoot.mainSelectAllButton:SetVisible(true)
	revRaidLoot.mainSelectAllButton:SetLayer(2)
	revRaidLoot.mainSelectAllButton:SetAlpha(1)
	revRaidLoot.mainSelectAllButton:SetText('Select All')
	revRaidLoot.mainSelectAllButton:SetPoint('TOPLEFT', revRaidLoot.window, "TOPLEFT", X, Y)
	function revRaidLoot.mainSelectAllButton.Event:LeftClick()
		revRaidLoot.BatchSelect("main", true)
	end

	X = X + revRaidLoot.config.colSize

	revRaidLoot.subSelectAllButton:SetVisible(true)
	revRaidLoot.subSelectAllButton:SetLayer(2)
	revRaidLoot.subSelectAllButton:SetAlpha(1)
	revRaidLoot.subSelectAllButton:SetText('Select All')
	revRaidLoot.subSelectAllButton:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)
	function revRaidLoot.subSelectAllButton.Event:LeftClick()
		revRaidLoot.BatchSelect("sub", true)
	end

	X = 140
	Y = Y + revRaidLoot.config.rowSize

	revRaidLoot.mainDeselectAllButton:SetVisible(true)
	revRaidLoot.mainDeselectAllButton:SetLayer(2)
	revRaidLoot.mainDeselectAllButton:SetAlpha(1)
	revRaidLoot.mainDeselectAllButton:SetText('Deselect All')
	revRaidLoot.mainDeselectAllButton:SetPoint('TOPLEFT', revRaidLoot.window, "TOPLEFT", X, Y)
	function revRaidLoot.mainDeselectAllButton.Event:LeftClick()
		revRaidLoot.BatchSelect("main", false)
	end

	X = X + revRaidLoot.config.colSize

	revRaidLoot.subDeselectAllButton:SetVisible(true)
	revRaidLoot.subDeselectAllButton:SetLayer(2)
	revRaidLoot.subDeselectAllButton:SetAlpha(1)
	revRaidLoot.subDeselectAllButton:SetText('Deselect All')
	revRaidLoot.subDeselectAllButton:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)
	function revRaidLoot.subDeselectAllButton.Event:LeftClick()
		revRaidLoot.BatchSelect("sub", false)
	end

	revRaidLoot.BatchSelect("main", true)
	revRaidLoot.BatchSelect("sub", true)
	-- END batch select buttons

	X = 140
	Y = Y + revRaidLoot.config.rowSize

	-- BEGIN batch update buttons and textfield
	revRaidLoot.mainBatchUpdateButton:SetVisible(true)
	revRaidLoot.mainBatchUpdateButton:SetLayer(2)
	revRaidLoot.mainBatchUpdateButton:SetAlpha(1)
	revRaidLoot.mainBatchUpdateButton:SetText('Batch Update')
	revRaidLoot.mainBatchUpdateButton:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)
	function revRaidLoot.mainBatchUpdateButton.Event:LeftClick()
		revRaidLoot.BatchUpdate("main")
	end

	X = X + 200

	revRaidLoot.subBatchUpdateButton:SetVisible(true)
	revRaidLoot.subBatchUpdateButton:SetLayer(2)
	revRaidLoot.subBatchUpdateButton:SetAlpha(1)
	revRaidLoot.subBatchUpdateButton:SetText('Batch Update')
	revRaidLoot.subBatchUpdateButton:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)
	function revRaidLoot.subBatchUpdateButton.Event:LeftClick()
		revRaidLoot.BatchUpdate("sub")
	end

	X = X - 70
	Y = Y + 10

	revRaidLoot.batchUpdateTextfield:SetVisible(true)
	revRaidLoot.batchUpdateTextfield:SetLayer(2)
	revRaidLoot.batchUpdateTextfield:SetAlpha(1)
	revRaidLoot.batchUpdateTextfield:SetWidth(70)
	revRaidLoot.batchUpdateTextfield:SetBackgroundColor(0.0, 0.0, 0.0, 0.4)
	revRaidLoot.batchUpdateTextfield:SetText('Batch Value')
	revRaidLoot.batchUpdateTextfield:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)
	-- END batch update buttons and textfield

	X = 140
	Y = Y + revRaidLoot.config.rowSize + revRaidLoot.config.rowSize - 10 -- get rid of the small offset from the previous increment of Y

	-- begin ROW 23
  -- init the deleteMembersButton
  revRaidLoot.updateMembersButton:SetVisible(true)
  revRaidLoot.updateMembersButton:SetText('Update')
  revRaidLoot.updateMembersButton:SetLayer(2)
  revRaidLoot.updateMembersButton:SetAlpha(1)
  revRaidLoot.updateMembersButton:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)
	function revRaidLoot.updateMembersButton.Event:LeftClick()
		revRaidLoot.UpdateMembers()
	end
  X = X + revRaidLoot.config.colSize

  -- init the deleteMembersButton
  revRaidLoot.deleteMembersButton:SetVisible(true)
  revRaidLoot.deleteMembersButton:SetText('Delete')
  revRaidLoot.deleteMembersButton:SetLayer(2)
  revRaidLoot.deleteMembersButton:SetAlpha(1)
  revRaidLoot.deleteMembersButton:SetPoint("TOPLEFT", revRaidLoot.window, "TOPLEFT", X, Y)
	function revRaidLoot.deleteMembersButton.Event:LeftClick()
		revRaidLoot.DeleteMembers()
	end
  -- END ROW 23


	-- init the tooltip UI element
	revRaidLoot.tooltip:SetVisible(false)
	revRaidLoot.tooltip:SetLayer(20)
	revRaidLoot.tooltip:SetAlpha(1)
	revRaidLoot.tooltip:SetFontSize(revRaidLoot.config.fontSize)
		-- add the revRaidLoot.tooltip to all of the elements
	--revRaidLoot.tooltip:InjectEvents(revRaidLoot.raidSelect, function() return "Choose your raid from the dropdown" end)		-- not working
	revRaidLoot.tooltip:InjectEvents(revRaidLoot.loadRaidButton, function() return "Load the raid selected from the dropdown to the left." end)
	revRaidLoot.tooltip:InjectEvents(revRaidLoot.deleteRaidButton, function() return "Delete the raid selected from the dropdown to the left." end)
	revRaidLoot.tooltip:InjectEvents(revRaidLoot.newRaidTextfield, function() return "Enter the name of a new raid that you want to create." end)
	revRaidLoot.tooltip:InjectEvents(revRaidLoot.newRaidButton, function() return "Create a new raid with the name that is in the textfield to the left." end)
	revRaidLoot.tooltip:InjectEvents(revRaidLoot.importRaidButton, function() return "Left Click: Gather's all of the players in your raid group and puts them in your currently selected raid ( whatever is selected by the dropdown above ). Right Click: Open up the CSV importer window.  WARNING: This can overwrite currently selected raid data!" end)
	revRaidLoot.tooltip:InjectEvents(revRaidLoot.mainSelectAllButton, function() return "Check all of the main raid members for update/delete." end)
	revRaidLoot.tooltip:InjectEvents(revRaidLoot.subSelectAllButton, function() return "Check all of the substitute raid members for update/delete." end)
	revRaidLoot.tooltip:InjectEvents(revRaidLoot.mainDeselectAllButton, function() return "Uncheck all of the main raid members for update/delete." end)
	revRaidLoot.tooltip:InjectEvents(revRaidLoot.subDeselectAllButton, function() return "Uncheck all of the substitute raid members for update/delete." end)
	revRaidLoot.tooltip:InjectEvents(revRaidLoot.mainBatchUpdateButton, function() return "Update all main raid member values by the amount in the textfield to the right." end)
	revRaidLoot.tooltip:InjectEvents(revRaidLoot.batchUpdateTextfield, function() return "Enter the amount you want to update a raid's values by." end)
	revRaidLoot.tooltip:InjectEvents(revRaidLoot.subBatchUpdateButton, function() return "Update all substitute raid member values by the amount in the textfield to the left." end)
	revRaidLoot.tooltip:InjectEvents(revRaidLoot.updateMembersButton, function() return "Update the value for each raid member that has a check next to their name.  Empty member rows will not be affected." end)
	revRaidLoot.tooltip:InjectEvents(revRaidLoot.deleteMembersButton, function() return "Delete members that have a check next to their name.  Empty member rows will not be affected." end)
	-- end tooltip stuff
end

function revRaidLoot.initSlashCommands()
	-- register slash command handler
	-- begin table.insert(...)
	table.insert(Command.Slash.Register('rrl'), {
		function(args)
			if (args == nil or args == "") and not revRaidLoot.window:GetVisible() then
				revRaidLoot.window:SetVisible(true)
			elseif (args == nil or args == "") and revRaidLoot.window:GetVisible() then
				print("I am not opening up the window again! It is already visible!!")
			else
				print("The only command available is /rrl")
			end
			revRaidLoot.UpdateRaidSelect()
		end,
	"revRaidLoot", 'revRaidLoot_OnSlash'}) -- end table.insert(...)
end

function revRaidLoot.init()
	-- begin : init object vars
	revRaidLoot.Config = {
			addon = "revRaidLoot",
			version = "2.2.0"}
	revRaidLoot.currentRaid = ''
	-- windows and context
	revRaidLoot.context = UI.CreateContext('revRaidLoot_Context')
	revRaidLoot.config = {
			width = 625,
			height = 700,
			rowSize = 30,
			colSize = 200,
			scrollHeight = 300,
			scrollWidth = 250,
			fontSize = 14}
	revRaidLoot.window = UI.CreateFrame('SimpleWindow', 'revRaidLoot_window', revRaidLoot.context)
	-- parts of the main (buttons, text input, etc)
	revRaidLoot.raidSelect = UI.CreateFrame('SimpleSelect', 'revRaidLoot_raidSelect', revRaidLoot.window)
	revRaidLoot.loadRaidButton = UI.CreateFrame('RiftButton', 'revRaidLoot_loadRaidButton', revRaidLoot.window)
	revRaidLoot.saveRaidButton = UI.CreateFrame('RiftButton', 'revRaidLoot_saveRaidButton', revRaidLoot.window)
	revRaidLoot.deleteRaidButton = UI.CreateFrame('RiftButton', 'revRaidLoot_deleteRaidButton', revRaidLoot.window)
	revRaidLoot.newRaidTextfield = UI.CreateFrame('RiftTextfield', 'revRaidLoot_newRaidTextfield', revRaidLoot.window)
	revRaidLoot.newRaidButton = UI.CreateFrame('RiftButton', 'revRaidLoot_newRaidButton', revRaidLoot.window)
	revRaidLoot.importRaidButton = UI.CreateFrame('RiftButton', 'revRaidLoot_importRaidButton', revRaidLoot.window)
	revRaidLoot.listHeaders = {}
	revRaidLoot.mainScrollView = UI.CreateFrame('SimpleScrollView', 'revRaidLoot_mainScrollView', revRaidLoot.window)
	revRaidLoot.subScrollView = UI.CreateFrame('SimpleScrollView', 'revRaidLoot_subScrollView', revRaidLoot.window)
	revRaidLoot.mainList = { frame = {}, checkboxes = {}, names = {}, values = {} }
	revRaidLoot.subList = { frame = {}, checkboxes = {}, names = {}, values = {} }
	revRaidLoot.mainSelectAllButton = UI.CreateFrame('RiftButton', 'revRaidLoot_mainSelectAllButton', revRaidLoot.window)
	revRaidLoot.subSelectAllButton = UI.CreateFrame('RiftButton', 'revRaidLoot_subSelectAllButton', revRaidLoot.window)
	revRaidLoot.mainDeselectAllButton = UI.CreateFrame('RiftButton', 'revRaidLoot_mainDeselectAllButton', revRaidLoot.window)
	revRaidLoot.subDeselectAllButton = UI.CreateFrame('RiftButton', 'revRaidLoot_subDeselectAllButton', revRaidLoot.window)
	revRaidLoot.mainBatchUpdateButton = UI.CreateFrame('RiftButton', 'revRaidLoot_mainBatchUpdateButton', revRaidLoot.window)
	revRaidLoot.batchUpdateTextfield = UI.CreateFrame('RiftTextfield', 'revRaidLoot_batchUpdateTextfield', revRaidLoot.window)
	revRaidLoot.subBatchUpdateButton = UI.CreateFrame('RiftButton', 'revRaidLoot_subBatchUpdateButton', revRaidLoot.window)
	revRaidLoot.updateMembersButton = UI.CreateFrame('RiftButton', 'revRaidLoot_updateMembersButton', revRaidLoot.window)
	revRaidLoot.deleteMembersButton = UI.CreateFrame('RiftButton', 'revRaidLoot_deleteMembersButton', revRaidLoot.window)
	-- revRaidLoot.tooltip
	revRaidLoot.tooltip = UI.CreateFrame('SimpleTooltip', 'revRaidLoot_tooltip', revRaidLoot.window)
	-- end : init object vars
end -- end revRaidLoot.init()

-- init the windows
revRaidLoot.init()	-- init the variables for the UI
revRaidLoot.initMain() -- config the main window
revRaidLoot.initSlashCommands()	-- init the slash commands
-- display a welcome message
print("revRaidLoot loaded successfully")
print("Version: " .. revRaidLoot.Config.version)
print("Use /rrl to start using!")
