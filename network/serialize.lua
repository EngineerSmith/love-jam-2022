local buffer = require("string.buffer")

local serialize = {
    encode = function(...)
        local data = { }
        for i=1, select('#', ...) do
          local var = select(i, ...)
          if type(var) == "userdata" then
            if var:typeOf("data") then
              var = var:getString()
            else
              error("Serialize cannot encode "..tostring(var:type()))
            end
          elseif var == nil then
            error("Serialize cannot encode nil, use a string instead")
          end
          data[i] = var
        end
        return buffer.encode(data)
      end,
    decode = function(data)
        return buffer.decode(data)
      end,
  }

return serialize