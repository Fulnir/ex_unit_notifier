defmodule ExUnitNotifier.Notifiers.HueNotifier do
  @moduledoc """
    This notifier uses Philips hue scenes to notify about the unit tests result.

  Hue API: [https://developers.meethue.com/develop/get-started-2/](https://developers.meethue.com/develop/get-started-2/)

  """
  @ip Application.get_env(:ex_unit_notifier, :hue_address)
  @id Application.get_env(:ex_unit_notifier, :hue_user)

  @hue_scene_alchemist Application.get_env(:ex_unit_notifier, :hue_scene_alchemist)
  @hue_scene_successful Application.get_env(:ex_unit_notifier, :hue_scene_successful)
  @hue_scene_failed Application.get_env(:ex_unit_notifier, :hue_scene_failed)

  @hue_scene_room Application.get_env(:ex_unit_notifier, :hue_scene_room)

  def notify(status, message, _opts) do
    result =
      Req.put!(
        "http://#{@ip}/api/#{@id}/groups/#{@hue_scene_room}/action",
        body: "{\"scene\": \"#{@hue_scene_failed}\"}"
      ).body

    Process.sleep(2000)

    result =
      Req.put!(
        "http://#{@ip}/api/#{@id}/groups/Arbeitszimmer/action",
        body: "{\"scene\": \"#{@hue_scene_alchemist}\"}"
      ).body

    Process.sleep(2000)

    result =
      Req.put!(
        "http://#{@ip}/api/#{@id}/groups/Arbeitszimmer/action",
        body: "{\"scene\": \"#{@hue_scene_successful}\"}"
      ).body

    Process.sleep(2000)

    result =
      Req.put!(
        "http://#{@ip}/api/#{@id}/groups/Arbeitszimmer/action",
        body: "{\"scene\": \"#{@hue_scene_alchemist}\"}"
      ).body
  end

  def available?, do: true
end
