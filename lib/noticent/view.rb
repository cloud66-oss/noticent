require 'yaml'

module Noticent
  class View

    attr_reader :file
    attr_reader :data
    attr_reader :content

    def initialize(file)
      raise ViewNotFound, "view #{file} not found" unless File.exist?(file)

      @file = file

      loaded = load
      @data = loaded[:data]
      @content = loaded[:content]
    end

    def data?
      !@data.nil?
    end

    private

    def parse
      result = {}
      content = File.read(@file)
      # is there front matter?
      match = FRONTMATTER.match(content)
      if !match.nil?
        result[:frontmatter] = match[1]
        result[:content] = match[2]
      else
        result[:content] = content
      end

      result
    end

    def load
      parsed = parse
      return { content: parsed[:content] } if parsed[:frontmatter].nil?

      data = ::YAML.safe_load(parsed[:frontmatter])
      { data: data.deep_symbolize_keys, content: parsed[:content] }
    end

    FRONTMATTER = Regexp.new(/([\s\S]*)^---\s*$([\s\S]*)/)

  end
end