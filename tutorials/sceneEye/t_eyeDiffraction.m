%% t_eyeDiffraction.m
%
% We recommend you go through t_eyeIntro.m before running
% this tutorial.
%
% This tutorial renders a retinal image of "slanted bar." We can then use
% this slanted bar to estimate the modulation transfer function of the
% optical system.
%
% We also show how the color fringing along the edge of the bar due to
% chromatic aberration. 
%
% Depends on: pbrt2ISET, ISETBIO, Docker, ISET
%
% TL ISETBIO Team, 2017

%% Check ISETBIO and initialize

if piCamBio
    fprintf('%s: requires ISETBio, not ISETCam\n',mfilename); 
    return;
end
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Set up the slanted bar scene

thisEye = sceneEye('slantedbar');

thisEye.set('rays per pixel',32);
from = [0 0 -500];
thisEye.set('from',from);
thisEye.set('use pinhole',true);
scene = thisEye.render;
sceneWindow(scene);


%%
thisEye.set('use optics',true);

thisEye.set('fov',1);                % About 3 deg on a side
thisEye.set('spatial samples',256);  % Number of OI sample points
thisEye.set('rays per pixel',256);
thisEye.set('focal distance',thisEye.get('object distance','m'));
thisEye.set('lens density',0);       % Yellow is harder to see.

thisEye.set('diffraction',true);
thisEye.set('pupil diameter',4);

oi = thisEye.render('render type','radiance');
oi = oiSet(oi,'name','4mm-diffractionOn');
oiWindow(oi);
oiPlot(oi,'illuminance hline',[128 128]);
set(gca,'xlim',[-30 30],'xtick',(-30:10:30));

%% Diffraction should not matter
thisEye.set('diffraction',false);
oi = thisEye.render('render type','radiance');
oi = oiSet(oi,'name','4mm-diffractionOff');
oiWindow(oi);

oiPlot(oi,'illuminance hline',[128 128]);
set(gca,'xlim',[-30 30],'xtick',(-30:10:30));
title('4 mm off')


%% Diffraction should matter

thisEye.set('rays per pixel',1024);
thisEye.set('pupil diameter',1);

thisEye.set('diffraction',true);
oi = thisEye.render('render type','radiance');
oi = oiSet(oi,'name','1mm-diffractionOn');
oiWindow(oi);

oiPlot(oi,'illuminance hline',[128 128]);
set(gca,'xlim',[-30 30],'xtick',(-30:10:30));
title('1 mm on')
%% Diffraction should matter.

% Make a direct comparison
thisEye.set('diffraction',false);
oi = thisEye.render('render type','radiance');
oi = oiSet(oi,'name','1mm-diffractionOff');
oiWindow(oi);
thisEye.summary;

oiPlot(oi,'illuminance hline',[128 128]);
set(gca,'xlim',[-30 30],'xtick',(-30:10:30));
title('1 mm off')
%%  Maybe we should be smoothing the curve at the edge?

thisEye.set('rays per pixel',4096);
thisEye.set('pupil diameter',0.5);

thisEye.set('diffraction',true);
oi = thisEye.render('render type','radiance');
oi = oiSet(oi,'name','Halfmm-diffractionOn');
oiWindow(oi);

oiPlot(oi,'illuminance hline',[128 128]);
set(gca,'xlim',[-30 30],'xtick',(-30:10:30));
title('Half mm on')
%%

thisEye.set('diffraction',false);
oi = thisEye.render('render type','radiance');
oi = oiSet(oi,'name','Halfmm-diffractionOff');
oiWindow(oi);

oiPlot(oi,'illuminance hline',[128 128]);
set(gca,'xlim',[-30 30],'xtick',(-30:10:30));
title('Half mm off')
%% END