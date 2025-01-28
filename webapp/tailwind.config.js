const safelist = require("./safelist");

module.exports = {
  safelist,
  content: ["./src/**/*.{vue,js}", "./public/index.html"],
  theme: {
    extend: {},
  },
  plugins: [],
};
