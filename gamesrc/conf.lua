function love.conf(t)
    -- System and Identity
    t.identity = "NyancatGame"         -- Save directory name for logs/saves
    t.version = "11.5"                -- Target LÖVE version

    -- Window settings
    t.window.title = "Nyancat Game"   -- Window title bar text
    t.window.width = 1024              -- Window width (pixels)
    t.window.height = 768             -- Window height (pixels)
    t.window.fullscreen = false       -- Start in fullscreen
    t.window.resizable = false        -- Allow player to drag-resize window
    t.window.vsync = 1                -- Enable vertical sync (1) or disable (0)
    t.window.msaa = 0                 -- Anti-aliasing samples (0 to 16)

    -- Performance and Console
    t.console = false                  -- Open attached terminal (Windows only)
    t.accelerometerjoystick = false   -- Use mobile accelerometer as joystick

    -- Disable unused modules to save memory (set to false)
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.thread = true
    t.modules.timer = true
    t.modules.touch = true
    t.modules.video = true
    t.modules.window = true
end
