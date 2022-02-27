local pixelArt = function(image)
  image:setFilter("nearest", "nearest")
end

return { 
    { "UI/logoES.png", "logo.ES", onLoad = pixelArt },
    
    { "tiles/test1.png", "tiles.test1", onLoad = pixelArt },
    { "tiles/test2.png", "tiles.test2", onLoad = pixelArt },
    { "tiles/test3.png", "tiles.test3", onLoad = pixelArt },
    { "tiles/grass.png", "tiles.grass", onLoad = pixelArt },
    { "tiles/stone.png", "tiles.stone", onLoad = pixelArt },
    { "tiles/water.png", "tiles.water", onLoad = pixelArt },

    { "characters/duck1.png", "characters.duck1", onLoad = pixelArt },
  }