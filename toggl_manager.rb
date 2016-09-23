module Toggler
  class TogglManager
    attr_accessor :billable

    def initialize
      @billable = ENV["TOGGLER_BILLABLE"] || false
      @api = Toggler::API::Connect.new.api
      @user = api.me(true)
      @workspaces = api.my_workspaces(user)
    end

    def task_start(wid: default_workspace["id"], pid:, description:)
      new_entry_attributes = {
        "description" => description,
        "wid" => wid,
        "pid" => pid,
        "billable" => billable,
        "duration" => Time.now.to_i * -1,
        "start" => api.iso8601((Time.now - 3600).to_datetime),
        "created_with" => "toggler",
      }
      api.create_time_entry(new_entry_attributes)
    end

    def task_stop
      puts "stop"
    end

    def fetch_list(workspace_name: default_workspace["name"])
      workspace = workspaces.find { |w| w["name"] == workspace_name }
      list = api.projects(workspace["id"])
      puts list
    end

    private

    attr_reader :api, :user, :workspaces

    def default_workspace
      @default_wid ||= workspaces.first
    end
  end
end
