local pixelArt = function(image)
  image:setFilter("nearest", "nearest")
end

return { 
    { "UI/logoES.png", "logo.ES", onLoad = pixelArt }
  }