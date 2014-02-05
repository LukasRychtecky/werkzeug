goog.provide 'wzk.app'

goog.require 'wzk.app.App'
goog.require 'wzk.app.Processor'

###*
  @return {wzk.app.App}
###
wzk.app.buildApp = ->
  proc = new wzk.app.Processor()
  new wzk.app.App proc
