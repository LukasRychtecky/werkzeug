suite 'wzk.ui.inlineform.FieldExpert', ->

  expert = new wzk.ui.inlineform.FieldExpert(1)

  attrFrom = (id, arg) ->
    "id_argument_set-#{id}-#{arg}"

  test 'Should return next attribute in a valid format', ->
    names = ['id', 'node', 'name']
    for name in names
      assert.equal expert.process(attrFrom(0, name)), attrFrom(1, name)

    expert.next()

    for name in names
      assert.equal expert.process(attrFrom(0, name)), attrFrom(2, name)
