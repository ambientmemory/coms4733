%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMS W4733 Computational Aspects of Robotics 2015
%
% Homework 1
%
% Team number: 007 
% Team leader: e.g. Jane Smith (js1234)
% Team members: Jett Andersen (jca2136), Piyali Mukherjee (pm2678), Tia Zhao (tzXXXX)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function finalRad = WallFollowProgram(serPort)
    % set constants
    maxDuration = 300; % s
    maxV = 0.4; % m/s
    tStart = tic; % s
    turnAlongWall = pi/16;
    turnOffWall = 0;
    angleTurnedSansBump = 0;
    
    % loop values
    v = maxV;
    angleTurned = 0;
    
    SetFwdVelAngVelCreate(serPort, v, 0);
    
    while toc(tStart) < maxDuration
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
                BumpsWheelDropsSensorsRoomba(serPort);
        if BumpRight || BumpLeft || BumpFront
            angleTurned = angleTurned + rotate(serPort, turnAlongWall);
            turnOffWall = -pi/16;
            angleTurnedSansBump = 0;
        else
            rotate(serPort, turnOffWall);
            angleTurnedSansBump = angleTurnedSansBump + turnOffWall;
            display(angleTurnedSansBump);
            if abs(angleTurnedSansBump) > 3*pi/4
                angleTurnedSansBump = 0;
                turnOffWall = -turnOffWall;
            end
        end
        
        SetFwdVelAngVelCreate(serPort, v, 0);
        
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
