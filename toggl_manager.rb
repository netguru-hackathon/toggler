module Toggler
  class TogglManager

    def initialize
      @default_billable = ENV["TOGGLER_BILLABLE"] || false
      @api = TogglV8::API.new(ENV["TOGGLER_API_KEY"])
      @user = api.me(true)
      @workspaces = api.my_workspaces(user)
    end

    def start_entry(description = nil,
                    project_name = default_project["name"],
                    billable = default_billable,
                    workspace_name = default_workspace["name"])
      wid = workspace_id(workspace_name)
      pid = project_id(workspace_name, project_name)
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
      return "time entry started" if api.create_time_entry(new_entry_attributes)
      "error adding time entry"
    end

    def stop_entry
      time_entry_id = api.get_current_time_entry&.[]("id")
      return "no running time entry" unless time_entry_id
      return "time entry stopped" if api.stop_time_entry(time_entry_id)
      "error stopping time entry"
    end

    def list_projects_with_tasks(workspace_name = default_workspace["name"])
      projects_with_tasks(workspace_id(workspace_name))
    end

    private

    attr_reader :api, :user, :workspaces, :default_billable, :default_project

    def list_projects(workspace_name = default_workspace["name"])
      wid = workspace_id(workspace_name)
      api.projects(wid)
    end

    def projects_with_tasks(wid)
      projects = api.projects(wid)
      tasks = api.tasks(wid)
      project_with_tasks = projects.map do |project|
        project_name = project["name"]
        project_tasks = tasks.select{ |task| task["pid"] == project["id"] }.map{ |taks| taks["name"] }
        "#{project_name}: \n\t#{project_tasks.join(', ')}"
      end
    end

    def default_workspace
      @default_wid ||= workspaces.first
    end

    def default_project
      list_projects(default_workspace["name"]).first
    end

    def workspace_id(workspace_name)
      workspaces.find { |w| w["name"] == workspace_name }["id"]
    end

    def project_id(workspace_name, project_name)
      list_projects(workspace_name)
        .find { |p| p["name"] == project_name }["id"]
    end
  end
end
