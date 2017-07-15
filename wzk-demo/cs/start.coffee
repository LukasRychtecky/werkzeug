goog.provide 'wzkdemo.start'

goog.require 'wzkdemo'

###*
  @param {Window} win
  @param {Object.<string, string>} msgs
###
wzkdemo.start = (win, msgs) ->

  flash = wzk.ui.buildFlash win.document
  wzkdemo._app.registerStandardComponents flash

  wzkdemo._app.run win, flash, msgs, {reloadOn403: true}

# ensure the symbol will be visible after compiler renaming
goog.exportSymbol 'wzkdemo.start', wzkdemo.start
