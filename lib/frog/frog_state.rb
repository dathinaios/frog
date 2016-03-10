
class FrogState

  HOME = Dir.home
  FROG_DIR = HOME + "/.frog"
  STATE_PATH = FROG_DIR + "/state.yaml"

  def self.write_state(options)
    File.open(STATE_PATH, 'w') do |f|
      f.write options.to_yaml
    end
  end

  def self.read_state(name)
    config = YAML.load_file(STATE_PATH)
    config[name]
  end

end
