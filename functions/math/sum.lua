local aoi = require("aoi")

return aoi.newFunction({
    name = "sum",
    code = function(data)
        local function fixn(str)
            local n = tonumber(str)
            if type(n) == "number" then
                return n
            else
                aoi.log("$sum: Invalid number provided.\nSkipping...", str)
                return 0
            end
        end
        local sums = 0
        for i,v in pairs(aoi.split(data)) do
            sums = sums + fixn(v)
        end
        
        return sums
    end
})