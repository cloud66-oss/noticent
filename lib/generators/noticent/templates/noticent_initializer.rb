Noticent.configure do |config|
  config.base_dir = File.join(Rails.root, 'app', 'models', 'noticent')
  config.base_module_name = 'Noticent'
  config.logger = Rails.logger
  config.halt_on_error = !Rails.env.production?

  # scope :post do
  #   channel :email
  #   channel :slack, group: :internal
  #
  #   alert :new_user do
  #     notify :user
  #     notify(:staff).on(:internal)
  #   end
  # end

end