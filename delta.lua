local CoreGui = gethui and gethui() or game:GetService("CoreGui")

for _, gui in ipairs(CoreGui:GetChildren()) do
	if gui:IsA("ScreenGui") then
		local isWeird = false
		local name = gui.Name
		for i = 1, #name do
			local c = name:sub(i, i)
			if not c:match("[%w_]") then
				isWeird = true
				break
			end
		end
		if isWeird then
			local hasConsole = false
			for _, obj in ipairs(gui:GetDescendants()) do
				if obj:IsA("GuiObject") and string.find(obj.Name, "Console") then
					hasConsole = true
					break
				end
			end
			if hasConsole then
				for _, obj in ipairs(gui:GetChildren()) do
					if not (obj.Name == "Console" or obj.Name == "Network") then
						obj:Destroy()
					end
				end
			else
				gui:Destroy()
			end
		end
	end
end