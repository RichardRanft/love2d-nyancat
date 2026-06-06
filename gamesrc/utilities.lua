-- Utilities
utilities = {};

-- utilities output options
utilities.DEBUG = false;			-- generally only prints function entry with parameters.
utilities.DEBUGCMD = false;			-- prints actual command strings sent used in utilities functions.
utilities.DEBUGLOG = false;			-- true to send to log file, false to log to console.
utilities.DEBUGPARAMS = false;		-- true to log function parameters.
utilities.TIMESTAMP = true;			-- true to add timestamps before each log message.
utilities.LOGACTIVE = false;		-- tracks whether the log system is active
utilities.LOGTIMEFORMAT = "%Y/%m/%d %H:%M:%S"; -- timestamp format

-- internal data
utilities.LOGOUTPUT = {};			-- table containing all log output
utilities.LOGFILENAME = "log.txt";	-- default logfile name
utilities.LOGFILEHANDLE = nil;		-- file handle for the log.
utilities.LOGTOCONSOLE = false;		-- disable log to console

function utilities.indexof(tbl, value)
	for i, v in pairs(tbl) do
		if v == value then
			return i;
		end
	end
	return nil;
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.getOS()
	local separator = package.config:sub(1,1);
	if separator == "/" then 
		return "Linux";
	end
	return "Windows";
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.list_iter(t)
    local i = 0
    local n = utilities.tablelength(t)
    return function()
        i = i + 1
        if i <= n then return t[i] end
    end
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.evalCmdLine(cmdArg, minArgs, maxArgs)
    local listArgs = {};
	if cmdArg == nil then 
		return;
	end
	if utilities.tablelength(cmdArg) > 0 then
		for i = 1, utilities.tablelength(cmdArg), 1 do
			if cmdArg[i] ~= nil then
				listArgs[i] = cmdArg[i];
			end
		end
	end
	if utilities.tablelength(listArgs) < minArgs then
        utilities.logPrint("Too few arguments");
        for i = 1, utilities.tablelength(arg), 1 do
            utilities.logPrint(listArgs[i]);
        end
        return nil;
    end
    if utilities.tablelength(listArgs) >= minArgs and utilities.tablelength(listArgs) > maxArgs then
		utilities.logPrint("Too many arguments");
		for i = 1, utilities.tablelength(listArgs), 1 do
			utilities.logPrint(listArgs[i]);
		end
		return nil;
    end
    return 0;
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.startLog(filename)
	if filename ~= nil then
		utilities.LOGFILENAME = filename;
		local msg, err;
		utilities.LOGFILEHANDLE, msg, err = io.open(filename, "a+");
		if utilities.LOGFILEHANDLE ~= nil then
			utilities.LOGACTIVE = true;
		else
			utilities.LOGTOCONSOLE = true;
			print("utilities.startLog() failed.  LOGTOCONSOLE enabled.");
			print(tostring(err));
			print(tostring(msg));
		end
	end
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.startLogAt(folder, filename)
	local OperatingSystem = utilities.getOS();
	local logfilename = "";
	if OperatingSystem == "Windows" then 
		logfilename = folder .. "\\" .. filename;

		os.execute("if not exist " .. folder .. " mkdir " .. folder);
	else
		logfilename = folder .. "/" .. filename;
		os.execute("if [ ! -d " .. folder .. " ]; then mkdir -p " .. folder .. "; fi");	
	end
	if logfilename ~= nil then
		utilities.LOGFILENAME = logfilename;
		local msg, err;
		utilities.LOGFILEHANDLE, msg, err = io.open(logfilename, "a+");
		if utilities.LOGFILEHANDLE ~= nil then
			utilities.LOGACTIVE = true;
		else
			utilities.LOGTOCONSOLE = true;
			print("utilities.startLog() failed.  LOGTOCONSOLE enabled.");
			print(tostring(err));
			print(tostring(msg));
		end
	end
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.logPrint(msg, fmt)
	local message = tostring(msg);
	local format = utilities.LOGTIMEFORMAT;
	if utilities.LOGTOCONSOLE then
		print(" - " .. os.date(format) .. " " .. message);
	end
	if not utilities.LOGACTIVE then
		return;
	end
    if utilities.LOGACTIVE and utilities.LOGFILEHANDLE ~= nil then
        if utilities.TIMESTAMP then
            table.insert(utilities.LOGOUTPUT, tostring(os.date(format) .. " - " ..  message .. "\n"));
			utilities.LOGFILEHANDLE:write(utilities.LOGOUTPUT[utilities.tablelength(utilities.LOGOUTPUT)]);
        else
            table.insert(utilities.LOGOUTPUT, tostring(message .. "\n"));
			utilities.LOGFILEHANDLE:write(utilities.LOGOUTPUT[utilities.tablelength(utilities.LOGOUTPUT)]);
        end
		utilities.LOGFILEHANDLE:flush();
    else
		local text = ""
        if utilities.TIMESTAMP then
            text = " --- " .. os.date(format) .. " ";
        end
        print(text .. message);
    end
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.closeLog()
	if not utilities.LOGACTIVE then
		return;
	end
	if utilities.LOGFILEHANDLE ~= nil then
		utilities.LOGFILEHANDLE:flush();
		utilities.LOGFILEHANDLE:close();
		utilities.LOGACTIVE = false;
	end
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.dumpLog()
	if utilities.LOGOUTPUT ~= nil then
		local dumpfile = "dump_" .. utilities.LOGFILENAME;
		local logdump =  io.open(dumpfile, "w+");
		if logdump == nil then
			
		else
			for i = 1, utilities.tablelength(utilities.LOGOUTPUT) do
				logdump:write(utilities.LOGOUTPUT[i]);
			end
			logdump:flush();
			logdump:close();
		end
	else
		print(" - No log buffer present.");
	end
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.checkLogFile(fileName)
    local LOGFILEHANDLE = io.open(fileName, "r");
    local result = 0;
    if LOGFILEHANDLE == nil then
        utilities.abort(" --- Error: unable to open log " .. fileName, 1);
	else
		for line in LOGFILEHANDLE:lines() do
			if line ~= nil then
				-- Ok, look for "error" except when it says "0 errors" for shit's sake....
				if string.find(line, "()0 errors()") == nil and string.find(line, "()Error()") ~= nil then
					result = 2;
				end
			end
		end
	end
    return result;
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.dumpOutput(fileHandle, message, filtertbl)
    -- dump command output to console
    if message ~= nil then
        utilities.logPrint(" -- " .. tostring(message));
    end
    local result = 0;
    local errorFound = false;
    for line in fileHandle:lines() do
        if line ~= nil then
			if filtertbl ~= nil then
				for filter in utilities.list_iter(filtertbl) do
					if string.find(line, "()" .. tostring(filter) .. "()") ~= nil then
						utilities.logPrint(tostring(filter) .. " found - ");
						errorFound = true;
						result = 2;
					end
				end
			else
				if string.find(line, "()Error()") ~= nil or string.find(line, "()failed()") ~= nil then
					errorFound = true;
					result = 2;
				end
			end
			if string.find(line, "()%c()") == nil then
				utilities.logPrint(" --- " .. tostring(line));
			end
        end
    end
    return result;
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.checkError(fileHandle, filtertbl)
    -- dump error output to console
    local result = 0;
    local errorFound = false;
	local errmsg = "";
    for line in fileHandle:lines() do
        if line ~= nil then
			if filtertbl ~= nil then
				for filter in utilities.list_iter(filtertbl) do
					if string.find(line, "()" .. tostring(filter) .. "()") ~= nil then
						utilities.logPrint(tostring(filter) .. " found - ");
						errorFound = true;
						result = 2;
						errmsg = line;
					end
				end
			else
				if string.find(line, "()Error()") ~= nil or string.find(line, "()failed()") ~= nil then
					errorFound = true;
					result = 2;
					errmsg = line;
					break;
				end
			end
        end
    end
    if errorFound then
        utilities.logPrint(" --- " .. errmsg);
        utilities.abort(" --- " .. errmsg, result);
    end
    return result;
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.checkResult(result, message)
    if result ~= true and result ~= 0 then
        if message == nil then
            message = " -- empty message: nil";
        end
        utilities.abort(" --- " .. message .. " step failed", result);
    end
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.abort(reason, code)
    utilities.logPrint(reason);
    if utilities.DEBUGLOG and utilities.LOGFILEHANDLE ~= nil then
        utilities.LOGFILEHANDLE:flush();
        utilities.LOGFILEHANDLE:close();
    end

    os.exit(code, true);
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.executeCmd(command)
    if utilities.DEBUGCMD then
        utilities.logPrint(command);
    end
    local handle, msg, err = io.popen(command);
    local result = 0;
    if handle ~= nil then
        if utilities.DEBUGCMD then
            result = utilities.dumpOutput(handle, command);
        else
            result = utilities.checkError(handle);
        end
	else
		utilities.logPrint("Command failed: " .. tostring(err) .. " " .. tostring(msg));
    end
    return result;
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.getFileList(path, filter)
    if path == nil then
        path = "./";
    end
	if filter == nil then
		filter = "*";
	end
    if utilities.DEBUG then
        utilities.logPrint(" -- getFileList(" .. path .. ")");
    end
	local environment = utilities.getOS();
    local command = ""
	if environment == "Linux" then
		command = "ls " .. path .. filter .. " 2>&1";
	else
		command = "dir " .. path .. filter .. " 2>&1";
	end
    if utilities.DEBUGCMD then
        utilities.logPrint(command);
    end
    local handle = io.popen(command);
    local result = 0;
    local fileList = {};
    local i = 1;
    if handle ~= nil then
        for line in handle:lines() do
            if line ~= nil then
                if utilities.DEBUG then
                    utilities.logPrint(" -- " .. line);
                end
                fileList[i] = line;
                i = i + 1;
            end
        end
    end
    return fileList;
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.getFiles(path)
	utilities.logPrint("getFiles(\"" .. path .. "\")...");
	-- want only files, but not "bare" so we can get file dates
	local dirCmd = "if exist " .. path .. " dir /a:-d " .. path .. " 2>&1";
	local OperatingSystem = utilities.getOS();
	if OperatingSystem == "Linux" then
		dirCmd = "ls -l " .. path .. " | awk \'{print $9}\' 2>&1";
	end
	--print(dirCmd);
	local filelist = {};
	local dirs = io.popen(dirCmd);
	if dirs ~= nil then
		if OperatingSystem == "Windows" then
			local currentLine = 0;
			for line in dirs:lines() do
				--print(line);
				currentLine = currentLine + 1;
				if currentLine > 5 then
					local begin = string.sub(line, 1, 2);
					if string.len(line) > 0 and string.find(begin, "%s") == nil then
						local parts = utilities.split(line, "[%.%-_/:%w]+");
						--local partcount = 0;
						--for part in utilities.list_iter(parts) do
							--partcount = partcount + 1;
							--print(tostring(partcount) .. " : " .. part);
						--end
						local file = parts[utilities.tablelength(parts)];
						local fileentry = {};
						if utilities.DEBUG or utilities.DEBUGCMD then
							print(file);
						end
						fileentry["File"] = file;
						fileentry["Path"] = path .. "\\" .. file;
						fileentry["Folder"] = path;
						fileentry["Date"] = parts[1];
						fileentry["Time"] = parts[2] .. " " .. parts[3];
						table.insert(filelist, fileentry);
					end
				end
			end
		else
			for file in dirs:lines() do
				if file ~= nil and string.len(file) > 0 then
					if utilities.DEBUG or utilities.DEBUGCMD then
						print(file);
					end
					local fileentry = {};
					fileentry["File"] = file;
					fileentry["Path"] = path .. file;
					fileentry["Folder"] = path;
					table.insert(filelist, fileentry);
				end
			end
		end
	end
	utilities.logPrint("getFiles() done.");
	return filelist;
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.findFiles(path, filter)
	local filelist = {};
	if utilities.DEBUG or utilities.DEBUGLOG then
		utilities.logPrint("utilities.findFiles(\"" .. path .. "\")...");
	end
	if filter == nil then
		filter = "*";
	end
	-- want only files, but not "bare" so we can get file dates
	local dirCmd = "if exist " .. path .. " dir /a:-d /s " .. path .. "\\" .. filter .. " 2>&1";
	local OperatingSystem = utilities.getOS();
	if OperatingSystem ~= "Windows" then
		dirCmd = "ls -l " .. path .. "/" .. filter .. " | awk '{print $9}' 2>&1";
	end
	--print(dirCmd);
	if utilities.DEBUGLOG then
		utilities.logPrint("utilities.findFiles() - command : " .. tostring(dirCmd));
	end
	local currentPath = "";
	local buffer, msg, err = io.popen(dirCmd);
	if buffer ~= nil then
		if OperatingSystem == "Windows" then
			local currentLine = 0;
			for line in buffer:lines() do
				--print(line);
				currentLine = currentLine + 1;
				if currentLine > 3 and line ~= nil and string.len(line) > 0 then
					if string.find(line, " Directory of ") ~= nil then
						local cpath = string.gsub(line, " Directory of ", "");
						if cpath ~= currentPath then
							currentPath = cpath;
						end
						if utilities.DEBUGLOG then
							utilities.logPrint("Setting current path to " .. tostring(line));
						end
					else
						local begin = string.sub(line, 1, 2);
						if string.len(line) > 0 and string.find(begin, "%s") == nil then
							if utilities.DEBUGLOG then
								utilities.logPrint(tostring(line));
							end
							local parts = utilities.split(line, "[%.%-_/:%w]+");
							--local partcount = 0;
							--for part in utilities.list_iter(parts) do
								--partcount = partcount + 1;
								--print(tostring(partcount) .. " : " .. part);
							--end
							local file = parts[utilities.tablelength(parts)];
							local fileentry = {};
							fileentry["File"] = file;
							fileentry["Path"] = currentPath .. "\\" .. file;
							fileentry["Folder"] = currentPath;
							fileentry["Date"] = parts[1];
							fileentry["Time"] = parts[2] .. " " .. parts[3];
							table.insert(filelist, fileentry);
						end
					end
				end
			end
		else
			for file in buffer:lines() do
				if file ~= nil and string.len(file) > 0 then
					if utilities.DEBUGLOG then
						utilities.logPrint(tostring(file));
					end
					local fileentry = {};
					fileentry["File"] = file;
					fileentry["Path"] = path .. file;
					fileentry["Folder"] = path;
					table.insert(filelist, fileentry);
				end
			end
		end
	else
		utilities.logPrint("Unable to list files in " .. tostring(path));
		utilities.logPrint("Error   : " .. tostring(err));
		utilities.logPrint("Message : " .. tostring(msg));
	end
	if utilities.DEBUG or utilities.DEBUGLOG then
		utilities.logPrint("Found " .. tostring(utilities.tablelength(filelist)) .. " files");
		utilities.logPrint("utilities.findFiles() done.");
	end
	return filelist;
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.getSubDirs(path)
	if utilities.DEBUG then
		utilities.logPrint(" -- getSubDirs(" .. path .. ")");
	end
	local dirCmd = "if exist " .. path .. " dir /a:d " .. path .. " 2>&1";
	if utilities.DEBUG then
		utilities.logPrint(dirCmd);
		utilities.logPrint(" -- get subdirectories for : " .. path);
	end
	local dirlist = {};
	local dirs = io.popen(dirCmd);
	if dirs ~= nil then
		for line in dirs:lines() do
			local begin = string.sub(line, 1, 2);
			if string.len(line) > 0 and string.find(begin, "%s") == nil then
				local parts = utilities.split(line, "[%.%-_/:%w]+");
				local folder = parts[utilities.tablelength(parts)];
				if folder ~= "." and folder ~= ".." then
					local folderInfo = {};
					folderInfo["Folder"] = folder;
					folderInfo["Path"] = path .. "\\" .. folder;
					folderInfo["Date"] = parts[1];
					folderInfo["Time"] = parts[2] .. " " .. parts[3];
					table.insert(dirlist, folderInfo);
					--utilities.logPrint(" -- add folder : " .. line);
				end
			end
		end
	end
	return dirlist;
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.findEXE(name)
	if name == nil then
		utilities.logPrint("param is nil");
		return false;
	end
	local found = true;
	local cmd = "where " .. name .. " 2>&1";
	local handle = io.popen(cmd);
	if handle == nil then
		utilities.logPrint("Unable to execute " .. cmd);
	else
		for line in handle:lines() do
			if string.sub(line, 1, 5) == "INFO:" then
				found = false;
			end
		end
		handle:close();
	end
	return found;
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.wait(seconds)
	local OS = utilities.getOS();
    if seconds == nil then
        utilities.logPrint(" -- wait() - seconds is nil");
        return 29;
    end
    if utilities.DEBUG then
        utilities.logPrint(" -- wait() : " .. seconds);
    end
	local hasSleep = utilities.findEXE("sleep");	
	if OS == "Windows" and hasSleep then
		os.execute("sleep " .. tonumber(seconds));
	else
		local ping = "ping -n " .. seconds .. " localhost";
		if not utilities.DEBUG or utilities.DEBUGCMD or utilities.DEBUGLOG or utilities.DEBUGPARAMS then
			ping = ping .. " > NUL 2>&1";
		end
		if OS == "Linux" then
			ping = "ping -c " .. seconds .. " localhost";
			if not utilities.DEBUG or utilities.DEBUGCMD or utilities.DEBUGLOG or utilities.DEBUGPARAMS then
				ping = ping .. " > /dev/null 2>&1";
			end
		end
		os.execute(ping);
	end
    return 0;
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.split(text, pattern)
    local count = 1;
    local wordList = {};
    if pattern == nil then
        pattern = "[_%w]+"; -- underscore and all alphanumerics
    end
    for w in string.gmatch(text, pattern) do
        wordList[count] = w;
        --print(wordList[count]);
        count = count + 1;
    end
    return wordList;
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.file_exists(name)
	local f = io.open(name,"r")
	if f ~= nil then 
		io.close(f);
		--print("file_exists: " .. name .. " found.");
		return true;
	else 
	--print("file_exists: " .. name .. " not found.");
	end
	return false;
end

-- <param: source> - if path has spaces, include quotes.
-- <param: target> - if path has spaces, include quotes.
-- <param: flags> - Additional flags, like /s, /e, or others.
-- <param: files> - files to include.  Must be "" if you wish to use exclusions.
-- <param: exclusions> - files to exclude.
-- <returns> - true if successful, false if there are errors.
---@diagnostic disable-next-line: duplicate-set-field
function utilities.robocopy(source, target, flags, files, exclusions)
	local opt = " /z /np /njh /xo";
	local needSourceQuotes = (string.find(source, "%w") ~= nil and string.find(source, "()\"()") == nil);
	if needSourceQuotes then
		source = "\"" .. source .. "\"";
	end
	local needTargetQuotes = (string.find(target, "%w") ~= nil and string.find(target, "()\"()") == nil);
	if needTargetQuotes then
		target = "\"" .. target .. "\"";
	end
	local cmd = "robocopy " .. source .. " " .. target;
	if files ~= nil and string.len(files) > 0 then
		cmd = cmd .. " " .. files;
	end
	cmd = cmd .. opt;
	if exclusions ~= nil and string.len(exclusions) > 0 then
		cmd = cmd .. " /xf " .. exclusions;
	end
	cmd = cmd .. " /r:20 ";
	if flags ~= nil then
		cmd = cmd .. flags;
	end
	cmd = cmd .. " 2>&1";
	if utilities.DEBUGCMD then
		utilities.logPrint(cmd);
	end
	local handle, msg, err = io.popen(cmd);
	local buffer = {};
	local success = true;
	if handle ~= nil then
		if msg ~= nil then
			utilities.logPrint(tostring(msg));
		end
		if err ~= nil then --and err >= 4 then
			utilities.logPrint("Robocopy encountered an issue: " .. tostring(err) .. " " .. tostring(msg));
			success = false;
		end
		for line in handle:lines() do
			if utilities.DEBUGCMD then
				utilities.logPrint(tostring(line));
			end
			if string.find(line, "ERROR") ~= nil and string.find(line, "%(0x00") ~= nil then
				local parts = utilities.split(line);
				err = tonumber(parts[8]);
				utilities.logPrint("Robocopy encountered an issue: " .. tostring(err) .. " " .. tostring(line));
				if err >= 2 then
					success = false;
				end
			end
			table.insert(buffer, line);
		end
		handle:close();
	else
		if msg ~= nil then
			utilities.logPrint(tostring(msg));
		end
		if err ~= nil then --and err >= 4 then
			utilities.logPrint("Robocopy encountered an issue: " .. tostring(err) .. " " .. tostring(msg));
			success = false;
		end
		utilities.logPrint("Error copying " .. source .. " to " .. target .. ".");
		os.exit(1, true);
	end
	local status = {};
	for line in utilities.list_iter(buffer) do
		if success then
			if string.find(line, "Files :") ~= nil then
				--print(line);
				utilities.logPrint("-------");
				utilities.logPrint(source ..  " > " .. target);
				local parts = utilities.split(line);
				utilities.logPrint("Total   : " .. tostring(tonumber(parts[2])));
				status["Total"] = tonumber(parts[2]);
				utilities.logPrint("Copied  : " .. tostring(tonumber(parts[3])));
				status["Copied"] = tonumber(parts[3]);
				utilities.logPrint("Skipped : " .. tostring(tonumber(parts[4])));
				status["Skipped"] = tonumber(parts[4]);
				utilities.logPrint("Failed  : " .. tostring(tonumber(parts[6])));
				status["Failed"] = tonumber(parts[6]);
				utilities.logPrint("-------");
			end
		else
			utilities.logPrint(line);
		end
	end
	if not success then
		utilities.logPrint("Robocopy encountered an issue: " .. tostring(err) .. " " .. tostring(msg));
		utilities.logPrint("Error copying " .. source .. " to " .. target .. ".");
	end
	return success, status;
end

-- <param: source> - if path has spaces, include quotes.
-- <param: target> - if path has spaces, include quotes.  May need [user@]host: prefix depending on target.
-- <param: flags> - Additional flags, like /s, /e, or others.
-- <param: files> - files to include.  Must be present (nil, "", or --include filter) if you wish to use exclusions.
-- <param: exclusions> - --exclude filter.
-- <returns> - true if successful, false if there are errors.
---@diagnostic disable-next-line: duplicate-set-field
function utilities.rsync(source, target, flags, files, exclusions)
	local opt = "-lE";
	if flags ~= nil and string.len(flags) > 0 then
		opt = opt .. " " .. flags;
	end
	if utilities.DEBUGCMD then
		opt = opt .. " -v";
	end
	local needSourceQuotes = (string.find(source, "%w") ~= nil and string.find(source, "()\"()") == nil);
	if needSourceQuotes then
		source = "\"" .. source .. "\"";
	end
	local needTargetQuotes = (string.find(target, "%w") ~= nil and string.find(target, "()\"()") == nil);
	if needTargetQuotes then
		target = "\"" .. target .. "\"";
	end
	local cmd = "rsync " .. opt;
	if files ~= nil and string.len(files) > 0 then
		cmd = cmd .. " " .. files;
	end
	if exclusions ~= nil and string.len(exclusions) > 0 then
		cmd = cmd .. " " .. exclusions;
	end
	cmd = cmd .. " " .. source .. " " .. target .. " 2>&1";
	if utilities.DEBUGCMD then
		utilities.logPrint(cmd);
	end
	local handle, msg, err = io.popen(cmd);
	local buffer = {};
	local success = true;
	if handle ~= nil then
		if msg ~= nil then
			utilities.logPrint(tostring(msg));
		end
		if err ~= nil then
			utilities.logPrint("rsync encountered an issue: " .. tostring(err) .. " " .. tostring(msg));
			success = false;
		end
		for line in handle:lines() do
			if utilities.DEBUGCMD then
				utilities.logPrint(tostring(line));
			end
			table.insert(buffer, line);
		end
	else
		if msg ~= nil then
			utilities.logPrint(tostring(msg));
		end
		if err ~= nil then --and err >= 4 then
			utilities.logPrint("rsync encountered an issue: " .. tostring(err) .. " " .. tostring(msg));
			success = false;
		end
		utilities.logPrint("Error copying " .. source .. " to " .. target .. ".");
		os.exit(1, true);
	end
	local status = {};
	for line in utilities.list_iter(buffer) do
		if success then
			if string.find(line, "Files :") ~= nil then
				local parts = utilities.split(line);
				status["Total"] = tonumber(parts[2]);
				status["Copied"] = tonumber(parts[3]);
				status["Skipped"] = tonumber(parts[4]);
				status["Failed"] = tonumber(parts[6]);
				if utilities.DEBUG or utilities.DEBUGCMD then
					print(line);
					utilities.logPrint("-------");
					utilities.logPrint(source ..  " > " .. target);
					utilities.logPrint("Failed  : " .. tostring(status.Total));
					utilities.logPrint("Skipped : " .. tostring(status.Copied));
					utilities.logPrint("Copied  : " .. tostring(status.Skipped));
					utilities.logPrint("Total   : " .. tostring(status.Failed));
					utilities.logPrint("-------");
				end
			end
		else
		end
	end
	if success then
		utilities.logPrint("Success");
		status["result"] = "Success";
	else
		utilities.logPrint("Failure");
		status["result"] = "Failure";
	end
	if not success then
		utilities.logPrint("rsync encountered an issue: " .. tostring(err) .. " " .. tostring(msg));
		utilities.logPrint("Error copying " .. source .. " to " .. target .. ".");
	end
	return success, status;
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.directory_exists( sPath )
	if type( sPath ) ~= "string" then 
		if utilities.DEBUGLOG then
			utilities.logPrint("utilities.directory_exists() - path is not a string");
		end
		return false 
	end

	local response, msg, err = os.execute( "cd " .. sPath )
	if response == nil then
		if utilities.DEBUGLOG then
			utilities.logPrint("utilities.directory_exists() - response is nil");
			utilities.logPrint(tostring(msg));
			utilities.logPrint(tostring(err));
		end
	end
	if response == 0 or response then
		if utilities.DEBUGLOG then
			utilities.logPrint("utilities.directory_exists() - seems to exist");
		end
		return true
	end
	if utilities.DEBUGLOG then
		utilities.logPrint("utilities.directory_exists() - path not found");
	end
	return false
end

---@diagnostic disable-next-line: duplicate-set-field
function utilities.getEnvironment()
	local cmd = "set";
	if utilities.getOS() == "Linux" then
		cmd = "env";
	end
    local handle, msg, err = io.popen(cmd);
	local env = {};
	if handle ~= nil then
		for line in handle:lines() do
			local parts = utilities.split(line, "[^=]+");
			if utilities.tablelength(parts) > 1 then
				local label = parts[1];
				local value = parts[2];
				env[label] = value;
			end
		end
	end
	local keys={};
	local n=0

	for k,v in pairs(env) do
	  n=n+1
	  keys[n]=k
	end
	table.sort(keys);
	return env, keys;
end

return utilities;
