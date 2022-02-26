
local extensions = {
    png  = "Image",
    jpg  = "Image",
    jpeg = "Image",
    bmp  = "Image",
    mp3  = "Source",
    ogg  = "Source",
    wav  = "Source",
    txt  = "read",
    ttf  = "Font",
    otf  = "Font",
    fnt  = "Font",
  }

local function splitFileExtension(strFilename)
  return strFilename:match("^.+%.(.+)$")
end

return function()
  local outAssets = require("util.assets")
  
  local assets = require("assets.defineAssets") or error("Unable to find asset")
  for _, asset in ipairs(assets) do
    local extension = splitFileExtension(asset[1])
    outAssets[asset[1]] = extensions[extension and extension:lower() or ""] or error("Couldn't find load type for "..tostring(extension).." extension from file "..tostring(asset[1]))
  end
end