require "utilities"
require "logging"

NYANCAT = {};
NYANCAT.SCRIPTNAME = "nyancat.lua";
NYANCAT.spritesheet = nil;
NYANCAT.x = 0;
NYANCAT.y = 0;
NYANCAT.direction = 1;
NYANCAT.speed = 20;
NYANCAT.quads = {};
NYANCAT.particles = {};

function NYANCAT.setParticles()
    local colors = {"red", "orange", "yellow", "green", "blue", "purple"};
    local yoffsetrange = NYANCAT.spritesheet.frameHeight / 2.2;
    local yoffsetincrement = yoffsetrange / (#colors + 1);
    local yoffsettop = yoffsetrange / 2;
    for color in utilities.list_iter(colors) do
        logging.DEBUG("Creating particle system for color: " .. color, NYANCAT.SCRIPTNAME);
        local particlesys = {};
        particlesys.system = NYANCATPARTICLES:Create(color, 40, 0, 5);
        particlesys.x = 0; -- Set initial x position
        particlesys.y = 0; -- Set initial y position
        particlesys.offsetx = 0;
        particlesys.offsety = yoffsettop + (yoffsetincrement * utilities.indexof(colors, color));
        table.insert(NYANCAT.particles, particlesys);
    end
end

function NYANCAT.updateParticles(dt)
    for particlesys in utilities.list_iter(NYANCAT.particles) do
        particlesys.x = NYANCAT.x + particlesys.offsetx;
        particlesys.y = NYANCAT.y + particlesys.offsety;
        particlesys.system.system:setPosition(particlesys.x, particlesys.y);
        particlesys.system.system:update(dt);
        if NYANCAT.direction > 0 then
            particlesys.system.system:setDirection(math.pi); -- Emit to the left
        else
            particlesys.system.system:setDirection(0); -- Emit to the right
        end
    end
end

function NYANCAT.load()
    logging.DEBUG("Loading Nyan Cat...", NYANCAT.SCRIPTNAME);
    NYANCAT.spritesheet = SPRITESHEET.getSpriteSheet("assets/sprites/NyanCatAnim01.png", 2, 1, 3);
    NYANCAT.setParticles();
end

function NYANCAT.flipDirection()
    NYANCAT.direction = NYANCAT.direction * -1;
    NYANCAT.y = love.math.random(0, love.graphics.getHeight() - NYANCAT.spritesheet.frameHeight);
end

function NYANCAT.update(dt)
    NYANCAT.x = NYANCAT.x + NYANCAT.speed * dt * NYANCAT.direction;
    NYANCAT.spritesheet.draw(NYANCAT.spritesheet, NYANCAT.x, NYANCAT.y, NYANCAT.direction);
    NYANCAT.spritesheet:update(dt);
    NYANCAT.updateParticles(dt);
end

function NYANCAT.draw()
    NYANCAT.spritesheet:draw(NYANCAT.x, NYANCAT.y, NYANCAT.direction);
    for particlesys in utilities.list_iter(NYANCAT.particles) do
        love.graphics.draw(particlesys.system.system);
    end
end

return NYANCAT;