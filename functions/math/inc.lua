return {
    name = "inc",
    code = function(n)
        local numn = tonumber(n)
        if type(numn) == "number" then
            numn = numn + 1
        end
        newn = tostring(numn)
        return newn
    end
}
