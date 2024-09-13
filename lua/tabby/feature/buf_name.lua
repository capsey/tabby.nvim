local buf_name = {}

local filename = require('tabby.module.filename')

---@class TabbyBufNameOption
---@field mode 'unique'|'relative'|'tail'|'shorten' @default unique
---@field placeholder string @default '[No Name]'
---@field override fun(bufid:number):string?

---@type TabbyBufNameOption
local default_option = {
  mode = 'unique',
  placeholder = '[No Name]',
  override = function()
    return nil
  end,
}

function buf_name.set_default_option(opt)
  default_option = vim.tbl_deep_extend('force', default_option, opt)
end

---get buf name
---@param bufid number
---@param opt? TabbyBufNameOption
---@param use_bufs boolean
---@return string
function buf_name.get(bufid, opt, use_bufs)
  local o = default_option
  if opt ~= nil then
    o = vim.tbl_deep_extend('force', default_option, opt)
  end
  local override = o.override(bufid)
  if override ~= nil then
    return override
  end
  if o.mode == 'unique' then
    return buf_name.get_unique_name(bufid, o.placeholder, use_bufs)
  elseif o.mode == 'relative' then
    return buf_name.get_relative_name(bufid, o.placeholder)
  elseif o.mode == 'tail' then
    return buf_name.get_tail_name(bufid, o.placeholder)
  elseif o.mode == 'shorten' then
    return buf_name.get_shorten_name(bufid, o.placeholder)
  else
    return ''
  end
end

---@param bufid number
---@param placeholder string?
---@param use_bufs boolean
---@return string filename
function buf_name.get_unique_name(bufid, placeholder, use_bufs)
  return filename.unique(bufid, placeholder, use_bufs)
end

---@param bufid number
---@param placeholder string?
---@return string filename
function buf_name.get_relative_name(bufid, placeholder)
  return filename.relative(bufid, placeholder)
end

---@param bufid number
---@param placeholder string?
---@return string filename
function buf_name.get_tail_name(bufid, placeholder)
  return filename.tail(bufid, placeholder)
end

---@param bufid number
---@param placeholder string?
---@return string filename
function buf_name.get_shorten_name(bufid, placeholder)
  return filename.shorten(bufid, placeholder)
end

return buf_name
