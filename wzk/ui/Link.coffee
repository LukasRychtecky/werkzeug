goog.require 'wzk.ui.LinkRenderer'


class wzk.ui.Link extends wzk.ui.Component

  ###*
    @param {Object} params
      renderer: {wzk.ui.LinkRenderer}
      href: {string}
      title: {string}
      target: {string}
      caption: {string} an escapted caption
      htmlCaption: {string} a non-escapted caption, it overrides a caption
  ###
  constructor: (params) ->
    params.renderer ?= wzk.ui.LinkRenderer.getInstance()
    super params
    {@href, @caption, @htmlCaption, @title, @target} = params
    @href ?= ''
    @caption ?= ''
    @htmlCaption ?= ''
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

  ###*
    @return {string}
  ###
  getHTMLCaption: ->
    @htmlCaption

  ###*
    @return {string}
  ###
  getContent: ->
    if @getElement() then @dom.getTextContent(@getElement()) else ''
