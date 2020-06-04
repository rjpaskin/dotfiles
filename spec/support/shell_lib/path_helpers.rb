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

    def profile_bin(path)
      profile_path("bin/#{path}")
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
  end
end
