require 'thor'
require 'fileutils'
require 'yaml'
require 'frog/version'
require 'frog/frog_config'
require 'frog/frog_state'
require 'frog/frog_helpers'

module Frog
  class Interface < Thor
    include Thor::Actions

    desc "init [--dirs --editor]", "Initialise frog and scan your Documents, Develop and Dropbox for todo.txt files"
    method_option :dirs, :desc=> "Supply custom search directories",
      :type => :array, 
      :default => ["Develop", "Documents", "Dropbox"]

    method_option :editor, :desc=> "Choose your editor command for opening todo files",
      :default => "gvim --remote-silent "

    def init
      if initialize?
        create_and_populate_frog_files
        choose_state
      end
    end

    desc "list", "List todos of current project or of a supplied one"
    def list(project=nil)
      project || project = FrogState.read_state('current')
      print_todo(project)
    end

    desc "projects", "List all projects and the paths to their todo"
    def projects
      paths = print_projects
      return paths
    end

    desc "switch PROJECT", "Switch to a different project. No argument allows interactive choice from a list"
    def switch(project = nil)
      project || project = choose_state
      FrogState.write_state({
        'current' => project
      })
    end

    desc "edit [PROJECT]", "Edit current or supplied PROJECT in your EDITOR (see frog help init)"
    def edit(project=nil)
      project || project = FrogState.read_state('current')
      edit_project(project)
    end

    desc "add 'TODO'", "Add a todo item to the current list (use quotes)"
    def add(item)
      add_item(item)
    end

    desc "remove ID", "Remove the todo item with ID. No argument allows interactive choice from a list"
    def remove(id = nil)
      id || id = choose_item_for_removal
      remove_item_for_id(id)
    end

    private

    def choose_item_for_removal
      self.list
      id = ask("Type an ID to remove an item\n")
      return id
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
      return todo_paths
    end

    def scan_and_inform(directory)
      puts "searching..."
      scan_result = scan(Dir.home + "/" + directory)
      puts "Found " + scan_result.size.to_s + " files in " + directory + ":"
      puts scan_result
      puts "\n"
      return scan_result
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

    def initialize?
      yes?("\nPLEASE READ: \n\nFrog -ribbit- will scan your system for todo.txt files. When modifications (such as adding or removing todo items) are applied to the files the YAML data will be reformatted and any info that has not been parsed as data (such as YAML comments and empty lines) will be removed.  If you are not sure that you want that do 'frog init --dirs exampleDir' to try it out with a test file in exampleDir/todo.txt first.\n\n -ribbit- \n\nShould I proceed (y/n)?", "\033[33m")
    end

    def print_projects
      paths = FrogConfig.read_config_files
      table_rows = [["Project", "File"], ["-------", "----"]]
      paths.each_pair { |project, path|
        table_rows.push([project,path])
      }
      print_table(table_rows)
      return paths
    end

    def edit_project(project)
      todo = FrogConfig.read_config_files[project]
      editor = FrogConfig.read_config_editor
      exec editor + todo
    end

    def add_item(item)
      item = item.capitalize
      project = FrogState.read_state('current')
      data = FrogConfig.read_todo_file(project)
      data['TODO'].push(item)
      FrogConfig.write_todo_file(project, data)
      puts "'" + item + "'  has been added to " + project
    end
      
    def remove_item_for_id(id)
      project = FrogState.read_state('current')
      data = FrogConfig.read_todo_file(project)
      content = data['TODO'][id.to_i]
      if yes? "Are you sure you want to delete '" + content + "' (y/n)?"
        data['TODO'].delete_at(id.to_i)
        FrogConfig.write_todo_file(project, data)
        puts "The item '" + content + "' has been removed from project " + project
      end
    end

  end

end
