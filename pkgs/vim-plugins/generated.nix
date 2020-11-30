# This file has been generated by ./pkgs/misc/vim-plugins/update.py. Do not edit!
{ lib, buildVimPluginFrom2Nix, fetchFromGitHub, overrides ? (self: super: {}) }:

let
  packages = ( self:
{
  conjure = buildVimPluginFrom2Nix {
    pname = "conjure";
    version = "2020-11-01";
    src = fetchFromGitHub {
      owner = "Olical";
      repo = "conjure";
      rev = "a4c31e1c0136e943fa7dd48ecc11849158d3554e";
      sha256 = "0xvz1s3lx75k9fgn319b0q6d8vj7cpw6mj2xkh73qmaqvvx3bni1";
    };
    meta.homepage = "https://github.com/Olical/conjure/";
  };

  splitjoin-vim = buildVimPluginFrom2Nix {
    pname = "splitjoin-vim";
    version = "2020-10-25";
    src = fetchFromGitHub {
      owner = "AndrewRadev";
      repo = "splitjoin.vim";
      rev = "1c1b94a6aa218c429421c82bcc56a216301b6e85";
      sha256 = "1jkny1ag82zvkfjvbzrkkh4s54jcf9hq5n9ak3g691zcddhmrp17";
      fetchSubmodules = true;
    };
    meta.homepage = "https://github.com/AndrewRadev/splitjoin.vim/";
  };

  vim-alias = buildVimPluginFrom2Nix {
    pname = "vim-alias";
    version = "2020-02-15";
    src = fetchFromGitHub {
      owner = "Konfekt";
      repo = "vim-alias";
      rev = "f0aa2bf9fbaa9e0d16c4b6d32841a126e41b9202";
      sha256 = "17cay94gvaqvxhq3vij2f8pcyfpgrf74lhwbwpwfciwqs9czg0hw";
    };
    meta.homepage = "https://github.com/Konfekt/vim-alias/";
  };

  vim-bundler = buildVimPluginFrom2Nix {
    pname = "vim-bundler";
    version = "2020-09-26";
    src = fetchFromGitHub {
      owner = "tpope";
      repo = "vim-bundler";
      rev = "40efd19c0a4447ff2f142d3d89735ac3d637a355";
      sha256 = "1vwvm708cdrrlyc1ys2i9qj2mv2mrcp183jgpn1bq0nnpz2w09w1";
    };
    meta.homepage = "https://github.com/tpope/vim-bundler/";
  };

  vim-crystal = buildVimPluginFrom2Nix {
    pname = "vim-crystal";
    version = "2020-10-12";
    src = fetchFromGitHub {
      owner = "vim-crystal";
      repo = "vim-crystal";
      rev = "bc4f115de69fdeb4419e2cbef1981f0b39c6d972";
      sha256 = "17qr5rbchpgh75g14i5m899zp56c4zkj0yaj0h0p4x184xkjrxl3";
    };
    meta.homepage = "https://github.com/vim-crystal/vim-crystal/";
  };

  vim-mkdir = buildVimPluginFrom2Nix {
    pname = "vim-mkdir";
    version = "2019-04-29";
    src = fetchFromGitHub {
      owner = "pbrisbin";
      repo = "vim-mkdir";
      rev = "f0ba7a7dc190a0cedf1d827958c99f3718109cf0";
      sha256 = "0kp2n1wfmlcxcwpqp63gmzs8ihdhd5qcncc4dwycwr1sljklarnw";
    };
    meta.homepage = "https://github.com/pbrisbin/vim-mkdir/";
  };

  vim-prettier = buildVimPluginFrom2Nix {
    pname = "vim-prettier";
    version = "2020-11-03";
    src = fetchFromGitHub {
      owner = "prettier";
      repo = "vim-prettier";
      rev = "bc7ae99c38a1d0f58380347515b212f93df5e68e";
      sha256 = "1czdzrhlsac08lgb0chqr1nbkwacggp74s02vfv3xsa1cqj3b1pw";
    };
    meta.homepage = "https://github.com/prettier/vim-prettier/";
  };

  vim-rails = buildVimPluginFrom2Nix {
    pname = "vim-rails";
    version = "2020-09-29";
    src = fetchFromGitHub {
      owner = "tpope";
      repo = "vim-rails";
      rev = "2c42236cf38c0842dd490095ffd6b1540cad2e29";
      sha256 = "0nhf4qd7dchrzjv2ijcddav72qb121c9jkkk06agsv23l9rb31pv";
    };
    meta.homepage = "https://github.com/tpope/vim-rails/";
  };

  vim-rspec = buildVimPluginFrom2Nix {
    pname = "vim-rspec";
    version = "2017-01-30";
    src = fetchFromGitHub {
      owner = "thoughtbot";
      repo = "vim-rspec";
      rev = "52a72592b6128f4ef1557bc6e2e3eb014d8b2d38";
      sha256 = "09prk06rrbs8pgfm4iz88sp151p6pi9bl76p6macvv5nxv72d9j8";
    };
    meta.homepage = "https://github.com/thoughtbot/vim-rspec/";
  };

  vim-ruby-refactoring = buildVimPluginFrom2Nix {
    pname = "vim-ruby-refactoring";
    version = "2011-12-28";
    src = fetchFromGitHub {
      owner = "ecomba";
      repo = "vim-ruby-refactoring";
      rev = "6447a4debc3263a0fa99feeab5548edf27ecf045";
      sha256 = "1fgwpfmzy3mfcx4cyfhmxk42np9g0bgp1nrc0w7vr9wlmzwn7mch";
    };
    meta.homepage = "https://github.com/ecomba/vim-ruby-refactoring/";
  };

  vim-rubyhash = buildVimPluginFrom2Nix {
    pname = "vim-rubyhash";
    version = "2011-12-27";
    src = fetchFromGitHub {
      owner = "rorymckinley";
      repo = "vim-rubyhash";
      rev = "d020a8eeac40a55617a72aa135b702b6da0c9b62";
      sha256 = "16shl7ww5qj4vqaai7crbsrrcvpdgrgww3n00lkzfyfp1chnhhd1";
    };
    meta.homepage = "https://github.com/rorymckinley/vim-rubyhash/";
  };

  vim-textobj-rubyblock = buildVimPluginFrom2Nix {
    pname = "vim-textobj-rubyblock";
    version = "2016-09-13";
    src = fetchFromGitHub {
      owner = "nelstrom";
      repo = "vim-textobj-rubyblock";
      rev = "2b882e2cc2599078f75e6e88cd268192bf7b27bf";
      sha256 = "197m0a45ywdpq2iqng6mi5qjal2qggjjww1k95iz2s7wvh8ng9yr";
    };
    meta.homepage = "https://github.com/nelstrom/vim-textobj-rubyblock/";
  };

  vim-textobj-variable-segment = buildVimPluginFrom2Nix {
    pname = "vim-textobj-variable-segment";
    version = "2019-12-30";
    src = fetchFromGitHub {
      owner = "Julian";
      repo = "vim-textobj-variable-segment";
      rev = "78457d4322b44bf89730e708b62b69df48c39aa3";
      sha256 = "14dcrnk83hj4ixrkdgjrk9cf0193f82wqckdzd4w0b76adf3habj";
    };
    meta.homepage = "https://github.com/Julian/vim-textobj-variable-segment/";
  };

  vim-yaml-helper = buildVimPluginFrom2Nix {
    pname = "vim-yaml-helper";
    version = "2020-03-11";
    src = fetchFromGitHub {
      owner = "lmeijvogel";
      repo = "vim-yaml-helper";
      rev = "403ff568e336def133b55d25a3f9517f406054cc";
      sha256 = "038f29hkq0xi60jyxmciszd1ssjkinc3zqhp25a2qk08qsigyg9f";
    };
    meta.homepage = "https://github.com/lmeijvogel/vim-yaml-helper/";
  };

});
in lib.fix' (lib.extends overrides packages)