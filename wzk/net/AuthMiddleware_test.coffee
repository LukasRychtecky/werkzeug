suite 'wzk.net.AuthMiddleware', ->
  AuthMiddleware = wzk.net.AuthMiddleware

  auth = null
  token = null
  headers = null

  mockDoc = (tok) ->
    cookie:
      "#{AuthMiddleware.HEADER.AUTH}=#{tok};"

  setup ->
    headers = {}
    token = 'dc2ad13d5b8da5bbca2a5c7061a4e07a393593c6'
    auth = new AuthMiddleware mockDoc(token)

  test 'Should set Auth header', ->
    auth = new AuthMiddleware mockDoc(token)
    auth.apply headers
    assert.equal headers[AuthMiddleware.HEADER.AUTH], token

  test 'Should not set Auth header', ->
    auth = new AuthMiddleware {cookie: ''}
    auth.apply headers
    assert.isUndefined headers[AuthMiddleware.HEADER.AUTH]
