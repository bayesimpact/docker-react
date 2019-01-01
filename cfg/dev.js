const path = require('path')
const webpack = require('webpack')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const WebpackPwaManifest = require('webpack-pwa-manifest')
const _ = require('lodash')

const baseConfig = require('./base')

var config = _.merge({
  cache: true,
  devtool: 'eval-source-map',
  entry: [
    'webpack-dev-server/client?http://0.0.0.0:0',
    'webpack/hot/only-dev-server',
  ].concat(baseConfig.entry),
  mode: 'development',
  output: {
    filename: 'app.js',
    path: __dirname,
    publicPath: baseConfig.devServer.publicPath,
  },
}, _.omit(baseConfig, 'entry'))

config.plugins = [].concat(
  config.plugins.filter(p => !(p instanceof WebpackPwaManifest)),
  [
    new webpack.LoaderOptionsPlugin({
      debug: true,
    }),
    new webpack.DefinePlugin({
      'process.env.ASSET_PATH': JSON.stringify(config.output.publicPath),
    }),
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NamedModulesPlugin(),
    // Embed the JavaScript in the index.html page.
    new HtmlWebpackPlugin(),
    new webpack.NoEmitOnErrorsPlugin(),
  ],
  config.plugins.filter(p => p instanceof WebpackPwaManifest),
)

// Add needed rules.
config.module.rules.push({
  include: [
    path.join(__dirname, '/../src'),
  ],
  test: /\.(js|jsx)$/,
  use: {
    loader: 'babel-loader',
    options: {
      plugins: [
        'react-hot-loader/babel',
        '@babel/plugin-syntax-dynamic-import',
        ['@babel/plugin-proposal-class-properties', {loose: false}],
      ],
      presets: [['@babel/env', {modules: false}], '@babel/react'],
    },
  },
})

module.exports = config
