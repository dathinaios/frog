require 'fileutils'
require 'yaml'

class FrogConfig

  HOME = Dir.home
  FROG_DIR = HOME + "/.frog"
  # CACHE_PATH = FROG_DIR + "/cache.yaml"
  CONFIG_PATH = FROG_DIR + "/config.yaml"

  def self.create_system_files
    unless File.directory?(FROG_DIR)
      FileUtils.mkdir_p(FROG_DIR)
    end
    # unless File.exists?(CACHE_PATH)
    #   FileUtils.touch(CACHE_PATH)
    # end
    unless File.exists?(CONFIG_PATH)
      FileUtils.touch(CONFIG_PATH)
    end
  end

  def self.write_config(options)
    File.open(CONFIG_PATH, 'w') do |f|
      f.write options.to_yaml
    end
  end

  def self.read_config_files
    config = YAML.load_file(CONFIG_PATH)
    config['files']
  end

  def self.read_config_editor
    config = YAML.load_file(CONFIG_PATH)
    config['editor']
  end

  def self.read_todo_file(project)
    path = read_config_files[project]
    return YAML.load_file(path)
  end

  def self.write_todo_file(project, newData)
    path = read_config_files[project]
    converted_data = YAML.dump newData
    File.write(path, converted_data)
  end

end
