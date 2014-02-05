suite 'wzk.resource.Client', ->
  Client = wzk.resource.Client
  E = goog.net.EventType

  context = null

  mockXhrFactory = (event, data = null, resHeaders = {}) ->
    fac =
      build: ->
        xhr = mockXhr event, data, resHeaders
        fac.last = xhr
        xhr
    fac

  mockXhr = (event, data = null, resHeaders = {}) ->
    xhr =
      responseHeaders: resHeaders
      getResponseJson: ->
        data
      events: {}
      attachEvent: (type, e) ->
        xhr.events[type] = e
      getResponseHeader: (header) ->
        xhr.responseHeaders[header]
      send: (url, method, content, headers) ->
        xhr.url = url
        xhr.method = method
        xhr.headers = headers
        xhr.content = content
        xhr.events["on#{event}"]()
    xhr

  checkHeaders = (actual) ->
    headers = {}
    headers[goog.net.XhrIo.CONTENT_TYPE_HEADER] = 'application/json'
    headers['Accept'] = 'application/json'

    for k, v of headers
      assert.equal actual[k], v

  setup ->
    context = 'users-user'


  suite '#find', ->

    test 'Should return a json', (done) ->
      arr = [foo: 'bar']
      xhrFac = mockXhrFactory E.SUCCESS, arr
      client = new Client xhrFac, context

      client.find '/foo', (data) ->
        xhr = xhrFac.last
        checkHeaders xhr.headers
        done() if data.foo is arr.foo

    test 'Should call an error callback', (done) ->
      xhrFac = mockXhrFactory E.ERROR, 'errors': {}
      client = new Client xhrFac, context

      client.find '/foo', null, done

    test 'Should return a result with paging headers', (done) ->
      xhrFac = mockXhrFactory E.SUCCESS, [foo: 'bar', bar: 'foo'], {'X-Total': '10'}
      client = new Client xhrFac, context

      client.find '/foo', (data, result) ->
        xhr = xhrFac.last
        checkHeaders xhr.headers
        assert.equal result.total, 10
        done()

    test 'Should send params for paging', (done) ->
      xhrFac = mockXhrFactory E.SUCCESS, [foo: 'bar', bar: 'foo']
      client = new Client xhrFac, context

      query =
        base: 10
        offset: 0

      onSuccess = (data, result) ->
        xhr = xhrFac.last
        checkHeaders xhr.headers
        assert.equal xhr.headers["X-Base"], query.base
        assert.equal xhr.headers["X-Offset"], query.offset
        done()

      client.find '/foo', onSuccess, null, query

  suite '#get', ->

    test 'Should get an object with a proper url', (done) ->
      obj = foo: 'bar'
      xhrFac = mockXhrFactory E.SUCCESS, obj
      client = new Client xhrFac, context
      url = '/foo/1'

      client.get url, ->
        xhr = xhrFac.last
        done() if xhr.url is url

  suite '#delete', ->

    id = null
    url = null
    model = null

    setup ->
      id = 1
      url = "/users/user/api/1"
      model =
        id: 1
        _rest_links:
          "api-resource-users-user":
            "url": url,
            "methods": ["PUT", "GET", "DELETE"]

    test 'Should successfully delete an entity', (done) ->
      xhrFac = mockXhrFactory E.SUCCESS
      client = new Client xhrFac, context

      client.delete model, ->
        xhr = xhrFac.last
        checkHeaders xhr.headers
        done() if xhr.url is url and xhr.method is 'DELETE'

    test 'Should call an error callback', (done) ->
      xhrFac = mockXhrFactory E.ERROR
      client = new Client xhrFac, context

      client.delete model, null, done

  suite '#request', ->

    test 'Should convert an object into JSON', ->
      xhrFac = mockXhrFactory E.SUCCESS
      client = new Client xhrFac, context

      client.request 'PUT', {a: 1}, ->
        assert.equal xhr.content, '{"a":1}'
