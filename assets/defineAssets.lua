local anim8 = require("libs.anim8")

local pixelArt = function(image)
  image:setFilter("nearest", "nearest")
end

local makePixelAnimation = function(image, frameCount, frameWidth, frameHeight, frameTime)
  pixelArt(image)
  local grid = anim8.newGrid(frameWidth, frameHeight, image:getDimensions())
  local animation = anim8.newAnimation(grid('1-'..frameCount, 1), frameTime)
  animation.image = image
  return animation
end

return { 
    -- UI
    { "UI/logoES.png", "logo.ES", onLoad = pixelArt },
    { "UI/leglessduck.png", "ui.main.duck", onLoad = pixelArt },
    
    -- Tiles
    { "tiles/test1.png", "tiles.test1", onLoad = pixelArt },
    { "tiles/test2.png", "tiles.test2", onLoad = pixelArt },
    { "tiles/test3.png", "tiles.test3", onLoad = pixelArt },
    { "tiles/grass.png", "tiles.grass", onLoad = pixelArt },
    { "tiles/stone.png", "tiles.stone", onLoad = pixelArt },
    { "tiles/sand.png", "tiles.sand", onLoad = pixelArt },
    { "tiles/water.png", "tiles.water", onLoad = makePixelAnimation, 8, 32, 32, 0.2},
    { "tiles/water2.png", "tiles.water2", onLoad = makePixelAnimation, 8, 32, 32, 0.2},
    -- Tile debrises
    { "tiles/debris/grass1.png", "tiles.debris.grass1", onLoad = pixelArt },
    { "tiles/debris/grass2.png", "tiles.debris.grass2", onLoad = pixelArt },
    { "tiles/debris/grass3.png", "tiles.debris.grass3", onLoad = pixelArt },
    { "tiles/debris/grass4.png", "tiles.debris.grass4", onLoad = pixelArt },
    { "tiles/debris/sand1.png", "tiles.debris.sand1", onLoad = pixelArt },
    { "tiles/debris/sand2.png", "tiles.debris.sand2", onLoad = pixelArt },
    { "tiles/debris/sand3.png", "tiles.debris.sand3", onLoad = pixelArt },
    { "tiles/debris/tree.png", "tiles.debris.tree", onLoad = pixelArt },
    
    -- Characters
    { "characters/duck1.png", "characters.duck1", onLoad = pixelArt },
    { "characters/duck2.png", "characters.duck2", onLoad = pixelArt },
    { "characters/duck1_standing1.png", "characters.duck1.standing1", onLoad = makePixelAnimation, 5, 30, 33, 0.2},
    { "characters/duck1_walking1.png", "characters.duck1.walking1", onLoad = makePixelAnimation, 5, 30, 33, 0.1},

    -- Game objects
    { "objects/towers/test.png", "objects.towers.test", onLoad = pixelArt },
    { "objects/towers/green.png", "objects.towers.green", onLoad = pixelArt },
    { "objects/towers/red.png", "objects.towers.red", onLoad = pixelArt },
    { "objects/towers/purple.png", "objects.towers.purple", onLoad = pixelArt }
  }