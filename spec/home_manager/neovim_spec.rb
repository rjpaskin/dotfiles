RSpec.describe "Neovim" do
  describe profile_bin("nvim") do
    it { should be_an_executable }
  end

  describe program("nvim") do
    its(:location) { should eq profile_bin }
  end

  context "aliases" do
    let(:version_output) { run_in_shell!("nvim --version").stdout }

    it "has Vim aliases that point to Neovim" do
      aggregate_failures do
        expect(run_in_shell!("vim --version").stdout).to eq(version_output)
        expect(run_in_shell!("vi --version").stdout).to eq(version_output)
      end
    end
  end

  context "config" do
    describe neovim_packages do
      # Not testing everything here, just the essentials, with the assumption
      # that if these are installed, others should be too
      let(:packages) do
        %w[
          vim-sensible
          vim-commentary
          vim-surround
          vim-repeat
          vim-unimpaired
          editorconfig-vim
          vim-tmux-navigator
          ale
          telescope.nvim
          deoplete.nvim
          vim-airline
        ]
      end

      it { should include(*packages) }
    end

    # Not testing everything here, again just assuming that if these are
    # set, others should be as well
    it "sets basic settings" do
      aggregate_failures do
        expect(neovim_variable "&encoding").to eq("utf-8")
        expect(neovim_variable "g:mapleader").to eq(" ")
        expect(neovim_variable "&number").to eq(1)
        expect(neovim_variable "&colorcolumn").to eq("")
      end
    end

    it "sets key bindings" do
      aggregate_failures do
        expect(neovim_keymappings["n"]["<Space>w"]).to eq(":write<CR>")
        expect(neovim_keymappings["n"]["<Space>'"]).to include("PreserveWindowState", "cs", "<CR>")
        expect(neovim_keymappings["n"]["<Space>\""]).to include("PreserveWindowState", "cs", "<CR>")
        expect(neovim_keymappings["n"]["<Space>="]).to include("PreserveWindowState", "gg=G", "<CR>")

        # From vim-tmux-navigator
        expect(neovim_keymappings["n"]["<C-H>"]).to include("TmuxNavigateLeft")
        expect(neovim_keymappings["n"]["<C-L>"]).to include("TmuxNavigateRight")
      end
    end

    it "sets correct colour scheme" do
      aggregate_failures do
        expect(neovim_variable "g:colors_name").to eq("one")
        expect(neovim_variable "&background").to eq("light")
        expect(neovim_variable "g:airline_theme").to eq("one")
      end
    end

    context "Deoplete" do
      it "enables Deoplete at startup and adds key bindings" do
        aggregate_failures do
          expect(neovim_variable "g:deoplete#enable_at_startup").to eq(1)

          expect(neovim_keymappings["i"]["<Tab>"]).to include("check_back_space", "deoplete#manual_complete()")
          expect(neovim_keymappings["i"]["<S-Tab>"]).to include("pumvisible()")
        end
      end
    end

    context "telescope.nvim" do
      it "sets key bindings" do
        aggregate_failures do
          keys = %w[u uu ub uo ur up um uc us uw uv uh uf uj].map {|key| "<Space>#{key}" }

          expect(neovim_keymappings["n"].slice(*keys).values).to all start_with(":Telescope")
        end
      end
    end
  end

  describe xdg_config_path("nvim/after/plugin/alias.vim") do
    it { should include(":Alias ag grep") }
  end
end
