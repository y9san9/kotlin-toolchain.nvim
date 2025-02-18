local sort_imports = require('kotlin-toolchain.file.sort-imports')
local remove_unused_imports =
  require('kotlin-toolchain.file.remove-unused-imports')

--- @class FormatOptions: table | nil
--- @field sort_imports boolean | nil
--- @field remove_unused_imports boolean | nil
local FormatOptions = {}

--- @param opts FormatOptions
return function(opts)
  opts = opts or {}
  local sort_imports_option = opts.sort_imports or true
  if sort_imports_option then
    sort_imports()
  end
  local remove_unused_imports_option = opts.remove_unused_imports or true
  if remove_unused_imports_option then
    remove_unused_imports()
  end
end
