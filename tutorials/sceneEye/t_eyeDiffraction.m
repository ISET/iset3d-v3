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

thisSE = sceneEye('slantedbar');

thisSE.set('rays per pixel',32);
from = [0 0 -500];
thisSE.set('from',from);
thisSE.set('use pinhole',true);
scene = thisSE.render;
sceneWindow(scene);


%%
thisSE.set('use optics',true);

thisSE.set('fov',1);                % About 3 deg on a side
thisSE.set('spatial samples',256);  % Number of OI sample points
thisSE.set('rays per pixel',256);
thisSE.set('focal distance',thisSE.get('object distance','m'));
thisSE.set('lens density',0);       % Yellow is harder to see.

thisSE.set('diffraction',true);
thisSE.set('pupil diameter',4);

oi = thisSE.render('render type','radiance');
oi = oiSet(oi,'name','4mm-diffractionOn');
oiWindow(oi);
oiPlot(oi,'illuminance hline',[128 128]);
set(gca,'xlim',[-30 30],'xtick',(-30:10:30));

%% Diffraction should not matter
thisSE.set('diffraction',false);
oi = thisSE.render('render type','radiance');
oi = oiSet(oi,'name','4mm-diffractionOff');
oiWindow(oi);

oiPlot(oi,'illuminance hline',[128 128]);
set(gca,'xlim',[-30 30],'xtick',(-30:10:30));
title('4 mm off')


%% Diffraction should matter

thisSE.set('rays per pixel',1024);
thisSE.set('pupil diameter',1);

thisSE.set('diffraction',true);
oi = thisSE.render('render type','radiance');
oi = oiSet(oi,'name','1mm-diffractionOn');
oiWindow(oi);

oiPlot(oi,'illuminance hline',[128 128]);
set(gca,'xlim',[-30 30],'xtick',(-30:10:30));
title('1 mm on')
%% Diffraction should matter.

% Make a direct comparison
thisSE.set('diffraction',false);
oi = thisSE.render('render type','radiance');
oi = oiSet(oi,'name','1mm-diffractionOff');
oiWindow(oi);
thisSE.summary;

oiPlot(oi,'illuminance hline',[128 128]);
set(gca,'xlim',[-30 30],'xtick',(-30:10:30));
title('1 mm off')
%%  Maybe we should be smoothing the curve at the edge?

thisSE.set('rays per pixel',4096);
thisSE.set('pupil diameter',0.5);

thisSE.set('diffraction',true);
oi = thisSE.render('render type','radiance');
oi = oiSet(oi,'name','Halfmm-diffractionOn');
oiWindow(oi);

oiPlot(oi,'illuminance hline',[128 128]);
set(gca,'xlim',[-30 30],'xtick',(-30:10:30));
title('Half mm on')
%%

thisSE.set('diffraction',false);
oi = thisSE.render('render type','radiance');
oi = oiSet(oi,'name','Halfmm-diffractionOff');
oiWindow(oi);

oiPlot(oi,'illuminance hline',[128 128]);
set(gca,'xlim',[-30 30],'xtick',(-30:10:30));
title('Half mm off')
%% END