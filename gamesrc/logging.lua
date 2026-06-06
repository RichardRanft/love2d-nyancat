require "utilities"

logging = {};

logging.LOGACTIVE = false;
logging.LOGFILEPATH = "logfile.lua.log";
logging.LOGTOCONSOLE = true;
logging.LOGOUTPUT = {};
logging.TIMESTAMP = true;
logging.DATETIMEFORMAT = "%Y/%m/%d %H:%M:%S";

logging.LOGLEVEL = 4;
logging.LOGLEVELS = {};
table.insert(logging.LOGLEVELS, "ERROR");
table.insert(logging.LOGLEVELS, "WARNING");
table.insert(logging.LOGLEVELS, "INFO");
table.insert(logging.LOGLEVELS, "DEBUG");

function logging.checkScriptName(scriptname)
    if scriptname == nil then
        return "logging.lua";
    else
        return scriptname;
    end
end

function logging.ERROR(msg, scriptname)
    if logging.LOGLEVEL < 1 then
        return;
    end
    scriptname = logging.checkScriptName(scriptname);
    logging.logPrint(tostring(msg), 1, scriptname);
end

function logging.WARNING(msg, scriptname)
    if logging.LOGLEVEL < 2 then
        return;
    end
    scriptname = logging.checkScriptName(scriptname);
    logging.logPrint(tostring(msg), 2, scriptname);
end

function logging.INFO(msg, scriptname)
    if logging.LOGLEVEL < 3 then
        return;
    end
    scriptname = logging.checkScriptName(scriptname);
    logging.logPrint(tostring(msg), 3, scriptname);
end

function logging.DEBUG(msg, scriptname)
    if logging.LOGLEVEL < 4 then
        return;
    end
    scriptname = logging.checkScriptName(scriptname);
    logging.logPrint(tostring(msg), 4, scriptname);
end

---@diagnostic disable-next-line: duplicate-set-field
function logging.logPrint(msg, loglevel, scriptname)
	local message = tostring(msg);
	local format = logging.DATETIMEFORMAT;
	if logging.LOGTOCONSOLE then
        local outstr = "[" .. logging.LOGLEVELS[loglevel] .. "] [" .. scriptname .. "] : " .. message;
		print(outstr);
	end
    local logmessage = tostring(msg);
    if logging.TIMESTAMP then
        logmessage = "[" .. os.date(format) .. "] [" .. logging.LOGLEVELS[loglevel] .. "] [" .. scriptname .. "] : " .. tostring(msg);
    else
        logmessage = "[" .. logging.LOGLEVELS[loglevel] .. "] [" .. scriptname .. "] : " .. tostring(msg);
    end
	if not logging.LOGACTIVE then
		return;
	end
    if logging.LOGACTIVE then
        table.insert(logging.LOGOUTPUT, tostring(logmessage .. "\n"));
        love.filesystem.append(logging.LOGFILEPATH, logging.LOGOUTPUT[utilities.tablelength(logging.LOGOUTPUT)]);
    else
		local text = ""
        if logging.TIMESTAMP then
            text = " --- " .. os.date(format) .. " ";
        end
        print(text .. message);
    end
end

return logging;