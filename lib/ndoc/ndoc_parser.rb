# -*- coding:utf-8
require 'cgi'

module Ndoc
  class NdocParser
    attr :options
    Outline = Struct.new(:type, :indent, :data)
    def initialize(wiki_text, options = {})
      @wiki_text = wiki_text
      @macro = nil
      @parser = nil

      options[:macro] ||= []
      options[:parser] ||= []
    
      @macro_dir = [File.expand_path(File.dirname(__FILE__) + '/../macro')] + options[:macro]
      @parser_dir = [File.expand_path(File.dirname(__FILE__) + '/../parser')] + options[:parser]
      @macro_dir.reverse!
      @parser_dir.reverse!
      
      @options = options
    end
    
    Statements = [
      [/^= (?<data>.+) =$/, :heading1],
      [/^== (?<data>.+) ==$/, :heading2],
      [/^=== (?<data>.+) ===$/, :heading3],
      [/^==== (?<data>.+) ====$/, :heading4],
      [/^===== (?<data>.+) =====$/, :heading5],
      [/^(?<indent> +)\*(?<data>.*)$/, :unordered_list],
      [/^(?<indent> +)\+(?<data>.*)$/, :ordered_list],
      [/^(?<indent> +)(?<data>.*\:\: .*)$/, :definition_list],
      [/^(?<indent> *)\|\|(?<data>.*)\|\|$/, :table],
      [/^(?<indent> *)\$\$(?<data>.*)\$\$/, :formula],
      [/^(?<indent> *){{(?<parser>{+)(?<data>.*)/, :parse_start],
      [/^(?<indent> *)(?<data>.+)/, :paragraph],
      [/^$/, :break]
    ]
    
    InlineRegexp = [
      [/^\$(?<data>.+?)\$/, :inline_math],
      [/^\&(?<escape>[a-zA-Z0-9#]+?);/, :inline_noformat],
      [/^<<(?<macro>[A-Za-z0-9].*?)>>/, :inline_macro],
      [/^<(?<html>[\/A-Za-z0-9].*?)>/, :inline_noformat],
      [/^,,(?<data>.+?),,/, :inline_subscript],
      [/^\^\^(?<data>.+?)\^\^/, :inline_superscript],
      [/^\[\[(?<data>.+?)\]\]/, :inline_link],
      [/^{{(?<data>.+?)}}/, :inline_image],
      [/^'''(?<data>.+?)'''/, :inline_italic],
      [/^''(?<data>.+?)''/, :inline_bold],
      [/^`(?<data>.+?)`/, :inline_monospace],
      [/^--(?<data>.+?)--/, :inline_strikeout],
      [/^__(?<data>.+?)__/, :inline_underline]
    ]

    def parse_outline
      lines = @wiki_text.gsub("\r", "").split("\n")
      
      result = []
      parse_mode = :normal
      parser_start = ''

       lines.each do |line|
        case parse_mode
        when :normal
          match_data = nil
          type = nil
          Statements.each do |regexp, rtype|
            if regexp =~ line
              match_data = $~
              type = rtype
              break
            end
          end
          if type == :parse_start
            parser_start = match_data[:parser]
            parse_mode = :parser
          end

          if type == :table
            result << Outline.new(type, match_data[:indent].size , '||' + match_data[:data] + '||')
          elsif type.to_s.start_with?('heading')
            result << Outline.new(type, -1, match_data[:data])
          elsif type == :break
            result << Outline.new(type, -1, nil)
          else
            result << Outline.new(type, match_data[:indent].size , match_data[:data])
          end
        when :parser
          if /^(?<indent> *)}}(?<parser>}+) */ =~ line
            if parser_start == $~[:parser].gsub('}', '{')
              result << Outline.new(:parse_end, 0, line)
              parse_mode = :normal
              next
            end
          end
          result << Outline.new(:parsed, 0, line)
        end

      end
      result << Outline.new(:break, -1, nil)
      return result
    end
    
    def parser(parse_type, parse_text)
      parse_type.strip!
      if parse_type == ''
        return '<pre>%s</pre>' % CGI::escapeHTML(parse_text)
      else
        unless @parser
          load_parser @parser_dir
        end

        p = parse_type.split
        if p[0] == 'code'
          return '<pre class="prettyprint %s">%s</pre>' % [p[1..-1].map{|a| CGI::escapeHTML(a)}.join(' '), CGI::escapeHTML(parse_text)]
        else
          begin
            return @parser[p[0].downcase].parse(parse_text, p[1..-1], self)
          rescue
            return "<div>Parser Error!</div>"
          end
        end
      end
    end
    
    def load_parser(dir = [])
      @parser = {}
      dir.each do |d|
        Dir.glob(d + "/*.rb").each do |file|
          require file
        end
      end

      Ndoc::Parser.constants(false).each do |c|
        t = Ndoc::Parser.const_get(c, false)
        @parser[t.name.downcase] = t
      end
    end


    def parse_inline(text)
      result = ''
      while text.length > 0
        found = nil
        InlineRegexp.each do |regexp, func|
          if regexp =~ text
            match_data = $~
            text = text[match_data.end(0)..-1]
            result += self.send(func, match_data)
            found = true
            break
          end
        end
          unless found
          result += CGI::escapeHTML(text[0])
          text = text[1..-1]
        end
      end
      return result
    end
    
    def load_macro(dir = [])
      @macro = {}
      dir.each do |d|
        Dir.glob(d + "/*.rb").each do |file|
          require file
        end
      end

      Ndoc::Macro.constants(false).each do |c|
        t = Ndoc::Macro.const_get(c, false)
        @macro[t.name.downcase] = t
      end
    end
  
    def to_html()
      outlines = parse_outline
      @html = ""

      @stack = [] # indent stack
      @indent = -1
      @indent_type = nil
      parse_text, parse_type = nil, nil
      outlines.each do |outline|
        if outline.type != :parsed && outline.type != :parse_end
          change_indent(outline)
        end
        case outline.type
        when :heading1, :heading2, :heading3, :heading4, :heading5
          tag = 'h%s' % outline.type.to_s.gsub('heading', '')
          @html << "%s%s%s" % ["<#{tag} class=\"ndoc-#{outline.type.to_s}\">", outline.data, "</#{tag}>"]
        when :paragraph
          @html << " " + parse_inline(outline.data)
        when :ordered_list, :unordered_list
          @html << "<li>%s" % parse_inline(outline.data)
        when :definition_list
          dd = outline.data.split('::')[0]
          @html << "<dt>%s</dt><dd>%s" % [parse_inline(dd), parse_inline(outline.data[(dd.size + 2)..-1])]
        when :parse_start
          parse_text = ''
          parse_type = outline.data
        when :parsed
          parse_text += outline.data + "\n"
        when :parse_end
          @html << parser(parse_type, parse_text)
        when :formula
          @html << outline_math(outline)
        end
      end
      return @html
    end
    
    def outline_math(outline)
      return ("\\[ %s \\]" % CGI::escapeHTML(outline.data))
    end

    def inline_math(match_data)
      return "\\(%s\\)" % CGI::escapeHTML(match_data[:data])
    end
    
    def inline_noformat(match_data)
      return match_data.to_s
    end
    
    def inline_macro(match_data)
      unless @macro
        load_macro(@macro_dir)
      end
      macro = match_data[:macro].split
      begin
        return @macro[macro[0].downcase].macro(macro[1..-1], self)
      rescue
        return '<div>Macro error</div>'
      end
    end

    def inline_subscript(match_data)
      return '<sub>%s</sub>' % parse_inline(match_data[:data])
    end

    def inline_superscript(match_data)
      return '<sup>%s</sup>' % parse_inline(match_data[:data])
    end

    def inline_link(match_data)
      res = match_data[:data].split('|')
      url = url(res[0])[0]
      if res[1]
        text = res[1]
      else
        text = url(res[0])[1]
      end
      return '<a href="%s">%s</a>' % [CGI::escapeHTML(url),CGI::escapeHTML(text)]
    end
    def inline_image(match_data)
      res = match_data[:data].split('|')
      url = url(res[0])[0]
      if res[1]
        text = res[1]
      else
        text = url(res[0])[1]
      end
      return '<img src="%s" alt="%s">' % [CGI::escapeHTML(url),CGI::escapeHTML(text)]
    end
  
    def inline_italic(match_data)
      return '<i>%s</i>' % parse_inline(match_data[:data])
    end

    def inline_bold(match_data)
      return '<b>%s</b>' % parse_inline(match_data[:data])
    end
    
    def inline_monospace(match_data)
      return '<span style="font-family: monospace;">%s</span>' % CGI::escapeHTML(match_data[:data])
    end

    def inline_strikeout(match_data)
      return '<del>%s</del>' % parse_inline(match_data[:data])
    end
    
    def inline_underline(match_data)
      return '<span style="text-decoration: underline;">%s</span>' % parse_inline(match_data[:data])
    end 
    
    def url(url)
      return [url, url]
    end

    private
    def change_indent(outline)
      if @indent >= outline.indent
        while @indent > outline.indent
          @html << close_indent(@stack.pop)
          @indent -= 1
        end
        return if @indent == -1

        if @stack.last != indent_type(outline.type) && indent_type(outline.type) != :normal
          @html << close_indent(@stack.pop)
          @stack << indent_type(outline.type)
          @html << open_indent(@stack.last)
        end
      else
        while @indent < outline.indent - 1
          @indent += 1
          if @indent == 0
            @stack << :top
          else
            @stack << :normal
          end
          @html << open_indent(@stack.last)
        end

        @indent += 1
        if @indent == 0
            @stack << :top
        else
            @stack << indent_type(outline.type)
        end
        @html << open_indent(@stack.last)
      end
    end

    def indent_type(type)
      case type
      when :ordered_list
        :ol
      when :unordered_list
        :ul
      when :definition_list
        :dl
      else
        :normal
      end
    end

    def open_indent(type)
      case type
      when :ol
        '<ol class="ndoc-indent">'
      when :ul
        '<ul class="ndoc-indent">'
      when :dl
        '<dl>'
      when :top
        '<div class="ndoc-top">'  
      when :normal
        '<div class="ndoc-indent">'
      end
    end

    def close_indent(type)
      case type
      when :ol
        '</ol>'
      when :ul
        '</ul>'
      when :dl
        '</dl>'
      when :top
        '</div>'
      when :normal
        '</div>'
      end
    end
  end
end

