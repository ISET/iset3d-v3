function underwater = piSceneSubmerge(scene, varargin)

p = inputParser;
p.addOptional('height',1,@isnumeric);
p.addOptional('width',1,@isnumeric);
p.addOptional('depth',1,@isnumeric);
p.addOptional('cPlankton',0,@isnumeric);
p.addOptional('aCDOM440',0,@isnumeric);
p.addOptional('aNAP400',0,@isnumeric);
p.addOptional('cSmall',0,@isnumeric);
p.addOptional('cLarge',0,@isnumeric);

p.parse(varargin{:});
inputs = p.Results;


underwater = scene;

dx = inputs.height/2;
dy = inputs.depth/2;
dz = inputs.width/2;


% Vertices of the cube
P = [-dx -dy -dz;
      dx -dy -dz;
      dx  dy -dz;
     -dx  dy -dz;
     -dx -dy  dz;
      dx -dy  dz;
      dx  dy  dz;
     -dx  dy  dz;];

 indices = [0 1 2
            0 2 3
            4 5 6
            4 6 7
            7 2 3
            7 6 2
            5 2 6
            5 1 2
            4 5 1
            4 1 0
            4 3 7
            4 0 3];
        
%{        
figure;
hold on; grid on; box on;
for i=1:size(indices,1)
    face = P(indices(i,:) + 1,:);
    face = cat(1,face,face(1,:));
   
    plot3(face(:,1),face(:,2),face(:,3),'lineWidth',2);
end
%}      
        
indices = indices';
        
numFiles = numel(dir(fullfile(scene.get('working directory'),'scene','PBRT','pbrt-geometry','*.pbrt')));

newAsset.size.l = inputs.height;
newAsset.size.h = inputs.depth;
newAsset.size.w = inputs.width;
newAsset.size.pmin = [-dx; -dy; -dz];
newAsset.size.pmax = [dx; dy; dz];
newAsset.scale = [1; 1; 1];
newAsset.name = 'Water';
newAsset.rotate = [ 0 0 0; 0 0 1; 0 1 0; 1 0 0];
newAsset.position = [0; 0; 0];
newAsset.children.index = numFiles + 1;
newAsset.children.name = 'WaterMesh';
newAsset.children.mediumInterface = 'MediumInterface "seawater" ""';
newAsset.children.material = 'Material "none"';
newAsset.children.output = fullfile(sprintf('scene/PBRT/pbrt-geometry/%i_Water.pbrt',newAsset.children.index));
 
fid = fopen(fullfile(scene.get('working directory'),newAsset.children.output),'w');
fprintf(fid,"# Water medium\n");
fprintf(fid,"Shape ""trianglemesh""\n");
fprintf(fid,"""integer indices"" [");
fprintf(fid,"%i ",indices);
fprintf(fid,"]\n");
fprintf(fid,"""point P"" [");
for j=1:size(P,1)
    fprintf(fid,"%f ",P(j,:));
end
fprintf(fid,"]\n");
fclose(fid);

underwater.assets = cat(1,underwater.assets, newAsset);

if isempty(underwater.media)

    underwater.media.txtLines = [];
    underwater.media.outputFile_media = fullfile(scene.get('working directory'),sprintf('%s_media.pbrt',scene.get('input base name')));
    
    m = piMediumCreate;
    m.name = "seawater";
    m.type = "water";
    m.cPlankton = inputs.cPlankton;
    m.aCDOM440 = inputs.aCDOM440;
    m.aNAP400 = inputs.aNAP400;
    m.cSmall = inputs.cSmall;
    m.cLarge = inputs.cLarge;

    underwater.media.list = m;
end


end