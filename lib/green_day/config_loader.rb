# frozen_string_literal: true

require 'yaml'
require_relative 'config'

module GreenDay
  class ConfigLoader
    DOTFILE = '.green_day.yml'
    GREEN_DAY_HOME = File.realpath(File.join(File.dirname(__FILE__), '..', '..'))
    DEFAULT_FILE = File.join(GREEN_DAY_HOME, 'config', 'default.yml')

    def load_config
      default_config = load_default_config
      project_config = load_project_config

      default_config.merge(project_config)
    end

    private

    def load_default_config
      yaml = YAML.safe_load(File.read(DEFAULT_FILE))
      Config.new(yaml)
    end

    def load_project_config
      file = find_project_dotfile
      return Config.new({}) unless file

      yaml = YAML.safe_load(File.read(file))
      Config.new(yaml)
    end

    def find_dotfile
      find_project_dotfile || DEFAULT_FILE
    end

    def find_project_dotfile(start_dir = Dir.pwd)
      Pathname.new(start_dir).ascend do |dir|
        file = dir + DOTFILE
        return file if file.exist?
      end
    end
  end
end
