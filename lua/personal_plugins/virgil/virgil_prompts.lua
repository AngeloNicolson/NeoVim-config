return {
	Generate = { prompt = "Virgil: $input", replace = true },
	Chat = { prompt = "$input" },
	Summarize = { prompt = "Summarize the following text:\n$text" },
	Ask = { prompt = "Me: $input:\n$text" },
	Review_Code = {
		prompt = "Review the following code and make concise suggestions:\n```$filetype\n$text\n```",
	},
	Enhance_Code = {
		prompt = "Enhance the following code, only ouput the result in format ```$filetype\n...\n```:\n```$filetype\n$text\n```",
		replace = true,
		extract = "```$filetype\n(.-)```",
	},
	Change_Code = {
		prompt = "Regarding the following code, $input, only ouput the result in format ```$filetype\n...\n```:\n```$filetype\n$text\n```",
		replace = true,
		extract = "```$filetype\n(.-)```",
	},
}
