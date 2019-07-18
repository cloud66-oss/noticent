# frozen_string_literal: true

require "yaml"

module Noticent
  class View
    # these are the attributes we should use in most cases
    attr_reader :data             # frontmatter in hash form with symbolized keys
    attr_reader :content          # content rendered

    # these are mostly for debug and testing purposes
    attr_reader :view_content     # contents of the view itself
    attr_reader :filename         # view filename
    attr_reader :template_content # contents of the template
    attr_reader :raw_content      # content in their raw (pre render) format
    attr_reader :raw_data         # frontmatter in their raw (pre render) format
    attr_reader :rendered_data    # frontmatter rendered in string format

    def initialize(filename, template_filename: "", channel:)
      raise ViewNotFound, "view #{filename} not found" unless File.exist?(filename)
      raise ViewNotFound, "template #{template_filename} not found" if template_filename != "" && !File.exist?(template_filename)
      raise ArgumentError, "channel is nil" if channel.nil?

      @filename = filename
      @view_content = File.read(filename)
      @template_content = template_filename != "" ? File.read(template_filename) : "<%= @content %>"
      @template_filename = template_filename != "" ? template_filename : ""
      @channel = channel
    end

    def process(context)
      parse
      render_data(context)
      read_data
      # TODO this is nasty. we need to refactor to have an independent render context which somehow merges the binding with the channel.
      @channel.data = @data
      render_content(context)
    end

    private

    def render_content(context)
      @content = @channel.render_within_context(template: @template_content, content: @raw_content, context: context)
    end

    def render_data(context)
      if @raw_data.nil?
        @rendered_data = nil
        return
      end

      @rendered_data = @channel.render_within_context(template: nil, content: @raw_data, context: context)
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

      @raw_data = result[:frontmatter]
      @raw_content = result[:content]
    end

    def read_data
      if @raw_data.nil?
        @data = nil
      else
        raise ArgumentError, "read_data was called before rendering" if @rendered_data.nil?

        data = ::YAML.safe_load(@rendered_data)
        @data = data.deep_symbolize_keys
      end
    end

    FRONTMATTER = Regexp.new(/([\s\S]*)^---\s*$([\s\S]*)/)
  end
end
