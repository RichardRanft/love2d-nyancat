require "logging"
require "background"
require "nyancat"

NYANCATGAME = {};
NYANCATGAME.GAMESTATE = "menu";
NYANCATGAME.SCRIPTNAME = "nyancatgame.lua";
NYANCATGAME.menuOptions = {};
NYANCATGAME.menuBGScaleX = 1;
NYANCATGAME.menuBGScaleY = 1;
NYANCATGAME.gameBGScaleX = 1;
NYANCATGAME.gameBGScaleY = 1;
NYANCATGAME.bgm = "assets/audio/NyanCat.wav";
NYANCATGAME.bgmSource = nil;
NYANCATGAME.nyanCat = nil;
NYANCATGAME.speedIncrement = 10;
NYANCATGAME.score = 0;

function NYANCATGAME.createButton(text, x, y, width, height, img, hoverimg, action)
    logging.DEBUG("Creating button: " .. text .. " at (" .. x .. ", " .. y .. ")", NYANCATGAME.SCRIPTNAME);
    return {
        text = text,
        x = x,
        y = y,
        width = width,
        height = height,
        action = action,
        img = img,
        hoverimg = hoverimg,
        isHovered = false
    };
end

function NYANCATGAME.getImgScaling(img)
    logging.DEBUG("Calculating image scaling for: " .. tostring(img), NYANCATGAME.SCRIPTNAME);
    local imgWidth = img:getWidth();
    local imgHeight = img:getHeight();
    local windowWidth, windowHeight = love.graphics.getDimensions();
    local scaleX = windowWidth / imgWidth;
    local scaleY = windowHeight / imgHeight;
    logging.DEBUG("Window size: " .. windowWidth .. "x" .. windowHeight, NYANCATGAME.SCRIPTNAME);
    logging.DEBUG("Image dimensions: " .. imgWidth .. "x" .. imgHeight, NYANCATGAME.SCRIPTNAME);
    logging.DEBUG("Calculated scale factors: " .. scaleX .. " (X), " .. scaleY .. " (Y)", NYANCATGAME.SCRIPTNAME);
    return scaleX, scaleY;
end

function NYANCATGAME.drawMenu()
    if BACKGROUND.system.isActive then
        BACKGROUND.system:stop();
    end
    love.graphics.draw(menuBGImg, 0, 0, 0, NYANCATGAME.menuBGScaleX, NYANCATGAME.menuBGScaleY);
    for i, option in ipairs(NYANCATGAME.menuOptions) do
        selectedOption = i;
        local img = option.isHovered and option.hoverimg or option.img;
        love.graphics.draw(img, option.x, option.y, 0, NYANCATGAME.menuBGScaleX, NYANCATGAME.menuBGScaleY);
    end
end

function NYANCATGAME.startGame()
    logging.DEBUG("Starting game...", NYANCATGAME.SCRIPTNAME);
    love.graphics.setNewFont(12);
    love.graphics.setColor(1,1,1);
    love.graphics.setBackgroundColor(1,1,1);
    NYANCATGAME.bgmSource = love.audio.newSource(NYANCATGAME.bgm, "stream");
    NYANCATGAME.bgmSource:setLooping(true);
    NYANCATGAME.bgmSource:setVolume(0.5);
    NYANCATGAME.bgmSource:play();
    NYANCATGAME.score = 0;
    BACKGROUND.system:start();
    NYANCAT.load();
    NYANCATGAME.GAMESTATE = "game";
end

function NYANCATGAME.drawScore()
    local screenWidth = love.graphics.getWidth();
    local oldcolor = {love.graphics.getColor()};
    local sysfont = love.graphics.newFont(48);
    love.graphics.setFont(sysfont);
    love.graphics.setColor(1, 1, 1);
    love.graphics.printf("Score: " .. NYANCATGAME.score, 0, 5, screenWidth, "center");
    love.graphics.setColor(unpack(oldcolor));
end

function NYANCATGAME.drawGame()
    -- Game logic and drawing would go here
    love.graphics.draw(gameBGImg, 0, 0, 0, NYANCATGAME.gameBGScaleX, NYANCATGAME.gameBGScaleY);
    BACKGROUND.draw();
    NYANCATGAME.drawScore();
    NYANCAT.draw();
end

function NYANCATGAME.leaveGame()
    logging.DEBUG("Leaving game...", NYANCATGAME.SCRIPTNAME);
    if BACKGROUND.system.isActive then
        BACKGROUND.system:stop();
    end
    if NYANCATGAME.bgmSource and NYANCATGAME.bgmSource:isPlaying() then
        NYANCATGAME.bgmSource:stop();
    end
    NYANCATGAME.GAMESTATE = "menu";
end

function NYANCATGAME.quitGame()
    logging.DEBUG("Cleaning up game resources...", NYANCATGAME.SCRIPTNAME);
    -- Clean up resources, stop music, etc.
    if BACKGROUND.system then
        BACKGROUND.system:stop();
    end
    if NYANCATGAME.bgmSource then
        NYANCATGAME.bgmSource:stop();
    end
end

function NYANCATGAME.testHit(x, y)
    logging.DEBUG("Testing hit at: (" .. x .. ", " .. y .. ")", NYANCATGAME.SCRIPTNAME);
    -- Placeholder for hit testing logic
    if NYANCAT.spritesheet then
        local catX, catY = NYANCAT.x, NYANCAT.y;
        if NYANCAT.direction < 0 then
            catX = catX - NYANCAT.spritesheet.frameWidth;
        end
        local catWidth = NYANCAT.spritesheet.frameWidth;
        local catHeight = NYANCAT.spritesheet.frameHeight;
        if x >= catX and x <= catX + catWidth and y >= catY and y <= catY + catHeight then
            logging.DEBUG("Hit detected!", NYANCATGAME.SCRIPTNAME);
            NYANCATGAME.score = NYANCATGAME.score + 1;
            NYANCAT.speed = NYANCAT.speed + NYANCATGAME.speedIncrement; -- Increase speed on hit
            NYANCAT.flipDirection();
            logging.DEBUG("Score: " .. NYANCATGAME.score, NYANCATGAME.SCRIPTNAME);
        else
            logging.DEBUG("Missed!", NYANCATGAME.SCRIPTNAME);
        end
    end
end

function NYANCATGAME.update(dt)
    BACKGROUND.update(dt);
    if NYANCAT.direction == 1 then
        local screenWidth = love.graphics.getWidth();
        if NYANCAT.x > screenWidth then
            logging.DEBUG("Nyan Cat went off the right edge!  Direction : " .. NYANCAT.direction, NYANCATGAME.SCRIPTNAME);
            NYANCATGAME.score = NYANCATGAME.score - 1;
            NYANCAT.flipDirection();
            NYANCAT.x = screenWidth;
            logging.DEBUG("NOTES: " .. NYANCAT.x .. " (Nyan Cat X), " .. screenWidth .. " (Screen Width)", NYANCATGAME.SCRIPTNAME);
        end
    else
        if NYANCAT.x < 0 then
            logging.DEBUG("Nyan Cat went off the left edge!  Direction : " .. NYANCAT.direction, NYANCATGAME.SCRIPTNAME);
            NYANCAT.x = 0
            NYANCATGAME.score = NYANCATGAME.score - 1;
            NYANCAT.flipDirection();
            logging.DEBUG("NOTES: " .. NYANCAT.x .. " (Nyan Cat X)", NYANCATGAME.SCRIPTNAME);
        end
    end
    NYANCAT.update(dt);
end

return NYANCATGAME;