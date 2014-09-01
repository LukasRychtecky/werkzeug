class wzk.ui.form.ActionButton extends wzk.ui.form.RemoteButton

  ###*
    @param {Object} params
  ###
  constructor: (params) ->
    super params

  ###*
    Sends a request on a given model with a given method

    @override
    @param {wzk.resource.Client} client
    @param {string} url
    @param {string} method
    @param {Object|null|string=} content
    @param {function(Object)|null=} onSuccess
  ###
  call: (client, url, method, content, onSuccess = null) ->
    super(client, url, method, content, onSuccess, true)
