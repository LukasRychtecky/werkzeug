goog.provide 'wzk.resource.UrlExpert'

class wzk.resource.UrlExpert

  constructor: ->

  ###*
    throw {Error}
    @param {Object} model
    @param {string} resource
    @param {string} method
    @return {string}
  ###
  getUrl: (model, resource, method) ->
    url = model['_rest_links']?[resource]?['url']
    throw new Error 'Given object is not a model' unless url

    @checkMethod method, model['_rest_links'][resource]['methods']

    url

  ###*
    throw {Error}
    @protected
    @param {string} method
    @param {Array.<string>} allowed
  ###
  checkMethod: (method, allowed) ->
    if not method in allowed
      throw new Error "Given model does not support #{method} method"
