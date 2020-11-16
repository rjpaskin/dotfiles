{
  colorize = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16bsjcqb6pg3k94dh1l5g3hhx5g2g4g8rlr76dnc78yyzjjrbayn";
      type = "gem";
    };
    version = "0.7.7";
  };
  flight_plan_cli = {
    dependencies = ["colorize" "git" "httparty" "thor"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04z36p5g6ar2kmwkwsiba4avsspr4m80xyvi02jj0fck1mhcby22";
      type = "gem";
    };
    version = "0.4.3";
  };
  git = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1waikaggw7a1d24nw0sh8fd419gbf7awh000qhsf411valycj6q3";
      type = "gem";
    };
    version = "1.3.0";
  };
  httparty = {
    dependencies = ["json" "multi_xml"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0c9gvg6dqw2h3qyaxhrq1pzm6r69zfcmfh038wyhisqsd39g9hr2";
      type = "gem";
    };
    version = "0.13.7";
  };
  json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qmj7fypgb9vag723w1a49qihxrcf5shzars106ynw2zk352gbv5";
      type = "gem";
    };
    version = "1.8.6";
  };
  multi_xml = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lmd4f401mvravi1i1yq7b2qjjli0yq7dfc4p1nj5nwajp7r6hyj";
      type = "gem";
    };
    version = "0.6.0";
  };
  thor = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yhrnp9x8qcy5vc7g438amd5j9sw83ih7c30dr6g6slgw9zj3g29";
      type = "gem";
    };
    version = "0.20.3";
  };
}