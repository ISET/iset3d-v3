%% t_eyeArizona
%
% Run the Arizona eye model
%
% The script runs the Arizona eye model to show it runs.  But it contains
% comments to show how to turn on chromatic aberration, narrow the FOV, and
% look at the spread in more detail.
%
% See also
%   t_eyeNavarro, t_eyeLeGrand

%%
ieInit
if piCamBio
    error('Use ISETBio, not ISETCam');
end

%
% piCamBio should be 0.  I think this is an ISETBio thing.
%

%% Make an oi of the chess set scene using the LeGrand eye model

thisSE = sceneEye('chess set scaled','human eye','arizona');

thisSE.set('rays per pixel',128);  % Pretty quick, but not high quality

oi = thisSE.render('render type','radiance');  % Render and show

oi = oiSet(oi,'name','Arizona');

oiWindow(oi);

%% Have a look with the slanted bar scene

% Commented out because it takes a while to run.  But in a way, seeing the
% chromatic aberration is the point.  So, I put it in here.  The slanted
% bar is at the focal distance.

%{
thisSE = sceneEye('slanted bar','human eye','arizona');

thisSE.set('rays per pixel',256);  % Pretty quick, but not high quality
thisSE.set('chromatic aberration',8);
thisSE.set('fov',2);

oi = thisSE.render('render type','radiance');  % Render and show

oi = oiSet(oi,'name','SB Arizona');
oiWindow(oi);

thisSE.summary;
%}

%% END

