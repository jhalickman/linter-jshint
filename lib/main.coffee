
module.exports =
  config:
    jshintExecutablePath:
      default: ''
      type: 'string'
      description: 'Leave empty to use bundled'
  provideLinter: ->
    jshintPath = require('path').join(__dirname, '..', 'node_modules', '.bin', 'jshint')
    helpers = require('atom-linter')
    reporter = require('jshint-json') # a string path
    provider =
      grammarScopes: ['source.js', 'source.js.jsx']
      scope: 'file'
      lintOnFly: true
      lint: (textEditor) ->
        exePath = atom.config.get('linter-jshint.jshintExecutablePath') || jshintPath
        filePath = textEditor.getPath()
        text = textEditor.getText()
        parameters = ['--reporter', reporter, '--extract', 'auto', '--filename', filePath, '-']
        return helpers.exec(exePath, parameters, {stdin: text}).then (output) ->
          try
            output = JSON.parse(output).result
          catch error
            atom.notifications.addError("Invalid Result recieved from JSHint", {detail: "Check your console for more info", dismissible: true})
            console.log('JSHint Result:', output)
            return []
          output = output.filter((entry) -> entry.error.id)
          return output.map (entry) ->
            error = entry.error
            pointStart = [error.line - 1, error.character - 1]
            pointEnd = [error.line - 1, error.character]
            return {
              type: error.id.substr(1, error.id.length - 2)
              text: "#{error.code} - #{error.reason}"
              filePath
              range: [pointStart, pointEnd]
            }