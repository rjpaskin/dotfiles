module GitCI
  module Tty
    module_function

    def red;    bold 31; end
    def green;  bold 32; end
    def yellow; bold 33; end
    def blue;   bold 34; end
    def purple; bold 35; end
    def cyan;   bold 36; end
    def grey;   bold 37; end

    def reset; escape 0; end

    def bold(n = 39)
      escape "1;#{n}"
    end

    def underline
      escape "4;39"
    end

    def escape(n)
      "\e[#{n}m" if STDOUT.tty?
    end
  end
end
