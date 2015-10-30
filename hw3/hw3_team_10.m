%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMS W4733 Computational Aspects of Robotics 2015
%
% Homework 3
%
% Team number: 10
% Team leader: Jett Andersen (jca2136)
% Team members: Tia Zhao (tz2191), Piyali Mukherjee (pm2678)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% main function
function hw3_team_10(serPort)
    cellSize = 1; % meters
    grid = ones(10/cellSize);
    v = 0.45;
    
    pauseTime = 0.1; % seconds;
    maxTimeBetweenUpdates = 60; % seconds
    
    position = [0, 0];
    orientation = 0;
    lastUpdateTime = toc;
    
    while toc - lastUpdateTime < maxTimeBetweenUpdates
        angleToTurn = normalizeAngle(rand*pi+pi/2);
        orientation = rotate(serPort, orientation, angleToTurn, pauseTime);
        lastGrid = grid;
        [position, grid] = moveStraight(serPort, v, grid, position, ...
            orientation, cellSize, pauseTime);
        [position, grid] = moveStraight(serPort, -v, grid, position, ...
            orientation, cellSize, pauseTime, 0.4);
        change = grid ~= lastGrid;
        if(sum(change(:)) > 0)
            lastUpdateTime = toc;
        end
    end
    HeatMap(grid);
end

function [position, grid] = moveStraight(serPort, v, grid, position, ...
        orientation, cellSize, pauseTime, timeToMove)
    if(nargin < 8)
        timeToMove = -1;
    end
    
    SetFwdVelAngVelCreate(serPort, v, 0);
    bumped = false;
    
    curTime = toc;
    while timeToMove > 0 && toc - curTime < timeToMove ...
            || timeToMove < 0 && ~bumped ...
            && position(1) < 5 && position(1) > -5 ...
            && position(2) < 5 && position(2) > -5
        
        pause(pauseTime)
        
        position = updatePosition(serPort, position, orientation);
        cell = positionToCell(position, cellSize, size(grid, 1));
        grid(cell(2), cell(1)) = 0;
        
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
            BumpsWheelDropsSensorsRoomba(serPort);
        bumped = BumpRight || BumpLeft || BumpFront;
    end
end

function cell = positionToCell(position, cellSize, gridSize)
    cell = floor(position / cellSize) + gridSize / 2 + 1;
    cell = max(min(cell, gridSize), 1);
end

% Rotates the robot at approximately the angle specified
function orientation = rotate(serPort, orientation, angleToTurn, pauseTime)
    v = 0;
    w = sign(angleToTurn)*v2w(v);
    startOrientation = orientation;
    
    SetFwdVelAngVelCreate(serPort, v, w);
    while abs(orientation - startOrientation) < abs(angleToTurn)
        pause(pauseTime);
        orientation = orientation + AngleSensorRoomba(serPort);
    end
    
    SetFwdVelAngVelCreate(serPort, 0, 0);
    orientation = normalizeAngle(orientation);
end

% Calculates the change in position since the last call
function position = updatePosition(serPort, position, orientation)
    distance = DistanceSensorRoomba(serPort);
    dx = distance * cos(orientation);
    dy = distance * sin(orientation);
    position = position + [dx, dy];
end

function orientation = updateOrientation(serPort, orientation)
    orientation = normalizeAngle(orientation + AngleSensorRoomba(serPort));
end

function angle = normalizeAngle(angle)
    angle = mod(angle, 2*pi);
    if(angle > pi)
        angle = angle - 2*pi;
    end
end

function w = v2w(v)
    % robot facts
    maxWheelV = 0.5; % m/s
    robotRadius = 0.2; % m

    w = (maxWheelV - v)/robotRadius * 0.9;
end