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

local loopAudio = function(source)
  source:setLooping(true)
end

return { 
    -- UI
    { "UI/logoES.png", "logo.ES", onLoad = pixelArt },
    { "UI/leglessduck.png", "ui.main.duck", onLoad = pixelArt },
    { "UI/wheel.png", "ui.wheel", onLoad = pixelArt },
    { "UI/wheel_NE.png", "ui.wheel.ne", onLoad = pixelArt },
    { "UI/wheel_NW.png", "ui.wheel.nw", onLoad = pixelArt },
    { "UI/wheel_SW.png", "ui.wheel.se", onLoad = pixelArt },
    { "UI/wheel_SE.png", "ui.wheel.sw", onLoad = pixelArt },
    { "UI/coin.png", "ui.coin", onLoad = pixelArt },
    { "UI/arrow.png", "ui.arrow", onLoad = makePixelAnimation, 15, 32, 64, 0.08 },
    { "UI/disabledArrow.png", "ui.arrow.disabled", onLoad = pixelArt },
    { "UI/wall_wheelGraphic.png", "ui.wheel.wall", onLoad = pixelArt },
    { "UI/cross.png", "ui.cross", onLoad = pixelArt },
    { "UI/tick.png", "ui.tick", onLoad = pixelArt },
    { "UI/logo.png", "ui.logo", onLoad = makePixelAnimation, 20, 160 * 2, 96 * 2, 0.1 },
    
    -- Tiles
    { "tiles/test1.png", "tiles.test1", onLoad = pixelArt },
    { "tiles/test2.png", "tiles.test2", onLoad = pixelArt },
    { "tiles/test3.png", "tiles.test3", onLoad = pixelArt },
    { "tiles/grass.png", "tiles.grass", onLoad = pixelArt },
    { "tiles/grass_darkbottom.png", "tiles.grass.dark", onLoad = pixelArt },
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
    -- Walls
    { "tiles/walls/horizontal.png", "tiles.walls.horizontal", onLoad = pixelArt },
    { "tiles/walls/vertical.png", "tiles.walls.vertical", onLoad = pixelArt },
    { "tiles/walls/rd.png", "tiles.walls.rd", onLoad = pixelArt },
    { "tiles/walls/ld.png", "tiles.walls.ld", onLoad = pixelArt },
    { "tiles/walls/lu.png", "tiles.walls.lu", onLoad = pixelArt },
    { "tiles/walls/ru.png", "tiles.walls.ru", onLoad = pixelArt },
    { "tiles/walls/pole.png", "tiles.walls.pole", onLoad = pixelArt },
    { "tiles/walls/up.png", "tiles.walls.up", onLoad = pixelArt },
    { "tiles/walls/down.png", "tiles.walls.down", onLoad = pixelArt },
    { "tiles/walls/left.png", "tiles.walls.left", onLoad = pixelArt },
    { "tiles/walls/right.png", "tiles.walls.right", onLoad = pixelArt },
    { "tiles/walls/all.png", "tiles.walls.all", onLoad = pixelArt },
    { "tiles/walls/leftdownright.png", "tiles.walls.leftdownright", onLoad = pixelArt },
    { "tiles/walls/updownleft.png", "tiles.walls.updownleft", onLoad = pixelArt },
    { "tiles/walls/uprightdown.png", "tiles.walls.uprightdown", onLoad = pixelArt },
    { "tiles/walls/uprightleft.png", "tiles.walls.uprightleft", onLoad = pixelArt },
    
    -- Characters
    { "characters/duck1.png", "characters.duck1", onLoad = pixelArt },
    { "characters/duck2.png", "characters.duck2", onLoad = pixelArt },
    { "characters/duck1_standing1.png", "characters.duck1.standing1", onLoad = makePixelAnimation, 5, 30, 33, 0.2},
    { "characters/duck1_walking1.png", "characters.duck1.walking1", onLoad = makePixelAnimation, 5, 30, 33, 0.1},
    { "characters/duck1_standing2.png", "characters.duck1.standing2", onLoad = makePixelAnimation, 5, 30, 32, 0.2},
    { "characters/duck1_walking2.png", "characters.duck1.walking2", onLoad = makePixelAnimation, 5, 30, 32, 0.1},
    
    -- Monsters
    { "monsters/shadow_standing.png", "monster.shadow.standing", onLoad = makePixelAnimation, 4, 32, 32, 0.2},
    { "monsters/GoldenGolem.png", "monster.goldengolem.standing", onLoad = makePixelAnimation, 4, 32, 32, 0.2},
    { "monsters/necromancer.png", "monster.necromancer.standing", onLoad = makePixelAnimation, 4, 32, 32, 0.2},
    { "monsters/redman.png", "monster.redman.standing", onLoad = makePixelAnimation, 4, 32, 32, 0.2},
    { "monsters/greenman.png", "monster.greenman.standing", onLoad = makePixelAnimation, 4, 32, 32, 0.2},
    { "monsters/skeleton.png", "monster.greenman.standing", onLoad = makePixelAnimation, 4, 32, 32, 0.2},
    
    -- Game objects
    { "objects/nest.png", "objects.nest", onLoad = pixelArt },
    { "objects/towers/test.png", "objects.towers.test", onLoad = pixelArt },
    { "objects/towers/green.png", "objects.towers.green", onLoad = pixelArt },
    { "objects/towers/red.png", "objects.towers.red", onLoad = pixelArt },
    { "objects/towers/purple.png", "objects.towers.purple", onLoad = pixelArt },
    { "objects/towers/greencharging.png", "objects.towers.greencharging", onLoad = makePixelAnimation, 33, 64, 128, 0.038 },
    { "objects/towers/redcharging.png", "objects.towers.redcharging", onLoad = makePixelAnimation, 27, 64, 128, 0.038 },
    { "objects/towers/purplecharging.png", "objects.towers.purplecharging", onLoad = makePixelAnimation, 42, 64, 128, 0.038 },
    { "objects/bullets/green.png", "objects.bullets.green", onLoad = pixelArt },
    { "objects/bullets/red.png", "objects.bullets.red", onLoad = pixelArt },
    { "objects/bullets/purple.png", "objects.bullets.purple", onLoad = pixelArt },
    
    -- Audio
    { "audio/BRPG_Take_Courage_FULL_Loop.wav", "audio.music.1", onLoad = loopAudio },
  }