NYANCATPARTICLES = {};
NYANCATPARTICLES.SCRIPTNAME = "nyancatparticles.lua";
NYANCATPARTICLES.IMAGES = {
    ["blue"] = "assets/sprites/StarAnimBlue01.png",
    ["green"] = "assets/sprites/StarAnimGreen01.png",
    ["orange"] = "assets/sprites/StarAnimOrange01.png",
    ["purple"] = "assets/sprites/StarAnimPurple01.png",
    ["red"] = "assets/sprites/StarAnimRed01.png",
    ["yellow"] = "assets/sprites/StarAnimYellow01.png"
};

function NYANCATPARTICLES:Update(dt)
    self.system:update(dt);
end

function NYANCATPARTICLES:Draw()
    love.graphics.draw(self.system);
end

function NYANCATPARTICLES:Create(color, spawnrate, lifetimestart, lifetimelen)
    logging.DEBUG("Creating particle system for color: " .. color, NYANCATPARTICLES.SCRIPTNAME);
    local this = {};
    this.particleImg = love.graphics.newImage(NYANCATPARTICLES.IMAGES[color]);
    this.quads = {};
    local frameWidth = this.particleImg:getWidth() / 2;
    local frameHeight = this.particleImg:getHeight() / 2;
    local columns, rows = 2, 2;
    for y = 0, rows - 1 do
        for x = 0, columns - 1 do
            local quad = love.graphics.newQuad(x * frameWidth, y * frameHeight, frameWidth, frameHeight, this.particleImg:getDimensions());
            table.insert(this.quads, quad);
        end
    end
    this.system = love.graphics.newParticleSystem(this.particleImg, 15);
    this.system:setParticleLifetime(lifetimestart or 0, lifetimelen or 3); -- Particles live 3 seconds
    this.system:setEmissionRate(spawnrate or 40);
    this.system:setEmissionArea("normal", 0, 0, 0, false);
    this.system:setSizes(0, 1, 2); -- Particles can have varying sizes
    this.system:setRotation(0, math.pi * 2); -- Random rotation
    this.system:setSpin(0, math.pi / 4); -- Random spin
    this.system:setColors(1, 1, 1, 1, 1, 1, 1, 0); -- Fade out over time
    return this;
end

return NYANCATPARTICLES;