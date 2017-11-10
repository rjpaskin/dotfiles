# rbenv-each doesn't have a version, so we just use the URL of the latest commit
# as a version instead.
#
# Install with --HEAD to ensure rbenv-each is always up-to-date.
class RbenvEach < Formula
  desc "rbenv plugin to run a command across all installed rubies"
  homepage "https://github.com/rbenv/rbenv-each"
  # Latest version as of 2017-11-10
  url "https://github.com/rbenv/rbenv-each/archive/ba46d74943730dc4e1ff2ba5bc813c509b122768.zip"
  sha256 "8695ed259f30e1197e8f85527dceab4cc00c51084ad15f14325e9fdfe3ebd5e6"
  head "https://github.com/rbenv/rbenv-each.git"

  bottle :unneeded

  depends_on :rbenv

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_match /^each$/, shell_output("rbenv commands")
  end
end
