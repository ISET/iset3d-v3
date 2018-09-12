%% t_occlusionExample.m
%
% Render a slanted bar where there  are two planes at depth depths,
% and each plane has a texture. This creates an edge where there is a
% depth discontinuity.
%
% We would like to compare the ray-traced rendering with a simpler
% version in which we simply convolve the two images with different
% blur functions and then add them.s
%
% TL ISETBIO Team, 2018
%
% See also
%   iset3d, isetbio, Docker
%

%% Initialize ISETBIO
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Try different depths
whiteDepthDpt = 5; % Always fixed at 5 dpt
blackDepthDpt = [4 5 6]; % Vary this
whiteDepth = 1/whiteDepthDpt;
blackDepth = 1./blackDepthDpt;

% Note: On a 4 core laptop, each image takes around 30 seconds to render
% with the following settings. In total, the script takes around 1.5
% minutes to run.

depthMapsFig = figure();
k = 1; % For subplots on figure

for ii = 1:length(blackDepth)
    
    % Create the scene
    
    % Scene is illuminated by EqualEnergy.spd by default.

    scene3d = sceneEye('slantedBarAdjustable',...
        'whiteDepth',whiteDepth,...
        'blackDepth',blackDepth(ii)); % in meters
    
    % Set eye parameters
    scene3d.accommodation = whiteDepthDpt; % Accommodate to white plane
    scene3d.numCABands = 8; % Can increase to 16 or 32 at the cost of render speed. 
    scene3d.numBounces = 3;
    
    % Set size parameters
    scene3d.fov        = 2; % The smaller the fov the more the LCA is visible.
    scene3d.resolution = 128; % Low quality
    scene3d.numRays    = 128; % Low quality
    
    % Render
    scene3d.name = sprintf('%0.2f_%0.2f_slantedBar',...
        whiteDepthDpt,blackDepthDpt(ii));
    [oi, result] = scene3d.render;
    
    ieAddObject(oi);
    oiWindow;
    
    % Put a figure together
    depthMap = oiGet(oi,'depthMap');
    rgb = oiGet(oi,'rgb');
    
    figure(depthMapsFig);
    subplot(2,length(blackDepthDpt),k);
    imshow(rgb);
    title(sprintf('%0.1f dpt vs %0.1f dpt',...
        blackDepthDpt(ii),whiteDepthDpt))
    
    subplot(2,length(blackDepthDpt),k+length(blackDepthDpt));
    imagesc(depthMap,[0 max(blackDepth)]); 
    colormap(gray);
    h = colorbar; axis off; axis image;
    ylabel(h, 'meters')
    title(sprintf('%0.1f dpt vs %0.1f dpt ',...
        blackDepthDpt(ii),whiteDepthDpt))
    k = k+1;
     
end


%%
