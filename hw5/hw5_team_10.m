%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMS W4733 Computational Aspects of Robotics 2015
%
% Homework 5
%
% Team number: 10
% Team leader: Jett Andersen (jca2136)
% Team members: Tia Zhao (tz2191), Piyali Mukherjee (pm2678)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% main function
function hw5_team_10(serPort)

    v = 0.35;
    
    AngleSensorRoomba(serPort);
    DistanceSensorRoomba(serPort);
    pauseTime = 0.1; % seconds;
    
    position = [0, 0];
    orientation = 0;
    
    % take camera image
    
    % pick color? get threshold??
    
    % segment image
    
    
    
    
    
    
    
    % robot travels from point to point
    for i = 1 : dims(2)
        angleToTurn = rot(i);
        orientation = rotate(serPort, orientation, angleToTurn, pauseTime);
        
        distToMove = dist(i);
        finPos = [y_points(i), x_points(i)]
        position = moveStraight(serPort, v, position, ...
            orientation, pauseTime, distToMove, finPos)
    end
end

function position = moveStraight(serPort, v, position, ...
        orientation, pauseTime, distToMove, finPos)
    
    SetFwdVelAngVelCreate(serPort, v, 0);
    bumped = false;
    
    initPos = position;
    while distToMove > 0 && ...
            sqrt(((position(1)-initPos(1))*(position(1)-initPos(1))) + ...
            ((position(2)-initPos(2))*position(2)*initPos(2))) ...
            < distToMove && ~bumped
        pause(pauseTime)
        
        position = updatePosition(serPort, position, orientation);
        
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
            BumpsWheelDropsSensorsRoomba(serPort);
        bumped = BumpRight || BumpLeft || BumpFront;
        
        % if robot bumps into an obstacle, assume it has reached
        % (surpassed) goal point prematurely
        if bumped
            % set position to goal point + extra padding
            % ***make sure pad matches the difference between robot 
            % diameter and obstacle growth size
            pad = 0.06;
            dx = pad * cos(orientation);
            dy = pad * sin(orientation);
            position = finPos + [dx, dy];
            
            % back up the distance of padding and move on
            % (updated position theoretically equal finPos)
            position = moveStraight(serPort, -v, position, ...
                orientation, pauseTime, pad);
        end
        
    end
end

% Rotates the robot at approximately the angle specified
function orientation = rotate(serPort, orientation, angleToTurn, pauseTime)
    v = 0;
    w = sign(angleToTurn)*v2w(v)*.75;
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