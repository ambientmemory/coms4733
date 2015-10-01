function [ angle ] = StopProgram( serPort)
%STOPPROGRAM Summary of this function goes here
%   Detailed explanation goes here

    SetFwdVelAngVelCreate(serPort, 0, 0);
    angle = 0;
end

