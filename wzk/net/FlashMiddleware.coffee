goog.require 'wzk.obj'
goog.require 'goog.object'

class wzk.net.FlashMiddleware

  ###*
    @enum {string}
  ###
  @MSGS:
    'error': 'Internal error occured. Service is unavailable, sorry.'
    'loading': 'Loading...'
    'offline': 'Offline...'

  ###*
    @param {wzk.ui.Flash} flash
    @param {Object.<string, string>} msgs
  ###
  constructor: (@flash, @msgs) ->
    wzk.obj.merge @msgs, wzk.net.FlashMiddleware.MSGS

  ###*
    @param {Object} res
    @param {number} status
  ###
  apply: (res, status) ->
    return if @hasDefaultMsgFor status

    @displayFlatErrors res
    msgs = res['messages'] ? res['message']
    if msgs?
      for type, msg of msgs
        @flash.addMessage(msg, type) if goog.isString(msg)

      @displayNonFieldErrors msgs

  ###*
    @protected
    @param {Object} msgs
  ###
  displayNonFieldErrors: (msgs) ->
    errors = msgs['errors']?['non-field-errors']
    if errors
      @flash.addError(err) for err in errors

  ###*
    @protected
    @param {Object} response
  ###
  displayFlatErrors: (response) ->
    if response['errors']?
      if goog.isArray(response['errors']) or goog.isString(response['errors'])
        @flash.addError response['errors']
    else if response['error']?
      @flash.addError response['error']

  ###*
    @protected
    @param {number} status
    @return {boolean}
  ###
  hasDefaultMsgFor: (status) ->
    goog.object.containsKey(@msgs, String(status))

  ###*
    @param {number} status
  ###
  error: (status) ->
    if @hasDefaultMsgFor(status)
      strStatus = String(status)
      @flash.addError(@msgs[strStatus]) if @msgs[strStatus]?
    else
      @flash.addError(@msgs['error'])

  loading: ->
    [@createInfoFlash(@msgs['loading'], 'loading', false, false)]

  offline: ->
    [@createInfoFlash(@msgs['offline'], 'info', true, true)]

  ###*
    @param {string} msgTxt
    @param {string} cls
    @param {boolean} fadeOut
    @param {boolean} closable
    @return {wzk.ui.FlashMessage}
  ###
  createInfoFlash: (msgTxt, cls, fadeOut, closable) ->
    msg = new wzk.ui.FlashMessage({
      dom: @flash.getDomHelper(),
      msg: msgTxt,
      severity: 'info',
      fadeOut: fadeOut,
      closable: closable
    })
    msg.addClass(cls) if cls?
    @flash.addChild(msg)
    msg

  clearAll: ->
    @flash.clearAll()
