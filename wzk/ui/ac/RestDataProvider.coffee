goog.require 'wzk.resource.Query'

class wzk.ui.ac.RestDataProvider

  @DATA:
    RESOURCE: 'resource'

  constructor: ->
    @query = new wzk.resource.Query()

  ###*
    @param {HTMLSelectElement} select
    @param {wzk.net.XhrFactory} xhrFac
    @param {function(Array.<wzk.resource.Model>)} callback
  ###
  load: (select, xhrFac, callback) ->
    url = goog.dom.dataset.get select, wzk.ui.ac.RestDataProvider.DATA.RESOURCE
    client = new wzk.resource.Client(xhrFac)

    if @query?
      client.setDefaultFields @query

    client.find url, ((data) => callback((@format(model) for model in data)))

  ###*
    @param {wzk.resource.Model} model
    @return {wzk.resource.Model}
  ###
  format: (model) ->
    if model['_autocomplete_value']?
      model['_obj_name'] = model['_autocomplete_value']
    return model

  ###*
    @param {string} field
  ###
  addField: (field) ->
    @query.addField field
