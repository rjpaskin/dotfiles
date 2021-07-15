require "tmpdir"

module SpecHelpers
  module DescribeHelpers
    def using_tmpdir
      attr_accessor :tmpdir

      around do |example|
        Dir.mktmpdir do |tmp|
          self.tmpdir = ShellLib::EditablePath.new(tmp)
          yield tmpdir, example
          example.run
        end
      end
    end
  end

  def custom_inspect(object, text: nil)
    object.tap do
      object.singleton_class.define_method(:inspect) do
        block_given? ? yield(object) : text
      end
    end
  end
end
