# Frog

**I discovered [spacemacs] (http://spacemacs.org/) and orgmode so this project is on hold and was removed from rubygems.org**

Frog is a command line utility for managing todo lists. It is published as a ruby gem. Instead of keeping a local todo.txt file at a location on your computer it scans folders (by default Documents, Dropbox and Develop but can be chosen on init) for todo.txt files. It will then assign as project name the enclosing folder name.

The second important concept is that frog has a current state corresponding to a project. In this way commands such as `frog list`, `frog add` and `frog remove` act on the current state. You can choose state interactively with `frog switch` or manually with `frog switch PROJECT`.

## Installation

Make sure ruby is installed on your machine and do:

    $ gem install frog

## Usage

Execute `frog` to see a list of commands or `frog help [COMMAND]` for specific commands. To scan and initialize:

    $ frog init


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dathinaios/frog. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

