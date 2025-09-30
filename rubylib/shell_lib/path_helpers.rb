module ShellLib
  module PathHelpers
    def file(path_str)
      Path.new(path_str)
    end

    alias_method :directory, :file

    HOME = Path.new("~").freeze
    NIX_PROFILE = Path.new("/etc/profiles/per-user/#{ENV["USER"]}").freeze

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

    NIX_DARWIN_SYSTEM = Path.new("/run/current-system/sw")

    def nix_darwin_system_path(path = nil)
      NIX_DARWIN_SYSTEM.join(path.to_s)
    end

    def nix_darwin_bin(path = nil)
      nix_darwin_system_path.join("bin", path.to_s)
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
