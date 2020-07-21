%% t_eyeCrop2Cones
%
%  We render a retinal irrdiance and then study the cone excitations from
%  different portions of the retinal image. 
%
%  We compare the information available when we are fixated on a region
%  where the cones are small and densely packed compared to when the same
%  retinal irradiance region is imaged on the cones 2mm (6 deg) away from
%  fixation. 
%
%  This code 
%
%   * renders a living room scene
%   * selects a scene region of the scene of interest to study
%   * shows the cone excitations if the region is imaged on the fovea
%   * shows the cone excitations if the region is imaged on the near
%      periphery
%
% See also
%   t_piIntro*
%

%% Check ISETBIO and initialize
if piCamBio
    fprintf('%s: requires ISETBio, not ISETCam\n',mfilename); 
    return;
end
ieInit;
if ~piDockerExists, piDockerConfig; end

%%  Render an indoor scene with a pinhole for speed 

% The rendering is rough, just to get the general overview
thisSE = sceneEye('white room');
thisSE.set('use pinhole',true);
thisSE.set('rays per pixel',256);   % Speed, not quality

scene = thisSE.render;
sceneWindow(scene); 
sceneSet(scene,'gamma',0.3);
scenePlot(scene,'depth map');

%% Let's do a bit better by calculating the retinal irradiance
tic

% This calculation takes about three minutes on my Mac
thisSE.set('use optics',true);
thisSE.set('spatial samples',[640 640]);
thisSE.set('rays per pixel',256);   % Speed, not quality
thisSE.set('accommodation',1/5);    % Back of the further chair
thisSE.set('to',[2 1.2 5.2]);       % Gets us near the pillow
thisSE.set('chromatic aberration',true);
thisSE.set('fov',20);

% Render the oi and show it
oi = thisSE.render('render type','both');

% Show the retinal irradiance
oiWindow(oi); oiSet(oi,'gamma',0.3);

oiPlot(oi,'depth map');

toc
%% This is how I picked a region of the OI to put on the cone mosaic

% [~,rect] = vcROISelect(oi);

%%  Now calculate the cone response

rect = [  411   143   117   182];
oiSmall = oiCrop(oi,rect);

oiWindow(oiSmall);
fov = oiGet(oiSmall,'fov');

%%  Image the irradiance on the fovea

conesF = coneMosaic('center',[0 0]);
conesF.setSizeToFOV(fov*1.2);
conesF.emGenSequence(50);
conesF.compute(oiSmall);
conesF.window;

%%  Image the irradiance on the near periphery

conesNP = coneMosaic('center',[2 0]*1e-3);  % 1 mm to the side
conesNP.setSizeToFOV(fov*1.2);
conesNP.emGenSequence(50);
conesNP.compute(oiSmall);
conesNP.window;

%% END

%%  Scratch

%{
% toOrig = [1.8159    1.2751    5.2786];  % white room
 % This is how I looked around and chose a from position
 % 
 thisSE.set('use pinhole',true);
 thisSE.set('fov',20);
 scene = thisSE.render('render type','radiance');
 sceneWindow(scene);
 sceneSet(scene,'gamma',0.4);

 fromOrig = thisSE.get('from');
 up   = thisSE.get('up')
 thisSE.set('rays per pixel',2);

 thisSE.set('from',fromOrig + [0 0 0]);
 scene = thisSE.render('render type','radiance');
 sceneWindow(scene);

%}

%{
% ISETBIO integration
  cm = coneMosaic;
  cm.setSizeToFOV(4);
  cm.compute(oi);
  cm.window; truesize;
%}

%{
 outDir = thisR.get('output dir')
 dir(fullfile(outDir,'renderings'))
%}

%{
% You might adjust the focus for different scenes.  Use piRender with
% the 'depth map' option to see how far away the scene objects are.
% There appears to be some difference between the depth map and the
% true focus.
  dMap = piRender(thisR,'render type','depth');
  ieNewGraphWin; imagesc(dMap); colormap(flipud(gray)); colorbar;
%}
