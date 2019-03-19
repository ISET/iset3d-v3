%% v_iset3d
% Run these validation tests before doing a git push
%
% Description:
%    Run these validation tests before doing a git push. This is a first
%    attempt at validating iset3d prior to committing.
%
% History:
%    XX/XX/18  ZL, BW  SCIEN Stanford 2018
%    03/18/19  JNM     Documentation pass

%% Initialize & Begin
% Determine whether you are working in ISETBio or ISETCam
fprintf('Attempting to execute using %s.\n', piCamBio);

%% Basic V2 basic testing
disp('Teapot: Takes one minute or so')
s_piReadRenderLookat

%%  Version 2 slightly more complex
% disp('ChessSet: Takes a couple of minutes')
% s_ChessSet

%%  Version 3
% disp('t_piMaterialChange: Takes a minute or two')
% t_piMaterialChange

%% End