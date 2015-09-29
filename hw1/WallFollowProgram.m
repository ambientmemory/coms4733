function finalRad = WallFollowProgram(serPort)
    % set constants
    maxDuration = 300; % s
    maxV = 0.4; % m/s
    minV = 0.1; % m/s
    tStart = tic; % s
    turnAlongWall = pi/16;
    turnOffWall = 0;
    
    % loop values
    v = maxV;
    w = 0;
    
    SetFwdVelAngVelCreate(serPort, v, w);
    
    while toc(tStart) < maxDuration
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
                BumpsWheelDropsSensorsRoomba(serPort);
        Wall = WallSensorReadRoomba(serPort);
        if BumpRight || BumpLeft || BumpFront
            turnOffWall = -pi/16;

            rotate(serPort, turnAlongWall);
            if BumpFront
                v = 0;
            else
                v = minV;
            end
        elseif ~Wall
            rotate(serPort, turnOffWall);
            v = maxV;
        else
            v = maxV;
        end
        
        SetFwdVelAngVelCreate(serPort, v, w);
        
        pause(0.1)
    end
    
    SetFwdVelAngVelCreate(serPort, 0, 0);
    
    finalRad = 0;
end

function [bumped, angleTurned] = bumpCheckReact(serPort)
    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
        BumpsWheelDropsSensorsRoomba(serPort);
    bumped = BumpRight || BumpLeft || BumpFront;
    display hi
    angleTurned = 0;
    if bumped
        angleTurned = rotate(serPort, pi/4);
    end
end

function angleTurned = rotate(serPort, angleToTurn)
    v = 0;
    w = sign(angleToTurn)*v2w(v);
    SetFwdVelAngVelCreate(serPort, v, w);
    angleTurned = 0;
    while abs(angleTurned) < abs(angleToTurn)
        angleTurned = angleTurned + AngleSensorRoomba(serPort);
        pause(0.1);
    end
    SetFwdVelAngVelCreate(serPort, 0, 0);
end

function w = v2w(v)
    
    % robot facts
    maxWheelV = 0.5; % m/s
    robotRadius = 0.2; % m

    w = (maxWheelV - v)/robotRadius;
end
