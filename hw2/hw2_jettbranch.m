%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMS W4733 Computational Aspects of Robotics 2015
%
% Homework 2
%
% Team number: 010 
% Team leader: Jett Andersen (jca2136)
% Team members: Jett Andersen (jca2136), Piyali Mukherjee (pm2678),
%               Tia Zhao (tz2191)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function finalRad = hw2_team_10(serPort)

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
    
    % Follows line until wall sensor is read
    while norm(goalPosition - position) > goalPositionEps
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
                BumpsWheelDropsSensorsRoomba(serPort);
        Wall = WallSensorReadRoomba(serPort);
        
        %If we encountered a wall
        if Wall || BumpFront || BumpLeft || BumpRight
             disp('Debug: Found a wall!');
            [position, orientation] = ...
                followWall(serPort, maxV, position, orientation, ...
                    pauseTime);
            disp('Debug: exited followWall');
            lastPosition = position;
            disp('position = ');
            disp(position); 
        end
        disp('Debug: outside wall-bumper if block');
        disp('orientation is:');
        disp(orientation);
        disp('position (outside wall-bumper block) is:');
        disp(position); 
        
        %We did not encounter a wall and intend to m-line to exit
        Rotate(serPort, -orientation, pauseTime);
        %TODO @Peels: Why can't we align this orientation witb the global
        %axis? 
        %Alternatively, how do we carry forward the orientation from before
        % hitting the wall?
        new_orientation = 0; %updateOrientation(serPort, orientation);
        SetFwdVelAngVelCreate(serPort, v, 0);
        %Dropping Jett's wisdom all over here
        pause(pauseTime);
        position = updatePosition(serPort, position, new_orientation);
        
        disp('position after update is:');
        disp(position);
    end
    
    finalRad = 0;
end

function [position, orientation] = ...
        followWall(serPort, maxV, position, orientation, pauseTime)
    mLineEps = maxV * pauseTime;
    hasNotLeft = true;
    turnAngle = pi/4;
    turnV = maxV/2;
    
    %True while not on the m-line
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
            
            Rotate(serPort, turnAngle, pauseTime);
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
function Rotate(serPort, angleToTurn, pauseTime)
    v = 0;
    w = sign(angleToTurn)*v2w(v);
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