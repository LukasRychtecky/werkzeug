goog.provide 'wzk.app.App'

goog.require 'wzk.app.Register'
goog.require 'wzk.net.XhrFactory'
goog.require 'wzk.ui.Flash'
goog.require 'wzk.ui.grid'
goog.require 'wzk.ui.form'
goog.require 'wzk.ui.inlineform'
goog.require 'wzk.ui.ac'
goog.require 'wzk.ui.tooltip'
goog.require 'wzk.uri.Frag'
goog.require 'goog.History'
goog.require 'wzk.stor.StateStorage'
goog.require 'wzk.net.AuthMiddleware'
goog.require 'wzk.net.SnippetMiddleware'
goog.require 'wzk.dom.Dom'
goog.require 'wzk.net.FlashMiddleware'
goog.require 'wzk.debug.ErrorReporter'

###*
  Provides asynchronous registering components. Every registered component is loaded asynchronously and independently
  to others. If the component fails (throws an exception etc.) occured errors are handled automatically and it
  does not block other components.

  Every component takes wzk.net.XhrFactory instance, which is decorated with wzk.net.AuthMiddleware,
  wzk.net.SnippetMiddleware and wzk.net.FlashMiddleware
###
class wzk.app.App

  constructor: ->
    @reporter = new wzk.debug.ErrorReporter()
    @reg = new wzk.app.Register @buildFunc, @reporter
    @regOnce = new wzk.app.Register @buildFunc, @reporter
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
    log = if @win['console']? then goog.bind(@win['console']['error'], @win['console']) else ->
    @reporter.setLog log

    @doc = @win.document
    @frag = new wzk.uri.Frag @win.location.hash
    @opts =
      app: @
      frag: @frag
      flash: flash

    dom = new wzk.dom.Dom @doc
    snip = new wzk.net.SnippetMiddleware @reg, dom, @opts

    auth = new wzk.net.AuthMiddleware @win.document
    flashmid = new wzk.net.FlashMiddleware flash, msgs
    @xhrFac = new wzk.net.XhrFactory flashmid, auth, snip, dom

    history = new goog.History()
    history.setEnabled true
    history.listen goog.history.EventType.NAVIGATE, @handleHistory

    @regOnce.process @doc
    @reg.process @doc

  ###*
    @protected
    @param {function(?, ?, ?, ?)} func
    @param {(Element|Document)} el
  ###
  buildFunc: (func, el) =>
    func el, new wzk.dom.Dom(@doc), @xhrFac, @opts

  ###*
    @protected
  ###
  handleHistory: =>
    @frag.setFragment @win.location.hash

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
    @return {wzk.app.Register}
  ###
  getRegister: ->
    @reg

  ###*
    @param {wzk.ui.Flash} flash
  ###
  registerStandardComponents: (flash) ->
    @once '.flash', (el) ->
      flash.decorateOrRender el

    @on 'table.js-grid', (table, dom, xhrFac, opts) ->
      wzk.ui.grid.build table, dom, xhrFac, opts.app.getRegister(), opts.app.getStorage('g'), opts.flash

    @on '.remote-button', (el, dom, xhrFac) ->
      wzk.ui.form.buildRemoteButton el, dom, xhrFac

    @on 'form.ajax', (form, dom, xhrFac) ->
      wzk.ui.form.ajaxifyForm form, dom, xhrFac

    @on 'select.fulltext-search', (el, dom) ->
      el = (`/** @type {HTMLSelectElement} */`) el
      wzk.ui.ac.buildSelectAutoCompleteNative el, dom

    @on 'select.fulltext-search-multiple', (el, dom) ->
      el = (`/** @type {HTMLSelectElement} */`) el
      wzk.ui.ac.buildExtSelectboxFromSelectNative el, dom

    @on 'fieldset.inline', (el, dom) ->
      wzk.ui.inlineform.buildDynamicButton el, dom

    @on '*[data-title]', (el, dom) ->
      wzk.ui.tooltip.tooltipy el, dom

    @on '.navbar-toggle', (el, dom) ->
      wzk.ui.navbarToggle el, dom

    @on '*[data-snippet-onload]', (el, dom, xhrFac) ->
      wzk.ui.loadSnippet el, dom, xhrFac

    @on '.related-button', (el, dom, xhrFac, opts) ->
      wzk.ui.form.buildRelatedObjectLookup el, dom, xhrFac, opts.app.getRegister()

  ###*
    @param {string} k
    @return {wzk.stor.StateStorage}
  ###
  getStorage: (k) ->
    unless goog.object.containsKey @ss, k
      @ss[k] = new wzk.stor.StateStorage k, @frag, @win.location
    @ss[k]
