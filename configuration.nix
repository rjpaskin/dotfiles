{ config, ... }:

{
  environment.variables = {
    EDITOR = "nvim"; # override default of `nano`
  };
}
