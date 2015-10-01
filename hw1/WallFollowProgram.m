%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMS W4733 Computational Aspects of Robotics 2015
%
% Homework 1
%
% Team number: 007 
% Team leader: Jett Andersen (jca2136)
% Team members: Jett Andersen (jca2136), Piyali Mukherjee (pm2678), Tia Zhao (tz2191)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function finalRad = WallFollowProgram(serPort)

    % set constants
    maxDuration = 300; % s
    maxV = 0.1; % m/s
    tStart = tic; % s
    turnAlongWall = pi/16;
    turnOffWall = 0;
    orientationEps = 2*pi;
    pauseTime = 0.1; % s
    positionEps = maxV * pauseTime * 40;
    
    % loop values
    v = maxV;
    orientation = 0;
    position = [0, 0];
    hasStarted = false;
    hasLeftStartPos = false;
    
    SetFwdVelAngVelCreate(serPort, v, 0);
    
    while toc(tStart) < maxDuration
        
        % Check if back at starting point
        orientation = orientation + AngleSensorRoomba(serPort);
        position = position + changeInPosition(serPort, orientation);
        normalizedOrientation = mod(orientation + orientationEps/2, 2*pi);
        if norm(position) < positionEps && ...
                normalizedOrientation <  orientationEps && ...
                hasStarted && hasLeftStartPos
            break;
        elseif hasStarted && norm(position) >= positionEps
            hasLeftStartPos = true;
            display(position);
            display(mod(orientation, 2*pi));
        end
        
        % Stay near wall
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
                BumpsWheelDropsSensorsRoomba(serPort);
        Wall = WallSensorReadRoomba(serPort);
        if BumpRight || BumpLeft || BumpFront
            rotate(serPort, turnAlongWall);
            turnOffWall = -turnAlongWall/2;
            v = 0;
            if ~hasStarted
                display hihihi
                hasStarted = true;
                DistanceSensorRoomba(serPort);
                position = [0, 0];
                orientation = 0;
            end
        elseif ~Wall
            rotate(serPort, turnOffWall);
            v = maxV;
        else
            v = maxV;
        end
        
        SetFwdVelAngVelCreate(serPort, v, 0);
        pause(pauseTime)
    end
    
    SetFwdVelAngVelCreate(serPort, 0, 0);
    finalRad = orientation;
end

function position = changeInPosition(serPort, orientation)
    distance = DistanceSensorRoomba(serPort);
    dx = distance * cos(orientation);
    dy = distance * sin(orientation);
    position = [dx, dy];
end

function rotate(serPort, angleToTurn)
    v = 0;
    w = sign(angleToTurn)*v2w(v);
    pauseTime = 0.05;
    elapsedTime = 0;
    
    AngleSensorRoomba(serPort);
    SetFwdVelAngVelCreate(serPort, v, w);
    
    while abs(elapsedTime * w) < abs(angleToTurn)
        pause(pauseTime);
        elapsedTime = elapsedTime + pauseTime;
    end
    
    SetFwdVelAngVelCreate(serPort, 0, 0);
end

function w = v2w(v)
    % robot facts
    maxWheelV = 0.5; % m/s
    robotRadius = 0.2; % m

    w = (maxWheelV - v)/robotRadius;
end
