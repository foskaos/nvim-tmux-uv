local M = {}

M.target_pane = ':.1'


function M.run_buffer()
	local file = vim.fn.expand('%')
	local send_cmd = string.format('tmux send-keys -t %s "uv run %s" Enter', M.target_pane, file)
	local switch_cmd = string.format('tmux select-pane -t %s', M.target_pane)

	os.execute(send_cmd)
	os.execute(switch_cmd)
end

function M.setup(opts)
    opts = opts or {}
    M.target_pane = opts.target_pane or M.target_pane

    vim.keymap.set('n', opts.keymap or '<leader>r', M.run_buffer, {
        noremap = true,
        silent = true,
        desc = 'Run buffer in tmux pane and swich'
    })
end

return M
