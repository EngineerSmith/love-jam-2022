local logger = require("util.logger")
local worldGen = require("coordinators.world.server.worldGen")

local network = require("network.server")

local ld = love.data
local insert = table.insert

return function(coordinator)
  
  local world
  local waveNum = nil
  local earthquake = {}
  coordinator.readyUpState = true
  
  coordinator.generateWorld = function()
      world = worldGen()
      local TOWERS = require("coordinators.towers")
      local MONSTERS = require("coordinators.monsters")
      for i=0, #world do
        if world[i] then
      for j=#world[i], 0, -1 do
        local target = world[i][j]
        if target then
          if target.tower then
            local t = TOWERS.towers[target.tower]
            if not t then
              print("CANNOT FIND TOWER ID: "..tostring(target.tower).."(world.server.init.L24)")
            else
              target.health = t.health
              target.maxhealth = t.health
              target.owner = "server"
              target.notWalkable = true
            end
          end
          if target.earthquake then
            MONSTERS.addSpawnTile(target.earthquake, i, j)
            if not earthquake[target.earthquake] then
              earthquake[target.earthquake] = {}
            end
            insert(earthquake[target.earthquake], target)
          end
        end
      end
      end
      end
    end
  
  local speed = 10
  coordinator.triggerEarthquake = function(level)
      if earthquake[level] then
        for _, tile in ipairs(earthquake[level]) do
          if tile.height > -2 then
            tile.height = -2
            tile.notWalkable = true
          end
        end
      end
    end
  
  
  network.addHandler(network.enum.confirmConnection, function(client)
      network.send(client, network.enum.worldData, world)
      network.send(client, network.enum.readyUpState, coordinator.readyUpState, waveNum or "nil")
    end)
  
  network.addHandler(network.enum.disconnect, function(client)
      network.sendAll(network.enum.foreignDisconnect, client.hash)
    end)
  
  coordinator.updateNetwork = function()
      local players = {}
      for clientID, client in pairs(network.clients) do
        if client.hash and client.position then
          client.money = (client.money or 0) + 10
          insert(players, {
              clientID  = client.hash,
              name      = client.name,
              position  = client.position,
              character = client.character,
              money     = client.money,
            })
        end
      end
      network.sendAll(network.enum.foreignPlayers, players)
    end
  
  coordinator.getTile = function(i, j)
      if world and world[i] then
        return world[i][j]
      end
    end
  
  coordinator.notifyTileUpdate = function(i, j)
      local tile = coordinator.getTile(i, j)
      if tile then
        network.sendAll(network.enum.tileUpdate, i, j, tile)
      end
    end
  
  coordinator.itsGoTime = function()
      waveNum = (waveNum or -1) + 1
      network.sendAll(network.enum.readyUpState, true, waveNum)
      coordinator.triggerEarthquake(waveNum)
      --coordinator.readyUpState = false
    end
  
end