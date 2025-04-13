local M = {}

local uv = vim.loop
M.target_pane = ":.1"

-- Check if the tmux pane exists
local function pane_exists(pane, callback)
	local handle = io.popen(string.format('tmux display-message -p -t "%s" "#{pane_id}" 2>/dev/null', pane))
	if not handle then
		callback(false)
		return
	end

	local result = handle:read("*a")
	handle:close()

	-- If result is non-empty, the pane exists
	callback(result ~= nil and result ~= "")
end
-- Run a tmux command asynchronously
local function async_tmux_cmd(cmd)
	uv.spawn("sh", {
		args = { "-c", cmd },
	}, function(code, _)
		if code ~= 0 then
			vim.schedule(function()
				vim.notify("tmux command failed: " .. cmd, vim.log.levels.ERROR)
			end)
		end
	end)
end

-- Run the current buffer in the configured tmux pane
function M.run_buffer()
	local file = vim.fn.expand("%:p") -- absolute path
	local send_cmd = string.format('tmux send-keys -t %s "uv run %s" Enter', M.target_pane, file)
	local switch_cmd = string.format("tmux select-pane -t %s", M.target_pane)

	pane_exists(M.target_pane, function(exists)
		if exists then
			async_tmux_cmd(send_cmd)
			async_tmux_cmd(switch_cmd)
		else
			vim.notify("Target tmux pane " .. M.target_pane .. " not found", vim.log.levels.ERROR)
		end
	end)
end

-- Setup function with options
function M.setup(opts)
	opts = opts or {}
	M.target_pane = opts.target_pane or M.target_pane

	vim.keymap.set("n", opts.keymap or "<leader>uv", M.run_buffer, {
		noremap = true,
		silent = true,
		desc = "Run buffer in tmux pane and switch",
	})
end

return M
