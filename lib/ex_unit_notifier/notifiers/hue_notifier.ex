defmodule ExUnitNotifier.Notifiers.HueNotifier do
  @moduledoc """
    This notifier uses Philips hue scenes to notify about the unit tests result.

  Hue API: [https://developers.meethue.com/develop/get-started-2/](https://developers.meethue.com/develop/get-started-2/)

  """
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

  def notify(status, _message, _opts) do
    if status == :ok do
      _result =
        Req.put!(
          "http://#{@ip}/api/#{@id}/groups/#{@hue_scene_room}/action",
          body: "{\"scene\": \"#{@hue_scene_successful}\"}"
        ).body

      Process.sleep(2000)

      _result =
        Req.put!(
          "http://#{@ip}/api/#{@id}/groups/Arbeitszimmer/action",
          body: "{\"scene\": \"#{@hue_scene_alchemist}\"}"
        ).body
    else
      _result =
        Req.put!(
          "http://#{@ip}/api/#{@id}/groups/Arbeitszimmer/action",
          body: "{\"scene\": \"#{@hue_scene_failed}\"}"
        ).body

      # Red until tests succesfull
      # Process.sleep(2000)
      # _result =
      #   Req.put!(
      #     "http://#{@ip}/api/#{@id}/groups/Arbeitszimmer/action",
      #     body: "{\"scene\": \"#{@hue_scene_alchemist}\"}"
      #   ).body
    end
  end

  def available?, do: true
end
