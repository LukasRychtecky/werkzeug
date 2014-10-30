goog.require 'wzk.obj'

class wzk.net.FlashMiddleware

  ###*
    @enum {string}
  ###
  @MSGS:
    'error': 'Internal error occured. Service is unavailable, sorry.'
    'loading': 'Loading...'

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
    if res['errors']?
      if goog.isArray(res['errors']) or goog.isString(res['errors'])
        @flash.addError res['errors']
      else if @msgs[String(status)]?
        @flash.addError @msgs[String(status)]

    msgs = res['messages'] ? res['message']
    if msgs?
      for type, msg of msgs
        @flash.addMessage msg, type

  error: ->
    @flash.addError @msgs['error']

  loading: ->
    msg = new wzk.ui.FlashMessage dom: @flash.getDomHelper(), msg: @msgs['loading'], severity: 'info', fadeOut: false, closable: false
    msg.addClass 'loading'
    @flash.addChild msg
    [msg]

  clearAll: ->
    @flash.clearAll()
