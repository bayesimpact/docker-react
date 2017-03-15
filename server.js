/*eslint no-console:0 */
var webpack = require('webpack')
var WebpackDevServer = require('webpack-dev-server')
var config = require('./webpack.config')

const host = process.env.BIND_HOST || 'localhost'

new WebpackDevServer(webpack(config), config.devServer).
listen(config.devServer.port, host, function(err) {
  if (err) {
    console.log(err)
  }
  console.log('Listening at ' + host + ':' + config.devServer.port)
})
