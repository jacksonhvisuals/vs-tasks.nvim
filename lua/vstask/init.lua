local M = {}

M.Predefined = require("vstask.Predefined")
M.Config = require("vstask.Config")
M.Telescope = require("vstask.Telescope")
M.Parse = require("vstask.Parse")

local function config(opts)
	if opts == nil then
		return
	end
	if opts.telescope_keys ~= nil then
		M.Telescope.Set_mappings(opts.telescope_keys)
	end
	if opts.term_opts ~= nil then
		M.Telescope.Set_term_opts(opts.term_opts)
	end
	if opts.cache_strategy ~= nil then
		M.Parse.Cache_strategy(opts.cache_strategy)
	end
	if opts.autodetect ~= nil then
		M.Parse.Set_autodetect(opts.autodetect)
	end
	if opts.config_dir ~= nil then
		M.Parse.Set_config_dir(opts.config_dir)
	end
	if opts.support_code_workspace ~= nil then
		M.Parse.Set_support_code_workspace(opts.support_code_workspace)
	end
	if opts.cache_json_conf ~= nil then
		M.Parse.Set_cache_json_conf(opts.cache_json_conf)
	end
	if opts.json_parser ~= nil then
		M.Parse.Set_json_parser(opts.json_parser)
	end
	if opts.buffer_options ~= nil then
		M.Parse.Set_buffer_options(opts.buffer_options)
	end
	if opts.default_tasks ~= nil then
		M.Parse.Set_default_tasks(opts.default_tasks)
	end
	if opts.ignore_input_default ~= nil and opts.ignore_input_default == true then
		M.Parse.ignore_input_default()
	end
end

M.config = function(opts)
	config(opts)
end

function M.setup(opts)
	config(opts)
end

M.get_last = M.Telescope.Get_last

return M
