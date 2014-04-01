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
  ###
  apply: (res) ->
    if res['errors']?
      @flash.addError res['errors']

    msgs = res['messages'] ? res['message']
    if msgs?
      for type, msg of msgs
        @flash.addMessage msg, type

  error: ->
    @flash.addError @msgs['error']

  loading: ->
    @flash.addMessage @msgs['loading'], 'info', false, false

  clearAll: ->
    @flash.clearAll()
