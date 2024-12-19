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
  @editor_theme_override Application.compile_env(:ex_unit_notifier, :editor_theme_override)
  @editor_theme_override_success Application.compile_env(
                                   :ex_unit_notifier,
                                   :editor_theme_override_success
                                 )
  @editor_theme_override_failed Application.compile_env(
                                  :ex_unit_notifier,
                                  :editor_theme_override_failed
                                )
  def notify(status, _message, _opts) do
    if status == :ok do
      if @editor_theme_override_success != nil, do: override_theme(@editor_theme_override_success)
      Process.sleep(@green_time)
      if @editor_theme_override != nil, do: override_theme(@editor_theme_override)
    else
      if @editor_theme_override_failed != nil, do: override_theme(@editor_theme_override_failed)
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

  def override_theme(theme_overrides) do
    settings_path = Path.join(System.user_home!(), ".config/zed/settings.json")

    if File.exists?(settings_path) do
      settings_file = File.read!(settings_path)
      # "text": "#6c0ab5ff",
      manipulated =
        Regex.replace(
          ~r/"experimental.theme_overrides": {\n *.. "text": *"#[a-zA-Z0-9]{4,9}",\n *.. "border": *"#[a-zA-Z0-9]{4,9}",\n *.. "title_bar\.background": *"#[a-zA-Z0-9]{4,9}",\n *.. "tab_bar\.background": *"#[a-zA-Z0-9]{4,9}",\n *.. "tab\.inactive_background": *"#[a-zA-Z0-9]{4,9}",\n *.. "tab\.active_background": *"#[a-zA-Z0-9]{4,9}"/,
          settings_file,
          "#{theme_overrides}",
          global: false
        )

      File.write(settings_path, manipulated)
    end
  end
end
