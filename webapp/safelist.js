// safelist.js
const safelistColors = ["blue", "red", "green", "yellow", "zinc", "amber", "stone", "fuchsia"].flatMap((color) => [
  `bg-${color}-500`,
  `bg-${color}-400`,
  `bg-${color}-600`,
  `hover:bg-${color}-600`,
  `border-${color}-500`,
  `border-${color}-400`,
]);

module.exports = ["text-white", "px-4", "py-2", "rounded", "border-2", "opacity-50", ...safelistColors];
