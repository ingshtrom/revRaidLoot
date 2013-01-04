revLibImport, revRaidLoot, revRaidLootAccount = ...


-- FUNCTION LIST

function revLibImport.Init()

	-- context
	revLibImport.context = UI.CreateContext('revImport_Context')

	-- window
	revLibImport.window = UI.CreateFrame('SimpleWindow', 'revImport_window', revLibImport.context)
	revLibImport.window:SetVisible(false)
	revLibImport.window:SetCloseButtonVisible(true)
	revLibImport.window:SetTitle('revImport')
	revLibImport.window:SetWidth(350)
	revLibImport.window:SetHeight(600)
	revLibImport.window:SetLayer(4)
	revLibImport.window:SetAlpha(1)
	revLibImport.window:SetPoint('CENTER', UIParent, 'CENTER', 500, 0)

	-- csvButton
	revLibImport.csvButton = UI.CreateFrame('RiftButton', 'revImport_csvButton', revLibImport.window)
	revLibImport.csvButton:SetVisible(true)
	revLibImport.csvButton:SetLayer(5)
	revLibImport.csvButton:SetAlpha(1)
	revLibImport.csvButton:SetText('Import as CSV')
	revLibImport.csvButton:SetPoint('BOTTOMCENTER', revLibImport.window, 'BOTTOMCENTER', 0, -50)
	function revLibImport.csvButton.Event:LeftClick()
		revLibImport.ImportCSV()
	end

	--[[
	-- xmlButton
	revLibImport.xmlButton = UI.CreateFrame('RiftButton', 'revImport_xmlButton', revLibImport.window)
	revLibImport.xmlButton:SetVisible(true)
	revLibImport.xmlButton:SetLayer(5)
	revLibImport.xmlButton:SetAlpha(1)
	revLibImport.xmlButton:SetText('Import as XML')
	revLibImport.xmlButton:SetPoint('BOTTOMCENTER', revLibImport.window, 'BOTTOMCENTER', 50, 50)
	function revLibImport.xmlButton.Event:LeftClick()
		revLibImport.ImportXML()
	end
	]]--

	-- textArea
	revLibImport.textArea = UI.CreateFrame('SimpleTextArea', 'revImport_textArea', revLibImport.window)
	revLibImport.textArea:SetVisible(true)
	revLibImport.textArea:SetLayer(5)
	revLibImport.textArea:SetAlpha(1)
	revLibImport.textArea:SetText('Paste the CSV or XML here, \nthen press the appropriate button to import data.')
	revLibImport.textArea:SetWidth(250)
	revLibImport.textArea:SetHeight(400)
	revLibImport.textArea:SetBackgroundColor(0.3, 0.3, 0.3, 1.0)
	revLibImport.textArea:SetBorder(2, 1.0, 1.0, 1.0, 1.0)
	revLibImport.textArea:SetPoint('TOPCENTER', revLibImport.window, 'TOPCENTER', 0, 50)
end

-- a wrapper around string.gsub
function MapSplit(line, sep, func)
	if line[#line] ~= sep then
		line = line .. sep
	end
	line:gsub("'?([^" .. sep .. "]*)'?" .. sep, func)
end

-- @return table that can be merged with the current raid groups saved variable
function revLibImport.ImportCSV()
	local importedRaids = {}

	local current_raid = ''
	local current_group = ''

	local csvString = revLibImport.textArea:GetText()

	MapSplit(csvString, "\r",
		function(part)
			local tp = {}
			MapSplit(part, ",", function(p) MapSplit(p, "'", function(p2) table.insert(tp, p2) end) end)

			if tp[1] == "raid_name" then
				importedRaids[tp[2]] = { main={}, sub={} }
				current_raid = tp[2]
			elseif tp[1] == "group" then
				current_group = tp[2]
			elseif tp[1] ~= nil and tp[2] ~= nil then
				local i = 1
				while i < #tp do
					if current_raid ~= '' and current_group ~= '' then
						importedRaids[current_raid][current_group][tp[i]] = tp[i+1]
					else
						print("There is an error with the format of your CSV import.  Please check it and retry.")
					end
					i = i + 2
				end
			else
				-- do nothing
			end
		end
	)
	for key,value in pairs(importedRaids) do
		revRaidLootAccount.raids[key] = value
		print("Raid Imported: " .. key)
	end
	revRaidLoot.UpdateRaidSelect()
end

-- shows the UI for importing
function revLibImport.DisplayImporter()
	if not revLibImport.window:GetVisible() then
		revLibImport.window:SetVisible(true)
	end
end

revLibImport.Init()
