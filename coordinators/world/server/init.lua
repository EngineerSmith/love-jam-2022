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
  coordinator.nests = {}
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
          target.i, target.j = i, j
          if target.tower then
            local t = TOWERS.towers[target.tower]
            if not t then
              print("CANNOT FIND TOWER ID: "..tostring(target.tower).."(world.server.init.L24)")
            else
              target.health = t.health
              target.maxhealth = t.health
              target.owner = "server"
              target.notWalkable = true
              table.insert(coordinator.nests, target)
              target.nestPos = #coordinator.nests
            end
          end
          if target.earthquake then
            MONSTERS.addSpawnTile(target.earthquake, target)
            if not earthquake[target.earthquake] then
              earthquake[target.earthquake] = {}
            end
            insert(earthquake[target.earthquake], {target, i, j})
          end
        end
      end
      end
      end
      MONSTERS.prepareSpawnTiles()
    end
  
  coordinator.addTarget = function(tile)
      table.insert(targets, tile)
      require("coordinators.monsters").prepareSpawnTiles()
      return #targets
    end
  
  local calculateDist = function(a, b)
    local i = b.i - a.i
    local j = b.j - a.j
    return i*i+j*j
  end

  local popBestNode = function(set, score)
    local best, node = math.huge, nil
    for k, v in pairs(set) do
      local s = score[k]
      if s < best then
        best, node = s, k
      end
    end
    if not node then 
      node = next(set)
    end
    if not node then
      logger.errror("WTF")
    end
    set[node] = nil
    return node
  end

  local getNode = function(i, j)
    return world[i] and world[i][j]
  end

  local sO = math.sqrt(1)
  local towerCost = 12
  local getNeighbours = function(node)
    local nodes, costs, i = {}, {}, 1
    local a = getNode(node.i-1, node.j)
    if a then
      local extraCost = 0
      if a.notWalkable then
        if a.tower then
          extraCost = towerCost
        else
          a = nil
          goto continuea
        end
      end
      nodes[i] = a
      costs[i] = 1 + extraCost
      i = i +1
      if extraCost == towerCost then
        a = nil
      end 
    end
    ::continuea::
    local b = getNode(node.i+1, node.j)
    if b then
      local extraCost = 0
      if b.notWalkable then
        if b.tower then
          extraCost = towerCost
        else
          b = nil
          goto continueb
        end
      end
      nodes[i] = b
      costs[i] = 1 + extraCost
      i = i + 1
      if extraCost == towerCost then
        b = nil
      end 
    end
    ::continueb::
    local c = getNode(node.i, node.j+1)
    if c then
      local extraCost = 0
      if c.notWalkable then
        if c.tower then
          extraCost = towerCost
        else
          c = nil
          goto continuec
        end
      end
      nodes[i] = c
      costs[i] = 1 + extraCost
      i = i + 1
      if extraCost == towerCost then
        c = nil
      end 
    end
    ::continuec::
    local d = getNode(node.i, node.j-1)
    if d then
      local extraCost = 0
      if d.notWalkable then
        if d.tower then
          extraCost = towerCost
        else
          d = nil
          goto continued
        end
      end
      nodes[i] = d
      costs[i] = 1 + extraCost
      i = i + 1
      if extraCost == towerCost then
        d = nil
      end 
    end
    ::continued::
    if a and c then
      local z = getNode(node.i-1,node.j+1)
      if z then
        local extraCost = 0
        if z.notWalkable then
          if z.tower then
            extraCost = towerCost
          else
            goto continuee
          end
        end
        nodes[i] = z
        costs[i] = sO + extraCost
        i = i + 1
      end
    end
    ::continuee::
    if a and d then
      local z = getNode(node.i-1,node.j-1)
      if z then
        local extraCost = 0
        if z.notWalkable then
          if z.tower then
            extraCost = towerCost
          else
            goto continuef
          end
        end
        nodes[i] = z
        costs[i] = sO + extraCost
        i = i + 1
      end
    end
    ::continuef::
    if b and c then
      local z = getNode(node.i+1,node.j+1)
      if z then
        local extraCost = 0
        if z.notWalkable then
          if z.tower then
            extraCost = towerCost
          else
            goto continueg
          end
        end
        nodes[i] = z
        costs[i] = sO + extraCost
        i = i + 1
      end
    end
    ::continueg::
    if b and d then
      local z = getNode(node.i+1,node.j-1)
      if z then
        local extraCost = 0
        if z.notWalkable then
          if z.tower then
            extraCost = towerCost
          else
            goto continueh
          end
        end
        nodes[i] = z
        costs[i] = sO + extraCost
        i = i + 1
      end
    end
    ::continueh::
    return nodes, costs
  end

  local unwindPath
  unwindPath = function(map, current, flat)
    flat = flat or {}
    if map[current] then
      local this = map[current]
      table.insert(flat, 1, this)
      return unwindPath(map, this, flat)
    else
      return flat
    end
  end

  coordinator.getMonsterPath = function(from, goal)
      if from == goal then
        return { goal }
      end
      local openset = { [from] = true }
      local closeset, cameFrom = { }, { }
      local gscore = { [from] = 0 }
      local hscore = { [from] = calculateDist(goal, from) }
      local fscore = { [from] = hscore[from] }
      while next(openset) do
        local current = popBestNode(openset, fscore)
        openset[current] = nil
        if current == goal then
          local path = unwindPath(cameFrom, goal)
          table.insert(path, goal)
          return path
        end
        closeset[current] = true
        local neighbours, costs = getNeighbours(current)
        for index, neighbour in ipairs(neighbours) do
          if not closeset[neighbour] then
            local tentativeGscore = gscore[current] + costs[index]
            if not openset[neighbour] or tentativeGscore < gscore[neighbour] then
              cameFrom[neighbour] = current
              gscore[neighbour] = tentativeGscore
              hscore[neighbour] = hscore[neighbour] or calculateDist(goal, neighbour)
              fscore[neighbour] = tentativeGscore + hscore[neighbour]
              openset[neighbour] = true
            end
           end
        end
      end
      return nil
    end
  
  local speed = 10
  coordinator.triggerEarthquake = function(level)
      if earthquake[level] then
        local MONSTERS = require("coordinators.monsters")
        for lvl=0, level do
          MONSTERS.spawnMonsters(lvl, ((lvl+1)*5)+math.floor((network.getNumberConnected()-1)*1.5))
        end
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
      network.sendAll(network.enum.readyUpState, false, waveNum)
      coordinator.triggerEarthquake(waveNum)
      coordinator.readyUpState = false
    end
  
  coordinator.resetForNextWave = function()
      coordinator.readyUpState = true
      network.sendAll(network.enum.readyUpState, true, waveNum)
    end
  
end