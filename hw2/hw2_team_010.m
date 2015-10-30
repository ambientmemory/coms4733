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

function finalRad = hw2_team_010(serPort)

    % set constants
    maxV = 0.5; % m/s
    turnV = maxV/2;
    pauseTime = 0.05; % s
    goalPosition = [4, 0];
    goalPositionEps = maxV * pauseTime * 5;

    % loop values
    orientation = 0;
    position = [0, 0];
    lastPosition = [-goalPositionEps, -goalPositionEps];
    AngleSensorRoomba(serPort);
    DistanceSensorRoomba(serPort);
    beginWallFollowX = -1;

    % Follows line until wall sensor is read
    while norm(goalPosition - position) > goalPositionEps
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
                BumpsWheelDropsSensorsRoomba(serPort);

        Wall = WallSensorReadRoomba(serPort);
        if Wall || BumpFront || BumpLeft || BumpRight && ...
                norm(lastPosition - position) > goalPositionEps
            beginWallFollowX = position(1);
            [position, orientation] = ...
                followWall(serPort, maxV, position, orientation, ...
                    pauseTime, beginWallFollowX, goalPosition);
            lastPosition = position;
            orientation = rotate(serPort, orientation, ...
                -orientation, pauseTime);
        end
        if norm(beginWallFollowX - position(1)) < goalPositionEps
            SetFwdVelAngVelCreate(serPort, 0, 0);
            break;
        end
        v = maxV;
        w = 0;
        if(orientation  > 0)
            v = turnV;
            w = -v2w(v) * 0.8;
        elseif(orientation < 0)
            v = turnV;
            w = v2w(v) * 0.8;
        end
        SetFwdVelAngVelCreate(serPort, v, w);
        pause(pauseTime);
        position = updatePosition(serPort, position, orientation);
        orientation = updateOrientation(serPort, orientation);
    end
    
    SetFwdVelAngVelCreate(serPort, 0, 0);
    finalRad = orientation;
end

function [position, orientation] = ...
        followWall(serPort, maxV, position, orientation, pauseTime, beginWallFollowX, goalPosition)
    mLineEps = maxV * pauseTime;
    hasNotLeft = true;
    turnAngle = pi/4;
    turnV = maxV/2;

    while abs(position(2)) >= mLineEps || ...
            position(1) < (beginWallFollowX - 4*mLineEps) || ...
            position(1) > goalPosition(1) || hasNotLeft

        % 1.2 creates buffer where position might oscillate in and out of
        % mLineEps range
        if(position(2) >= mLineEps * 4)
            hasNotLeft = false;
        end

        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
            BumpsWheelDropsSensorsRoomba(serPort);
        if BumpFront || BumpLeft || BumpRight
            moveStraight(serPort, -maxV, 0.1, false, pauseTime);
            position = updatePosition(serPort, position, orientation);
            orientation = rotate(serPort, orientation, turnAngle, ...
                pauseTime);
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
        timeMoved = timeMoved + pauseTime;
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
            BumpsWheelDropsSensorsRoomba(serPort);
        bumped = BumpRight || BumpLeft || BumpFront;
        if bumped || (~WallSensorReadRoomba(serPort) && stopOffWall)
            break;
        end
    end
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

    w = (maxWheelV - v)/robotRadius;
end
