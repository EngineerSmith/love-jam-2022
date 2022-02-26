local json = require("libs.json")
local lfs = love.filesystem

return {
  decode = function(filepath)
      local content = assert(lfs.read(filepath))
      local success, json = pcall(json.decode, content)
      return success, json
    end,
  encode =  function(filepath, table)
      local success, json = pcall(json.encode, table)
      if not success then
        return success, json
      end
      local success, message = lfs.write(filepath, json)
      return success, message
    end,
}