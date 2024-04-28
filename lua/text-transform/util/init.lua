local state = require("text-transform.state")
local utils = {}

--- Merges two tables into one. Same as `vim.tbl_extend("keep", t1, t2)`.
--- Mutates the first table.
---
--- TODO accept multiple tables to merge
---
--- @param t1 table
--- @param t2 table
--- @return table
function utils.merge(t1, t2)
  return vim.tbl_extend("force", t1, t2)
end

--- Dumps the object into a string.
--- @param obj any
--- @return string
function utils.dump(obj)
  return vim.inspect(obj)
end

function utils.is_block_visual_mode()
  return state.positions.mode == 'block'
  -- return vim.fn.mode() == "V" or vim.fn.mode() == "\22"
end

function utils.is_visual_mode()
  return state.positions.mode == 'visual'
  -- return vim.fn.mode() == 'v'
end

return utils
