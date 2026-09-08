-- The per-animation "speed" values below are durations in deciseconds (1 =
-- 100ms). SPEED scales them all at once: 2 = twice as fast, 0.5 = twice as
-- slow.
local SPEED = 2.5

local function animation(opts)
	opts.speed = opts.speed / SPEED
	hl.animation(opts)
end

hl.curve("easeOutQuint",   { type = "bezier", points = {{ 0.23, 1    }, { 0.32, 1 }}})
hl.curve("easeInOutCubic", { type = "bezier", points = {{ 0.65, 0.05 }, { 0.36, 1 }}})
hl.curve("linear",         { type = "bezier", points = {{ 0, 0       }, { 1, 1    }}})
hl.curve("almostLinear",   { type = "bezier", points = {{ 0.5, 0.5   }, { 0.75, 1 }}})
hl.curve("quick",          { type = "bezier", points = {{ 0.15, 0    }, { 0.1, 1  }}})

animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default"       })
animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint"  })
animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint"  })
animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear"  })
animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear"  })
animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick"         })
animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint"  })
animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear"  })
animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear"  })
animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "almostLinear", style = "fade" })
animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick"         })
