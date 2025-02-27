local parsers = require('nvim-treesitter.parsers')

--- @param root TSNode
--- @return {[string]: boolean}
--- TODO: filter out generics in-file functions and local-variables
local function collect_used_types(root, filetype)
  local query = vim.treesitter.query.parse(
    filetype,
    [[
    [
      (user_type
        . (type_identifier) @identifier)
      (value_argument
        (simple_identifier) @identifier
        (call_expression) @ignore)
      (call_expression
        . (simple_identifier) @identifier)
      (callable_reference
        . (simple_identifier) @identifier)
      (callable_reference
        . (type_identifier) @identifier)
      (infix_expression
        (simple_identifier) @identifier)
      (additive_expression
        (simple_identifier) @identifier)
      (multiplicative_expression
        (simple_identifier) @identifier)
      (statements
        (simple_identifier) @identifier)
      (navigation_expression
        . (simple_identifier) @identifier)
      (navigation_suffix
        . (simple_identifier) @identifier)
    ]
    ]]
  )

  local identifier_id = 1
  local ignore_id = 2

  local used_types = {}
  for _, match, _ in query:iter_matches(root, 0, 0, -1, { all = true }) do
    if match[ignore_id] == nil then
      local identifiers = match[identifier_id]
      for _, identifier in ipairs(identifiers) do
        used_types[vim.treesitter.get_node_text(identifier, 0)] = true
      end
    end
  end

  return used_types
end

--- @param import TSNode
--- @return string | nil
local function get_import_identifier(import)
  local identifier_node = nil
  for simple_identifier in import:child(1):iter_children() do
    identifier_node = simple_identifier
  end
  if identifier_node ~= nil then
    return vim.treesitter.get_node_text(identifier_node, 0)
  end
  return nil
end

--- @param import TSNode
--- @return boolean
local function has_wildcard(import, filetype)
  local query = vim.treesitter.query.parse(
    filetype,
    [[
      (wildcard_import) @wildcard
    ]]
  )
  for _, _, _ in query:iter_matches(import, 0, 0, -1, { all = true }) do
    return true
  end
  return false
end

--- @param imports TSNode[]
--- @param used_types {[string]: boolean}
--- @return TSNode[]
local function remove_unused_imports(imports, used_types, filetype)
  local result = {}

  for i = 1, #imports do
    local import = imports[i]
    local identifier = get_import_identifier(import)
    if used_types[identifier] or has_wildcard(import, filetype) then
      result[#result + 1] = import
    end
  end

  return result
end

--- @param root TSNode
--- @return TSNode[]
local function collect_imports(root, filetype)
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

  return imports
end

--- TODO: Support embedded in markdown removing?
return function()
  local filetype = vim.bo.filetype
  if filetype ~= 'kotlin' then
    error("Can't use kotlin-toolchain inside non-kotlin files")
  end
  local parser = parsers.get_parser(vim.api.nvim_get_current_buf(), filetype)
  local tree = parser:parse()[1]
  local root = tree:root()

  local imports = collect_imports(root, filetype)
  local line_start = imports[1]:start()
  local line_end = imports[#imports]:end_() + 1

  local used_types = collect_used_types(root, filetype)

  local optimized = remove_unused_imports(imports, used_types, filetype)

  local lines = {}
  for i = 1, #optimized do
    local import = optimized[i]
    lines[i] = vim.treesitter.get_node_text(import, 0)
  end

  vim.api.nvim_buf_set_lines(0, line_start, line_end, true, lines)
end
