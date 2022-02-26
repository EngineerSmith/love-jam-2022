local pixelArt = function(image)
  image:setFilter("nearest", "nearest")
end

return { 
    { "UI/logo.png", "logo", onLoad = pixelArt }
  }