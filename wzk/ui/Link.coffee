goog.provide 'wzk.ui.Link'

goog.require 'wzk.ui.LinkRenderer'

class wzk.ui.Link extends wzk.ui.Component

  ###*
    @param {Object} params
      renderer: {wzk.ui.LinkRenderer}
      href: {string}
      title: {string}
      target: {string}
  ###
  constructor: (params) ->
    params.renderer ?= wzk.ui.LinkRenderer.getInstance()
    super params
    {@href, @caption, @title, @target} = params
    @href ?= ''
    @caption ?= ''
    @title ?= @caption

  ###*
    @return {string}
  ###
  getHref: ->
    @href

  ###*
    @return {string}
  ###
  getTitle: ->
    @title

  ###*
    @return {string}
  ###
  getTarget: ->
    @target
