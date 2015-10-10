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

function finalRad = hw1_team_007(serPort)

    % set constants
    maxDuration = 300; % s
    maxV = 0.2; % m/s
    tStart = tic; % s
    turnAlongWall = pi/8;
    turnOffWall = 0;
    orientationEps = 3*pi/4;
    pauseTime = 0.05; % s
    positionEps = maxV * pauseTime * 20;
    
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
            reverse(serPort, pauseTime * 2, maxV);
            rotate(serPort, turnAlongWall);
            turnOffWall = -turnAlongWall/4;
            if BumpFront
                v = 0;
            else
                v = maxV;
            end
            
            if ~hasStarted
                display hihihi
                hasStarted = true;
                DistanceSensorRoomba(serPort);
                AngleSensorRoomba(serPort);
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

% Calculates the change in position since the last call
function position = changeInPosition(serPort, orientation)
    distance = DistanceSensorRoomba(serPort);
    dx = distance * cos(orientation);
    dy = distance * sin(orientation);
    position = [dx, dy];
end

% Moves the robot in reverse for the set time at the set speed
function reverse(serPort, time, speed)
    SetFwdVelAngVelCreate(serPort, -speed, 0);
    curTime = 0;
    pauseTime_ = 0.01;
    while curTime < time
        curTime = time + pauseTime_;
        pause(pauseTime_);
    end
end

% Rotates the robot at approximately the angle specified
function rotate(serPort, angleToTurn)
    v = 0;
    w = sign(angleToTurn)*v2w(v);
    pauseTime = 0.05;
    elapsedTime = 0;
    
    SetFwdVelAngVelCreate(serPort, v, w);
    while abs(elapsedTime * w) < abs(angleToTurn)% && ~bumped
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
