%% Render the simple scene (PBRT-v3-spectral) using different metadata types. 
% 
% TL/BW SCIEN 2018

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Import the pbrt file

fname = fullfile(piRootPath,'data','V3','SimpleScene','SimpleScene.pbrt');
if ~exist(fname,'file'), error('File not found'); end
thisR = piRead(fname,'version',3); % We must specify version 3 here!

%% Write out recipe

thisR.set('film resolution',[400 300]);

[p,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local','SimpleScene',[n,e]));
piWrite(thisR);

%% Render a radiance file and a depth map.

scene = piRender(thisR);
scene = oiSet(scene,'name','Radiance_and_Depth');
ieAddObject(scene); sceneWindow;   

%% Render an image segmented by material type.

matImage = piRender(thisR,'renderType','material'); % This just returns a 2D image
figure(2)
imagesc(matImage); title('Material');
% You can find a txt file with the material names corresponding to each index
% in the 'renderings' folder of the output. In this case...
fprintf('For material indices labels, see %s \n',fullfile(piRootPath,'local','SimpleScene','renderings'));

%% Render an image segmented by mesh type.

meshImage = piRender(thisR,'renderType','mesh'); % This just returns a 2D image
figure(4)
imagesc(meshImage); title('Mesh');
% You can find a txt file with the mesh names corresponding to each index
% in the 'renderings' folder of the output. In this case...
fprintf('For mesh indices labels, see %s \n',fullfile(piRootPath,'local','SimpleScene','renderings'));

% Let's remap the values so it's easier to see 
% (the 100 has a similar index as the background, which is why it seems to
% disappear in the previous image. )
uniqueValues = unique(meshImage(:));
remap = 1:length(uniqueValues);
for j = 1:length(uniqueValues)
    curI = (meshImage == uniqueValues(j));
    meshImage(curI) = remap(j);
end
figure(5)
imagesc(meshImage);colormap;
 title('Mesh (re-mapped)');
 
%% Render the coordinates of the intersections

coordMap = piRender(thisR,'renderType','coordinates');
figure(6);
subplot(1,3,1); imagesc(coordMap(:,:,1)); axis image; colorbar; title('x-axis')
subplot(1,3,2); imagesc(coordMap(:,:,2)); axis image; colorbar; title('y-axis')
subplot(1,3,3); imagesc(coordMap(:,:,3)); axis image; colorbar; title('z-axis')

%%