return {
	Generate = { prompt = "Virgil: $input", replace = true },
	Chat = { prompt = "$input" },
	Summarize = { prompt = "Summarize the following text:\n$text" },
	Ask = { prompt = "Me: $input:\n$text" },
	Change = {
		prompt = "Change the following text, $input, just output the final text without additional quotes around it:\n$text",
		replace = true,
	},
	Enhance_Wording = {
		prompt = "Modify the following text to use better wording, just output the final text without additional quotes around it:\n$text",
		replace = true,
	},
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
