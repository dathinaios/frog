require 'thor'
require 'fileutils'
require 'yaml'
require 'frog/version'
require 'frog/frog_config'
require 'frog/frog_state'
require 'frog/frog_helpers'

module Frog
  class Main < Thor
    include Thor::Actions

    desc "init [--dirs --editor]", "initialise frog and scan your Documents, Develop and Dropbox for todo.txt files"
    method_option :dirs, :desc=> "supply custom search directories [--dirs dir1 dir2 dir3 etc.]",
      :type => :array, 
      :default => ["Develop", "Documents", "Dropbox"]

    method_option :editor, :desc=> "choose your editor command for opening todo files. Default is gvim --remote-silent ",
      :default => "gvim --remote-silent "

    def init
      if yes? set_color("\nPLEASE READ: \n\nFrog -ribbit- will scan your system for todo.txt files. When modifications (such as adding or removing todo items) are applied to the files the YAML data will be reformatted and any info that has not been parsed as data (such as YAML comments and empty lines) will be removed.  If you are not sure that you want that do 'frog init --dirs exampleDir' to try it out with a test file in exampleDir/todo.txt first.\n\n Should I proceed (y/n)?", Color.red)
        create_and_populate_frog_files
        choose_state
      end
    end

    desc "list", "list todos of current project or of a supplied one"
    def list(project=nil)
      project || project = FrogState.read_state('current')
      print_todo(project)
    end

    desc "projects", "list all projects and the paths to their todo"
    def projects
      files = FrogConfig.read_config_files
      table_rows = [["Project", "File"], ["-------", "----"]]
      files.each_pair { |project, path|
        table_rows.push([project,path])
      }
      print_table(table_rows)
      return files
    end

    desc "switch PROJECT", "switch to a different project. No argument allows interactive choice from a list"
    def switch(project = nil)
      project || project = choose_state
      FrogState.write_state({
        'current' => project
      })
    end

    desc "edit PROJECT", "edit current or supplied TODO in your editor (defaults to vim)"
    def edit(project=nil)
      project || project = FrogState.read_state('current')
      todo = FrogConfig.read_config_files[project]
      editor = FrogConfig.read_config_editor
      exec editor + todo
    end

    desc "add 'TODO'", "add a todo item to the current list (use quotes)", :type => 'string'
    def add(item)
      item = item.capitalize
      project = FrogState.read_state('current')
      data = FrogConfig.read_todo_file(project)
      data['TODO'].push(item)
      FrogConfig.write_todo_file(project, data)
      puts "'" + item + "'  has been added to " + project
    end

    desc "remove ID", "remove the todo item with ID. No argument allows interactive choice from a list"
    def remove(id = nil)
      id || id = choose_item_for_removal
      project = FrogState.read_state('current')
      data = FrogConfig.read_todo_file(project)
      content = data['TODO'][id.to_i]
      if yes? "Are you sure you want to delete '" + content + "' (y/n)?"
        data['TODO'].delete_at(id.to_i)
        FrogConfig.write_todo_file(project, data)
        puts "The item '" + content + "' has been removed from project " + project
      end
    end

    private

    def choose_item_for_removal
      self.list
      id = ask("Type an ID to remove an item\n")
      id
    end

    def scan(dir)
      Dir.glob("#{dir}/**/todo.txt")
    end

    def scan_all(dirs)
      todo_paths = {}
      dirs.each do |directory|
        scan_result = scan_and_inform(directory)
        scan_result.each do |path|
          basename = File.dirname(path).split('/').last.snake_case
          todo_paths[basename] = path
        end
      end
      todo_paths
    end

    def scan_and_inform(directory)
      puts "searching..."
      scan_result = scan(Dir.home + "/" + directory)
      puts "Found " + scan_result.size.to_s + " files in " + directory + ":"
      puts scan_result
      puts "\n"
      scan_result
    end

    def print_todo(project)
      puts "Project: " + project
      puts "."*(project.length + 9)
      table_rows = [["ID", "Item"], ["--", "----"]]
      todo = YAML.load_file(FrogConfig.read_config_files[project])
      todo['TODO'].each_with_index do |item, index|
        table_rows.push([index, item])
      end
      print_table(table_rows)
      puts "\n"
    end

    def print_divider
      puts "=========="
    end

    def create_and_populate_frog_files
      FrogConfig.create_system_files
      FrogConfig.write_config({
        'files' => scan_all(options[:dirs]),
        'editor' => options[:editor]
      })
    end

    def choose_state
      states = self.projects
      print_divider
      current = ask("Type project name to set state:\n")
      if states.key?(current)
        puts "Switched to project: #{current}"
        FrogState.write_state({
          'current' => current
        })
        return current
      else
        puts "That's not a project! Give it another try.\n"
        choose_state
      end
    end
  end
end
