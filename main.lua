-- PICO-8 Spritesheet Exporter
-- version 1.0
-- (c) by kennstewayne.de
--
-- Extract PICO-8’s project graphics to a separate *.png file
-- Drag & Drop any *.p8 file onto the app window
-- Based on idea from https://github.com/briacp/pico2png
--

function love.load()
	resetProject()
	love.window.setMode(674, 532, {resizable = false})
	love.window.setTitle("PICO-8 PNG Exporter")
	love.window.setIcon(love.image.newImageData("icon.png"))
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	openDialog = love.graphics.newImage("open_dialog.png")
	exportDialog = love.graphics.newImage("export_dialog.png")
	errorDialog = love.graphics.newImage("error_dialog.png")
	confirmDialog = love.graphics.newImage("confirm_dialog.png")
	transparencyFalseCheckbox = love.graphics.newImage("transparency_false_checkbox.png")
	transparencyTrueCheckbox = love.graphics.newImage("transparency_true_checkbox.png")
	grid = love.graphics.newImage("grid.png")
end

function resetProject()
	FILE = nil -- dropped file handle
	FILENAME = nil
	FILEPATH = nil
	FILEFORMAT = nil -- file extension
	SAVEFORMAT = "_spritesheet.png" -- output file suffix
	IMAGE = nil
	PROCESS = nil
	STATUS = 0
	ERROR = false
	transparencyCheckbox = false
end

function love.filedropped(file)
	if not FILE then
		local dir, obj, format = file:getFilename():match("(.-)([^\\/]-%.?([^%.\\/]*))$")
		FILENAME = obj:match("^[^%.\\/]*")
		FILEPATH = dir
		FILEFORMAT = format
		FILE = file
		PROCESS = coroutine.create(generatePreview)
	end
end

function generatePreview(file)
	local evaluateLine = false
	local searchStart = "__gfx__"
	local searchStop = "__gff__"
	local newFile = ""
	local canvas = love.image.newImageData(128, 128)
	local y = 0
	local colors = { -- RGBA
		["0"] = {0,   0,   0,   transparencyCheckbox and 0 or 255}, -- Black Is Transparent
		["1"] = {29,  43,  83,  255},
		["2"] = {128, 37,  83,  255},
		["3"] = {0,   135, 81,  255},
		["4"] = {171, 82,  54,  255},
		["5"] = {95,  87,  79,  255},
		["6"] = {194, 195, 199, 255},
		["7"] = {255, 241, 232, 255},
		["8"] = {255, 0,   77,  255},
		["9"] = {255, 163, 0,   255},
		["a"] = {255, 255, 39,  255},
		["b"] = {0,   231, 86,  255},
		["c"] = {41,  173, 255, 255},
		["d"] = {131, 118, 156, 255},
		["e"] = {255, 119, 168, 255},
		["f"] = {255, 204, 170, 255}
	}
	
	print("Process Pixels...")
	
	for line in file.lines and file:lines() or file:gmatch "[^\n]+" do
		if line:find(searchStop) then
			newFile = newFile..tostring(searchStop)
			searchStop = false
			break
		end
		if evaluateLine then
			local x = 0
			for px in line:gmatch "." do
				canvas:setPixel(x, y, colors[px])
				newFile = newFile..px
				x = x + 1
			    print("x: "..x..", y: "..y, "rgb: "..table.concat(colors[px], ","))
			end
			newFile = newFile.."\n"
			y = y + 1
		else
			if line:find(searchStart) then
				newFile = newFile..tostring(searchStart).."\n"
				searchStart = false
				evaluateLine = true
			end
		end
		STATUS = y / 128 -- progress in percent
		coroutine.yield()
	end
	
	if not (searchStart and searchStop) then
		FILE = newFile
		IMAGE = love.graphics.newImage(canvas)
		print("Spritesheet Generated")
	else
		ERROR = true -- invalid file
		print("Invalid File")
	end
end

function love.draw()
	love.graphics.setBackgroundColor(53, 53, 53)
	love.graphics.setColor(253, 241, 233, 255)
	
	
	if ERROR then
		love.graphics.draw(errorDialog, 212, 178)
	else
		if not FILE then
			love.graphics.draw(openDialog, 132, 85)
		else
			love.graphics.push("all")
			love.graphics.setColor(255, 255, 255, 25)
			love.graphics.draw(grid, 64, 161, 0, 2, 2)
			love.graphics.pop()
			love.graphics.push("all")
			if transparencyCheckbox then
				love.graphics.draw(transparencyTrueCheckbox, 386, 324)
			else
				love.graphics.draw(transparencyFalseCheckbox, 386, 324)
			end
			love.graphics.pop()
			if IMAGE then
				love.graphics.draw(IMAGE, 64, 161, 0, 2, 2)
			end
			love.graphics.draw(exportDialog, 386, 64)
			love.graphics.printf(tostring(FILEPATH..FILENAME..SAVEFORMAT), 386, 222, 226, "left")
			if actionConfirm and actionConfirm + 1.0 > love.timer.getTime() then
				love.graphics.draw(confirmDialog, 125, 123)
			else
				actionConfirm = nil
			end
			
			if coroutine.status(PROCESS) ~= "dead" then
				love.graphics.push("all")
				love.graphics.setColor(127, 122, 155, 255)
				love.graphics.rectangle("fill", 0, 516, STATUS*674, 16)
				love.graphics.pop()
				coroutine.resume(PROCESS, FILE)
			else
				STATUS = 0
			end
		end
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then
		if ERROR then
			if x > 227 and x < 451 and y > 322 and y < 354 then
				print("Error Confirmed")
				resetProject()
			end
		else
			if x > 386 and x < 610 then
				if y > 324 and y < 356 then
					transparencyCheckbox = not transparencyCheckbox -- state flag
					PROCESS = coroutine.create(generatePreview)
					print("Black Is Transparent ("..tostring(transparencyCheckbox)..")")
				end
			
				if y > 380 and y < 412 then
					local file = FILENAME..SAVEFORMAT
					IMAGE:getData():encode("png", file)
					os.execute("mv '"..love.filesystem.getSaveDirectory().."/"..file.."' '"..FILEPATH.."'")
					actionConfirm = love.timer.getTime() -- timer flag
					print("File Saved To "..tostring(FILEPATH..file))
				end
			
				if y > 436 and y < 468 then
					print("Export Canceled")
					resetProject()
				end
			end
		end
	end
end