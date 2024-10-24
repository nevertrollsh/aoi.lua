local aoi = require("aoi")
aoi.functions = aoi.fetchFunctions("./functions")

aoi.parse([[
$print(Hello!)
$print(huh)
]])