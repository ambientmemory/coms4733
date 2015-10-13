%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMS W4733 Computational Aspects of Robotics 2015
%
% Homework 2
%
% Team number: 10 
% Team leader: Jett Andersen (jca2136)
% Team members: Jett Andersen (jca2136), Piyali Mukherjee (pm2678),
%               Tia Zhao (tz2191)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function finalRad = hw2_team_007(serPort)

    % set constants
    maxV = 0.5; % m/s
    pauseTime = 0.05; % s
    goalPosition = [4, 0];
    goalPositionEps = maxV * pauseTime * 20;
    
    % loop values
    v = maxV;
    orientation = 0;
    position = [0, 0];
    lastPosition = [-goalPositionEps, -goalPositionEps];
    AngleSensorRoomba(serPort);
    DistanceSensorRoomba(serPort);
    
    SetFwdVelAngVelCreate(serPort, v, 0);
    % Follows line until wall sensor is read
    while norm(goalPosition - position) > goalPositionEps
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
                BumpsWheelDropsSensorsRoomba(serPort);
        
        Wall = WallSensorReadRoomba(serPort);
        if Wall || BumpFront || BumpLeft || BumpRight && ...
                norm(lastPosition - position) > goalPositionEps
            [position, orientation] = ...
                followWall(serPort, maxV, position, orientation, ...
                    pauseTime);
            lastPosition = position;
        end
        
        % TODO: this doesn't quite work!!!
 %       rotateDir = [1, 0, 0];
        rotate(serPort, -orientation); %, pauseTime
        orientation = updateOrientation(serPort, orientation); % was set to 0
        SetFwdVelAngVelCreate(serPort, v, 0);
        pause(pauseTime);
        position = updatePosition(serPort, position, orientation);
    end
    
    SetFwdVelAngVelCreate(serPort, 0, 0);
    finalRad = 0;
end

function [position, orientation] = ...
        followWall(serPort, maxV, position, orientation, pauseTime)
    mLineEps = maxV * pauseTime;
    hasNotLeft = true;
    turnAngle = pi/2;
    turnV = maxV/2;
    
    while abs(position(2)) >= mLineEps || hasNotLeft
        
        % 1.2 creates buffer where position might oscillate in and out of
        % mLineEps range
        if(position(2) >= mLineEps * 1.2)
            hasNotLeft = false;
        end
        
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
            BumpsWheelDropsSensorsRoomba(serPort);
        if BumpFront || BumpLeft || BumpRight
            moveStraight(serPort, -maxV, 0.3, false, pauseTime);
            position = updatePosition(serPort, position, orientation);
            
            rotate(serPort, turnAngle); %, pauseTime
            orientation = updateOrientation(serPort, orientation);
        end
        
        if WallSensorReadRoomba(serPort)
            SetFwdVelAngVelCreate(serPort, turnV, v2w(turnV));
        else
            SetFwdVelAngVelCreate(serPort, turnV, -v2w(turnV));
        end
        
        % position might get off if things happen wrongly or something? gah
        position = updatePosition(serPort, position, orientation);
        orientation = updateOrientation(serPort, orientation);
    end
end

function moveStraight(serPort, v, timeToMove, stopOffWall, pauseTime)
    SetFwdVelAngVelCreate(serPort, v, 0);
    timeMoved = 0;
    while timeMoved < timeToMove

        pause(pauseTime)
        timeMoved = timeMoved + 0.1;
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
            BumpsWheelDropsSensorsRoomba(serPort);
        bumped = BumpRight || BumpLeft || BumpFront;
        if bumped || (~WallSensorReadRoomba(serPort) && stopOffWall)
            break;
        end
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

% Calculates the change in position since the last call
function position = updatePosition(serPort, position, orientation)
    distance = DistanceSensorRoomba(serPort);
    dx = distance * cos(orientation);
    dy = distance * sin(orientation);
    position = position + [dx, dy];
end

function orientation = updateOrientation(serPort, orientation)

    orientation = mod(orientation + AngleSensorRoomba(serPort), 2*pi);
end

function w = v2w(v)
    % robot facts
    maxWheelV = 0.5; % m/s
    robotRadius = 0.2; % m

    w = (maxWheelV - v)/robotRadius;
end
