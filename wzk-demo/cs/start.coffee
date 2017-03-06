goog.provide 'app.start'

goog.require 'app'

###*
  @param {Window} win
  @param {Object.<string, string>} msgs
###
app.start = (win, msgs) ->

  flash = wzk.ui.buildFlash win.document
  app._app.registerStandardComponents flash

  app._app.run win, flash, msgs, {reloadOn403: true}

# ensure the symbol will be visible after compiler renaming
goog.exportSymbol 'app.start', app.start
