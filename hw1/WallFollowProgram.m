function finalRad = WallFollowProgram(serPort)

    % Set constants
    maxDuration = 300; % s
    maxDistSansBump = 5; % m
    maxForwardVelocity = 0.5; % m/s
    maxVelocityIncrement = 0.005; % m/s
    tStart = tic;
    
    % Loop values
    distSansBump = 0;
    
    SetFwdVelAngVelCreate(serPort, maxForwardVelocity, 0);
    
    while toc(tStart) < maxDuration && ...
            distSansBump <= maxDistSansBump
        if bumpCheckReact(serPort)
            DistanceSensorRoomba(serPort);
            AngleSensorRoomba(serPort);
            
            distSansBump = 0;
        end
    end
    
    finalRad = 0;
end