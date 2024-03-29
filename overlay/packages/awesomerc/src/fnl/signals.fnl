(let [awful (require :awful)
      beautiful (require :beautiful)
      naughty (require :naughty)]
  ; Check if awesome encountered an error during startup and fell back to
  ; another config (This code will only ever execute for the fallback config))
  (when awesome.startup-errors
    (naughty.notify {:preset naughty.config.presets.critical
                     :title "Oops, there were errors during startup!"
                     :text awesome.startup-errors}))

  ; Handle runtime errors after startup)
  (do
    (var in-error? false)
    (awesome.connect_signal "debug::error"
     (fn [err]
       (when (not in-error?)
         (set in-error? true)
         (naughty.notify {:preset naughty.config.presets.critical
                          :title "Oops, an error happened!"
                          :text (tostring err)})
         (set in-error? false)))))

  ; Signal function to execute when a new client appears.
  (client.connect_signal "manage"
    (fn [c] (when (and awesome.startup
                       (not c.size_hints.user_position)
                       (not c.size_hints.program_position))
              (awful.placement.no_offscreen c))))

  ; Add a titlebar if titlebars_enabled is set to true in the rules.)
  (client.connect_signal "request::titlebars"
    (fn [c]))

  ; Enable sloppy focus, so that focus follows mouse.
  (client.connect_signal "mouse::enter"
    (fn [c] (when (and (not= (awful.layout.get c.screen)
                             awful.layout.suit.magnifier)
                       (awful.client.focus.filter c))
              (set client.focus c))))

  (client.connect_signal "focus"
    (fn [c] (set c.border_color beautiful.border_focus)))

  (client.connect_signal "unfocus"
    (fn [c] (set c.border_color beautiful.border_normal))))
