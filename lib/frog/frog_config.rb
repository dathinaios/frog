require 'fileutils'
require 'yaml'

module FrogConfig

  HOME = Dir.home
  FROG_DIR = HOME + "/.frog"
  # CACHE_PATH = FROG_DIR + "/cache.yaml"
  CONFIG_PATH = FROG_DIR + "/config.yaml"

  def self.create_system_files
    unless File.directory?(FROG_DIR)
      puts 'Creating .frog directory'
      FileUtils.mkdir_p(FROG_DIR)
    end
    # unless File.exists?(CACHE_PATH)
    #   FileUtils.touch(CACHE_PATH)
    # end
    unless File.exists?(CONFIG_PATH)
      puts 'Creating .frog/config.yaml'
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

  def self.write_config_editor(editor_command)
    editor_command = editor_command + " "
    data = YAML.load_file(CONFIG_PATH)
    data['editor'] = editor_command
    converted_data = YAML.dump data
    File.write(CONFIG_PATH, converted_data)
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

  def self.scan(dir)
    Dir.glob("#{dir}/**/todo.txt")
  end

  def self.scan_all(dirs)
    todo_paths = {}
    dirs.each do |directory|
      scan_result = scan_and_inform(directory)
      scan_result.each do |path|
        basename = File.dirname(path).split('/').last.snake_case
        todo_paths[basename] = path
      end
    end
    return todo_paths
  end

  def self.scan_and_inform(directory)
    puts "searching..."
    scan_result = scan(Dir.home + "/" + directory)
    puts "Found " + scan_result.size.to_s + " files in " + directory + ":"
    puts scan_result
    puts "\n"
    return scan_result
  end

  def self.create_and_populate_frog_files(dirs)
    create_system_files
    write_config({
      'files' => scan_all(dirs),
    })
  end

end
