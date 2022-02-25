local lily = require("libs.lily")

local insert = table.insert

local extensions = {
    png = "newImage",
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

return function(outAssets)
  local assets = require("assets.defineAssets") or error("Unable to find asset")
  local lilyTable = {}
  for _, asset in ipairs(assets) do
    local extension = splitFileExtension(assets[1])
    insert(lilyTable, {
        extensions[extension or ""] or error("Couldn't find load function for "..tostring(extension).." from file "..tostring(assets[1])),
        assets[1],
      })
  end
  
  local multiLily = lily.loadMulti(lilyTable)
  multiLily:onComplete(function(_, lilies)
      for index, lilyAsset in ipairs(lilies) do
        local import = assets[index]
        outAssets[import[2]] = lilyAsset[1]
        if import.onLoad then
          import.onLoad(lilyAsset[1], unpack(import, 3))
        end
      end
    end)
  return multiLily
end