-- 1. Full Border
require("full-border"):setup()

-- 2. Git Status
require("git"):setup()

-- 3. Yatline (Status Bar)
-- We use pcall so it doesn't crash if the folder is missing
local ok, yatline = pcall(require, "yatline")
if ok then
    yatline:setup()
end
