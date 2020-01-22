cask "cypress" do
  version "3.3.1"
  sha256 :no_check

  url "https://cdn.cypress.io/desktop/#{version}/darwin-x64/cypress.zip"
  name "Cypress"
  homepage "https://cypress.io"

  app "Cypress.app"
end
