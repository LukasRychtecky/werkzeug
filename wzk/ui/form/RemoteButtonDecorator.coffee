goog.require 'goog.fx.dom.FadeOutAndHide'
goog.require 'goog.fx.Transition.EventType'
goog.require 'goog.object'

goog.require 'wzk.ui.form.RemoteButton'
goog.require 'wzk.resource.Client'


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
    STATE: 'state'

  ###*
    @enum {string}
  ###
  @ACTION:
    REMOVE: 'remove'

  ###*
    @enum {function(wzk.dom.Dom)}
  ###
  @POST_ACTIONS =
    'reload': (self) -> self.dom.getWindow().location.reload(true)
    'remove': (self) -> self.removeElement()

  ###*
    @param {wzk.dom.Dom} dom
    @param {wzk.net.XhrFactory} xhrFac
  ###
  constructor: (@dom, @xhrFac) ->
    @btn = new wzk.ui.form.RemoteButton dom: dom
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
    @invokeFromHash btn

  ###*
    @protected
    @param {Element} btn
  ###
  invokeFromHash: (btn) ->
    return unless @state
    if @dom.getWindow().location.hash is '#' + @state
      @handleAction()

  ###*
    @protected
  ###
  handleAction: =>
    @dom.getWindow().location.hash = @state if @state
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
    @state = goog.dom.dataset.get(@btnEl, D.STATE)

  ###*
    @protected
  ###
  onSuccess: =>
    PA = wzk.ui.form.RemoteButtonDecorator.POST_ACTIONS
    if goog.object.containsKey(PA, @postAction)
      PA[@postAction](@)

  ###*
    @protected
  ###
  fadeOutTrigger: =>
    anim = new goog.fx.dom.FadeOutAndHide @toRemove, 1000
    anim.listen goog.fx.Transition.EventType.END, =>
      @dom.removeNode @toRemove
      undefined
    anim.play()

  ###*
    @protected
  ###
  removeElement: ->
    @toRemove = @dom.getElement(@postElement)
    if @toRemove?
      @dom.getWindow().setTimeout(@fadeOutTrigger(), 1000)
