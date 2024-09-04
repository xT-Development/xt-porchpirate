return {
    maxPackages = 1,                        -- Max spawned packages

    locations = {                           -- Package locations
        vector3(989.61, -433.78, 63.75),
        vector3(863.36, -512.2, 57.33),
        vector3(888.51, -608.43, 58.22),
        vector3(1000.53, -592.22, 59.23),
        vector3(1201.91, -600.33, 67.72),
        vector3(1272.53, -680.57, 65.77),
        vector3(1386.88, -568.25, 74.48),
        vector3(1302.27, -573.23, 71.73),
        vector3(1268.81, -456.59, 69.84),
        vector3(891.72, -538.85, 58.13)
    },

    packageItems = {                        -- Items received from opeing packages
        { 'water', 1 }
    },

    chanceOfExplosion = 100,                -- Check of explosion from package

    timeUntilExplosion = {                  -- Length of time until the package explodes if its rigged
        min = 5,
        max = 10
    }
}