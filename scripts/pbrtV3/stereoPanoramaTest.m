%% Test stereo panorama transforms

%% Initialize
clear; close all;
load('envCameraTestPoints.mat');
envDir = envDir(1:2:end,:);
envOrigins = envOrigins(1:2:end,:);

% nPoints = 20;
% theta = linspace(0,360,nPoints);
% envDir = [cosd(theta)' sind(theta)' zeros(nPoints,1)];
% envOrigins = repmat([0 0 0],[nPoints 1]);


%%

targets = envOrigins + envDir.*1;
nPoints = length(targets);

for ii = 1:nPoints
    
    figure(1); axis image;
    A = envOrigins(ii,:);
    B = targets(ii,:);
    pts = [A;B];
    hold on
    plot3(pts(:,1),pts(:,2),pts(:,3),'k');
    plot3(A(1),A(2),A(3),'rx');
    plot3(B(1),B(2),B(3),'bo');
    grid on;
    
end

%% Shift according to IPD

ipd = 64e-3; % mm
pole_merge_angle_to = 90;
pole_merge_angle_from = 90;
for ii = 1:nPoints
    
    interocular_offset = ipd;
    
    % Assume direction is normalized
    altitude = abs(asind(envDir(ii,3)));
    if(altitude > pole_merge_angle_to)
        interocular_offset = 0;
    elseif(altitude > pole_merge_angle_from)
        fac = (altitude - pole_merge_angle_from)/ ...
            (pole_merge_angle_to - pole_merge_angle_from);
        fade = cosd(fac*90);
        interocular_offset = fade*ipd;
    end
    
    up = [0 0 1];
    side = cross(envDir(ii,:),up);
    side = side./norm(side);
    
    stereo_offset = side .* interocular_offset;
    envOrigins(ii,:) = envOrigins(ii,:) + stereo_offset;
    
    convergence_distance = Inf;
    if(convergence_distance ~= Inf)
        screen_offset = convergence_distance .* envDir(ii,:);
        diff = screen_offset - stereo_offset;
        envDir(ii,:) = diff./norm(diff);
    end

end

for ii = 1:nPoints
    
    figure(2); axis image;
    A = envOrigins(ii,:);
    B = envDir(ii,:);
    pts = [A;B];
    hold on
    plot3(pts(:,1),pts(:,2),pts(:,3),'k');
    plot3(A(1),A(2),A(3),'rx');
    plot3(B(1),B(2),B(3),'bo');
    grid on;
end   

