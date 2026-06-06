require "utilities"
require "logging"

BACKGROUND = {};
BACKGROUND.SCRIPTNAME = "background.lua";
BACKGROUND.particleImg = nil;
BACKGROUND.system = nil;
BACKGROUND.width = 0;
BACKGROUND.height = 0;

function BACKGROUND.load()
    logging.DEBUG("Loading background...", BACKGROUND.SCRIPTNAME);
    BACKGROUND.width, BACKGROUND.height = love.graphics.getDimensions();
    BACKGROUND.particleImg = love.graphics.newImage("assets/sprites/StarAnim01.png");
    BACKGROUND.quads = {};
    local frameWidth = BACKGROUND.particleImg:getWidth() / 2;
    local frameHeight = BACKGROUND.particleImg:getHeight() / 2;
    local columns, rows = 2, 2;
    for y = 0, rows - 1 do
        for x = 0, columns - 1 do
            local quad = love.graphics.newQuad(x * frameWidth, y * frameHeight, frameWidth, frameHeight, BACKGROUND.particleImg:getDimensions());
            table.insert(BACKGROUND.quads, quad);
        end
    end
    BACKGROUND.system = love.graphics.newParticleSystem(BACKGROUND.particleImg, 100);
    BACKGROUND.system:setQuads(BACKGROUND.quads);
    BACKGROUND.system:setParticleLifetime(3, 3); -- Particles live between 1 and 3 seconds
    BACKGROUND.system:setEmissionRate(40); -- Emit 20 particles per seconds
    BACKGROUND.system:setEmissionArea("normal", BACKGROUND.width, BACKGROUND.height, 0, false); -- Emit from the whole screen
    BACKGROUND.system:setSizeVariation(0.7); -- Particles can have varying sizes
    BACKGROUND.system:setSizes(1.5);
    BACKGROUND.system:setRotation(0, math.pi * 2); -- Random rotation
    BACKGROUND.system:setSpin(0, math.pi / 4); -- Random spin
    BACKGROUND.system:setColors(1, 1, 1, 1, 1, 1, 1, 0); -- Fade out over time
end

function BACKGROUND.update(dt)
    -- Update background logic here (e.g., animate particles)
    if BACKGROUND.system then
        BACKGROUND.system:update(dt);
    end
end

function BACKGROUND.draw()
    -- Draw background elements here (e.g., particles)
    if BACKGROUND.system then
        love.graphics.draw(BACKGROUND.system);
    end
end

return BACKGROUND;