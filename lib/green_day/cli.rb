# frozen_string_literal: true

require 'thor'
require 'parallel'
require 'colorize'
require 'io/console'
require_relative 'atcoder_client'
require_relative 'config_loader'
require_relative 'contest'
require_relative 'test_builder'

module GreenDay
  class Cli < Thor
    desc 'login Atcoder', 'login Atcoder and save session'
    def login
      print 'username:'
      username = $stdin.gets(chomp: true)
      print 'password:'
      password = $stdin.noecho { |stdin| stdin.gets(chomp: true) }.tap { puts }

      AtcoderClient.new.login(username, password)
      puts(
        "Successfully created #{AtcoderClient::COOKIE_FILE_NAME}"
        .colorize(:green)
      )
    end

    desc 'new [contest name]', 'create contest workspace and spec'
    def new(contest_name)
      contest = Contest.new(contest_name, AtcoderClient.new)
      config = ConfigLoader.new.load_config
      make_contest_dirs(contest, config)

      Parallel.each(contest.tasks, in_threads: THREAD_COUNT) do |task|
        create_submit_file(task, config)
        create_spec_file(task, config)
      end

      puts "Successfully created #{contest.name} directory".colorize(:green)
    end

    private

    def make_contest_dirs(contest, config)
      FileUtils.makedirs(submit_file_dir(contest, config))
      FileUtils.makedirs(spec_file_dir(contest, config))
    end

    def create_submit_file(task, config)
      File.open(submit_file_path(task, config), 'w')
    end

    def create_spec_file(task, config)
      test =
        TestBuilder.build_test(
          submit_file_path(task, config),
          task.sample_answers
        )
      File.write(spec_file_path(task, config), test)
    end

    def submit_file_dir(contest, config)
      "#{config.generate_root}/#{contest.name}"
    end

    def submit_file_path(task, config)
      base_dir = submit_file_dir(task.contest, config)
      "#{base_dir}/#{task.name}.rb"
    end

    def spec_file_dir(contest, config)
      base_dir = submit_file_dir(contest, config)

      if config.generate_spec_dir_flatten?
        base_dir
      else
        "#{base_dir}/#{config.generate_spec_dir}"
      end
    end

    def spec_file_path(task, config)
      base_dir = spec_file_dir(task.contest, config)
      "#{base_dir}/#{task.name}_spec.rb"
    end
  end
end
