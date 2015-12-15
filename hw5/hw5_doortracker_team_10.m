%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMS W4733 Computational Aspects of Robotics 2015
%
% Homework 5
% Part 2
%
% Team number: 10
% Team leader: Jett Andersen (jca2136)
% Team members: Tia Zhao (tz2191), Piyali Mukherjee (pm2678)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function hw5_team_10_part2(serPort)

% PART 2   
    url = 'http://192.168.0.101/snapshot.cgi?user=admin&pwd=&resolution=10&rate=0';
    image = imread(url);
    
    width = size(image, 2);
    height = size(image, 1);
    
    figure(1);
    imshow(image);

    [x, y] = ginput(1);
    while x <= 0 || x > width || y <= 0 || y > height
        [x, y] = ginput(1);
    end
    
    color = getColor(im2double(image), floor(x), floor(y))
    
    [area, centroid] = imgfind(image, color)
    figure(2);
    
    position = [0, 0];
    orientation = 0;
    pauseTime = 0.1;
    v = 0.05;
    distToMove = 0.01;
    angleToTurn = pi/32;
    while 1
        image = imread(url);
        stay_running_inner = 1; 
        
        [curArea, curCentroid] = imgfind(image, color)
        
        % If door is still large enough in frame, brings us to closer to door
        if curArea > 0.1 % may change this threshold later, possibly to 0?
            position = moveStraight(serPort, v, position, orientation, ...
                pauseTime, distToMove);
        else 
            stay_running_inner=0;
        end 
        
        % Break out of the inner loop if door has exited frame
        if stay_running_inner == 0
           break
        end
             imdouble = im2double(image);
             color2 = getColor(imdouble, floor(curCentroid(2)), ...
                 floor(curCentroid(1)));
    end % end of giant while
        

    position = moveStraight(serPort, v, position, orientation, ...
                pauseTime, 3.5); % hardcoded distance...test later

    prevArea = 0;            
    while 1
        image = imread(url);
        stay_running_inner = 1; 
        
        [curArea, curCentroid] = imgfind(image, color)
        
        % Rotates until door has max area
        if curArea >= prevArea
            orientation = rotate(serPort, orinetation, angleToTurn, ...
                pauseTime);
        else 
            stay_running_inner=0;
        end 
        
        % Break out of the inner loop if area of door begins to shrink
        if stay_running_inner == 0
           break
        end
             imdouble = im2double(image);
             color2 = getColor(imdouble, floor(curCentroid(2)), ...
                 floor(curCentroid(1)));
        prevArea = curArea; % update the old area
        
    end % end of giant while 2

    bumped = false;
    while 1 % For knocking: move forward until bumped
        position = moveStraight(serPort, v, position, orientation, ...
                    pauseTime, distToMove);
        % check for bumper hits here
        [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
            BumpsWheelDropsSensorsRoomba(serPort);
         bumped = BumpRight || BumpLeft || BumpFront; 
        if bumped
            position =  moveStraight(serPort, -v, position, orientation, ...
                    pauseTime, 0.3); % hardcoded back up distance
            BeepRoomba(serPort); % beeps 
        end
    end %end while loop 3
 
end

function position = moveStraight(serPort, v, position, ...
        orientation, pauseTime, distToMove)
    
    SetFwdVelAngVelCreate(serPort, v, 0);
    
    initPos = position;
    while distToMove > 0 && ...
            sqrt(((position(1)-initPos(1))*(position(1)-initPos(1))) + ...
            ((position(2)-initPos(2))*position(2)*initPos(2))) ...
            < distToMove
        
        pause(pauseTime);
        position = updatePosition(serPort, position, orientation);
    end 
end

function orientation = rotate(serPort, orientation, angleToTurn, pauseTime)
    v = 0;
    w = sign(angleToTurn)*v2w(v)*.1;
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

function color = getColor(image, x, y)
    width = size(image, 2);
    height = size(image, 1);
    
    startX = max([0, x - 20]);
    startY = max([0, y - 20]);
    endX = min([width, x + 20]);
    endY = min([height, y + 20]);
    area = (endX - startX)*(endY - startY);
    
    subimage = image(startX:endX, startY:endY, :);
    color = sum(sum(subimage,1),2)/area;
end