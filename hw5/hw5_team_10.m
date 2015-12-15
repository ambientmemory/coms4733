function hw5_team_10(serPort)
    url = 'http://192.168.0.100/img/snapshot.cgi?user=admin&pwd=&resolution=10&rate=0';
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
    distToMove = 0.04;
    angleToTurn = pi/32;
    while 1
        image = imread(url);
        [curArea, curCentroid] = imgfind(image, color)
        if curArea > area * 1.25
            position = moveStraight(serPort, -v, position, orientation, ...
                pauseTime, distToMove);
        elseif area > curArea * 1.25
            position = moveStraight(serPort, v, position, orientation, ...
                pauseTime, distToMove);
        end
        if curCentroid(1) > centroid(1) * 1.25
            orientation = rotate(serPort, orientation, -angleToTurn, ...
                pauseTime);
        elseif centroid(1) > curCentroid(1) * 1.25
            orientation = rotate(serPort, orientation, angleToTurn, ...
                pauseTime);
        else
             imdouble = im2double(image);
             color2 = getColor(imdouble, floor(curCentroid(2)), ...
                 floor(curCentroid(1)));
             %color = color*.75 + color2*.25;
        end
    end
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
    SetFwdVelAngVelCreate(serPort, 0, 0);
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