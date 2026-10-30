-- Note: Francesco's spec declares a dependency on `saghen/blink.cmp` (his
-- completion engine, not part of this aesthetic-only setup) purely for an
-- optional completion source for markview's own syntax; the core inline
-- markdown rendering this plugin is installed for works standalone.
return {
  "OXY2DEV/markview.nvim",
  ft = "markdown",
}
