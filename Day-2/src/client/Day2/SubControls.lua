local SubControls = {}
local Positions = require(script.Parent.Positions)
local input1 = require(script.Parent.input1)
local collection = require(script.Parent.Parent.luafp.collection)
local map = collection.map
local reduce = collection.reduce
local TweenService = game:GetService("TweenService")

function SubControls.reset(config, submarine)
    local deleted = deleteAllParts(config)
    return {
        plots = {},
        showPlots = false,
        autoPilot = false,
        speed = 2,
        currentPlotIndex = nil,
        parts = {},
        submarine = submarine
    }
end

function SubControls.plotCourse(config)
    local deleted = deleteAllParts(config)
    config.plots = Positions.getPositions(input1.getPuzzleInput())
    config.currentPlotIndex = 1
    local reduced = reduce(createPlotPart, { depth = 0, horizontal = 0, aim = 0, index = 0, parts = {} }, config.plots)
    config.parts = reduced.parts
    return config
end

function deleteAllParts(config)
    if config == nil then
        return nil
    end
    if #config.plots > 0 then
        local deletedParts = map(deletePart, config.plots)
        return deletedParts
    else
        return nil
    end
end

function deletePart(position, index)
    local part = game.Workspace["plotPosition_" .. index]
    if part ~= nil then
        part:Destroy()
    end
    return part
end

local Up = "up"
local Down = "down"
local Forward = "forward"

function createPlotPart(acc, position)
    acc.index = acc.index + 1
    if position.direction == Up then
        acc.aim = acc.aim - position.amount
    elseif position.direction == Down then
        acc.aim = acc.aim + position.amount
    elseif position.direction == Forward then
        acc.horizontal = acc.horizontal + position.amount
        acc.depth = acc.depth + (acc.aim * position.amount)
    end
    local vector = Vector3:new(acc.horizontal, acc.depth, 0)
    local newPart = createPart("plotPosition_" .. acc.index, vector)
    table.insert(acc.parts, newPart)
    return acc
end

function createPart(partName, position)
    local part:Part = Instance.new("Part")		-- Create a new part
    part.Name = partName		-- Name the part... hehe
    part.Anchored = true				-- Anchor the part
    part.Parent = game.Workspace		-- Put the part into the Workspace
    part.Shape = Enum.PartType.Ball		-- Give the part a ball shape
    part.Color = Color3.new(1, 1, 1)		-- Set the color to black
    part.Position = position
    return part
end

function SubControls.togglePlots(config)
    config.showPlots = not config.showPlots
    return config
end

function SubControls.previous(config)
    if config.currentPlotIndex - 1 >= 1 and #config.plots > 0 then
        config.currentPlotIndex = config.currentPlotIndex - 1
        return config
    else
        return config
    end
end

function SubControls.next(config)
    if config.currentPlotIndex + 1 <= #config.plots and #config.plots > 0 then
        config.currentPlotIndex = config.currentPlotIndex + 1
        local tween = moveToNext(config)
        return config
    else
        return config
    end
end

function moveToNext(config)
    local part = config.parts[config.currentPlotIndex]
    -- local goal = {}
	-- goal.Position = nextPart.Position
	-- local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, 0, false, 0)
	-- local tween = TweenService:Create(config.submarine, tweenInfo, goal)
	-- tween:Play()

    -- config.submarine:MoveTo(nextPart.Position)

    -- dx = 500 - 0;
    -- dy = 250 - 0;
    -- angle = atan2(dy, dx)

    -- Using the angle, you can decompose your velocity into its x and y components.

    -- xVelocity = velocity * cos(angle);
    -- yVelocity = velocity * sin(angle);

    local velocity = 0.01
    local notThereYet = true
    while notThereYet do
        local currentPosition = config.submarine.PrimaryPart.Position
        local dx = part.Position.X - currentPosition.X
        local dy = part.Position.Y - currentPosition.Y
        local angle = math.atan2(dy, dx)
        local xVelocity = velocity * math.cos(angle)
        local yVelocity = velocity * math.sin(angle)
        local newPosition = Vector3:new(currentPosition.X + xVelocity, currentPosition.Y + yVelocity, currentPosition.Y)
        config.submarine:MoveTo(newPosition)
        wait(0)
        local updatedPosition = config.submarine.PrimaryPart.Position
        if math.abs(part.Position.X - updatedPosition.X) <= 5 and math.abs(part.Position.Y - updatedPosition.Y) <= 5 then
            notThereYet = false
        end
    end

end

function SubControls.toggleAutoPilot(config)
    config.autoPilot = not config.autoPilot
    return config
end

function SubControls.setSpeedSlow(config)
    config.speed = 1
    return config
end

function SubControls.setSpeedMedium(config)
    config.speed = 2
    return config
end

function SubControls.setSpeedFast(config)
    config.speed = 3
    return config
end

return SubControls

