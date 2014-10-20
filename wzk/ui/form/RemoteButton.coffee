goog.require 'goog.dom.dataset'
goog.require 'goog.dom.forms'
goog.require 'goog.Uri'

###*
  A button that allows an Ajax call.
###
class wzk.ui.form.RemoteButton extends wzk.ui.Button

  ###*
    @enum {string}
  ###
  @DATA:
    FIELDS: 'fields'

  ###*
    @param {Object} params
  ###
  constructor: (params) ->
    super params
    @fields = {}

  ###*
    Sends a request on a given model with a given method

    @param {wzk.resource.Client} client
    @param {string} url
    @param {string} method
    @param {Object|null|string=} content
    @param {function(Object)|null=} onSuccess
    @param {boolean=} responseByModel
  ###
  call: (client, url, method, content, onSuccess = null, responseByModel = false) ->
    @setEnabled false
    url = @composePath url
    handleSuccess = (response) =>
      @setEnabled true
      onSuccess(response) if onSuccess?

    client.request url, method, content, handleSuccess, null, responseByModel

  ###*
    @override
  ###
  createDom: ->
    @addClassName 'remote-button'
    super()

  ###*
    @override
  ###
  decorate: (el) ->
    el.setAttribute 'type', 'button'
    super el
    @parseFields el

  ###*
    @protected
    @param {string} url
    @return {string}
  ###
  composePath: (url) ->
    uri = new goog.Uri url
    for param, field of @fields
      uri.setParameterValue param, goog.dom.forms.getValue field
    parts = [uri.getPath()]
    parts.push uri.getQuery() if uri.getQuery()
    parts.join '?'

  ###*
    @protected
    @param {Element} el
  ###
  parseFields: (el) ->
    els = goog.dom.dataset.get el, wzk.ui.form.RemoteButton.DATA.FIELDS
    if els
      selectors = String(els).split ','
      for s in selectors
        field = @dom.cls('remote-button-param-' + s)
        if field?
          @fields[s] = field
