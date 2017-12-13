function [locations, targets, up, camI] = mapSurround360Cameras(numCamerasCircum, whichCameras,basePlateHeight) %, fovRectilinear, resX, resY)

%MAPSURROUND360CAMERAS Outputs and plots "LookAt's" for cameras arranged
%around a circumference. Also outputs JSON file describing camera setup.

% fov is horizontal FOV of rectilinear lens (circumference)

% TODO: Break this into more functions in the future

% Base plate has a radius of 6.911 inches == 175.54 mm
% I think the last element of the lens will roughly be at the edge of the
% base plate, since the lenses seem to stick out of the plate, judging from
% the other diagrams in the schematics.
radius = 175.54; % mm
angleIncrement = 360/numCamerasCircum;
%basePlateHeight = 1524; % mm, this is adjustable, from 4'10'' min to 6'2'' max

% Set up the camera locations around the circumference
horizCameraLocations = zeros(14,3); % [x,y,z]
horizLookDir = zeros(14,3);
currAngle = 0;
for i = 1:numCamerasCircum
    currAngle = currAngle - angleIncrement;
    horizCameraLocations(i,:) = [radius.*[cosd(currAngle) sind(currAngle)] basePlateHeight];
    horizLookDir(i,:) = [(radius*2).*[cosd(currAngle) sind(currAngle)] basePlateHeight];
end

% Set up the locations of top and bottom (x2) cameras
% Note: Point grey camera module is around 50 mm tall, so we factor that in
% as well.
% Second bottom camera is 3.375 inches == 85.73 off the center
vertCameraLocations = [0 0 basePlateHeight+50;
    0 0 basePlateHeight-50;
    85.73 0 basePlateHeight-50];
vertLookDir= vertCameraLocations +[0 0 100;
    0 0 -100;
    0 0 -100];

% Plot locations to visualize
figure;
scatter3(horizCameraLocations(:,1),horizCameraLocations(:,2),horizCameraLocations(:,3),'x'); hold on;
scatter3(vertCameraLocations(:,1),vertCameraLocations(:,2),vertCameraLocations(:,3),'x');

horizVector = horizLookDir - horizCameraLocations;
quiver3(horizCameraLocations(:,1),horizCameraLocations(:,2),horizCameraLocations(:,3), ...
    horizVector(:,1),horizVector(:,2),horizVector(:,3))

vertVector = vertLookDir - vertCameraLocations;
quiver3(vertCameraLocations(:,1),vertCameraLocations(:,2),vertCameraLocations(:,3), ...
    vertVector(:,1),vertVector(:,2),vertVector(:,3))

xlabel('x (mm)'); ylabel('y (mm)'); zlabel('z (mm)'); grid on; axis image;

% We match the up direction of the top/bottom cameras with the lookAt of
% the first camera. Not strictly necessary, but it might make rotating the
% top and bottom views easier.
cameraUp = [ repmat([0 0 1],[numCamerasCircum 1]); ...
    [horizVector(1,:); horizVector(1,:); horizVector(1,:)] ];

quiver3(horizCameraLocations(:,1),horizCameraLocations(:,2),horizCameraLocations(:,3), ...
    cameraUp(1:numCamerasCircum,1),cameraUp(1:numCamerasCircum,2),cameraUp(1:numCamerasCircum,3))

quiver3(vertCameraLocations(:,1),vertCameraLocations(:,2),vertCameraLocations(:,3), ...
    cameraUp((numCamerasCircum+1):end,1),cameraUp((numCamerasCircum+1):end,2),cameraUp((numCamerasCircum+1):end,3))

% Combine all cameras into a single vector. the indexing must correspond to
% the indexing given in the Facebook 360 manual (see Section 3)
locationsAll = [horizCameraLocations; vertCameraLocations];
targetsAll = [horizLookDir; vertLookDir];
upAll = cameraUp;
indexing = [15 1:14 16 17]; % Facebook indexes the camera starting from 0.
locationsAll = locationsAll(indexing,:);
targetsAll = targetsAll(indexing,:);
upAll = upAll(indexing,:);

quiver3(locationsAll(:,1),locationsAll(:,2),locationsAll(:,3), ...
    upAll(:,1),upAll(:,2),upAll(:,3));

% Add camera ID's
camIAll = zeros((numCamerasCircum+3),1);
for i = 1:(numCamerasCircum+3)
    x = locationsAll(i,1);
    y = locationsAll(i,2);
    z = locationsAll(i,3);
    text(x,y,z,num2str(i-1));
    camIAll(i) = i-1;
end


%% Output 

% Only output the cameras we chose to render
locations = locationsAll(whichCameras,:);
targets = targetsAll(whichCameras,:);
up = upAll(whichCameras,:);
camI = camIAll(whichCameras);

end

