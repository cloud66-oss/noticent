Dir["#{File.dirname(__FILE__)}/act_as_notified/**/*.rb"].each { |f| load(f) }

module ActAsNotified
  @@base_dir = nil

  def self.base_dir(base_dir)
    @@base_dir = base_dir
  end

end
