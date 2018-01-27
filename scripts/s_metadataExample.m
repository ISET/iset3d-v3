%% Render the numbers at depth scene using different metadata types. 
% 
% TL/BW SCIEN 2018

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Import the pbrt file

fname = fullfile(piRootPath,'data','NumbersAtDepth','numbersAtDepth.pbrt');
if ~exist(fname,'file'), error('File not found'); end
thisR = piRead(fname);

%% Let's use a pinhole for quick rendering. 

thisR.set('camera','pinhole');
thisR.set('fov',40);
thisR.set('film resolution',128);
thisR.set('rays per pixel',64);

% Write out the recipe
[p,n,e] = fileparts(fname); 
thisR.set('outputFile',fullfile(piRootPath,'local',[n,e]));
piWrite(thisR);

%% Render a radiance file and a depth map.

scene = piRender(thisR);
scene = oiSet(scene,'name','Radiance_and_Depth');
vcAddObject(scene); sceneWindow;   

%% Render an image segmented by material type.

matImage = piRender(thisR,'renderType','material'); % This just returns a 2D image
figure(2)
imagesc(matImage); title('Material');
% There is no text file associated with materials, since it is difficult to
% look up material names, internally, within PBRT. 

%% Render only a depth map
depthImage = piRender(thisR,'renderType','depth'); % This just returns a 2D image
figure(3)
imagesc(depthImage); title('Depth'); colorbar;

%% Render an image segmented by mesh type.

meshImage = piRender(thisR,'renderType','mesh'); % This just returns a 2D image
figure(4)
imagesc(meshImage); title('Mesh');
% You can find a txt file with the mesh names corresponding to each index
% in the 'renderings' folder of the output. In this case...
fprintf('For mesh indices labels, see %s \n',fullfile(piRootPath,'local','renderings',strcat(n,'_mesh_mesh.txt')));

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
 
%% Render only a radiance image
scene = piRender(thisR,'renderType','radiance');
scene = oiSet(scene,'name','RadianceOnly');
vcAddObject(scene); sceneWindow; 

%%