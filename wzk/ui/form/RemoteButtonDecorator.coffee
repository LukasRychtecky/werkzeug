goog.require 'wzk.ui.form.RemoteButton'
goog.require 'wzk.resource.Client'
goog.require 'goog.fx.dom.FadeOutAndHide'
goog.require 'goog.fx.Transition.EventType'

class wzk.ui.form.RemoteButtonDecorator

  ###*
    @enum {string}
  ###
  @DATA:
    POST_ACTION: 'postAction'
    POST_ELEMENT: 'postElement'
    METHOD: 'method'
    URL: 'url'
    DATA: 'data'

  ###*
    @enum {string}
  ###
  @ACTION:
    REMOVE: 'remove'

  ###*
    @param {wzk.dom.Dom} dom
    @param {wzk.net.XhrFactory} xhrFac
  ###
  constructor: (@dom, @xhrFac) ->
    @btn = new wzk.ui.form.RemoteButton null, null, dom
    @client = new wzk.resource.Client @xhrFac
    @url = ''
    @method = ''
    @data = null
    @postAction = null
    @postElement = null
    @btnEl = null
    @toRemove = null

  ###*
    @param {Element} btn
  ###
  decorate: (btn) ->
    @btnEl = btn
    @btn.decorate @btnEl
    @parseParams()
    @btn.listen goog.ui.Component.EventType.ACTION, @handleAction

  ###*
    @protected
  ###
  handleAction: =>
    @btn.call @client, @url, @method, @data, @onSuccess

  ###*
    @protected
  ###
  parseParams: ->
    D = wzk.ui.form.RemoteButtonDecorator.DATA
    @url = String goog.dom.dataset.get(@btnEl, D.URL)
    @method = String goog.dom.dataset.get(@btnEl, D.METHOD)
    @data = goog.dom.dataset.get(@btnEl, D.DATA) ? {}
    @postAction = String goog.dom.dataset.get(@btnEl, D.POST_ACTION)
    @postElement = String goog.dom.dataset.get(@btnEl, D.POST_ELEMENT)

  ###*
    @protected
  ###
  onSuccess: =>
    if @postAction is wzk.ui.form.RemoteButtonDecorator.ACTION.REMOVE
      @toRemove = @dom.getElement @postElement
      if @toRemove?
        setTimeout @fadeOutTrigger(), 1000

  ###*
    @protected
  ###
  fadeOutTrigger: =>
    anim = new goog.fx.dom.FadeOutAndHide @toRemove, 1000
    anim.listen goog.fx.Transition.EventType.END, =>
      @dom.removeNode @toRemove
      undefined
    anim.play()
