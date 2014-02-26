goog.provide 'wzk.app'

goog.require 'wzk.app.App'

###*
  @return {wzk.app.App}
###
wzk.app.buildApp = ->
  new wzk.app.App()
