# VS Tasks

Telescope plugin to load and run tasks in a project that conform to VS Code's [Editor Tasks](https://code.visualstudio.com/docs/editor/tasks)

## Features

- ⚙ Run commands in a terminal as jobs!
  - split or float the terminal
  - source from `./vscode/tasks.json` or `./*.code-workspace` file
  - source from package.json scripts
- With jobs picker, see all running and completed jobs, including a live output preview
- 👀 Run any task as a watched job
- 🧵 Run any task in the background as a job
- 📖 Browse history of completed background jobs
- ✏️ edit input variables that will be used for the session
- Use VS Code's [variables](https://code.visualstudio.com/docs/editor/variables-reference) in the command (limited support, see desired features)
- Use VS Code's [launch.json](https://code.visualstudio.com/docs/editor/debugging#_launch-configurations) pattern (limited support)
- ⟳ Run tasks from your history, sorted by most used
- 🐚 run shell commands with .run() or `<C-r>`
- basic support for option picker for task input (similar to extension.commandvariable.pickStringRemember)
- dependsOn and dependsOrder support, utilizing the background jobs feature. View with Jobs picker
- add default tasks in setup for projects without `.vscode/tasks.json` or `./*.code-workspace`, or if you want to add your own

## Example

Short Demo

![Short Demo](https://i.imgur.com/sQtRQdO.gif)

## Setup

With Plug:

```vim
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim' " make sure you have telescope installed
Plug 'EthanJWright/vs-tasks.nvim'
```

With Packer:

```vim
use {
  'EthanJWright/vs-tasks.nvim',
  requires = {
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim'
  }
}
```

With Lazy:

```lua
{
  "EthanJWright/vs-tasks.nvim",
  dependencies = {
    "nvim-lua/popup.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
}
```

Set up keybindings:

```vim
nnoremap <Leader>ta :lua require("telescope").extensions.vstask.tasks()<CR>
nnoremap <Leader>ti :lua require("telescope").extensions.vstask.inputs()<CR>
nnoremap <Leader>tj :lua require("telescope").extensions.vstask.jobs()<CR>
nnoremap <Leader>td :lua require("telescope").extensions.vstask.clear_inputs()<CR>
nnoremap <Leader>tc :lua require("telescope").extensions.vstask.cleanup_completed_jobs()<CR>
nnoremap <Leader>tl :lua require('telescope').extensions.vstask.launch()<cr>
nnoremap <Leader>tl :lua require('telescope').extensions.vstask.command()<cr>
```

## Functions

### Task Management

`:Telescope vstask tasks`

- Opens task picker showing all available tasks from `.vscode/tasks.json`
- Also can load language specific of `default_tasks` based on config
- Key mappings:
  - `<CR>` - Run in current window
  - `<C-v>` - Run in vertical split
  - `<C-p>` - Run in horizontal split
  - `<C-t>` - Run in new tab
  - `<C-b>` - Run in background terminal
  - `<C-w>` - Run as watched job (restarts on file save)

`:Telescope vstask run`

- Opens empty task picker for running arbitrary shell commands
- Supports same key mappings as tasks

`:Telescope vstask inputs`

- Opens input variables picker
- Set values for task variables
- Supports:
  - promptString (text input)
  - pickString (selection from list)

`:Telescope vstask launch`

- Opens launch configuration picker from `.vscode/launch.json`
- Key mappings:
  - `<CR>` - Run in current window
  - `<C-v>` - Run in vertical split
  - `<C-p>` - Run in horizontal split
  - `<C-t>` - Run in new tab
  - `<C-b>` - Run in background terminal (hidden from buffers)

### Job Management

`:Telescope vstask jobs`

- Shows all jobs (running and completed)
- Key mappings:
  - `<CR>` - View output in current window
  - `<C-v>` - View output in vertical split
  - `<C-p>` - View output in horizontal split
  - `<C-w>` - Toggle watch mode (restart on save)
  - `<C-d>` - Kill task and remove from job list
- Features:
  - Live output preview
  - Watch mode for auto-restart
  - Task status indicators (🟠 running, 🟢 success, 🔴 failed)
  - 👀 Watch indicator for watched tasks
  - Smart sorting: Recently selected tasks appear first
  - Runtime duration tracking
  - Exit code display for completed tasks
  - Terminal buffer management

### Utility Functions

`:Telescope vstask clear_inputs`

- Clears all stored input variable values for current session

`:Telescope vstask cleanup_completed_jobs`

- Removes all completed jobs from the job list

### Autodetect

VS Tasks can auto detect certain scripts from your package, such as npm
scripts.

## Configuration

- Configure toggle term use
- Configure terminal behavior
- Cache json conf sets whether the config will be ran every time. If the cache
  is removed, this will also remove cache features such as remembering last
  ran command

Make sure to load the plugin in your telescope config

```lua
require("telescope").load_extension("vstask")
```

```lua
lua <<EOF
require("vstask").setup({
  cache_json_conf = true, -- don't read the json conf every time a task is ran
  cache_strategy = "last", -- can be "most" or "last" (most used / last used)
  config_dir = ".vscode", -- directory to look for tasks.json and launch.json
  support_code_workspace = true -- load from a *.code-workspace file, if available
  telescope_keys = { -- change the telescope bindings used to launch tasks
    vertical = '<C-v>',
    split = '<C-p>',
    tab = '<C-t>',
    current = '<CR>',
    background = '<C-b>',
    watch_job = '<C-w>',
    kill_job = '<C-d>',
    run = '<C-r>',
  },
  autodetect = { -- auto load scripts
    npm = "on"
  },
  terminal = 'nvim',-- can be 'nvim' or 'toggleterm'
  term_opts = {
    vertical = {
      direction = "vertical",
      size = "80"
    },
    horizontal = {
      direction = "horizontal",
      size = "10"
    },
    current = {
      direction = "float",
    },
    tab = {
      direction = 'tab',
    }
  },
  json_parser = vim.json.decode,
  default_tasks = {
        {
          label = " npm install",
          type = "shell",
          command = "npm i",
          filetypes = { "typescript" }, -- remove field to always add
        },
      },
  ignore_input_default = false -- always ignore an input default if `true`
})
EOF
```

### Work with json5 files

VS Code uses json5 which allows use of comments and trailing commas.
If you want to use the same tasks as your teammates, and they leave trailing commas and comments in the project's task.json,
you will need another parser than the default `vim.fn.json_decode`.

A proposed solution:
Add the following to your dependencies.

```lua
lua <<EOF
    {
      'Joakker/lua-json5',
      run = './install.sh'
    }
EOF
```

And add the following option in the setup:

```lua
lua <<EOF
require("vstask").setup({
    json_parser = require('json5').parse
})
EOF
```

## Example

### Tasks.json

In your project root set up `.vscode/tasks.json` (default config directory set to `.vscode`, but can be changed in setup)

```json
{
  "inputs": [
    {
      "default": "",
      "description": "Some term",
      "id": "phrase",
      "type": "promptString"
    },
    {
      "type": "command",
      "id": "cowsay",
      "command": "extension.commandvariable.pickStringRemember",
      "args": {
        "description": "what type of cow?",
        "options": [
          ["normal cow", "mooooo"],
          ["imposture", "bark bark"]
        ]
      }
    }
  ],
  "tasks": [
    {
      "command": "echo ${input:phrase} | cowsay",
      "label": "🐮 Cowsay",
      "problemMatcher": [],
      "type": "shell"
    },
    {
      "command": "echo ${input:cowsay} | cowsay",
      "label": "🐮 Cowsay with arg list",
      "problemMatcher": [],
      "type": "shell"
    },
    {
      "command": "echo ${relativeFile} | cowsay",
      "label": "Relative File",
      "problemMatcher": [],
      "type": "shell"
    },
    {
      "command": "echo ${relativeFileDirname} | cowsay",
      "label": "Relative File Dirname",
      "problemMatcher": [],
      "type": "shell"
    },
    {
      "args": ["hello", "world"],
      "command": "echo ",
      "label": "Arg Hello World",
      "problemMatcher": [],
      "type": "shell"
    },
    {
      "command": "sleep 1 ; echo 'hello from subtask 1' > /tmp/tmp.txt",
      "label": "subtask 1",
      "type": "shell"
    },
    {
      "command": "sleep 1 ; echo 'hello from subtask 2' >> /tmp/tmp.txt",
      "label": "subtask 2",
      "type": "shell"
    },
    {
      "command": "cat /tmp/tmp.txt",
      "label": "hello from subtask",
      "type": "shell",
      "dependsOrder": "sequence",
      "dependsOn": ["subtask 1", "subtask 2"]
    },
    {
      "command": "echo 'starting server' ; sleep 5 ; echo 'stopping server'",
      "label": "server",
      "type": "shell"
    },
    {
      "command": "echo 'starting client' ; sleep 5 ; echo 'stopping client'",
      "label": "client",
      "type": "shell"
    },
    {
      "label": "start server and client",
      "dependsOn": ["server", "client"]
    }
  ],
  "version": "2.0.0"
}
```

### Functions

```lua
lua require("telescope").extensions.vstask.tasks() -- open task list in telescope
lua require("telescope").extensions.vstask.inputs() -- open the input list, set new input
lua require("telescope").extensions.vstask.jobs() -- view and manage all jobs (running and completed)
lua require("telescope").extensions.vstask.history() -- search history of tasks
lua require("telescope").extensions.vstask.close() -- close the task runner (if toggleterm)
lua require("telescope").extensions.vstask.run() -- open menu to type cli cmd and run it with standard bindings
```

You can also configure themes and pass options to the picker

```lua
lua require("telescope").extensions.vstask.tasks(require('telescope.themes').get_dropdown()) -- open task list in telescope
```

You can also grab the last run task and do what you want with it, such as open
it in a new terminal:

```lua
function _RUN_LAST_TASK()
  local vstask_ok, vstask = pcall(require, "vstask")
  if not vstask_ok then
    return
  end
  local cmd = vstask.get_last()
  vim.cmd("vsplit")
  vim.cmd("term " .. cmd)
end
```

## Features to implement

### Full VS Code variable support

All [variables available in VS Code](https://code.visualstudio.com/docs/editor/variables-reference) should also work in this plugin, though they are not all tested.

### Extend support for VS Code schema

At this point only the features I need professionally have been implemented.
The implemented schema elements are as follows:

- [] dependsOn visual layouts
- [] problemMatcher
- [] auto run job on opening certain files

As I do not use VS Code, the current implementation are the elements that seem
most immediately useful. In the future it may be good to look into implementing
other schema elements such as problemMatcher and group.
