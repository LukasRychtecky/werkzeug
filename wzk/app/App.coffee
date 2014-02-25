goog.provide 'wzk.app.App'

goog.require 'wzk.app.Register'
goog.require 'wzk.net.XhrFactory'
goog.require 'wzk.ui.Flash'
goog.require 'wzk.ui.grid'
goog.require 'wzk.uri.Frag'
goog.require 'goog.History'
goog.require 'wzk.stor.StateStorage'

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
    @frag = null
    @opts = {}
    @ss = {}
    @win = null

  ###*
    @param {Window} win
    @param {wzk.ui.Flash} flash
    @param {Object=} msgs
  ###
  run: (@win, flash, msgs = {}) ->
    @xhrFac = new wzk.net.XhrFactory flash, msgs

    @doc = @win.document
    @frag = new wzk.uri.Frag @win.location.hash
    @opts =
      app: @
      frag: @frag

    history = new goog.History()
    history.setEnabled true
    history.listen goog.history.EventType.NAVIGATE, @handleHistory

    @proc.once @regOnce.process, @doc, @doc, @xhrFac, @opts
    @proc.process @doc, @doc, @xhrFac, @opts

  ###*
    @protected
  ###
  handleHistory: =>
    @frag.setFragment @win.location.hash

  ###*
    @return {wzk.app.Processor}
  ###
  getProc: ->
    @proc

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

    @on 'table.grid', (table, dom, xhrFac, opts) ->
      wzk.ui.grid.build table, dom, xhrFac, opts.app.getProc(), opts.app.getStorage('g')

  ###*
    @param {string} k
    @return {wzk.stor.StateStorage}
  ###
  getStorage: (k) ->
    unless goog.object.containsKey @ss, k
      @ss[k] = new wzk.stor.StateStorage k, @frag, @win.location
    @ss[k]
