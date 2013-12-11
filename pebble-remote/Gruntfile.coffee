pebbleLocation  = '192.168.123.21'
pebble = {}

pebbleLog = (msg) ->
  red     = '\x1B[0;31m'
  reset   = '\x1B[0m'

  console.log "#{red}Pebble:#{reset} #{msg}"

installPebbleApp = (grunt) ->
  {exec}    = require('child_process')
  {spawn}   = require('child_process')
  done      = grunt?.async()
  isRunning = false

  pebble.kill?()
  exec 'pebble clean', (err, stdout, stderr) ->
    exec 'pebble build', (err, stdout, stderr) ->
      pebble = spawn 'pebble', ['install', '--phone', pebbleLocation, '--logs']
      done?()

      pebble.stdout.on 'data', (data) ->
        pebbleLog data

      pebble.stderr.on 'data', (data) ->
        console.log '\n' unless isRunning
        isRunning = true
        pebbleLog data


module.exports = (grunt) ->
  fs      = require('fs')

  grunt.initConfig
    coffee:
      compile:
        files:
          grunt.file.expandMapping(['src/coffeescript/**/*.coffee'], 'src/js/',
            rename: (destBase, destPath) ->
              return destBase + destPath.slice(17, destPath.length).replace(/\.coffee$/, '.js')
          )

    watch:
      coffee:
        files: ['src/**/*.coffee']
        tasks: ['coffee']
      other:
        files: ['src/**/*.h', 'src/**/*.c']

    grunt.event.on 'watch', (action, filepath) -> 
      installPebbleApp()

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'run', 'Start up Pebble app', ->
    installPebbleApp(@)

  grunt.registerTask 'start', ['coffee', 'run', 'watch']