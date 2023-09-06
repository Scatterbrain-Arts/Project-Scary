local ServerScriptService = game:GetService("ServerScriptService")
local Loader = ServerScriptService:FindFirstChild("LoaderUtils", true).Parent
local Packages = require(Loader).bootstrapGame(ServerScriptService.NevermoreEngine)


require(Packages.Puppet)
