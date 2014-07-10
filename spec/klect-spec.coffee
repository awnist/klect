path = require 'path'
expect = require('chai').expect
Klect = require '../lib/klect'
klect = null

describe 'Klect', ->
  beforeEach ->
    klect = new Klect()

  describe '#cwd', ->
    context 'when options.cwd is not specified', ->
      it 'should be the directory of the requiring module', ->
        expect(klect._config.cwd).to.equal __dirname

    context 'when options.cwd is specified', ->
      it 'should be updated', ->
        klect2 = new Klect { cwd: '/some/root' }

        expect(klect2._config.cwd).to.not.equal klect._config.cwd

  describe '#urlcwd', ->
    context 'when options.urlcwd is specified', ->
      it 'should be updated', ->
        klect2 = new Klect { urlcwd: '/some/root' }

        expect(klect2._config.urlcwd).to.not.equal klect._config.urlcwd

  describe '#defaultBundleName', ->
    context 'when options.defaultBundleName is specified', ->
      it 'should be updated', ->
        klect2 = new Klect { defaultBundleName: '$' }

        expect(klect2._config.defaultBundleName)
          .to.not.equal klect._config.defaultBundleName

  describe '#gather(obj)', ->
    context 'when no arguments are passed', ->
      it 'should contain no bundles', ->
        klect.gather()

        keyCount = Object.keys klect._bundles
        expect(keyCount.length).to.equal 0

    context 'when a string is passed', ->
      it 'should create a bundle with the default bundle name', ->
        klect.gather 'fixtures/**/*.js'

        expect(klect._bundles).to.have.keys [klect._config.defaultBundleName]

      it 'should gather the bundles specified', ->
        klect.gather 'fixtures/**/*.js'

        bundle = klect._bundles[klect._config.defaultBundleName]
        expect(bundle.files.length).to.equal 3

    context 'when an array is passed', ->
      it 'should create a bundle with the default bundle name', ->
        klect.gather ['fixtures/bundle1/*.js', 'fixtures/bundle2/*.js']

        expect(klect._bundles).to.have.keys [klect._config.defaultBundleName]

      it 'should gather the bundles specified', ->
        klect.gather ['fixtures/bundle1/*.js', 'fixtures/bundle2/*.js']

        bundle = klect._bundles[klect._config.defaultBundleName]
        expect(bundle.files.length).to.equal 2

    context 'when an object is passed', ->
      beforeEach ->
        klect.gather
          group1: ['fixtures/bundle1/*.js', 'fixtures/bundle2/*.js']
          group2: 'fixtures/bundle3/*.js'

      it 'should create bundle the bundles specified', ->
        expect(klect._bundles).to.have.keys ['group1', 'group2']

      context 'when a string is passed as a bundle', ->
        it 'should gather the bundles specified', ->
          expect(klect._bundles.group2.files.length).to.equal 1

      context 'when an array is passed as a bundle', ->
        it 'should gather the bundles specified', ->
          expect(klect._bundles.group1.files.length).to.equal 2

    context 'when a custom #defaultBundleName is supplied', ->
      it 'should create a bundle properly named', ->
        dbn = '$$'
        klect2 = new Klect { defaultBundleName: dbn }
        klect2.gather 'fixtures/**/*.js'
        expect(klect2._bundles).to.have.keys [dbn]

  describe '#bundles(name)', ->
    beforeEach ->
      klect.gather
        group1: ['fixtures/bundle1/*.js', 'fixtures/bundle2/*.js']
        group2: 'fixtures/bundle3/*.js'

    context 'when no bundle name is passed', ->
      it 'should return all bundles', ->
        expect(klect.bundles()).to.have.length 2

    context 'when a bundle name is passed', ->
      it 'should return only the specified bundle', ->
        bundles = klect.bundles 'group1'

        expect(bundles).to.have.length 1
        expect(bundles[0].name).to.equal 'group1'

    context 'when a bundle pattern is passed', ->
      it 'should return only the bundles matching the pattern', ->
        bundles = klect.bundles '*1'

        expect(bundles).to.have.length 1
        expect(bundles[0].name).to.equal 'group1'

        bundles = klect.bundles 'group*'
        expect(bundles).to.have.length 2
        expect(bundles[0].name).to.equal 'group1'
        expect(bundles[1].name).to.equal 'group2'

  describe '#urls()', ->
    klect2 = null
    customUrlcwd = '/some/root/'

    beforeEach ->
      klect2 = new Klect
        urlcwd: customUrlcwd

      bundles =
        group1: ['fixtures/bundle1/*.js', 'fixtures/bundle2/*.js']
        group2: 'fixtures/bundle3/*.js'

      klect.gather bundles
      klect2.gather bundles

    context 'when calling from bundles', ->
      context 'when no #urlcwd has been specified', ->
        it 'should return all bundle URLs with default #urlcwd', ->
          urls = klect.bundles().urls()
          expect(urls).to.have.length 3

          for url in urls
            expect(url).to.match new RegExp('^' + klect._config.urlcwd)

        it 'should return defined bundle URLs with default #urlcwd', ->
          urls = klect.bundles('group1').urls()
          expect(urls).to.have.length 2

          for url in urls
            expect(url).to.match new RegExp('^' + klect._config.urlcwd)

      context 'when #urlcwd has been specified', ->
        it 'should return all bundle URLs with custom #urlcwd', ->
          urls = klect2.bundles().urls()
          expect(urls).to.have.length 3

          for url in urls
            expect(url).to.match new RegExp('^' + customUrlcwd)

        it 'should return defined bundle URLs with custom #urlcwd', ->
          urls = klect2.bundles('group1').urls()
          expect(urls).to.have.length 2

          for url in urls
            expect(url).to.match new RegExp('^' + customUrlcwd)
    context 'when calling from klect', ->
      context 'when no #urlcwd has been specified', ->
        it 'should return all bundle URLs with default #urlcwd', ->
          urls = klect.urls()
          expect(urls).to.have.length 3

          for url in urls
            expect(url).to.match new RegExp('^' + klect._config.urlcwd)

      context 'when #urlcwd has been specified', ->
        it 'should return all bundle URLs with custom #urlcwd', ->
          urls = klect2.urls()
          expect(urls).to.have.length 3

          for url in urls
            expect(url).to.match new RegExp('^' + customUrlcwd)

  describe '#files()', ->
    klect2 = null
    customCwd = path.join __dirname, 'fixtures'

    beforeEach ->
      klect2 = new Klect
        cwd: customCwd

      klect.gather
        group1: ['fixtures/bundle1/*.js', 'fixtures/bundle2/*.js']
        group2: 'fixtures/bundle3/*.js'

      klect2.gather
        group1: ['bundle1/*.js', 'bundle2/*.js']
        group2: 'bundle3/*.js'

    context 'when calling from bundles', ->
      context 'when no #cwd has been specified', ->
        it 'should return all bundle files with default #cwd', ->
          urls = klect.bundles().files()
          expect(urls).to.have.length 3

        it 'should return defined bundle files with default #cwd', ->
          urls = klect.bundles('group1').files()
          expect(urls).to.have.length 2

      context 'when #cwd has been specified', ->
        it 'should return all bundle files with custom #cwd', ->
          urls = klect2.bundles().files()
          expect(urls).to.have.length 3

        it 'should return defined bundle files with custom #cwd', ->
          urls = klect2.bundles('group1').files()
          expect(urls).to.have.length 2

    context 'when calling from klect', ->
      context 'when no #cwd has been specified', ->
        it 'should return all bundle files with default #cwd', ->
          urls = klect.files()
          expect(urls).to.have.length 3

      context 'when #cwd has been specified', ->
        it 'should return all bundle files with custom #cwd', ->
          urls = klect2.files()
          expect(urls).to.have.length 3
