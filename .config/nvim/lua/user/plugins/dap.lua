local dap_status_ok, dap = pcall(require, "dap")
if not dap_status_ok then
    return
end

dap.adapters.cppdbg = {
    id = 'cppdbg',
    type = 'executable',
    command = '/home/n30/.vscode/extensions/ms-vscode.cpptools-1.10.8-linux-x64/debugAdapters/bin/OpenDebugAD7',
}

dap.configurations.cpp = {
    {
        name = 'Launch Marmortal (DebugGame)',
        type = 'cppdbg',
        request = 'launch',
        program = '/home/n30/Repos/Marmortal/Binaries/Linux/Marmortal-Linux-DebugGame',
        cwd = '/mnt/data/unrealengine',
        miDebuggerPath = '/usr/bin/gdb',
        MIMode = 'gdb',
    },
    {
        name = "Launch file",
        type = "cppdbg",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = true,
    },
}

require 'dapui'.setup()
