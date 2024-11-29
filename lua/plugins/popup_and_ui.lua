return {
	-- Popup UI/Floating Window
	"MunifTanjim/nui.nvim",

	-- Noice for enhanced UI
	{
		"folke/noice.nvim",
		dependencies = { "rcarriga/nvim-notify" },
		config = function()
			require("noice").setup({
				-- Views for cmdline popup and popup menu
				views = {
					-- Cmdline popup configuration
					cmdline_popup = {
						position = {
							row = "50%",
							col = "50%",
						},
						size = {
							width = 60,
							height = "auto",
						},
					},

					-- Popup menu configuration
					popupmenu = {
						relative = "editor",
						position = {
							row = 8,
							col = "50%",
						},
						size = {
							width = 60,
							height = 10,
						},
						border = {
							style = "rounded",
							padding = { 0, 1 },
						},
						win_options = {
							winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
						},
					},
				},
			})
		end,
	},
}
