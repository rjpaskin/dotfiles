require File.join(
  ENV["HOME"],
  "Library/Mobile Documents/com~apple~CloudDocs",
  "dotfiles/Formula/generic"
)

GenericBrewGem.generate(__FILE__, ruby_formula: "ruby@2.3")
