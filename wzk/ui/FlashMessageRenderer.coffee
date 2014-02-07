goog.provide 'wzk.ui.FlashMessageRenderer'

goog.require 'wzk.ui.ComponentRenderer'

class wzk.ui.FlashMessageRenderer extends wzk.ui.ComponentRenderer

  ###*
    @enum {string}
  ###
  @SEVERITY:
    'info': 'alert-info'
    'success': 'alert-success'
    'warn': 'alert-warning'
    'error': 'alert-danger'

  ###*
    @enum {string}
  ###
  @CLASSES:
    FLASH: 'flash-msg'
    ALERT: 'alert'
    CLOSABLE: 'alert-dismissable'
    NO_HIDE: 'ho-hide'

  ###*
    @constructor
    @extends {wzk.ui.ComponentRenderer}
  ###
  constructor: ->
    super()
    @classes.push wzk.ui.FlashMessageRenderer.CLASSES.FLASH
    @classes.push wzk.ui.FlashMessageRenderer.CLASSES.ALERT

  ###*
    @param {Element} el
  ###
  decorate: (el) ->
    goog.dom.classes.add el, wzk.ui.FlashMessageRenderer.CLASSES.ALERT
    for k, v of wzk.ui.FlashMessageRenderer.SEVERITY
      if goog.dom.classes.has el, k
        goog.dom.classes.add el, v

  ###*
    @override
  ###
  createDom: (flash) ->
    dom = flash.getDomHelper()
    el = super flash
    txt = dom.el 'span', 'msg-text', el
    dom.setTextContent txt, flash.msg
    el

  ###*
    @param {Element} el
    @param {string} severity
  ###
  mark: (el, severity) ->
    goog.dom.classes.add el, wzk.ui.FlashMessageRenderer.SEVERITY[severity]

  ###*
    @param {Element} el
    @return {boolean}
  ###
  isClosable: (el) ->
    not (goog.dom.classes.has(el, 'error') or goog.dom.classes.has(el, wzk.ui.FlashMessageRenderer.SEVERITY['alert-danger']))

  ###*
    @param {Element} el
  ###
  markClosable: (el) ->
    goog.dom.classes.add el, wzk.ui.FlashMessageRenderer.CLASSES.CLOSABLE

  ###*
    @param {Element} el
    @return {boolean}
  ###
  isFadeOut: (el) ->
    not (goog.dom.classes.has(el, 'error') or goog.dom.classes.has(el, wzk.ui.FlashMessageRenderer.CLASSES.NO_HIDE))

goog.addSingletonGetter wzk.ui.FlashMessageRenderer
