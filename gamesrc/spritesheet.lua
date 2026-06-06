SPRITESHEET = {};
SPRITESHEET.SCRIPTNAME = "spritesheet.lua";

function SPRITESHEET.getSpriteSheet(imagePath, framesX, framesY, framerate)
    logging.DEBUG("Loading sprite sheet: " .. imagePath .. " with " .. framesX .. "x" .. framesY .. " frames at " .. framerate .. " FPS", SPRITESHEET.SCRIPTNAME);
    local spriteSheet = {};
    spriteSheet.image = love.graphics.newImage(imagePath);
    local width, height = spriteSheet.image:getDimensions();
    spriteSheet.frames = {};
    spriteSheet.frameWidth = width / framesX;
    spriteSheet.frameHeight = height / framesY;
    local totalFrames = framesX * framesY;
    for i = 0, totalFrames - 1 do
        local x = (i % framesX) * spriteSheet.frameWidth;
        local y = math.floor(i / framesX) * spriteSheet.frameHeight;
        local quad = love.graphics.newQuad(x, y, spriteSheet.frameWidth, spriteSheet.frameHeight, width, height);
        table.insert(spriteSheet.frames, quad);
    end
    spriteSheet.framesPerRow = math.floor(spriteSheet.image:getWidth() / spriteSheet.frameWidth);
    spriteSheet.update = function(self, dt)
        self.currentTime = (self.currentTime or 0) + dt;
        local frameDuration = 1 / framerate;
        if self.currentTime >= frameDuration then
            self.currentTime = self.currentTime - frameDuration;
            self.currentFrame = (self.currentFrame or 1) + 1;
            if self.currentFrame > #self.frames then
                self.currentFrame = 1;
            end
        end
    end
    spriteSheet.draw = function(self, x, y, dir)
        love.graphics.draw(self.image, self.frames[self.currentFrame or 1], x, y, 0, dir or 1, 1);
    end
    logging.DEBUG("Sprite sheet loaded successfully: " .. imagePath, SPRITESHEET.SCRIPTNAME);
    return spriteSheet;
end

return SPRITESHEET;