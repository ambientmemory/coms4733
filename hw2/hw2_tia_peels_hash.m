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

function finalRad = hw2_team_010(serPort)

    % set constants
    maxV = 0.5; % m/s
    pauseTime = 0.05; % s
    goalPosition = [4, 0];
    goalPositionEps = maxV * pauseTime * 20; %This value starts with 0.500
    
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
        
        %If either wall sensor has detected or any of the bump sensors
            % detected a wall, and we have moved at least > 0.5 m
        if Wall || BumpFront || BumpLeft || BumpRight && ...
                norm(lastPosition - position) > goalPositionEps
            %update last position before the next iteration    
            lastPosition = position;
            %Follow along the wall using this function
            [position, orientation] = ...
                followWall(serPort, maxV, position, orientation, ...
                    pauseTime);
        end
        
        % TODO: this doesn't quite work!!!
         rotate(serPort, -orientation);
         SetFwdVelAngVelCreate(serPort, v, 0);
         
         orientation = updateOrientation(serPort, orientation);
         position = updatePosition(serPort, position, orientation);
         pause(pauseTime);
    end
    
    finalRad = 0;
end

%Follow Wall happens here
function [position, orientation] = ...
        followWall(serPort, maxV, position, orientation, pauseTime)
    
    %initialize certain loop values
    mLineEps = maxV * pauseTime;
    hasNotLeft = true;
    turnAngle = pi/2;
    turnV = maxV/2;
    
    while (abs(position(2))>= mLineEps) || (hasNotLeft)
        % 1.2 creates buffer where position might oscillate in and out of
        % mLineEps range. Once outside the buffer zone, there is no wall
        if(position(2) >= (mLineEps * 1.2))
            hasNotLeft = false;
        end
        
        %Discover who was bumped
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
            BumpsWheelDropsSensorsRoomba(serPort);
        if (BumpFront || BumpLeft || BumpRight)
            %If either bump sensor was bumped, call moveStraight
            %Executes when forward bump is hit the first time?
            moveStraight(serPort, -maxV, 0.3, false, pauseTime);
            rotate(serPort, -turnAngle);
            
%             %Updating the necessary params
%             position = updatePosition(serPort, position, orientation);
%             orientation = updateOrientation(serPort, orientation);
        end
        
        if WallSensorReadRoomba(serPort)
            SetFwdVelAngVelCreate(serPort, turnV, v2w(turnV));
        else
            SetFwdVelAngVelCreate(serPort, turnV, -v2w(turnV));
        end
        
        %Updating the necessary params
        position = updatePosition(serPort, position, orientation);
        orientation = updateOrientation(serPort, orientation);
        
%         % position might get off if things happen wrongly or something? gah
%         position = updatePosition(serPort, position, orientation);
%         orientation = updateOrientation(serPort, orientation);
    end
end

%Copied over Jett's rotate function because it appears
% more reliable 
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


function moveStraight(serPort, v, timeToMove, stopOffWall, pauseTime)
%Debug: Called here with: moveStraight(serPort, -/+maxV, 0.3, false, pauseTime);
    SetFwdVelAngVelCreate(serPort, v, 0);
    timeMoved = 0;
    while timeMoved < timeToMove
        pause(pauseTime)
        timeMoved = timeMoved + 0.1;
        %Check if we are still bumped
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
            BumpsWheelDropsSensorsRoomba(serPort);
        bumped = BumpRight || BumpLeft || BumpFront;
        %Boolean short circuit evaluates always to TRUE as stopOffWall
        %never changes value
        if bumped || (~WallSensorReadRoomba(serPort) && stopOffWall)
            break;
        end
    end
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
