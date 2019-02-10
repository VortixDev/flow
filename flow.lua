-- Implemented to support both Lua and GLua
local include = include or dofile;

flow = {};

flow.assertionFactory = include("assertion_factory.lua");
flow.assert = {
    isBoolean = include("assertions/boolean.lua"),
    isFunction = include("assertions/func.lua"),
    isNumber = include("assertions/number.lua"),
    isString = include("assertions/string.lua"),
    isTable = include("assertions/table.lua")
}

-- The table which houses the exception information
flow.exceptions = {};

--[[
    Returns a table containing the debugging information for each
    stack level, starting at the level of this function and reaching
    up to the last non-nil level.
]]
function flow.getStackInfo(relativeLevel)
    local level = 1 + (relativeLevel or 0);
    
	local levelInfo = debug.getinfo(level, "lnS");
	local stackInfo = {};

	repeat
		table.insert(stackInfo, levelInfo);

		level = level + 1;

		levelInfo = debug.getinfo(level, "lnS");
	until (levelInfo == nil);

	return stackInfo;
end;

--[[
    Returns a string, explaining the stack information in an easily
    understandable way. If no stack info is provided, the current
    stack information will be used.
]]
function flow.getVerboseTrace(stackInfo)
    local logMessage = "Trace:";

    stackInfo = stackInfo or flow.getStackInfo();

    local function getFunctionNameFromLevelInfo(levelInfo)
        if (levelInfo.what == "main") then
            return "Main Execution";
        end;

        if (not levelInfo.name) then
            return "Anonymous Function";
        end;

        return levelInfo.name;
    end;

    for i = 2, #stackInfo do
        local calledLevel = stackInfo[i - 1];
        local currentLevel = stackInfo[i];

        local calledFunctionName = getFunctionNameFromLevelInfo(calledLevel);
        local currentFunctionName = getFunctionNameFromLevelInfo(currentLevel);

        logMessage = logMessage .. "\n\r\t[" .. tostring(i - 1) .. "] " .. calledFunctionName .. " was called by " .. currentFunctionName;

        if (currentLevel.what ~= "C") then
            if (currentLevel.currentline and currentLevel.currentline ~= -1) then
                logMessage = logMessage .. " on line " .. currentLevel.currentline .. " of " .. (currentLevel.short_src or "an unknown file");
            end;

            if (calledLevel.short_src) then
                logMessage = logMessage .. ", and is defined on line " .. (calledLevel.linedefined or "unknown") .. " of " .. (calledLevel.short_src or "an unknown file");
            end;
        end;
    end;

    return logMessage;
end;

--[[
    Throws an error, and adds noteworthy information to the exceptions
    table.
]]
function flow.throw(exceptionType, message, relativeLevel)
    local level = 1 + (relativeLevel or 0);
    
    table.insert(flow.exceptions, {
        type = exceptionType,
        message = message,
        info = flow.getStackInfo(level)
    });

    error("flow:" .. #flow.exceptions .. ": " .. exceptionType .. " - " .. message, 0);
end;

--[[
    Calls the provided function in a protected run, returning a table of
    information on the status of the execution. If the call was a success,
    the status will have the following structure:
    {
        wasSuccess => boolean,
        returns => table
    }
    If execution failed to complete, and the error wasn't generated by this
    library, it will have the following structure:
    {
        isFlowException => false,
        exceptionHeader => string or number
    }
    If execution failed to complete and the error was generated by this library,
    it will have the following structure:
    {
        isFlowException => true,
        exceptionHeader => number,
        exception => table
    }
]]
function flow.protectedCall(executer)
    local callData = { pcall(executer) };
    local status = {};

    status.wasSuccess = callData[1];

    if (status.wasSuccess) then
        table.remove(callData, 1);

        status.returns = callData;

        return status;
    end;

    local errorData = callData[2];
    local exceptionID;

    if (type(errorData) == "string") then
        exceptionID = errorData:match("^flow:([%d+]):");
    end;

    status.isFlowException = exceptionID and true or false;

    -- The value that was passed into the error function to generate the exception
    status.exceptionHeader = errorData;

    if (status.isFlowException) then
        status.exception = flow.exceptions[tonumber(exceptionID)];
    end;

    return status;
end;

--[[
    Attempts to run the primary callback, but runs a secondary callback in the
    case of its failure.
]]
function flow.try(attemptCallback, failureCallback)
    local status = flow.protectedCall(attemptCallback);

    if (status.wasSuccess) then
        return;
    end;

    failureCallback(status.isFlowException, status.isFlowException and status.exception or status.exceptionHeader);
end;

return flow;
