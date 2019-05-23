require 'yaml'

module Noticent
  class View

    attr_reader :template_content
    attr_reader :filename
    attr_reader :layout_content
    attr_reader :data
    attr_reader :raw_content
    attr_reader :data_content
    attr_reader :content

    def initialize(filename, layout: '')
      raise ViewNotFound, "view #{filename} not found" unless File.exist?(filename)
      raise ViewNotFound, "layout #{layout} not found" if layout != '' && !File.exist?(layout)

      @filename = filename
      @template_content = File.read(filename)
      @layout_content = layout != '' ? File.read(layout) : '<%= yield %>'
    end

    def process
      parse
      render_content
      render_data
      read_data
    end

    private

    def render_content
      templates = [@raw_content, @layout_content]
      templates.inject(nil) do |prev, temp|
        _render(temp) { prev }
      end
    end

    def render_data
      _render(@data_content)
    end

    def _render(template)
      ERB.new(template).result(binding)
    end

    def parse
      result = {}

      # is there front matter?
      match = FRONTMATTER.match(@template_content)
      if !match.nil?
        result[:frontmatter] = match[1]
        result[:content] = match[2]
      else
        result[:content] = @template_content
      end

      @data_content = result[:frontmatter]
      @raw_content = result[:content]
    end

    def read_data
      if @data_content.nil?
        @data = nil
      else
        data = ::YAML.safe_load(@data_content)
        @data = data.deep_symbolize_keys
      end

      @content = @template_content
    end

    FRONTMATTER = Regexp.new(/([\s\S]*)^---\s*$([\s\S]*)/)

  end
end