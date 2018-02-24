% Quick utility to read in all the optical images in a folder and resave
% them with the right focal length, aperture, and FOV settings. I need this
% because I have a lot of data I generated with s_360CameraRig.m in which I
% did not set these values correctly when saving out the optical image.

% TLian 1/2018

%% Initialize
clear; close all; ieInit;

oiDir = '/share/wandell/users/tlian/360Scenes/renderings/livingRoom_2048_2048_2048_8';
overWriteFlag = false; % Directly overwrite the optical images?

if(~overWriteFlag)
    % Make a new directory to save generated opitcal images
    saveDir = fullfile(oiDir,'fixedOI');
    mkdir(saveDir);
else
    saveDir = oiDir;
end

%% Loop through all oi in directory

dirInfo = dir(fullfile(oiDir,'*.mat'));
nFiles = length(dirInfo);
    
for ii = 1:nFiles
    
    fprintf('%d/%d \n',ii,nFiles);
    
    clear oi;
    
    currFilename = dirInfo(ii).name;
    
    
    % For the facebook camera, this changes depending on the camera
    if(strcmp(currFilename,'cam0.mat') || ...
            strcmp(currFilename,'cam15.mat') || ...
            strcmp(currFilename,'cam16.mat'))
        % Fish eye lens
        lensFocalLength = 6;
        apertureDiameter = 6;
        filmDiag = 16;
    else
        % Wide-angle
        lensFocalLength = 6;
        apertureDiameter = 0.87;
        filmDiag = 16;
    end
    
    % Google camera
    %{
    lensFocalLength = 3;
    apertureDiameter = 0.435;
    filmDiag = 8;
      %}
    
    % Load current optical image
    load(fullfile(oiDir,currFilename));
    
    if(~exist('oi','var'))
        continue;
    end
    
    % Reset the parameters
    oi = oiSet(oi, 'optics focal length', lensFocalLength * 1e-3);
    oi = oiSet(oi,'optics fnumber',lensFocalLength/apertureDiameter);
    
    % Compute the horizontal field of view
    photons = oiGet(oi, 'photons');
    x = size(photons,2);
    y = size(photons,1);
    d = sqrt(x.^2 + y.^2);  % Number of samples along the diagonal
    fwidth= (filmDiag / d) * x;    % Diagonal size by d gives us mm per step
    fov = 2 * atan2d(fwidth / 2, lensFocalLength);
    
    % Store the horizontal field of view in degrees in the oi
    oi = oiSet(oi, 'fov', fov);
    
    vcAddAndSelectObject(oi);
    oiWindow;
    
    % Save "fixed" optical image
    save(fullfile(saveDir,currFilename),'oi');
    
end


