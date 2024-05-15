local TextTransform = {}

--- Merges two tables into one. Same as `vim.tbl_extend("keep", t1, t2)`.
--- Mutates the first table.
---
--- TODO accept multiple tables to merge
---
---@param t1 table
---@param t2 table
---@return table
function TextTransform.merge(t1, t2)
  return vim.tbl_extend("force", t1, t2)
end

function TextTransform.has_range(visual_start, visual_end)
  return visual_start and visual_end and visual_start[2] ~= visual_end[2]
end

return TextTransform
