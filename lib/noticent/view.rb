require 'yaml'

module Noticent
  class View

    class TemplateRenderer; end

    # these are the attributes we should use in most cases
    attr_reader :data             # frontmatter in hash form with symbolized keys
    attr_reader :content          # content rendered

    # these are mostly for debug and testing purposes
    attr_reader :view_content     # contents of the view itself
    attr_reader :filename         # view filename
    attr_reader :template_content # contents of any layout template
    attr_reader :raw_content      # content in their raw (pre render) format
    attr_reader :data_content     # frontmatter in their raw (pre render) format
    attr_reader :rendered_data    # frontmatter rendered in string format

    def initialize(filename, template: '', binding_context:)
      raise ViewNotFound, "view #{filename} not found" unless File.exist?(filename)
      raise ViewNotFound, "template #{template} not found" if template != '' && !File.exist?(template)
      raise ArgumentError, 'binding is nil' if binding_context.nil?

      @filename = filename
      @view_content = File.read(filename)
      @template_content = template != '' ? File.read(template) : '<%= yield %>'
      @binding_context = binding_context
    end

    def process
      parse
      render_content
      render_data
      read_data
    end

    private

    def render_content
      erb = ERB.new(@template_content)
      erb.def_method(TemplateRenderer, 'render', @filename)

      @content = TemplateRenderer.new.render { @view_content }
    end

    def render_data
      @rendered_data = ERB.new(@data_content).result(@binding_context)
    end

    def parse
      result = {}

      # is there front matter?
      match = FRONTMATTER.match(@view_content)
      if !match.nil?
        result[:frontmatter] = match[1]
        result[:content] = match[2]
      else
        result[:content] = @view_content
      end

      @data_content = result[:frontmatter]
      @raw_content = result[:content]
    end

    def read_data
      if @data_content.nil?
        @data = nil
      else
        raise ArgumentError, 'read_data was called before rendering' if @rendered_data.nil?

        data = ::YAML.safe_load(@rendered_data)
        @data = data.deep_symbolize_keys
      end
    end

    FRONTMATTER = Regexp.new(/([\s\S]*)^---\s*$([\s\S]*)/)

  end
end