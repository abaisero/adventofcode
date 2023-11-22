local M = {}

function M.make_tmpfile(str)
  local f = io.tmpfile()
  f:write(str)
  f:seek('set', 0)
  return f
end

return M
