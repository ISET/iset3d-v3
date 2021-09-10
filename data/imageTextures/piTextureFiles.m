%% piTextureFiles

%{
scene = sceneCreate('slanted bar',1024);
rgb = sceneGet(scene,'rgb');
textureFile = fullfile(piRootPath,'data','imageTextures','slantedbar.png');
imwrite(rgb,textureFile);
%}

%{
scene = sceneCreate('rings rays',8,1024);
rgb = sceneGet(scene,'rgb');
textureFile = fullfile(piRootPath,'data','imageTextures','ringsrays.png');
imwrite(rgb,textureFile);
%}

%{
scene = sceneCreate('grid lines',1024,128,'ee',10);
rgb = sceneGet(scene,'rgb');
textureFile = fullfile(piRootPath,'data','imageTextures','gridlines.png');
imwrite(rgb,textureFile);
%}

%{
scene = sceneCreate('point array',512,64);
rgb = sceneGet(scene,'rgb');
textureFile = fullfile(piRootPath,'data','imageTextures','pointArray_512_64.png');
imwrite(rgb,textureFile);
%}

%{
scene = sceneCreate('point array',1024,64);
rgb = sceneGet(scene,'rgb');
textureFile = fullfile(piRootPath,'data','imageTextures','pointArray_1024_64.png');
imwrite(rgb,textureFile);
%}
