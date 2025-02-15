local parsers = require('nvim-treesitter.parsers')

--- Stackoverflow type shit
--- @param imports TSNode[]
local function sort_on_values(imports)
  table.sort(imports, function(left, right)
    local left_import_identifier = left:child(1)
    if left_import_identifier == nil then
      error('Unexpected nil')
    end

    local left_simple_imports = {}
    for simple_import in left_import_identifier:iter_children() do
      left_simple_imports[#left_simple_imports + 1] = simple_import
    end

    local right_import_identifier = right:child(1)
    if right_import_identifier == nil then
      error('Unexpected nil')
    end

    local right_simple_imports = {}
    for simple_import in right_import_identifier:iter_children() do
      right_simple_imports[#right_simple_imports + 1] = simple_import
    end

    for i = 1, math.min(#left_simple_imports, #right_simple_imports) do
      local left_text = vim.treesitter.get_node_text(left_simple_imports[i], 0)
      local right_text =
        vim.treesitter.get_node_text(right_simple_imports[i], 0)
      if left_text > right_text then
        return false
      end
      if left_text < right_text then
        return true
      end
    end

    return false
  end)
end

--- TODO: Support embedded in markdown sorting?
return function()
  local filetype = vim.bo.filetype
  if filetype ~= 'kotlin' then
    error("Can't use kotlin-toolchain inside non-kotlin files")
  end
  local parser = parsers.get_parser(vim.api.nvim_get_current_buf(), filetype)
  local tree = parser:parse()[1]
  local root = tree:root()

  local query = vim.treesitter.query.parse(
    filetype,
    [[
      (import_list) @imports
    ]]
  )

  local import_blocks = {}
  for _, result, _ in query:iter_matches(root, 0, 0, -1, { all = true }) do
    import_blocks[#import_blocks + 1] = result[1][1]
  end

  local imports = {}
  for i = 1, #import_blocks do
    local block = import_blocks[i]
    for import in block:iter_children() do
      imports[#imports + 1] = import
    end
  end

  local line_start = imports[1]:start()
  local line_end = imports[#imports]:end_() + 1

  sort_on_values(imports)

  local lines = {}
  for i = 1, #imports do
    local import = imports[i]
    lines[i] = vim.treesitter.get_node_text(import, 0)
  end

  vim.api.nvim_buf_set_lines(0, line_start, line_end, true, lines)
end
