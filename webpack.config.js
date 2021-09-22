const { resolve } = require("path");
const webpack = require("webpack");

const { BACKEND } = process.env;

const publicFolder = resolve("./public");

module.exports = (env) => {
  const devMode = Boolean(env.WEBPACK_SERVE);

  const loaderConfig = {
    loader: "elm-webpack-loader",
    options: {
      debug: false,
      optimize: !devMode,
      cwd: __dirname,
    },
  };

  const elmLoader = devMode
    ? [{ loader: "elm-hot-webpack-loader" }, loaderConfig]
    : [loaderConfig];

  return {
    mode: devMode ? "development" : "production",
    entry: "./src/index.js",
    output: {
      publicPath: "/",
      path: publicFolder,
      filename: "bundle.js",
    },
    stats: devMode ? "errors-warnings" : "normal",
    infrastructureLogging: {
      level: "warn",
    },
    devServer: {
      port: 8000,
      hot: "only",
      proxy: {
        "/ping": BACKEND,
        changeOrigin: true,
      },
    },
    module: {
      rules: [
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: elmLoader,
        },
        {
          test: /\.(woff(2)?|ttf)$/,
          type: "asset/inline",
        },
        {
          test: /\.css$/,
          use: ["style-loader", "css-loader"],
        },
      ],
    },
    plugins: [new webpack.NoEmitOnErrorsPlugin()],
  };
};
