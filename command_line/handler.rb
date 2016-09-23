require_relative "parser"

module CommandLine
  class Handler
    attr_accessor :command, :params, :options, :project, :task

    def initialize
      @params = ARGV
      @command = params.shift
      assign_project_and_task(params.shift) unless params[0]&.start_with?("-")
      @options = Parser.parse params
    end

    def call
      run_command
    end

    private

    def assign_project_and_task(value)
      return if value.nil?
      @project, @task = value.split("/")
    end

    def run_command
      case command
        when "start" then task_start
        when "stop" then task_stop
        when "list" then fetch_list
        when "current" then fetch_current
        when "summary" then fetch_summary
        else command_not_found
      end
    end

    def task_start
      entry_params = {
        description: options.description,
        task_name: task,
        project_name: project,
        billable: options.billable,
        workspace_name: options.workspace
      }
      puts Toggler::TogglManager.new.start_entry(entry_params)
    end

    def task_stop
      puts Toggler::TogglManager.new.stop_entry
    end

    def fetch_list
      Toggler::TogglManager.new.list_projects_with_tasks.each{ |project_info| puts project_info }
    end

    def fetch_current
      puts Toggler::TogglManager.new.current_time_entry
    end

    def fetch_summary
      entry_params = {
        workspace_name: nil
      }
      #summary current
      puts Toggler::TogglManager.new.summary(entry_params)
    end

    def command_not_found
      puts """
      Command not found

      start [[project]/[task]] - to start entry
      stop                     - to stop current entry
      list                     - to fetch all project entries
      current                  - show current time entry
      summary [*description*]  - show summary of entry (default current)
      """
      puts CommandLine::Parser.parse %w[--help]
    end
  end
end
