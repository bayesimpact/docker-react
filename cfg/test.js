var path = require('path')
var srcPath = path.join(__dirname, '/../src/')
var baseConfig = require('./base')

module.exports = {
  devtool: 'eval',
  entry: './test/loadtests.js',
  mode: 'development',
  module: {
    rules: [
      {
        test: /\.(png|jpg|gif|svg|woff|woff2|css|sass|scss|less|styl)$/,
        use: 'null-loader',
      },
      {
        include: [
          path.join(__dirname, '../src'),
          path.join(__dirname, '../test'),
        ],
        test: /\.[jt]sx?$/,
        use: {
          loader: 'babel-loader',
          options: {
            plugins: [
              '@babel/plugin-syntax-dynamic-import',
              ['@babel/plugin-proposal-class-properties', {loose: false}],
              ['@babel/plugin-proposal-optional-chaining', {loose: false}],
            ],
            presets: [
              ['@babel/env', {corejs: 3, modules: false, useBuiltIns: 'usage'}],
              '@babel/react',
              '@babel/typescript',
            ],
          },
        },
      },
    ],
  },
  resolve: baseConfig.resolve,
}
