class Changelog
  def self.all
    HashWithIndifferentAccess.new(YAML.load_file(File.join(Rails.root, 'config', 'changelogs.yml')))[:changelogs]
  end
end