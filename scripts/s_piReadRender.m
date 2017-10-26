% s_piReadRender
%
% The simplest script to read a PBRT scene file and then write it back
% out.  This 
%
% TL/BW SCIEN

%%
ieInit

%% In this case, everything is inside the one file.  Very simple

fname = fullfile(piRootPath,'data','teapot-area-light.pbrt');
exist(fname,'file')

% Read the file and return it in a recipt format
recipe = piRecipe(fname);
disp(recipe)

% Write out a file based on the recipe
oname = fullfile(piRootPath,'local','deleteMe.pbrt');
piWrite(recipe,oname);

% You can open and view the file this way
% edit(oname);
%
% We could use the single file piRender function to rennder from this
% output.

%% When we have a more complex data set ...


%%