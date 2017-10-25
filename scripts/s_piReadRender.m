% s_piReadRender
%
% The simplest possible script
%
% TL/BW SCIEN

%%
ieInit

%% In this case, everything is inside the one file.  Very simple

fname = fullfile(piRootPath,'data','teapot-area-light.pbrt');
exist(fname,'file')

% Read the file and return it in a recipt format
recipe = piRecipe(fname);

% Write it out
oname = fullfile(piRootPath,'local','deleteMe.pbrt');

piWrite(recipe,oname);

% edit(oname);
% We could write the single file execution on this output and it
% should run.  Later.

%% When we have a more complex data set ...


%%