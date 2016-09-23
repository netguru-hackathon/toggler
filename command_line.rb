class CommandLine
  attr_accessor :command, :params

  def initialize
    @params = ARGV
    @command = params.shift
  end

  def call
    run_command
  end

  private

  def run_command
    case command
      when "start" then task_start
      when "stop" then task_stop
      when "list" then fetch_list
      else command_not_found
    end
  end

  def task_start
    pid = params.shift
    description = params.join(' ')
    Toggler::TogglManager.new.start_entry
  end

  def task_stop
    Toggler::TogglManager.new.stop_entry
  end

  def fetch_list
    Toggler::TogglManager.new.list_projects
  end

  def command_not_found
    puts "Command not found"
  end
end
