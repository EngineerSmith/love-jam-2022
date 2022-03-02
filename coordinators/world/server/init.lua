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
  local nests = {}
  local targets = {}
  
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
              table.insert(nests, {i, j})
              target.nestPos = #nests
            end
          end
          if target.earthquake then
            MONSTERS.addSpawnTile(target.earthquake, i, j)
            if not earthquake[target.earthquake] then
              earthquake[target.earthquake] = {}
            end
            insert(earthquake[target.earthquake], {target, i, j})
          end
        end
      end
      end
      end
    end
  
  coordinator.addTarget = function(i, j)
      table.insert(targets, {i, j})
      return #targets
    end
  
  local calculateDist = function(ax, ay, bx, by)
      local x = bx - ax
      local y = by - by
      return x*x+y*y
    end
  
  local sortInsert = function(array, dist, tbl)
      for index, tar in ipairs(array) do
        if tar[3]+tar[4] > dist+realDist then
          table.insert(array, index, tbl)
          return
        end
      end
      table.insert(array, tbl) -- add to end
    end
  
  local sqrtOne = math.sqrt(1) -- diagonal distance 
  coordinator.getMonsterPath = function(fromI, fromJ)
      local target = nests[love.math.random(1,#nests)]
      local tI, tJ = target[1], target[2]
      local current = {fromI, fromJ} -- calculate dist to goal
      local di, dj = tI - fromI, tJ - fromJ
      local unexplored = {{fromI, fromJ, di*di+dj*dj, 0}}
      while #unexplored ~= 0 do
        local current = unexplored[1]
        table.remove(unexplored, 1)
        local ci, cj = current[1], current[2]
        local currentDist = current[4]
        
        if ci+1 == tI and cj == tJ then
          error("TODO found")
        end
        local a = world[ci+1] and world[ci+1][cj]
        if a and not a.notWalkable then
          local dist = calculateDist(tI, tJ, ci+1, cj)
          sortInsert(unexplored, dist+currentDist+1, {ci+1, cj, dist, currentDist+1})
        else
          a = nil
        end
        if ci-1 == tI and cj == tJ then
          error("TODO found")
        end
        local b = world[ci-1] and world[ci-1][cj]
        if b and not b.notWalkable then
          local dist = calculateDist(tI, tJ, ci-1, cj)
          sortInsert(unexplored, dist+currentDist+1, {ci-1, cj, dist, currentDist+1})
        else
          b = nil
        end
        if ci == tI and cj == tJ+1 then
          error("TODO found")
        end
        local c = world[ci] and world[ci][cj+1]
        if c and not c.notWalkable then
          local dist = calculateDist(tI, tJ, ci, cj+1)
          sortInsert(unexplored, dist+currentDist+1, {ci, cj+1, dist, currentDist+1})
        else
          c = nil
        end
        if ci == tI and cj == tJ-1 then
          error("TODO found")
        end
        local d = world[ci] and world[ci][cj-1]
        if d and not d.notWalkable then
          local dist = calculateDist(tI, tJ, ci, cj-1)
          sortInsert(unexplored, dist+currentDist+1, {ci, cj-1, dist, currentDist+1})
        else
          c = nil
        end
        if a and c then
          if ci+1 == tI and cj+1 == tJ then
            error("TODO found")
          end
          local z = world[ci+1] and world[ci+1][cj+1]
          if z and not z.notWalkable then
            local dist = calculateDist(tI, tJ, ci+1, cj+1)
            sortInsert(unexplored, dist+currentDist+sqrtOne, {ci+1, cj+1, dist, currentDist+sqrtOne})
          end
        end
        if a and d then
          if ci+1 == tI and cj-1 == tJ then
            error("TODO found")
          end
          local z = world[ci+1] and world[ci+1][cj-1]
          if z and not z.notWalkable then
            local dist = calculateDist(tI, tJ, ci+1, cj-1)
            sortInsert(unexplored, dist+currentDist+sqrtOne, {ci+1, cj-1, dist, currentDist+sqrtOne})
          end
        end
        if b and c then
          if ci-1 == tI and cj+1 == tJ then
            error("TODO found")
          end
          local z = world[ci-1] and world[ci-1][cj+1]
          if z and not z.notWalkable then
            local dist = calculateDist(tI, tJ, ci-1, cj+1)
            sortInsert(unexplored, dist+currentDist+sqrtOne, {ci-1, cj+1, dist, currentDist+sqrtOne})
          end
        end
        if b and d then
          if ci-1 == tI and cj-1 == tJ then
            error("TODO found")
          end
          local z = world[ci-1] and world[ci-1][cj-1]
          if z and not z.notWalkable then
            local dist = calculateDist(tI, tJ, ci-1, cj-1)
            sortInsert(unexplored, dist+currentDist+sqrtOne, {ci-1, cj-1, dist, currentDist+sqrtOne})
          end
        end
      end
    end
  
  local speed = 10
  coordinator.triggerEarthquake = function(level)
      if earthquake[level] then
        for _, tile in ipairs(earthquake[level]) do
          for _, client in pairs(network.clients) do
            if client.position then
              if tile[1] == coordinator.getTileAtPixels(client.position.x, client.position.y) then
                require("coordinators.player").movePlayer(client, coordinator.getSpawnPoint())
              end
            end
          end
          if tile[1].height > -2 then
            tile[1].height = -2
            tile[1].notWalkable = true
          end
        end
      end
    end
  -- TODO Move players back to spawn if on tiles as a safe escape
  
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
   
  coordinator.getSpawnPoint = function()
      return 1200, -20
    end
  
  coordinator.getTile = function(i, j)
      if world and world[i] then
        return world[i][j]
      end
    end
  
  coordinator.getTileAtPixels = function(x, y)
      local a = x/32
      local b = y/16
      local i = math.floor(a + b)
      local j = math.floor(a - b)
      if world and world[i] then
        return world[i][j], i, j
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