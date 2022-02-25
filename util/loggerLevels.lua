local levels
levels = {
  ["INFO"] = "i",
  ["WARN"] = "w",
  ["ERROR"] = "e",
  ["FATAL"] = "f",
  ["UNKNOWN"] = "u",
  reverse = function(enum)
    for k, e in pairs(levels) do
      if e == enum then
        return k
      end
    end
    return "UNKNOWN"
  end,
}

return levels