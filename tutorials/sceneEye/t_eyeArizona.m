%% t_eyeArizona
%
% Run the Arizona eye model
%
%

%%
ieInit

%% Make an oi of the chess set scene using the LeGrand eye model

thisSE = sceneEye('chess set scaled','human eye','arizona');

thisSE.set('rays per pixel',512);  % Pretty quick, but not high quality

oi = thisSE.render('render type','radiance');  % Render and show

oi = oiSet(oi,'name','Arizona');

oiWindow(oi);

%% END

