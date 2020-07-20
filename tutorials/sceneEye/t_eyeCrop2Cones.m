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

%%  Render a scene with a pinhole for speed and to pick the region

% A natural scene
thisSE = sceneEye('white room');

% For speed, I didn't turn on chromatic aberration
%
thisSE.set('spatial samples',[640 640]);
thisSE.set('rays per pixel',32);   % Speed, not quality
thisSE.set('accommodation',1/5);   % Back of the further chair

% Render the oi and show it
oi = thisSE.render('render type','both');
oi = oiSet(oi,'fov',20);
oiWindow(oi); oiSet(oi,'gamma',0.3);

oiPlot(oi,'depth map');

%% This is how I picked a region of the OI to put on the cone mosaic

% [~,rect] = vcROISelect(oi);

%%  Now calculate the cone response

% rect = [169   280   122   128];
rect = [213   306    48    76];
oiSmall = oiCrop(oi,rect);
oiWindow(oiSmall);
fov = oiGet(oiSmall,'fov');

%%
conesF = coneMosaic('center',[0 0]);
conesF.setSizeToFOV(fov*1.2);
conesF.emGenSequence(50);
conesF.compute(oiSmall);
conesF.window;

%%
conesNP = coneMosaic('center',[2 0]*1e-3);  % 1 mm off to the side
conesNP.setSizeToFOV(fov*1.2);
conesNP.emGenSequence(50);
conesNP.compute(oiSmall);
conesNP.window;

%%  Scratch

%{
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
