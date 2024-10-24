local aoi = {
    variables = {},
    functions = {},
    logs = {}
}


-- Ignore.
table = table or {}

function table.insert(arr, entry)
    arr[#arr+1] = entry
end
--

function aoi.log(header, info)
    aoi.logs[#aoi.logs+1] = (header
    .. "\n"
    .. string.rep("=", 20)
    .. "\n"
    .. info
    .. "\n"
    .. string.rep("=", 20)
    )
    if io then
        local logfile = io.open("aoi-log.txt","w")
        local logstr = ""
        for i,v in pairs(aoi.logs) do
            logstr = logstr .. v .. "\n\n\n"
        end
        logfile:write(logstr)
        logfile:close()
    end
end

function aoi.decode(tbl, indent)
    indent = indent or 0
    local result = ""
    local indentStr = string.rep("    ", indent)

    for k, v in pairs(tbl) do
        local key = type(k) == "string" and string.format("%q", k) or tostring(k)
        if type(v) == "table" then
            result = result .. indentStr .."["..key.."]" .. " = {\n" .. aoi.decode(v, indent + 1) .. indentStr .. "},\n"
        else
            local value = type(v) == "string" and string.format("%q", v) or tostring(v)
            result = result .. indentStr .. "[".. key .."]".. " = " .. value .. ",\n"
        end
    end

    return result
end

function aoi.newFunction(data)
    if type(data) == "table" then
        if (not data.name) or (not data.code) then
            print("[ERROR] Couldn't load a function. Check the logs.")
            aoi.log("[ERROR]: Invalid arguments for function provided.\nAoi Functions require a `name` (string) and `code` (function).", aoi.decode(data))
            return 0
        else
            aoi.functions[data.name] = data;
            return aoi.functions[data.name]
        end
    else
        aoi.log("Invalid data type!", data)
        return 0
    end
end

function aoi.tokenize(str)
    local tokens = {}
    local current_token = ""
    local in_parens = 0
    
    for i = 1, #str do
        local char = str:sub(i, i)
        
        if char == "(" then
            in_parens = in_parens + 1
            current_token = current_token .. char
        elseif char == ")" then
            in_parens = in_parens - 1
            current_token = current_token .. char
            if in_parens == 0 then
                table.insert(tokens, current_token)
                current_token = ""
            end
        else
            current_token = current_token .. char
        end
    end

    if #current_token > 0 then
        table.insert(tokens, current_token)
    end

    return tokens
end

function aoi.hasFunctions(a)
    local hasfuncs = false
    string.gsub(a, "%$(%w+)%(.-%).-$", function(daf)
        if aoi.functions[daf] then
            hasfuncs = true
        end
        return "$(" ..daf.. ")"
    end)
    
    return hasfuncs
end

function aoi.parse(cnt)
    local aoistr = ""
    local tkns = aoi.tokenize(cnt)
    local tokens = {}
    aoi.log("Getting ready to parse.", cnt)
    for index, content in pairs(tkns) do
        aoi.log("Parsing [" ..index.. "]...", content)
        
        tokens[index] = string.gsub(content, "%$(%w+)%((.-)%)$", function(func, incontent)
            
            if aoi.functions[func] then
                output = aoi.functions[func].code(aoi.hasFunctions(incontent) and aoi.parse(incontent) or incontent)
            else
                output = "$" ..func.. "(" .. (aoi.hasFunctions(incontent) and aoi.parse(incontent) or incontent) .. ")"
            end
            
            return output
        end)
        
    end
    if #tokens > 1 then
        for i,v in pairs(tokens) do
            aoistr = aoistr ..v
        end
    else
        aoistr = tokens[1]
    end
    return aoistr
end


function aoi.split(str)
    local res = {}
    for cont in (str..";"):gmatch("(.-);") do
        table.insert(res, cont)
    end
    return res
end

function aoi.getFiles(directory)
    local filesTable = {}
    -- Updating this to LFS later on.
    local files = io.popen('find "' .. directory .. '" -type f -name "*.lua"'):lines()
    for file in files do
        table.insert(filesTable, file)
    end
        return filesTable
end

function aoi.loadFunctions(dir)
    local files = aoi.getFiles(dir)
    local funcs = {}
    for index, file in pairs(files) do
        local func = require(string.sub(file, 1, -5))
        funcs[func.name] = func
    end
    return funcs
end

return aoi
