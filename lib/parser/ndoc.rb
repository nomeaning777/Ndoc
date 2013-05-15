module Ndoc
  module Parser
    class Ndoc
      def self.name
        return 'ndoc'
      end

      def self.parse(text, args, parser)
        return '<div style="padding: 6px; border-radius: 5px; margin-left:4px; margin-right: 4px; border: solid 1px #999; ">%s</div>' % parser.class.new(text, parser.options).to_html
      end
    end
  end
end
