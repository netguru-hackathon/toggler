module Toggler
  class TogglManager

    def initialize
      @default_billable = ENV["TOGGLER_BILLABLE"] || false
      @api = Toggler::API::Connect.new.api
      @user = api.me(true)
      @workspaces = api.my_workspaces(user)
      # @default_project = { name: "hackaton", id: "342" }
    end

    def start_entry(workspace = default_workspace["name"],
                    billable = default_billable,
                    description = nil)
                    # project = default_project["name"],
      wid = workspace_id(workspace)
      pid = 22925160
      new_entry_attributes = {
        "wid" => wid,
        "pid" => pid,
        "billable" => billable,
        "duration" => Time.now.to_i * -1,
        "start" => @api.iso8601((Time.now - 3600).to_datetime),
        "created_with" => "toggler",
      }
      new_entry_attributes["description"] = description if description
      api.create_time_entry(new_entry_attributes)
      "time entry started" if api.create_time_entry(new_entry_attributes)
    end

    def stop_entry
      time_entry_id = api.get_current_time_entry&.[]("id")
      return "no running time entry" unless time_entry_id
      "time entry stopped" if api.stop_time_entry(time_entry_id)
    end

    def list_projects_with_tasks(workspace_name = default_workspace["name"])
      wid = workspace_id(workspace_name)
      projects = api.projects(wid)
      tasks = api.tasks(wid)
      projects.map do |project|
        project["tasks"] = tasks.select{ |task| task["pid"] == project["id"] }
        project
      end
    end

    private

    attr_reader :api, :user, :workspaces, :default_billable, :default_project

    def list_projects(workspace_name = default_workspace["name"])
      wid = workspace_id(workspace_name)
      api.projects(wid)
    end

    def default_workspace
      @default_wid ||= workspaces.first
    end

    def workspace_id(workspace_name)
      workspaces.find { |w| w["name"] == workspace_name }["id"]
    end

    def project_id(workspace_name, project_name)
      list_projects(workspace_name: workspace_name)
        .find { |p| p["name"] == project_name }["id"]
    end

  end
end
