local tasks = {}

-- package.config is a special string provided by Lua that contains system-dependent configuration info.
local function ensureFolderExists()
	local isWindows = package.config:sub(1, 1) == "\\"
	if isWindows then
		os.execute("mkdir files >nul 2>nul")
	else
		os.execute("mkdir -p files")
	end
end

-- Get today's file path
local function getTodayFilePath()
	ensureFolderExists()
	local date = os.date("%Y-%m-%d")
	return "files/" .. date .. ".txt"
end

-- Load tasks from file
local function loadTasks()
	local filePath = getTodayFilePath()
	local file = io.open(filePath, "r")
	if not file then
		return
	end
	for line in file:lines() do
		table.insert(tasks, line)
	end
	file:close()
end

-- Save tasks to file
local function saveTasks()
	local filePath = getTodayFilePath()
	local file = io.open(filePath, "w")
	if not file then
		return
	end
	for _, task in ipairs(tasks) do
		file:write(task .. "\n")
	end
	file:close()
end

-- Add a task
local function addTask()
	io.write("Enter task: ")
	local task = io.read()
	table.insert(tasks, "[ ] " .. task)
	saveTasks()
	print("Task added.")
end

-- Colorize
local function colorize(text, colorCode)
	return string.format("\27[%sm%s\27[0m", colorCode, text)
end

local function printTask(i, task)
	local color = "31" -- red
	if task:find("%[x%]") then
		color = "32"
	end
	print(colorize(i .. ". " .. task, color))
end

-- List tasks
local function listTasks()
	for i, task in ipairs(tasks) do
		printTask(i, task)
	end
end

-- Mark task as done
local function markDone()
	listTasks()
	io.write("Enter task number to mark done: ")
	local index = tonumber(io.read())
	if index and tasks[index] then
		tasks[index] = tasks[index]:gsub("%[ %]", "[x]")
		print("Task marked as done.")
	else
		print("Invalid task number.")
	end
end

-- Delete a task
local function deleteTask()
	listTasks()
	io.write("Enter task number to delete: ")
	local index = tonumber(io.read())
	if index and tasks[index] then
		table.remove(tasks, index)
		print("Task deleted.")
	else
		print("Invalid task number.")
	end
end

-- Show only incomplete tasks
local function listRemainingTasks()
	print("\nRemaining Tasks:")
	for i, task in ipairs(tasks) do
		if task:find("%[ %]") then
			printTask(i, task)
		end
	end
end

-- Show only completed tasks
local function listCompletedTasks()
	print("\nCompleted Tasks:")
	for i, task in ipairs(tasks) do
		if task:find("%[x%]") then
			printTask(i, task)
		end
	end
end

-- Edit tasks
local function editTask()
	listTasks()
	io.write("Enter task number to edit: ")
	local index = tonumber(io.read())
	if index and tasks[index] then
		io.write("Current task: " .. tasks[index] .. "\n")
		io.write("Enter new task description: ")
		local newText = io.read()
		local isDone = tasks[index]:find("%[x%]")
		tasks[index] = (isDone and "[x] " or "[ ] ") .. newText
		saveTasks()
		print("Task updated.")
	else
		print("Invalid task number.")
	end
end

local function showMenu()
	print("\n==== To-Do List ====")
	print("1. Add Task")
	print("2. List Tasks")
	print("3. Mark Task as Done")
	print("4. Edit Task")
	print("5. Delete Task")
	print("6. Show Remaining Tasks")
	print("7. Show Completed Tasks")
	print("8. Exit")
	print("====================")
end

-- Main loop
loadTasks()
while true do
	showMenu()
	io.write("Choose an option: ")
	local choice = io.read()
	if choice == "1" then
		addTask()
	elseif choice == "2" then
		listTasks()
	elseif choice == "3" then
		markDone()
	elseif choice == "4" then
		editTask()
	elseif choice == "5" then
		deleteTask()
	elseif choice == "6" then
		listRemainingTasks()
	elseif choice == "7" then
		listCompletedTasks()
	elseif choice == "8" then
		saveTasks()
		break
	else
		print("Invalid choice.")
	end
end
