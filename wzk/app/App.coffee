goog.provide 'wzk.app.App'

goog.require 'wzk.app.Register'
goog.require 'wzk.net.XhrFactory'
goog.require 'wzk.ui.Flash'
goog.require 'wzk.ui.grid'

class wzk.app.App

  ###*
    @param {wzk.app.Processor} proc
  ###
  constructor: (@proc) ->
    @reg = new wzk.app.Register()
    @proc.add @reg.process
    @regOnce = new wzk.app.Register()
    @xhrFac = null
    @doc = null
    @opts = app: @

  ###*
    @param {Window} win
    @param {wzk.ui.Flash} flash
    @param {Object=} msgs
  ###
  run: (win, flash, msgs = {}) ->
    @xhrFac = new wzk.net.XhrFactory flash, msgs

    @doc = win.document
    @proc.once @regOnce.process, @doc, @doc, @xhrFac
    @proc.process @doc, @doc, @xhrFac, @opts

  ###*
    @param {Element} el
  ###
  process: (el) ->
    @proc.process el, @doc, @xhrFac, @opts

  ###*
    @param {string} selector
    @param {function(Element, wzk.dom.Dom, wzk.net.XhrFactory, Object=)} filter
  ###
  on: (selector, filter) ->
    @reg.register selector, filter

  ###*
    @param {string} selector
    @param {function(Element, wzk.dom.Dom, wzk.net.XhrFactory, Object=)} filter
  ###
  once: (selector, filter) ->
    @regOnce.register selector, filter

  ###*
    @param {wzk.ui.Flash} flash
  ###
  registerStandardComponents: (flash) ->
    @once '.flash', (el) ->
      flash.decorateOrRender el

    @on 'table.grid', (table, dom, xhrFac) ->
      wzk.ui.grid.build table, dom, xhrFac
