local _, addon = ...
addon.L = {}
local L = addon.L

local function default(L, key)
    return key
end

setmetatable(L, {__index=default})