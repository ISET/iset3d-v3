%% t_eyeStereo
%
% Show how to create stereo pairs by moving the 'from' position 6cm
% horizontally.  The chess set is a good example to illustrate the stereo.
%

%%  Read a scene
thisR = piRecipeDefault('scene name','SimpleScene');

%% Modify it here
thisR.set('spatial resolution',512);

%% Instead of perspective (pinhole) let's put in a camera lens
lensname = 'dgauss.22deg.12.5mm.json';
c = piCameraCreate('omni','lens file',lensname);
thisR.set('camera',c);
thisR.set('fov',25);

% thisR.set('film diagonal',15);
thisR.summarize;

%% Write and render

piWrite(thisR);
oi = piRender(thisR,'render type','irradiance');
oiWindow(oi);

%% END
