-- Define the folder path prefix
local folder_prefix = "Captains Logs/Daily Captains Log"

-- Define the folder path string based on the current date
local current_year = os.date("%Y")
local current_month = os.date("%B")
local folder_path = string.format("%s/%s/%s", folder_prefix, current_year, current_month)

-- Configure obsidian.nvim using the predefined folder path
require("obsidian").setup({
	workspaces = {
		{
			name = "personal",
			path = "~/Documents/Obsidian_Vault",
		},
	},
	ui = {
		enable = false,
	},
	templates = {
		subdir = "/Templates",
		template = "Daily Captains Log Template.md",
		date_format = "%Y-%m-%d-%a",
		time_format = "%H:%M",
	},
	daily_notes = {
		folder = folder_path,
		date_format = "%Y-%m-%d",
		alias_format = "%B %-d, %Y",
		template = "Daily Captains Log Template.md",
	},
})
