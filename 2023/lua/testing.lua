local M = {}

function M.example(value, expected)
  assert(value == expected, string.format('Example error: %s (expected %s)', value, expected))
end

function M.solution(value, expected)
  print(value)

  if expected ~= nil then
    assert(value == expected, string.format('Solution error: %s (expected %s)', value, expected))
  end
end

return M
