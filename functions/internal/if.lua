local aoi = require("aoi")

function aoi.parseCondition(expr)
    local operators = {
        ["=="] = function(a, b) return a == b end,
        ["~="] = function(a, b) return a ~= b end,
        [">="] = function(a, b) return tonumber(a) >= tonumber(b) end,
        [">"]  = function(a, b) return tonumber(a) > tonumber(b) end,
        ["<="] = function(a, b) return tonumber(a) <= tonumber(b) end,
        ["<"]  = function(a, b) return tonumber(a) < tonumber(b) end
    }
    
    for op, func in pairs(operators) do
        local split_pos = string.find(expr, op)
        if split_pos then
            local left = aoi.parse(string.sub(expr, 1, split_pos - 1))
            local right = aoi.parse(string.sub(expr, split_pos + #op))
            
            left = left:match("^%s*(.-)%s*$")
            right = right:match("^%s*(.-)%s*$")
            
            local left_num = tonumber(left) or left
            local right_num = tonumber(right) or right
            
            return func(left_num, right_num)
        end
    end
    return true
end

return aoi.newFunction({
    name = "if",
    code = function(content)
        local data = aoi.split(content)
        
        local condition, ifBlock, elseBlock = data[1], data[2], data[3]
        
        if aoi.parseCondition(condition) then
            aoi.parse(ifBlock)
        elseif (elseBlock ~= "" or elseBlock ~= nil) then
            aoi.parse(elseBlock)
        end
        
        return ""
    end
})
