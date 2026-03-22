{ inputs, ... }: {
  perSystem = { pkgs, system, ... }: 
    let
      myNeovim = inputs.nixvim.legacyPackages.${system}.makeNixvim {

        colorschemes.onedark = {
          enable = true;
          autoLoad = true;
          settings = {
            style = "deep";
          };
        };

        # --- Core Options ---
        opts = {
        # WHITESPACE
        #     tabstop     - The width of a hard tabstop measured in 'spaces'
        #                   effectively the (maximum) width of an actual tab character.
        #     shiftwidth  - The size of an 'indent'. It's also measured in spaces, so if
        #                   your code base indents with tab characters
        #                   then you want shiftwidth to equal the number of tab
        #                   characters times tabstop.
        #                   This is also used by things like the =, > and < commands.
        #     softtabstop - Setting this to a non-zero value other than tabstop will
        #                   make the tab key (in insert mode) insert a combination of
        #                   spaces (and possibly tabs) to simulate tab stops
        #     expandtab   - Enabling this will make the tab key (in insert mode) insert
        #                   spaces instead of tab characters.
        #                   This also affects the behavior of the retab command.
        #     smarttab    - Enabling this will make the tab key (in insert mode) insert
        #                   spaces or tabs to go to the next indent of the next tabstop
        #                   when the cursor is at the beginning of a line
        #                   (i.e. the only preceding characters are whitespace).
          expandtab = true;
          shiftwidth = 2;
          tabstop = 2;
          softtabstop = 2;
          smarttab = true;
          smartindent = false;
          autoindent = true;
          list = true;
          listchars = "tab:~>,trail:#"; # set listchars=tab:~>,trail:#

          # SEARCH
          ignorecase = true;  # set ignorecase
          smartcase = true;   # set smartcase
          incsearch = true; # incremental search as you type

          cursorline = true; # highlight current line
          # This allows buffers to be hidden if you've modified a buffer.
          # This is almost a must if you wish to use buffers as a replacement for tabs.
          hidden = true;

          number = true;
          relativenumber = true;
          # use case sensitive when there is an upper case in pattern
          wrap = false;       # set nowrap
          #turn off timeout on key mappings ( e.g. it will wait indefinitely after leader)
          timeout = false;    # set notimeout
          #on windows this needs to change to \\ paths
          wildignore = "*/dist-newstyle/*,*/cache/*,*/tmp/*,*.so,*.swp,*.zip,*.o,*.obj,*/.git/*";
          termguicolors = true; # Required for modern Lua bars
          showtabline = 2;      # Always show the bufferline
          laststatus = 3;       # Global statusline (optional, but looks cleaner)
        };

  keymaps = [
    {
      mode = "n"; key = "<leader>t"; action = "mt$x`t";
      options.desc = "remove trailing chars";
    }
    {
      mode = "n"; key = "<leader>s"; action = "^yiwO<esc>pA :: ";
      options.desc = "Insert type signature above";
    }
    # Clear search highlights on Escape
    {
      mode = "n"; key = "<esc>"; action = "<esc>:noh<cr><esc>";
      options.silent = true;
    }

    # Insert empty line below/above without leaving Normal mode
    {
      mode = "n"; key = "<C-j>"; action = "mlo<esc>0D`l";
      options.desc = "Insert empty line below";
    }
    {
      mode = "n"; key = "<C-k>"; action = "mlO<esc>0D`l";
      options.desc = "Insert empty line above";
    }
    { mode = "n"; key = "<C-N>"; action = ":Neotree toggle<CR>";
      options.silent = true;
    }
    { mode = "n"; key = "<leader>L"; action = ":Neotree reveal<CR>";
      options.silent = true;
    }
    { mode = "n"; key = "<leader>cc"; action = ":lua toggle_colorcolumn()<CR>";
      options = { silent = true; desc = "Toggle ColorColumn at 81"; };
    }
    { mode = "n"; key = "<leader>u"; action = "<cmd>UndotreeToggle<CR>";
      options.desc = "Toggle Undo Tree";
    }

    # Move with Ctrl in Insert mode
    { mode = "i"; key = "<C-l>"; action = "<Right>"; }
    { mode = "i"; key = "<C-h>"; action = "<Left>"; }
    { mode = "i"; key = "<C-j>"; action = "<Down>"; }
    { mode = "i"; key = "<C-k>"; action = "<Up>"; }
    # Buffer Navigation (Ctrl+Shift+H/L usually, or Ctrl+H/L depending on terminal)
    { mode = "n"; key = "<C-H>"; action = ":bprevious<CR>"; options.silent = true; }
    { mode = "n"; key = "<C-L>"; action = ":bnext<CR>"; options.silent = true; }
              #   { mode = "n"; key = "<leader>cl"; action = "vim.lsp.codelens.run"; options.desc = "LSP CodeLens"; }
              #   { mode = "n"; key = "<leader>hs"; action = "require('haskell-tools').hoogle.hoogle_signature"; options.desc = "Hoogle Signature"; }
    #hoogle requires db to be generated first, run generate or setup.sh
    { mode = "n"; key = "<leader>h"; action.__raw = "function() require('haskell-tools').hoogle.hoogle_signature() end"; options.silent = true; }
    #FIXME:
    # { mode = "n"; key = "<leader>v"; action.__raw = "function() require('haskell-tools').lsp.buf_eval_all() end"; options.silent = true; }
    { mode = "n"; key = "<leader>cl"; action.__raw = "function() vim.lsp.codelens.run() end"; options.silent = true; }
    { mode = "n"; key = "gk";
      action.__raw = "function()
                      local _, winid = vim.diagnostic.open_float(nil, { scope = 'line' })
                      vim.api.nvim_win_set_config(winid or 0, { focusable = true }) end";
      options.silent = true; }
    { mode = "n"; key = "<leader>d"; action.__raw = "function() require('lsp_lines').toggle() end"; options.silent = true; }
    { mode = "n"; key = "]d"; action = "<cmd> lua vim.diagnostic.goto_next()<CR>"; options.silent = true; }
    { mode = "n"; key = "[d"; action = "<cmd> lua vim.diagnostic.goto_prev()<CR>"; options.silent = true; }
    { mode = "n"; key = "]e"; action = "<cmd> lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })<CR>"; options.silent = true; }
    { mode = "n"; key = "[e"; action = "<cmd> lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })<CR>"; options.silent = true; }
    { mode = "n"; key = "]w"; action = "<cmd> lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })<CR>"; options.silent = true; }
    { mode = "n"; key = "[w"; action = "<cmd> lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })<CR>"; options.silent = true; }
    { mode = "n"; key = "]h"; action = "<cmd> lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.HINT })<CR>"; options.silent = true; }
    { mode = "n"; key = "[h"; action = "<cmd> lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.HINT })<CR>"; options.silent = true; }
    { mode = "n"; key = "<leader>a"; action.__raw = "function() require('actions-preview').code_actions() end"; options.silent = true; }

    #   { mode = "n"; key = "<leader>rf"; action = "function() require('haskell-tools').repl.toggle(vim.api.nvim_buf_get_name(0)) end"; options.desc = "REPL for current file"; lua = true; }
    # -- Toggle a GHCi repl for the current package
    # vim.keymap.set('n', '<leader>rr', ht.repl.toggle, opts)
    # -- Toggle a GHCi repl for the current buffer
    # vim.keymap.set('n', '<leader>rf', function() ht.repl.toggle(vim.api.nvim_buf_get_name(0)) end, opts)
    # vim.keymap.set('n', '<leader>rq', ht.repl.quit, opts)

  ];

        # --- Plugins with dedicated NixVim Modules ---
        plugins = {
          # VIM Essentials
          vim-surround.enable = true;
          commentary.enable = true;

          undotree = {
            enable = true;
            settings = {
              WindowLayout = 2; # This mimics the classic Gundo/Undotree layout
              SetFocusWhenToggle = true;
            };
          };

          # The Top Bar (Buffers as Tabs)
          bufferline = {
            enable = true;
            settings.options = {
              # This makes it look like a real tab bar
              separator_style = "slant"; # Options: "slant", "thick", "thin"
              always_show_bufferline = true;
              show_buffer_close_icons = false;
              show_close_icon = false;
            };
          };

          # The Bottom Bar (Status line)
          lualine = {
            enable = true;
            settings.options = {
              theme = "nightfly"; # Matches your colorscheme
              icons_enabled = true;
              component_separators = { left = "|"; right = "|"; };
              section_separators = { left = ""; right = ""; };
            };
          };

          # IDE Features
          treesitter = {
            enable = true;
            nixvimInjections = true;
            settings = {
              highlight.enable = true;
              highlight.additional_vim_regex_highlighting = false;
              indent.enable = true;
              #FIXME
              # incremental_selection = {
              #    enable = true;
              #    keymaps = {
              #       init_selection = "<leader>n";
              #       node_incremental = "<leader>j";
              #       # -- scope_incremental = "gl";
              #       node_decremental = "<leader>k";
              #     };

              # };
            };
            # Ensure the Haskell grammar is explicitly installed
            grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
              haskell
              # cabal
              # nix # works for flake, fails for nvim.nix TODO
            ];
          };

          # Telescope (File Finder)
    web-devicons.enable = true;
          telescope = {
            enable = true;
            keymaps = {
              # usage: <C-x>  Go to file selection as a split
              # usage: <C-v>  Go to file selection as a vsplit
              # usage: <C-t>  Go to a file in a new tab
              # usage: <C-u>  Scroll up in preview window
              # usage: <C-d>  Scroll down in preview window
              # usage: <C-/>  Show mappings for picker actions (insert mode)
              "<C-p>" = "find_files";
              "<leader>A" = "live_grep";
              "<leader>S" = "grep_string"; #search for under cursor
              "<leader>fb" = "buffers";
              "gr" = "lsp_references";
              "gd" = "lsp_definitions";
              "<leader>H" = "git_commits";
            };
          };

          # Completion (nvim-cmp)
          cmp = {
            enable = true;
            settings = {
              sources = [
                { name = "nvim_lsp"; }
                { name = "haskell-tools"; }
                { name = "buffer"; }
                { name = "path"; }
              ];
             mapping = {
               # Confirm with Enter
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              # Navigate through the list
              "<Tab>" = "cmp.mapping.select_next_item()";
              "<S-Tab>" = "cmp.mapping.select_prev_item()";
              # Use Ctrl+Space to manually trigger completion
              "<C-Space>" = "cmp.mapping.complete()";
              };
            };
          };

          # Haskell & Diagnostics
          neo-tree.enable = true;
          haskell-tools = {
              enable = true;
              autoLoad = true; # just because it's in flake for the repo
              # Formatting provider: 'ormolu', 'fourmolu', 'stylish-haskell', etc.

              # HLS Specific Settings
              settings = {
                hls = {
                  default_settings = {
                    haskell = {
                      formattingProvider = "fourmolu";
                      plugin = {
                        class = { # missing class methods
                          codeLensOn = true;
                        };
                        importLens = { # make import lists fully explicit
                          codeLensOn = false;
                        };
                        refineImports = { # refine imports
                          codeLensOn = true;
                        };
                        tactics = { # wingman
                          codeLensOn = true;
                        };
                        moduleName = { # fix module names
                          globalOn = true;
                        };
                        eval = { # evaluate code snippets
                          codeActionsOn = true;
                          diagnosticsOn = true;
                          globalOn = true;
                        };
                        hlint = {
                          codeActionsOn = true;
                          diagnosticsOn = true;
                          globalOn = true;
                        };
                        # ['ghcide-type-lenses'] = { # show/add missing type signatures
                        #   globalOn = false;
                        # };
                      };
                    };
                  };
                };
              };

            };
          lsp-lines.enable = true;
        };

        # Define the group to prevent duplicate autocmds
        autoGroups = {
          lsp_codelens = { clear = true; };
        };

        # Define the trigger logic
        autoCmd = [
          {
            event = [ "BufEnter" "CursorHold" "InsertLeave" ];
            group = "lsp_codelens";
            pattern = [ "*.hs" "*.lhs" ]; # Added literate haskell just in case
            callback.__raw = "function() vim.lsp.codelens.refresh() end";
          }
        ];

        # --- Plugins without dedicated modules (Vim-Plug style) ---
        extraPlugins = with pkgs.vimPlugins; [
          actions-preview-nvim # Code actions
          # fast-tags-vim
          # nvim-lsp-selection-range #TODO
        ];

        # --- Manual Lua Config for specific plugins ---
        extraConfigLua = ''
          -- Function to toggle colorcolumn
          _G.toggle_colorcolumn = function()
            if vim.wo.colorcolumn == "" then
              vim.wo.colorcolumn = "81"
              print("ColorColumn On")
            else
              vim.wo.colorcolumn = ""
              print("ColorColumn Off")
            end
          end
          -- Setup for actions-preview
          require("actions-preview").setup {
            diff = { algorithm = "patience" }
          }
        '';

      };
    in {
      packages.default = myNeovim;
      packages.myNeovim = myNeovim;
    };
}
