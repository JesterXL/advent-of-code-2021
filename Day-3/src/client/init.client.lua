print("Hello world, from client!")
local TestEZ = require(script.TestEZ)

local testLocations = {
    game.StarterPlayer.StarterPlayerScripts.Client.Day3
}
TestEZ.TestBootstrap:run(testLocations)


