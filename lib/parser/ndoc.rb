module Ndoc
  module Parser
    class Ndoc
      def self.name
        return 'ndoc'
      end

      def self.parse(text, args, parser)
        return '<div class="ndoc-inside">%s</div>' % parser.class.new(text, parser.options).to_html
      end
    end
  end
end
