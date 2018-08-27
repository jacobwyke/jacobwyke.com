'use strict';

const path = require('path');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const HashOutput = require('webpack-plugin-hash-output');
const fs = require('fs');

const webpackConfig = {
	entry: {
		app: './src/main.js'
	},
	output: {
		filename: process.env.NODE_ENV === 'production' ? 'assets/js/[hash:8].js' : 'assets/js/script.js',
		path: path.resolve(__dirname, './build'),
		publicPath: process.env.NODE_ENV === 'production' ? 'https://assets.jacobwyke.com/' : 'http://assets.dev.jacobwyke.com/'
	},
	resolve: {
		alias: {
			Src: path.resolve(__dirname, 'src/'),
			Assets: path.resolve(__dirname, 'src/assets'),
			Images: path.resolve(__dirname, 'src/assets/images')
		},
		extensions: [
			'.js',
			'.css',
			'.png',
			'.jpg'
		],
	},
	module: {
		rules: [
			{
				test: /\.js$/,
				exclude: /node_modules/,
				loader: 'babel-loader'
			},
			{
				test: /\.css$/,
				use: ExtractTextPlugin.extract({
					fallback: 'style-loader',
					use: [
						{
							loader: 'css-loader',
							options: {
								minimize: process.env.NODE_ENV === 'production' ? true : false
							}
						}
					]
				})
			},
			{
				test: /\.(png|jpe?g|gif|svg)(\?.*)?$/,
				loader: 'url-loader',
				options: {
					limit: 10000,
					name: process.env.NODE_ENV === 'production' ? 'assets/images/[hash:8].[ext]' : 'assets/images/[path]/[name].[ext]'
				}
			},
		],
	},
	devtool: process.env.NODE_ENV === 'production' ? (process.env.DEBUG_MODE ? 'source-map' : '') : 'cheap-module-eval-source-map',
	plugins: [
		new webpack.ExtendedAPIPlugin(),
		new webpack.DefinePlugin({
			'process.env': {
				NODE_ENV: '"'+process.env.NODE_ENV+'"',
				DEBUG_MODE: process.env.NODE_ENV === 'production' ? (process.env.DEBUG_MODE ? process.env.DEBUG_MODE : false) : true
			}
		}),
		new ExtractTextPlugin(
			{
				filename: process.env.NODE_ENV === 'production' ? 'assets/css/[contenthash:8].css' : 'assets/css/screen.css',
				allChunks: true,
			}
		),
		new webpack.NamedModulesPlugin(),
		new HashOutput()
	],
	node: {
		setImmediate: false,
		dgram: 'empty',
		fs: 'empty',
		net: 'empty',
		tls: 'empty',
		child_process: 'empty'
	},
	watchOptions: {
		aggregateTimeout: 300,
		poll: 1000
	}
};

//optimise CSS on production
if(process.env.NODE_ENV === 'production'){
	const OptimizeCSSPlugin = require('optimize-css-assets-webpack-plugin');
	webpackConfig.plugins.push(
		new OptimizeCSSPlugin(
			{
				assetNameRegExp: /\.css$/g
			}
		)
	);
}

//uglyfy JS on production
if(process.env.NODE_ENV === 'production'){
	const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
	webpackConfig.plugins.push(
		new UglifyJsPlugin(
			{
				uglifyOptions: {
					warnings: process.env.DEBUG_MODE ? true : false,
					compress: {
						warnings: process.env.DEBUG_MODE ? true : false
					}
				},
				sourceMap: process.env.DEBUG_MODE ? true : false,
				parallel: true
			}
		)
	);
}

//optimise images on production
if(process.env.NODE_ENV === 'production'){
	const ImageminPlugin = require('imagemin-webpack-plugin').default;
	webpackConfig.plugins.push(
		new ImageminPlugin(
			{
				test: /\.(jpe?g|png|gif|svg)$/i,
				pngquant: {
					quality: '95-100'
				}
			}
		)
	);
}

// Our function that generates our html plugins
function generateHtmlPlugins(templateDir, baseDir){
	// Read files in template directory
	const templateFiles = fs.readdirSync(path.resolve(__dirname, templateDir));
	let files = [];
	templateFiles.map(item => {
		// Split names and extension
		const parts = item.split('.');
		const name = parts[0];
		const extension = parts[1];
		const dir = path.relative(baseDir, templateDir)+'/';
		const minify = process.env.NODE_ENV === 'production' && extension != 'txt' ? true : false

		let stats = fs.statSync(path.resolve(__dirname, templateDir, item));
		if(stats.isFile()){
			files.push( new HtmlWebpackPlugin({
				filename: `www/${dir}${name}.${extension}`,
				template: path.resolve(__dirname, `${templateDir}/${name}.${extension}`),
				inject: false,
				domain: process.env.NODE_ENV === 'production' ? 'https://jacobwyke.com' : 'http://dev.jacobwyke.com',
				assetsDomain: process.env.NODE_ENV === 'production' ? 'https://assets.jacobwyke.com' : 'http://assets.dev.jacobwyke.com',
				base: path.resolve(__dirname, './src'),
				requireBase: __dirname,
				minify: {
					collapseInlineTagWhitespace: minify,
					collapseWhitespace: minify,
					minifyCSS: minify,
					minifyJS: minify,
					removeComments: minify,
					removeAttributeQuotes: minify,
				}
			}));
		}else{
			files = files.concat(generateHtmlPlugins(`${templateDir}/${name}`, baseDir));
		}
	});

	return files;
}

// Call our function on our views directory.
const htmlPlugins = generateHtmlPlugins('./build/_jekyll', './build/_jekyll');

webpackConfig.plugins = webpackConfig.plugins.concat(htmlPlugins);

//export the config
module.exports = webpackConfig;