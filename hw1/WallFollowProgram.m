function finalRad = WallFollowProgram(serPort)
    % set constants
    maxDuration = 300; % s
    maxDistSansBump = 5; % m
    maxAngleSansBump = 2*pi;
    maxV = 0.3; % m/s
    tStart = tic; % s
    
    % loop values
    angleSansBump = 0;
    distSansBump = 0;
    angleTurned = 0;
    v = maxV;
    w = v2w(v);
    
    SetFwdVelAngVelCreate(serPort, v, w);
    
    while toc(tStart) < maxDuration && ...
            distSansBump <= maxDistSansBump
        [bumped, angleTurned_] = bumpCheckReact(serPort);
        angleTurned = angleTurned + angleTurned_;
        
        if bumped
            DistanceSensorRoomba(serPort);
            AngleSensorRoomba(serPort);
            
            distSansBump = 0;
            angleSansBump = 0;
            v = maxV;
            w = 0;
        else
            v = min(maxV * (1 - angleSansBump / maxAngleSansBump), maxV);
            display(v)
            w = v2w(v);
        end
        
        SetFwdVelAngVelCreate(serPort, v, w);
        
        distSansBump = distSansBump + DistanceSensorRoomba(serPort);
        deltaAngle = AngleSensorRoomba(serPort);
        angleTurned = angleTurned + deltaAngle;
        angleSansBump = angleSansBump + deltaAngle;
        
        if(abs(angleSansBump) > abs(maxAngleSansBump))
            display deltaAngle
            rotate(serPort, -angleSansBump);
            angleSansBump = 0;
        end
        
        pause(0.1)
    end
    
    SetFwdVelAngVelCreate(serPort, 0, 0);
    
    finalRad = 0;
end

function [bumped, angleTurned] = bumpCheckReact(serPort)
    [BumpRight, BumpLeft, ~, ~, ~, BumpFront] = ...
        BumpsWheelDropsSensorsRoomba(serPort);
    bumped = BumpRight || BumpLeft || BumpFront;   
    display hi
    angleTurned = 0;
    if bumped
        angleTurned = rotate(serPort, pi/4);
    end
end

function angleTurned = rotate(serPort, angleToTurn)
    v = 0;
    w = -v2w(v);
    SetFwdVelAngVelCreate(serPort, v, w);
    angleTurned = 0;
    while abs(angleTurned) < abs(angleToTurn)
        angleTurned = angleTurned + AngleSensorRoomba(serPort);
        pause(0.1);
    end
    SetFwdVelAngVelCreate(serPort, 0, 0);
end

function w = v2w(v)
    
    % robot facts
    maxWheelV = 0.5; % m/s
    robotRadius = 0.2; % m

    w = (maxWheelV - v)/robotRadius;
end