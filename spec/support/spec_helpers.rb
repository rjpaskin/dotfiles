module SpecHelpers
  def custom_inspect(object, text: nil)
    object.tap do
      object.singleton_class.define_method(:inspect) do
        block_given? ? yield(object) : text
      end
    end
  end
end
