local log = require('tabby.core.log')

local M = {}

---A element is a "hyper text" object
---@class Element
---@field node  Node         children node
---@field hl    Highlight
---@field lo    Layout
---@field click ClickHandler

---@alias Highlight string
-- fg   string foreground color
-- bg   string background color
-- attr string gui attributes

---@class Layout
---@field right? boolean Is left justify @default false
---@field maxwid? number maximum width
---@field minwid? number minimum width

---@alias ClickHandler ClickTab|CloseTab|CustomerHander

---@class ClickTab
---@field [1] "to_tab"
---@field [2] number tabid

---@class CloseTab
---@field [1] "x_tab"
---@field [2] number tabid

---@class CustomerHander
---@field [1] "customer"
---@field [2] number handle id
---@field [3] function(number,string,string) handler

---@alias Frag Element|string
---@alias Node Frag|Frag[]

---@class Context
---@field parent_hl Highlight
---@field current_hl Highlight

---render node to tabline string
---@param node Node
---@param ctx Context? highlight group in context
---@return string, Context? rendered string and context
function M.render_node(node, ctx)
  vim.validate({
    ['ctx.current_hl'] = { ctx.current_hl, 'string', true },
    ['ctx.parent_hl'] = { ctx.parent_hl, 'string', true },
  })
  if vim.tbl_islist(node) then
    local strs = {}
    for i, frag in ipairs(node) do
      strs[i], ctx = M.render_frag(frag, ctx)
    end
    return table.concat(strs, ''), ctx
  else
    return M.render_frag(node, ctx)
  end
end

---render frag to string
---@param frag Frag
---@param ctx Context? highlight group in context
---@return string, Context? rendered string and context
function M.render_frag(frag, ctx)
  vim.validate({
    ['ctx.current_hl'] = { ctx.current_hl, 'string', true },
    ['ctx.parent_hl'] = { ctx.parent_hl, 'string', true },
  })
  if type(frag) == 'table' then
    return M.render_element(frag, ctx)
  elseif type(frag) == 'string' then
    return frag, ctx
  else
    log.error.format('invalid frag for tabby: %s', vim.inspect(frag))
    return '', ctx
  end
end

---render Element to string
---@param el Element
---@param ctx Context? highlight group in context
---@return string, Context? rendered string and context
function M.render_element(el, ctx)
  vim.validate({
    el = { el, 'table' },
    ctx = { ctx, 'table' },
    ['ctx.current_hl'] = { ctx.current_hl, 'string', true },
    ['ctx.parent_hl'] = { ctx.parent_hl, 'string', true },
  })
  local hl = el.hl or ctx.parent_hl
  local text = M.render_node(el.node, { current_hl = hl, parent_hl = hl })
  if hl ~= nil and hl ~= ctx.current_hl then
    text = M.render_highlight(hl, text)
    ctx.current_hl = hl
  end
  if el.lo ~= nil then
    text = M.render_lo(el.lo, text)
  end
  return text, ctx
end

---render highlight
---@param hl Highlight
---@param text string
---@return string
function M.render_highlight(hl, text)
  vim.validate({
    hl = { hl, 'string' },
    text = { text, 'string' },
  })
  return string.format('%%#%s#', hl) .. text
end

---render Layout
---@param lo Layout
---@param text string
---@return string
function M.render_lo(lo, text)
  vim.validate({
    lo = { lo, 'table' },
    text = { text, 'string' },
    ['lo.right'] = { lo.right, 'boolean', true },
    ['lo.minwid'] = { lo.minwid, 'number', true },
    ['lo.maxwind'] = { lo.maxwid, 'number', true },
  })
  if (lo.maxwid or 0 == 0) and (lo.minwid or 0 == 0) then
    return text
  end

  -- text is: %-{minwid}.{maxwid}(<string>%)
  local head = '%-'
  local width = ''
  if lo.right then
    head = '%'
  end
  if (lo.maxwid or 0) > 0 then
    width = string.format('%d.%d', lo.minwid or 0, lo.maxwid or 0)
  elseif (lo.minwid or 0) > 0 then
    width = lo.minwid
  end
  return table.concat({ head, width, '(', text, '%)' })
end

return M
