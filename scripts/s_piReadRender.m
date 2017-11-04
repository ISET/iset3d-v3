% s_piReadRender
%
% Read a PBRT scene file, interpret it, render it (with depth map)
%
% Path requirements
%    ISET
%    CISET      - If we need the autofocus, we could use this
%    pbrt2ISET  - 
%   
%    Consider RemoteDataToolbox, UnitTestToolbox for the lenses and
%    curated scenes.
%
% TL/BW SCIEN

%%
ieInit;
if ~piDockerExists, piDockerConfig; end

%% In this case, everything is inside the one file.  Very simple

% Pinhole camera case has infinite depth of field, so no focal length is needed.
fname = fullfile(piRootPath,'data','teapot-area-light.pbrt');
if ~exist(fname,'file'), error('File not found'); end

% Read the file and return it in a recipe format
thisR = piRead(fname);
opticsType = thisR.recipeGet('optics type');

oname = fullfile(piRootPath,'local','deleteMe.pbrt');
piWrite(thisR,oname,'overwrite',true);

% Render
ieObject = piRender(oname,'opticsType',opticsType);
vcAddObject(ieObject);
switch(opticsType)
    case 'pinhole'
        sceneWindow;
        sceneSet(ieObject,'gamma',0.5);     
    case 'lens'
        oiWindow;
        oiSet(ieObject,'gamma',0.5);
end

%%