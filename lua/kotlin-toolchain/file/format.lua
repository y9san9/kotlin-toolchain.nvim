local sort_imports = require('kotlin-toolchain.file.sort-imports')

--- @class FormatOptions: table
--- @field sort_imports boolean | nil
local FormatOptions = {}

--- @param opts FormatOptions
return function(opts)
  opts = opts or {}
  local sort_imports_option = opts.sort_imports or true
  if sort_imports_option then
    sort_imports()
  end
end
