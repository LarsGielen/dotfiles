-- Work machine: overrides on top of config/default/.
require("config.work.monitor-work")

-- Narrower master column than the desktop's ultrawide wants.
hl.config({
    master = {
        mfact = 0.5,
    },
})
