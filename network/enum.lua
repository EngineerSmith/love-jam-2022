local enum = {
    disconnect = {
        normal = 0,
        badconnect = 0,
        badserver = 0,
        badusername = 0,
      },
    packetType = { -- must be 1 char in size
        receive           = 'r',
        disconnect        = 'd',
        confirmConnection = 'c',
        firstConnect      = 'f',
        -- custom
        chatMessage       = 'm',
        -- world data
        playerPosition    = 'p',
      },
  }
  
enum.convert = function(value, enumType)
  local enums = enum[enumType]
  if not enums then return nil end
  for k, v in pairs(enums) do
    if v == value then
      return k
    end
  end
  return nil
end

return enum