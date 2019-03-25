%% s_metadataExamplev3
% Render the simple scene (PBRT-v3-spectral) using different metadata types
%
% Description:
%    Render the simple scene below in pbrt-v3-spectral using the different
%    metadata types.
%

% History:
%    XX/XX/18  TL/BW  SCIEN 2018
%    03/22/19  JNM    Documentation pass

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

% Determine whether you are working in ISETBio or ISETCam
fprintf('Attempting to execute using %s.\n', piCamBio);

%% Import the pbrt file
fname = fullfile(piRootPath, 'data', 'V3', ...
    'SimpleScene', 'SimpleScene.pbrt');
if ~exist(fname, 'file'), error('File not found'); end
thisR = piRead(fname, 'version', 3); % We must specify version 3 here!

%% Write out recipe
thisR.set('film resolution', [400 300]);
[p, n, e] = fileparts(fname);
thisR.set('outputFile', ...
    fullfile(piRootPath, 'local', 'SimpleScene', [n, e]));
piWrite(thisR);

%% Render a radiance file and a depth map.
% to reuse an existing rendered file of the correct size, uncomment the
% parameter key/value pair provided below.
scene = piRender(thisR, 'reuse', true);
scene = oiSet(scene, 'name', 'Radiance_and_Depth');
ieAddObject(scene);
sceneWindow;

%% Render an image segmented by material type.
% The below matImage just returns a 2D image
%
% to reuse an existing rendered file of the correct size, uncomment the
% parameter key/value pair provided below.
matImage = piRender(thisR, 'renderType', 'material'); %, 'reuse', true);
figure(2);
imagesc(matImage);
title('Material');
% You can find a txt file with the material names corresponding to each
% index in the 'renderings' folder of the output. In this case...
fprintf('For material indices labels, see %s \n', ...
    fullfile(piRootPath, 'local', 'SimpleScene', 'renderings'));

%% Render an image segmented by mesh type.
% The below meshImage just returns a 2D image
%
% to reuse an existing rendered file of the correct size, uncomment the
% parameter key/value pair provided below.
meshImage = piRender(thisR, 'renderType', 'mesh'); %, 'reuse', true);
figure(4);
imagesc(meshImage);
title('Mesh');

% You can find a txt file with the mesh names corresponding to each index
% in the 'renderings' folder of the output. In this case...
fprintf('For mesh indices labels, see %s \n', ...
    fullfile(piRootPath, 'local', 'SimpleScene', 'renderings'));

% Let's remap the values so it's easier to see
% (the 100 has a similar index as the background, which is why it seems to
% disappear in the previous image. )
uniqueValues = unique(meshImage(:));
remap = 1:length(uniqueValues);
for j = 1:length(uniqueValues)
    curI = (meshImage == uniqueValues(j));
    meshImage(curI) = remap(j);
end
figure(5);
imagesc(meshImage);
colormap;
 title('Mesh (re-mapped)');

%% Render the coordinates of the intersections
% to reuse an existing rendered file of the correct size, uncomment the
% parameter key/value pair provided below.
coordMap = piRender(thisR, 'renderType', 'coordinates'); %, 'reuse', true);
figure(6);
subplot(1, 3, 1);
imagesc(coordMap(:, :, 1));
axis image;
colorbar;
title('x-axis')
subplot(1, 3, 2);
imagesc(coordMap(:, :, 2));
axis image;
colorbar;
title('y-axis')
subplot(1, 3, 3);
imagesc(coordMap(:, :, 3));
axis image;
colorbar;
title('z-axis')

%%