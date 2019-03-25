function v_piRead
% Validate the piRead command using different example pbrt scenes
%
% More examples needed.
%
% BW, SCIEN Stanford, 2017
%%
disp('Validating pi_read');

%% Read the first test file

% This is a big file and tests the HB form
thisR = piRead(fullfile(piRootPath,'data','piExample.pbrt'));
assert(max(abs(thisR.lookAt.up - [0.1293 -0.0688 -0.9892])) < 1e-3);

%% Check a small teapot file

thisR = piRead(fullfile(piRootPath,'data','teapot-area','teapot-area-light.pbrt'));
assert(isequal(thisR.get('film xresolution'), 256));

%% Read a file without comments

%% Read files with and without blank lines 

%% Other test files needed

%%