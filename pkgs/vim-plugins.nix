{ fetchFromGitHub, vimUtils }:

{
  vim-bundler = vimUtils.buildVimPlugin {
    name = "vim-bundler";
    src = fetchFromGitHub {
      owner = "tpope";
      repo = "vim-bundler";
      rev = "c261509e78fc8dc55ad1fcf3cd7cdde49f35435c";
      hash = "sha256-z8ZQhCITVxW+RShX5drAQm4aKFWT5K3yw72nBcwVGa4=";
    };
  };

  vim-mkdir = vimUtils.buildVimPlugin {
    name = "vim-mkdir";
    src = fetchFromGitHub {
      owner = "pbrisbin";
      repo = "vim-mkdir";
      rev = "af9c990cfe8962a4ea981023b329927891664a34";
      hash = "sha256-GttPI6PgIc1jcuOt6aGx6nbk4drVaOqgYygB9IFILEM=";
    };
  };

  vim-rspec = vimUtils.buildVimPlugin {
    name = "vim-rspec";
    src = fetchFromGitHub {
      owner = "thoughtbot";
      repo = "vim-rspec";
      rev = "c0251b2e40eba5c9fb145adb8896424fa11972da";
      hash = "sha256-PWOqs4AOCeKEDNIqAmoVD3sMLmmDiwQGNEO8hJz8fkY=";
    };
  };

  vim-ruby-refactoring = vimUtils.buildVimPlugin {
    name = "vim-ruby-refactoring";
    src = fetchFromGitHub {
      owner = "ecomba";
      repo = "vim-ruby-refactoring";
      rev = "6447a4debc3263a0fa99feeab5548edf27ecf045";
      hash = "sha256-kNVj+a+Up7wPByzbcN8CL10ryOwVOs9IZ64O/6u7/Lk=";
    };
  };

  vim-rubyhash = vimUtils.buildVimPlugin {
    name = "vim-rubyhash";
    src = fetchFromGitHub {
      owner = "rorymckinley";
      repo = "vim-rubyhash";
      rev = "d020a8eeac40a55617a72aa135b702b6da0c9b62";
      hash = "sha256-oUFoIQvXefcnBcAOzl9+7W6Ws16ZnagU3kTiwvmhUJs=";
    };
  };

  vim-textobj-rubyblock = vimUtils.buildVimPlugin {
    name = "vim-textobj-rubyblock";
    src = fetchFromGitHub {
      owner = "nelstrom";
      repo = "vim-textobj-rubyblock";
      rev = "2b882e2cc2599078f75e6e88cd268192bf7b27bf";
      hash = "sha256-2adnEdz8aPFjSTNwLuV7WFAlcYnVPIujwLdxX4gC9aQ=";
    };
  };

  vim-yaml-helper = vimUtils.buildVimPlugin {
    name = "vim-yaml-helper";
    src = fetchFromGitHub {
      owner = "lmeijvogel";
      repo = "vim-yaml-helper";
      rev = "403ff568e336def133b55d25a3f9517f406054cc";
      hash = "sha256-Lj3/osYITCxUERfiP5iNU2od2teR1e4lMLEDPGESDg0=";
    };
  };
}
