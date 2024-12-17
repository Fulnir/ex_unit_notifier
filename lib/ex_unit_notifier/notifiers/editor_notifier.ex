defmodule ExUnitNotifier.Notifiers.EditorNotifier do
  @moduledoc """

  """
  @green_time Application.compile_env(:ex_unit_notifier, :green_time, 5000)
  @editor_theme Application.compile_env(:ex_unit_notifier, :editor_theme, "Andromeda")
  @editor_theme_success Application.compile_env(
                          :ex_unit_notifier,
                          :editor_theme_success,
                          "One Light"
                        )
  @editor_theme_failed Application.compile_env(
                         :ex_unit_notifier,
                         :editor_theme_failed,
                         "One Dark"
                       )

  def notify(status, _message, _opts) do
    if status == :ok do
      set_theme(@editor_theme_success)
      Process.sleep(@green_time)
      set_theme(@editor_theme)
    else
      set_theme(@editor_theme_failed)
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
