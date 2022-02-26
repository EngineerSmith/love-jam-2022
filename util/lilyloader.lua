local lily = require("libs.lily")

local insert = table.insert

local extensions = {
    png  = "newImage",
    jpg  = "newImage",
    jpeg = "newImage",
    bmp  = "newImage",
    mp3  = "newSource",
    ogg  = "newSource",
    wav  = "newSource",
    txt  = "read",
    ttf  = "newFont",
    otf  = "newFont",
    fnt  = "newFont",
  }
  
local function splitFileExtension(strFilename)
  return strFilename:match("^.+%.(.+)$")
end

return function()
  local assets = require("assets.defineAssets") or error("Unable to find asset")
  local lilyTable = { }
  for _, asset in ipairs(assets) do
    local extension = splitFileExtension(asset[1])
    insert(lilyTable, {
        extensions[extension and extension:lower() or ""] or error("Couldn't find load function for "..tostring(extension).." extension from file "..tostring(asset[1])),
        "assets/"..asset[1],
      })
  end
  
  local outAssets = require("util.assets")
  
  local multiLily = lily.loadMulti(lilyTable)
  multiLily:onComplete(function(_, lilies)
      for index, lilyAsset in ipairs(lilies) do
        local import = assets[index]
        outAssets[import[2]] = lilyAsset[1]
        if import.onLoad then
          local a = import.onLoad(lilyAsset[1], unpack(import, 3))
          if a then
            outAssets[import[2]] = a
          and
        end
      end
    end)
  return multiLily
end