defmodule ExUnitNotifier.Notifiers.HueNotifier do
  @moduledoc """
    This notifier uses Philips hue scenes to notify about the unit tests result.

  Hue API: [https://developers.meethue.com/develop/get-started-2/](https://developers.meethue.com/develop/get-started-2/)

  """
  @green_time Application.compile_env(:ex_unit_notifier, :green_time, 5000)
  @ip Application.compile_env(:ex_unit_notifier, :hue_address, "hue_ip")
  @id Application.compile_env(:ex_unit_notifier, :hue_user, "hue_user_id")

  @hue_scene_alchemist Application.compile_env(
                         :ex_unit_notifier,
                         :hue_scene_alchemist,
                         "scene_id"
                       )
  @hue_scene_successful Application.compile_env(
                          :ex_unit_notifier,
                          :hue_scene_successful,
                          "scene_id"
                        )
  @hue_scene_failed Application.compile_env(:ex_unit_notifier, :hue_scene_failed, "scene_id")

  @hue_scene_room Application.compile_env(:ex_unit_notifier, :hue_scene_room, "Office")
  @editor_theme Application.compile_env(:ex_unit_notifier, :editor_theme)
  @editor_theme_success Application.compile_env(
                          :ex_unit_notifier,
                          :editor_theme_success
                        )
  @editor_theme_failed Application.compile_env(
                         :ex_unit_notifier,
                         :editor_theme_failed
                       )
  def notify(status, _message, _opts) do
    if status == :ok do
      if @editor_theme_success != nil, do: set_theme(@editor_theme_success)

      _result =
        Req.put!(
          "http://#{@ip}/api/#{@id}/groups/#{@hue_scene_room}/action",
          body: "{\"scene\": \"#{@hue_scene_successful}\"}"
        ).body

      Process.sleep(@green_time)
      if @editor_theme != nil, do: set_theme(@editor_theme)

      _result =
        Req.put!(
          "http://#{@ip}/api/#{@id}/groups/Arbeitszimmer/action",
          body: "{\"scene\": \"#{@hue_scene_alchemist}\"}"
        ).body
    else
      if @editor_theme_failed != nil, do: set_theme(@editor_theme_failed)

      _result =
        Req.put!(
          "http://#{@ip}/api/#{@id}/groups/Arbeitszimmer/action",
          body: "{\"scene\": \"#{@hue_scene_failed}\"}"
        ).body
    end
  end

  def available?, do: true

  def set_theme(theme_name) do
    settings_path = Path.join(System.user_home!(), ".config/zed/settings.json")

    if File.exists?(settings_path) do
      settings_file = File.read!(settings_path)

      manipulated =
        Regex.replace(~r/"theme": *"[^(...)]*",/, settings_file, "\"theme\": \"#{theme_name}\",",
          global: false
        )

      File.write(settings_path, manipulated)
    end
  end
end
