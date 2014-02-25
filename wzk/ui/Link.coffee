goog.provide 'wzk.ui.Link'

goog.require 'wzk.ui.LinkRenderer'

class wzk.ui.Link extends wzk.ui.Component

  ###*
    @param {Object} params
      renderer: {wzk.ui.LinkRenderer}
      href: {string}
  ###
  constructor: (params) ->
    params.renderer ?= wzk.ui.LinkRenderer.getInstance()
    super params
    {@href, @caption} = params
    @href ?= ''
    @caption ?= ''

  ###*
    @return {string}
  ###
  getHref: ->
    @href
