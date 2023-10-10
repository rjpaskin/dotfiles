module ShellLib
  module PathHelpers
    def file(path_str)
      Path.new(path_str)
    end

    alias_method :directory, :file

    HOME = Path.new("~").freeze
    NIX_PROFILE = HOME.join(".nix-profile").freeze

    def profile_path(path)
      NIX_PROFILE.join(path)
    end

    def profile_bin(path = nil)
      NIX_PROFILE.join("bin", path.to_s)
    end

    def home
      HOME
    end

    def home_path(path)
      HOME.join(path)
    end

    def xdg_config_path(path)
      home_path(".config/#{path}")
    end

    def xdg_data_path(path)
      home_path(".local/share/#{path}")
    end

    def xdg_state_path(path)
      home_path(".local/state/#{path}")
    end

    DOTFILES = Path.new(
      File.expand_path("../..", __dir__)
    ).freeze

    def dotfiles_path(path = nil)
      DOTFILES.join(path.to_s)
    end

    NIX_PROFILES = Path.new(
      "/nix/var/nix/profiles/per-user"
    ).freeze

    def nix_profiles_path(path = nil, user: ENV["USER"], xdg: false)
      if xdg
        file("~#{user}/.local/state/nix/profiles").join(path.to_s)
      else
        NIX_PROFILES.join(user, path.to_s)
      end
    end

    ICLOUD = HOME.join("Library/Mobile Documents/com~apple~CloudDocs")

    def icloud_path(path = nil)
      ICLOUD.join(path.to_s)
    end

    HOMEBREW_PREFIX = Path.new(
      ShellLib.arm? ? "/opt/homebrew" : "/usr/local"
    ).freeze

    def homebrew_path(path = nil)
      HOMEBREW_PREFIX.join(path.to_s)
    end

    extend self
  end
end
