module Ndoc
  module Macro
    class Br
      def self.name
        return 'br'
      end

      def self.macro(parser, params)
        return "<br>"
      end
    end
  end
end
