local Config = require "config"
local stasinv = require "@ox_inventory/data/stashes"

local function getNameBeforeColon(name)
    local colonPos = string.find(name, ":")
    if colonPos then
        return string.sub(name, 1, colonPos - 1)
    else
        return name
    end
end
for _, stash in pairs(stasinv) do
	if stash.freezer then
		exports.ox_inventory:registerHook('swapItems', function(payload)
			local toInventory = payload.toInventory
			local fromInventory = payload.fromInventory
			local fromSlot = payload.fromSlot
			local toSlot = payload.toSlot
			local toType = payload.toType
			local fromType = payload.fromType
			if stash.freezer == "normal" then
				if toType == "stash" and getNameBeforeColon(toInventory) == stash.name then
					if not fromSlot.metadata or not fromSlot.metadata.degrade or not fromSlot.metadata.durability then
						if Config.durabilityOnly then
							return false
						end
					end
					if fromSlot.metadata and fromSlot.metadata.durability then
						local metadata = fromSlot.metadata
						
						local sisaDurasi = metadata.durability - os.time()
						if sisaDurasi <= 0 then
							return false
						end
						
						metadata.stash_entry_time = os.time()
						metadata.durability_sisa = sisaDurasi
						metadata.stash_original_degrade = metadata.degrade
						metadata.old_description = metadata.description
						metadata.description = string.format("Slows down the reduction in durability")
						-- Freeze durability dengan set ke nil (seperti kulkas)

						--metadata.durability = nil
						
						SetTimeout(500, function()
							exports.ox_inventory:SetMetadata(toInventory, toSlot, metadata)
						end)
					end
				elseif fromType == "stash" and getNameBeforeColon(fromInventory) == stash.name then
					local metadata = fromSlot.metadata
					if fromSlot.metadata.durability_sisa then
						-- Hitung waktu di stash
						local timeInStash = os.time() - (metadata.stash_entry_time or os.time())
						
						-- Hitung degradasi dengan rate yang diperlambat (5x lebih lambat)
						local originalDegrade = metadata.stash_original_degrade or 1
						local slowRate = 0.42857  -- 0.42857 = 1 menit jadi 2menit20detik
						local degradationInStash = timeInStash * slowRate
						
						-- Hitung sisa durability
						local newSisaDurasi = metadata.durability_sisa - degradationInStash
						
						-- Pastikan tidak negatif
						if newSisaDurasi < 0 then
							newSisaDurasi = 1  -- Minimum 1 detik
						end
						
						-- Kembalikan ke sistem normal
						metadata.durability = os.time() + newSisaDurasi
						metadata.degrade = metadata.stash_original_degrade or 1
						metadata.description = metadata.old_description
						-- Bersihkan data stash
						metadata.stash_entry_time = nil
						metadata.durability_sisa = nil
						metadata.stash_original_degrade = nil
						metadata.old_description = nil
						
						SetTimeout(500, function()
							exports.ox_inventory:SetMetadata(toInventory, toSlot, metadata)
						end)
					end
				end
			elseif stash.freezer == "hard" then
				if toType == "stash" and getNameBeforeColon(toInventory) == stash.name then
					if not fromSlot.metadata or not fromSlot.metadata.degrade or not fromSlot.metadata.durability then
						if Config.durabilityOnly then
							return false
						end
					end
					if fromSlot.metadata and fromSlot.metadata.durability then
						local metadata = fromSlot.metadata
						local sisaDurasi = metadata.durability - os.time()
						local totalDurasi = metadata.degrade * 60
						local old_description = metadata.description
						if sisaDurasi <= 0 then
							return false
						end
						local persen = math.floor((sisaDurasi / totalDurasi) * 100)
						metadata.old_description = metadata.description
						metadata.description = string.format("Durability: %d%%", persen)
						metadata.durability_sisa = sisaDurasi
						metadata.durability = nil
						SetTimeout(500, function()
							exports.ox_inventory:SetMetadata(toInventory, toSlot, metadata)
						end)
					end
				elseif fromType == "stash" and getNameBeforeColon(fromInventory) == stash.name then
					if fromSlot.metadata.durability_sisa then
						local metadata = fromSlot.metadata
						metadata.durability = os.time() + metadata.durability_sisa
						metadata.durability_sisa = nil
						metadata.description = metadata.old_description
						metadata.old_description = nil
						SetTimeout(500, function()
							exports.ox_inventory:SetMetadata(toInventory, toSlot, metadata)
						end)
					end
				end
			end
			return true
		end, {
			print = true,
		})
	end
end


for _, stash in pairs(Config.RegisterFreezer) do
	if stash.freezer then
		exports.ox_inventory:registerHook('swapItems', function(payload)
			local toInventory = payload.toInventory
			local fromInventory = payload.fromInventory
			local fromSlot = payload.fromSlot
			local toSlot = payload.toSlot
			local toType = payload.toType
			local fromType = payload.fromType
			if stash.freezer == "normal" then
				if toType == "stash" and getNameBeforeColon(toInventory) == stash.stashName then
					if not fromSlot.metadata or not fromSlot.metadata.degrade or not fromSlot.metadata.durability then
						if Config.durabilityOnly then
							return false
						end
					end
					if fromSlot.metadata and fromSlot.metadata.durability then
						local metadata = fromSlot.metadata
						local sisaDurasi = metadata.durability - os.time()
						if sisaDurasi <= 0 then
							return false
						end
						metadata.stash_entry_time = os.time()
						metadata.durability_sisa = sisaDurasi
						metadata.stash_original_degrade = metadata.degrade
						metadata.old_description = metadata.description
						metadata.description = string.format("Slows down the reduction in durability")
						--metadata.durability = nil
						
						SetTimeout(500, function()
							exports.ox_inventory:SetMetadata(toInventory, toSlot, metadata)
						end)
					end
				elseif fromType == "stash" and getNameBeforeColon(fromInventory) == stash.stashName then
					local metadata = fromSlot.metadata
					if fromSlot.metadata.durability_sisa then
						local timeInStash = os.time() - (metadata.stash_entry_time or os.time())
						local originalDegrade = metadata.stash_original_degrade or 1
						local slowRate = 0.42857
						local degradationInStash = timeInStash * slowRate
						local newSisaDurasi = metadata.durability_sisa - degradationInStash

						if newSisaDurasi < 0 then
							newSisaDurasi = 1
						end
						
						metadata.durability = os.time() + newSisaDurasi
						metadata.degrade = metadata.stash_original_degrade or 1
						metadata.description = metadata.old_description
						metadata.old_description = nil
						metadata.stash_entry_time = nil
						metadata.durability_sisa = nil
						metadata.stash_original_degrade = nil
						
						SetTimeout(500, function()
							exports.ox_inventory:SetMetadata(toInventory, toSlot, metadata)
						end)
					end
				end
			elseif stash.freezer == "hard" then
				if toType == "stash" and getNameBeforeColon(toInventory) == stash.stashName then
					if not fromSlot.metadata or not fromSlot.metadata.degrade or not fromSlot.metadata.durability then
						if Config.durabilityOnly then
							return false
						end
					end
					if fromSlot.metadata and fromSlot.metadata.durability then
						local metadata = fromSlot.metadata
						local sisaDurasi = metadata.durability - os.time()
						local totalDurasi = metadata.degrade * 60
						local old_description = metadata.description
						if sisaDurasi <= 0 then
							return false
						end
						local persen = math.floor((sisaDurasi / totalDurasi) * 100)
						metadata.old_description = metadata.description
						metadata.description = string.format("Durability: %d%%", persen)
						metadata.durability_sisa = sisaDurasi
						metadata.durability = nil
						SetTimeout(500, function()
							exports.ox_inventory:SetMetadata(toInventory, toSlot, metadata)
						end)
					end
				elseif fromType == "stash" and getNameBeforeColon(fromInventory) == stash.stashName then
					if fromSlot.metadata.durability_sisa then
						local metadata = fromSlot.metadata
						metadata.durability = os.time() + metadata.durability_sisa
						metadata.durability_sisa = nil
						metadata.description = metadata.old_description
						metadata.old_description = nil
						SetTimeout(500, function()
							exports.ox_inventory:SetMetadata(toInventory, toSlot, metadata)
						end)
					end
				end
			end
			return true
		end, {
			print = true,
		})
	end
end