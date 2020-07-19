%% t_eyeCrop2Cones
%
% Draft of rendering a large scene and then pulling out a section of the
% retinal irradiance using oiCrop and rendering it on the cone mosaic
%
% See also
%

% TODO:
%   Copy some of the ROI utilities from ISETCam over to ISETBio

%%
ieInit

%%
thisSE = sceneEye('bathroom');
fromOrig = thisSE.get('from');

%{
 % Look around and choose position of the crop region
 % 
 thisSE.set('use pinhole',true);
 thisSE.set('fov',20);
 scene = thisSE.render('render type','radiance');
 sceneWindow(scene);
 sceneSet(scene,'gamma',0.4);

 thisSE.set('from',fromOrig + [0 -5 0]);
 scene = thisSE.render('render type','radiance');
 sceneWindow(scene);

%}
thisSE.set('use pinhole',false);

thisSE.set('from',fromOrig + [0 -5 0]);

thisSE.set('rays per pixel',256);

oi = thisSE.render('render type','radiance');
oiWindow(oi);
[~,rect] = vcROISelect(oi);

%%
oi2 = oiCrop(oi,rect);
oiWindow(oi2);
oi2 = oiSet(oi2,'fov',3);

%%
cones = coneMosaic;
cones.setSizeToFOV(2);
cones.emGenSequence(50);
cones.compute(oi2);
cones.window;

