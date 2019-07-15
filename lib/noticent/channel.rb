# frozen_string_literal: true

module Noticent
  class Channel
    class_attribute :default_ext, default: :erb
    class_attribute :default_format, default: :html

    def initialize(config, recipients, payload, configuration)
      @config = config
      @recipients = recipients
      @payload = payload
      @configuration = configuration
      @current_user = payload.current_user if payload.respond_to? :current_user
      @routes = Rails.application.routes.url_helpers
    end

    def render_within_context(template:, content:, context:)
      @content = ERB.new(content).result(context)
      template.nil? ? @content : ERB.new(template).result(binding)
    end

    protected

    attr_reader :payload
    attr_reader :recipients
    attr_reader :configuration

    def current_user
      raise Noticent::NoCurrentUser if @current_user.nil?

      @current_user
    end

    def render(format: default_format, ext: default_ext, layout: "")
      alert_name = caller[0][/`.*'/][1..-2]
      channel_name = self.class.name.split("::").last.underscore
      view_filename, layout_filename = filenames(channel: channel_name, alert: alert_name, format: format, ext: ext, layout: layout)

      raise Noticent::ViewNotFound, "view #{view_filename} not found" unless File.exist?(view_filename)

      view = View.new(view_filename, template_filename: layout_filename, channel: self)
      view.process(binding)

      [view.data, view.content]
    end

    private

    def view_file(channel:, alert:, format:, ext:)
      File.join(@config.view_dir, channel, "#{alert}.#{format}.#{ext}")
    end

    def filenames(channel:, alert:, format:, ext:, layout:)
      view_filename = view_file(channel: channel, alert: alert, format: format, ext: ext)
      layout_filename = ""
      layout_filename = File.join(@config.view_dir, "layouts", "#{layout}.#{format}.#{ext}") unless layout == ""

      return view_filename, layout_filename
    end
  end
end
