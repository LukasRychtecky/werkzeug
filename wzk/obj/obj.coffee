goog.provide 'wzk.obj'

goog.require 'goog.array'
goog.require 'goog.object'

goog.require 'wzk.array'

###*
  Merge given objects. Adds key-value pair from obj2 into obj1, iff
  obj1 does not contain the key

  @param {Object} obj1
  @param {Object} obj2
  @return {Object} obj1
###
wzk.obj.merge = (obj1, obj2) ->
  for k, v of obj2
    if not goog.object.containsKey obj1, k
      obj1[k] = v
  obj1


###*
  Generates an object as a dictionary from a given sequence or object.
  A given funtion has to return two values: key and value.
  It's a primary helper for a dict comprehension

  E.g.: wzk.obj.dict([0, 1, 2], (item, i) -> [String(i), item])
  produces: {'0': 0, '1': 1, '2': 2}

  @param {Array|Object} seqOrObj
  @param {function(*, *): Array} func takes a key and a value as arguments
###
wzk.obj.dict = (seqOrObj, func) ->
  obj = {}
  if seqOrObj.length?
    for item, i in seqOrObj
      [key, value] = func(item, i)
      obj[key] = value
  else
    for i, item of seqOrObj
      [key, value] = func(item, i)
      obj[key] = value
  return obj


###*
  Adds a key-value pair to the object/map/hash.

 @param {Object.<K,V>} obj The object to which to add the key-value pair.
 @param {string} k The key to add.
 @param {V} v The value to add.
 @return {Object.<K,V>}
 @template K,V
###
wzk.obj.set = (obj, k, v) ->
  obj = obj or {}
  goog.object.set(obj, k, v)
  obj


###*
  Associates a value in a nested associative structure, where ks is a
  sequence of keys and v is the new value and returns a new nested structure.
  If any levels do not exist, hash-maps will be created
  Adds a key-value pair to the object/map/hash.

  @param {Object.<K,V>} obj The object to which to add the key-value pair.
  @param {Array.<K>} path The path to add.
  @param {V} value The value to add.
  @return {Object.<K,V>}
  @template K,V
###
wzk.obj.assocIn = (obj, path, value) ->
  obj = obj or {}
  if goog.array.isEmpty(path)
    obj
  else if path.length is 1
    wzk.obj.set(obj, path[0], value)
  else
    wzk.obj.set(obj, path[0], wzk.obj.assocIn(goog.object.get(obj, path[0]), wzk.array.rest(path), value))


###*
  Returns the value in a nested associative structure,
  where ks is a sequence of keys. Returns nil if the key
  is not present, or the not-found value if supplied

  @param {Object.<K,V>} obj The object to which to add the key-value pair.
  @param {Array.<K>} path The key to add.
  @param {V=} implicit The default value value when key is missing.
  @return {V}
  @template K,V
###
wzk.obj.getIn = (obj, path, implicit=null) ->
  obj = obj or {}
  if goog.array.isEmpty(path)
    obj
  else if path.length is 1
    goog.object.get(obj, path[0], implicit)
  else
    wzk.obj.getIn(goog.object.get(obj, path[0], implicit), wzk.array.rest(path), implicit)
