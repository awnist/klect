path = require 'path'
expect = require('chai').expect
Klect = require '../lib/klect'

describe 'Klect', ->
  describe '#cwd', ->
    it 'should be the directory of the requiring module', ->
      klect = new Klect()
      expect(klect._config.cwd).to.equal __dirname

    it 'should allow for the configuration of cwd', ->
      klect1 = new Klect()
      klect2 = new Klect { cwd: '/some/root' }

      expect(klect2._config.cwd).to.not.equal klect1._config.cwd

    it 'should allow for the configuration of url cwd', ->
      klect1 = new Klect()
      klect2 = new Klect { urlcwd: '/some/root' }

      expect(klect2._config.urlcwd).to.not.equal klect1._config.urlcwd

    it 'should allow for the configuration of the defualt bundle name', ->
      klect1 = new Klect()
      klect2 = new Klect { defaultBundleName: '$' }

      expect(klect2._config.defaultBundleName)
        .to.not.equal klect1._config.defaultBundleName
