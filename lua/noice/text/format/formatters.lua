local require = require("noice.util.lazy")

local Util = require("noice.util")
local NoiceText = require("noice.text")

local M = {}

---@param message NoiceMessage
---@param input NoiceMessage
---@param opts NoiceFormatOptions.message
function M.message(message, opts, input)
  if opts.hl_group then
    message:append(input:content(), opts.hl_group)
  else
    message:append(input)
  end
end

---@param message NoiceMessage
---@param opts NoiceFormatOptions.text
function M.text(message, opts)
  if opts.text and opts.text ~= "" then
    message:append(opts.text, opts.hl_group)
  end
end

---@param message NoiceMessage
---@param opts NoiceFormatOptions.level
function M.level(message, opts)
  if message.level then
    local str = message.level:sub(1, 1):upper() .. message.level:sub(2)
    if opts.icons[message.level] then
      str = opts.icons[message.level] .. " " .. str
    end
    message:append(" " .. str .. " ", opts.hl_group[message.level])
  end
end

---@param message NoiceMessage
---@param opts NoiceFormatOptions.kind
function M.kind(message, opts)
  if message.kind and message.kind ~= "" then
    message:append(message.kind, opts.hl_group)
  end
end

---@param message NoiceMessage
---@param opts NoiceFormatOptions.title
function M.title(message, opts)
  if message.opts.title then
    message:append(message.opts.title, opts.hl_group)
  end
end
---@param message NoiceMessage
---@param opts NoiceFormatOptions.event
function M.event(message, opts)
  if message.event then
    message:append(message.event, opts.hl_group)
  end
end

---@param message NoiceMessage
---@param opts NoiceFormatOptions.date
function M.date(message, opts)
  message:append(os.date(opts.format, message.ctime), opts.hl_group)
end

---@param message NoiceMessage
function M.debug(message)
  local blocking, reason = Util.is_blocking()
  local debug = {
    message:is({ cleared = true }) and "" or "",
    "#" .. message.id,
    message.event .. (message.kind and message.kind ~= "" and ("." .. message.kind) or ""),
    blocking and "⚡ " .. reason,
  }
  message:append(NoiceText.virtual_text(" " .. table.concat(
    vim.tbl_filter(
      ---@param t string
      function(t)
        return t
      end,
      debug
    ),
    " "
  ) .. " ", "DiagnosticVirtualTextInfo"))
  if message.event == "cmdline" then
    message:newline()
  else
    message:append(" ")
  end
end

return M