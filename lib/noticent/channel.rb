# frozen_string_literal: true

module Noticent
  class Channel
    @@default_ext = :erb
    @@default_format = :html

    def initialize(config, recipients, payload, context)
      @config = config
      @recipients = recipients
      @payload = payload
      @context = context
      @current_user = payload.current_user if payload.respond_to? :current_user
    end

    def render_within_context(template, content)
      rendered_content = ERB.new(content).result(get_binding)
      template.nil? ? rendered_content : ERB.new(template).result(get_binding { rendered_content })
    end

    protected

    attr_reader :payload
    attr_reader :recipients
    attr_reader :context

    class << self
      def default_format(format)
        @@default_format = format
      end

      def default_ext(ext)
        @@default_ext = ext
      end
    end

    def get_binding
      binding
    end

    def current_user
      raise Noticent::NoCurrentUser if @current_user.nil?

      @current_user
    end

    def render(format: @@default_format, ext: @@default_ext, layout: '')
      alert_name = caller[0][/`.*'/][1..-2]
      channel_name = self.class.name.split('::').last.underscore
      view_filename, layout_filename = filenames(channel: channel_name, alert: alert_name, format: format, ext: ext, layout: layout)

      raise Noticent::ViewNotFound, "view #{view_filename} not found" unless File.exist?(view_filename)

      view = View.new(view_filename, template_filename: layout_filename, channel: self)
      view.process

      [view.data, view.content]
    end

    private

    def view_file(channel:, alert:, format:, ext:)
      File.join(@config.view_dir, channel, "#{alert}.#{format}.#{ext}")
    end

    def filenames(channel:, alert:, format:, ext:, layout:)
      view_filename = view_file(channel: channel, alert: alert, format: format, ext: ext)
      layout_filename = ''
      layout_filename = File.join(@config.view_dir, 'layouts', "#{layout}.#{format}.#{ext}") unless layout == ''

      return view_filename, layout_filename
    end

  end
end
