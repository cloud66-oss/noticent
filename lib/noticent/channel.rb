module Noticent
  class Channel

    @@default_ext = :erb
    @@default_format = :html

    def initialize(recipients, payload, context)
      @recipients = recipients
      @payload = payload
      @context = context
      @current_user = payload.current_user if payload.respond_to? :current_user
    end

    protected

    attr_reader :payload
    attr_reader :recipients
    attr_reader :context

    def self.default_format(format)
      @@default_format = format
    end

    def self.default_ext(ext)
      @@default_ext = ext
    end

    def current_user
      raise Noticent::NoCurrentUser if @current_user.nil?

      @current_user
    end

    def render(format: @@default_format, ext: @@default_ext)
      alert_name = caller[0][/`.*'/][1..-2]
      channel_name = self.class.name.split('::').last.underscore
      view_file = view(channel: channel_name, alert: alert_name, format: format, ext: ext)

      raise Noticent::ViewNotFound, "view #{view_file} not found" unless File.exist?(view_file)

      # TODO: now render the file as erb
    end

    private

    def view(channel:, alert:, format:, ext: )
      File.join(Noticent.view_dir, channel, "#{alert}.#{format}.#{ext}")
    end

  end
end