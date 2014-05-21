_ = require 'lodash'
glob = require 'glob'
minimatch = require 'minimatch'
path = require 'path'


# Extending Array native type.
# "wrappers can be used ... in which object’s prototype chain is augmented, rather than object itself."
KlectCollection = ->
  arr = []
  arr.push.apply arr, arguments
  arr.__proto__ = KlectCollection::
  arr
KlectCollection:: = new Array
# Custom methods
KlectCollection::methods = (method) -> [].concat (item[method]() for item in @)...
KlectCollection::html = -> @methods 'html'
KlectCollection::files = -> [].concat (item.files for item in @)...

class Klect

  constructor: (config={}) ->
    @_config = config
    @_bundles = {}
    @_config.cwd ?= path.dirname(module.parent.filename) or "./"
    @_config.htmlcwd ?= "/"
    @

  html: -> KlectCollection.apply(new KlectCollection(), (val for key, val of @_bundles)).html()
  files: -> KlectCollection.apply(new KlectCollection(), (val for key, val of @_bundles)).files()

  gather: (obj) ->
    _gathered = []

    obj = { _: obj } if _.isArray obj

    for name, files of obj

      # console.log "Building", name
      _gathered.push name

      bundle = @_bundles[name] =
        name: name
        files: []

      _config = @_config
      Object.defineProperty bundle, 'html', 
        enumerable: false
        value: -> (path.join(_config.htmlcwd, file) for file in @files)

      for file in files

        # console.log "\tReading #{file}"

        # TODO: support for ':bundle.name/foo/bar/baz'
        # if name.match /^:([^\/]+)/ 
        #   # this is a bundle, steal its stuff

        # http:// to //
        file = file.replace /^http(s)?:/, ''

        if isForced = /^\!/.test file
          file = file.replace /^\!/, ''

        # List of files we already have
        # If this glob is forced, skip the unique check. (via empty array)
        _uniques = if isForced then [] else [].concat (val.files for key, val of @_bundles)...

        # New files based on pattern minus already have
        found = if file.substr(0,2) is '//' then [file] else _.difference glob.sync(file, {cwd: @_config.cwd, nonegate: true}), _uniques

        bundle.files.push found...

    # # Cheaty way to get new Array([foo, bar]) without having a nested array [[foo, bar]]
    # KlectCollection.apply new KlectCollection(), (val for name, val of @_bundles when _gathered.indexOf(name) isnt -1)

    @

  bundles: (name) ->
    matches = minimatch.match Object.keys(@_bundles), name, nonull: false
    bundles = (@_bundles[match] for match in matches)
    KlectCollection.apply new KlectCollection(), bundles

module.exports = Klect
