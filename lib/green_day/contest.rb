# frozen_string_literal: true

require_relative 'atcoder_client'
require_relative 'task'

module GreenDay
  class Contest
    attr_reader :atcoder_client, :name, :tasks

    def initialize(contest_name, client)
      unless client.contest_exist?(contest_name)
        raise GreenDay::Error 'could not find contest'
      end

      @name = contest_name

      task_codes = client.fetch_task_codes(self)
      @tasks =
        Parallel.map(task_codes, in_threads: THREAD_COUNT) do |task_code|
          Task.new(self, task_code, client)
        end
    end
  end
end
