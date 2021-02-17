function [underwater, waterProperties] = piSceneSubmerge(scene, varargin)

p = inputParser;
p.addOptional('sizeX',1,@isnumeric);
p.addOptional('sizeY',1,@isnumeric);
p.addOptional('sizeZ',1,@isnumeric);
p.addOptional('offsetX',0, @isnumeric);
p.addOptional('offsetY',0, @isnumeric);
p.addOptional('offsetZ',0, @isnumeric);
p.addOptional('waterAbs',true,@islogical);
p.addOptional('waterSct',true,@islogical);
p.addOptional('cPlankton',0,@isnumeric);
p.addOptional('aCDOM440',0,@isnumeric);
p.addOptional('aNAP400',0,@isnumeric);
p.addOptional('cSmall',0,@isnumeric);
p.addOptional('cLarge',0,@isnumeric);
p.addOptional('wallOnly',0,@islogical);
p.addOptional('wallXY',0,@islogical);
p.addOptional('wallXZ',0,@islogical);
p.addOptional('wallYZ',0,@islogical);

p.parse(varargin{:});
inputs = p.Results;

%%

wave = 395:5:705;

% Light and water page 90
waterAbsWave = 200:10:800;
waterAbs = [3.07 1.99 1.31 0.927 0.720 0.559 0.457 0.373 0.288 0.215 0.141 0.105 0.0844 0.0678 0.0561 0.0463 0.0379 0.0300 0.0220 0.0191 0.0171 0.0162 0.0153 0.0144 0.0145 0.0145 0.0156 0.0156 0.0176 0.0196 0.0257 0.0357 0.0477 0.0507 0.0558 0.0638 0.0708 0.0799 0.108 0.157 0.244  0.289 0.309 0.319 0.329 0.349 0.400 0.430 0.450 0.500 0.650 0.839 1.169 1.799 2.38 2.47 2.55 2.51 2.36 2.16 2.07];

% absWave = [400, 405, 410, 415, 420, 425, 430, 435, 440, 445, 450, 455, 460, 465, 470, 475, 480, 485, 490, 495, 500, 505, 510, 515, 520, 525, 530, 535, 540, 545, 550, 555, 560, 565, 570, 575, 580, 585, 590, 595, 600, 605, 610, 615, 620, 625, 630, 635, 640, 645, 650, 655, 660, 665, 670, 675, 680, 685, 690, 695, 700];
% pureWaterAbs = [0.035080, 0.033118, 0.030408, 0.028562, 0.026118, 0.024902, 0.023099, 0.021404, 0.019910, 0.018851, 0.017619, 0.017859, 0.018095, 0.018295, 0.018501, 0.018991, 0.019880, 0.020770, 0.021810, 0.023542, 0.025761, 0.029207, 0.032930, 0.037112, 0.040245, 0.042098, 0.044156, 0.046693, 0.049525, 0.052769, 0.056292, 0.061013, 0.065429, 0.070765, 0.076831, 0.085858, 0.100352, 0.121569, 0.148864, 0.180922, 0.221222, 0.243105, 0.257202, 0.267508, 0.277863, 0.285397, 0.292787, 0.299453, 0.306261, 0.314608, 0.325244, 0.348966, 0.374212, 0.393069, 0.407539, 0.422468, 0.441646, 0.470825, 0.505272, 0.557488, 0.617855];
planktonAbsWave = [400, 405, 410, 415, 420, 425, 430, 435, 440, 445, 450, 455, 460, 465, 470, 475, 480, 485, 490, 495, 500, 505, 510, 515, 520, 525, 530, 535, 540, 545, 550, 555, 560, 565, 570, 575, 580, 585, 590, 595, 600, 605, 610, 615, 620, 625, 630, 635, 640, 645, 650, 655, 660, 665, 670, 675, 680, 685, 690, 695, 700];
planktonAbs = [0.015500, 0.016200, 0.016900, 0.016950, 0.017000, 0.017400, 0.017800, 0.018100, 0.018400, 0.018100, 0.017800, 0.017950, 0.018100, 0.017600, 0.017100, 0.015850, 0.014600, 0.013850, 0.013100, 0.012600, 0.012100, 0.011450, 0.010800, 0.010250, 0.009700, 0.009250, 0.008800, 0.008300, 0.007800, 0.007100, 0.006400, 0.005800, 0.005200, 0.004900, 0.004600, 0.004700, 0.004800, 0.004850, 0.004900, 0.004500, 0.004100, 0.004150, 0.004200, 0.004550, 0.004900, 0.005400, 0.005900, 0.006000, 0.006100, 0.005750, 0.005400, 0.006500, 0.007600, 0.009500, 0.011400, 0.011250, 0.011100, 0.008650, 0.006200, 0.003900, 0.001600];

cdomAbs = exp(-0.014 * (wave - 440));
napAbs = exp(-0.011 * (wave - 400));
        
totalAbs = interp1(waterAbsWave,waterAbs, wave, 'linear','extrap') * inputs.waterAbs + ...
           interp1(planktonAbsWave,planktonAbs, wave, 'linear', 'extrap') * inputs.cPlankton + ...
           cdomAbs * inputs.aCDOM440 + napAbs * inputs.aNAP400;
absFile = sprintf('%f %f\n', [wave; totalAbs]);

waterProperties.wave = wave;
waterProperties.absorption = totalAbs;

particleAngles = [0.000000, 0.008727, 0.017453, 0.026180, 0.034907, 0.069813, 0.104720, 0.174533, 0.261799, 0.523599, 0.785398, 1.047198, 1.308997, 1.570796, 1.832596, 2.094395, 2.356194, 2.617994, 3.141593];
smallParticles = [5.300000, 5.300000, 5.200000, 5.200000, 5.100000, 4.600000, 3.900000, 2.500000, 1.300000, 0.290000, 0.098000, 0.041000, 0.020000, 0.012000, 0.008600, 0.007400, 0.007400, 0.007500, 0.008100];
largeParticles = [140.000000, 98.000000, 46.000000, 26.000000, 15.000000, 3.600000, 1.100000, 0.200000, 0.050000, 0.002800, 0.000620, 0.000380, 0.000200, 0.000063, 0.000044, 0.000029, 0.000020, 0.000020, 0.000070];

numAngles = 64;
angles = (0:(numAngles-1))/(numAngles-1) * pi;

vsfWater = (550 ./ wave(:)).^(4.32) * (0.000093 * (1 + 0.835 * (cos(pi - angles).^2)));
vsfSmall = (550 ./ wave(:)).^(1.7) * interp1(particleAngles, smallParticles, pi - angles);
vsfLarge = (550 ./ wave(:)).^(0.3) * interp1(particleAngles, largeParticles, pi - angles);

vsfWave = repmat(wave(:),[1, numAngles]);
vsf = vsfWater * inputs.waterSct + inputs.cSmall * vsfSmall + inputs.cLarge * vsfLarge;

vsfFile = sprintf('%f %f\n%f %f\n',length(wave), numAngles, [vsfWave(:), vsf(:)]');

waterProperties.vsf = vsf;
waterProperties.scattering = sum(vsf .* repmat(sin(pi - angles),length(wave),1) * angles(2) * 2 * pi, 2);
waterProperties.phaseFunction = vsf ./ repmat(waterProperties.scattering, [1, numAngles]);
waterProperties.angles = angles;

%{
testAngle = 37;
figure; 
hold on; grid on; box on;
plot(waterProperties.vsf(:,testAngle));
plot(waterProperties.scattering .* waterProperties.phaseFunction(:,testAngle),'x');
%}


%%

underwater = copy(scene);
underwater.integrator.subtype = 'spectralvolpath';

dx = inputs.sizeX/2;
dy = inputs.sizeY/2;
dz = inputs.sizeZ/2;
   
        
% Vertices of the cube
P = [ dx -dy  dz;
      dx -dy -dz;
      dx  dy -dz;
      dx  dy  dz;
     -dx -dy  dz;
     -dx -dy -dz;
     -dx  dy -dz;
     -dx  dy  dz;];

 indices = [4 0 3 
            4 3 7 
            0 1 2 
            0 2 3 
            1 5 6 
            1 6 2 
            5 4 7 
            5 7 6 
            7 3 2 
            7 2 6 
            0 5 1 
            0 4 5]'; 
        
%{  
figure;
hold on; grid on; box on;
for i=1:size(indices,1)
    face = P(indices(i,:) + 1,:);
    face = cat(1,face,face(1,:));
   
    plot3(face(:,1),face(:,2),face(:,3),'lineWidth',2);
end

for p=1:size(P,1)
    text(P(p,1),P(p,2),P(p,3),sprintf('%i',p-1), 'fontsize',20); 
end
            xlabel('x');
            ylabel('y');
            zlabel('z');
%}
            
waterCubeShape.meshshape = 'trianglemesh';
waterCubeShape.integerindices = ['[', sprintf('%i ',indices), ']'];
waterCubeShape.pointp = ['[' sprintf('%.3f ',P') ']'];
            
                  
if inputs.wallOnly == false
       
    water = piAssetCreate('type','branch');
    water.name = 'Water';
    water.size.l = inputs.sizeX;
    water.size.h = inputs.sizeY;
    water.size.w = inputs.sizeZ;
    water.size.pmin = [-dx; -dy; -dz];
    water.size.pmax = [dx; dy; dz];
    water.position = [inputs.offsetX; inputs.offsetY; inputs.offsetZ];
    
    [underwater.assets, waterID] = underwater.assets.addnode(1,water);
    
    waterCube = piAssetCreate('type','object');
    waterCube.name = 'WaterMesh';
    waterCube.mediumInterface = 'Seawater';
    waterCube.material = 'none';
    waterCube.shape = waterCubeShape;
    
    underwater.assets = underwater.assets.addnode(waterID, waterCube);


    if isempty(underwater.media)

        m = piMediumCreate;
        m.name = "Seawater";
        m.type = "uber";
        m.absFile = absFile;
        m.vsfFile = vsfFile;

        underwater.media.list = m;
    end

    % Submerge the camera if needed
    xstart = -dx + inputs.offsetX;
    xend = dx + inputs.offsetX;

    ystart = -dy + inputs.offsetY;
    yend = dy + inputs.offsetY;

    zstart = -dz + inputs.offsetZ;
    zend = dz + inputs.offsetZ;

    camPos = underwater.get('from');

    if xstart <= camPos(1) && camPos(1) <= xend && ...
       ystart <= camPos(2) && camPos(2) <= yend && ...
       zstart <= camPos(3) && camPos(3) <= zend

        underwater.camera.medium = "Seawater";

    end

end

%% Add a black wall around water volume
if inputs.wallXY || inputs.wallXZ || inputs.wallYZ
    
    
    walls = piAssetCreate('type','branch');
    walls.name = 'Walls';
    walls.size.l = inputs.sizeX;
    walls.size.h = inputs.sizeY;
    walls.size.w = inputs.sizeZ;
    walls.size.pmin = [-dx; -dy; -dz];
    walls.size.pmax = [dx; dy; dz];
    walls.position = [inputs.offsetX; inputs.offsetY; inputs.offsetZ];

    [underwater.assets, wallsID] =  underwater.assets.addnode(1,walls);
    
    
    P = P * 1.01;
    
    if inputs.wallXY 
        wallIDs = [1, 2, 5, 6];
    
        wall = piAssetCreate('type','object');
        wall.name = 'WallXY';
        wall.material.namedmaterial = 'WallXY_material';
        wall.shape.meshshape = 'trianglemesh';
        wall.shape.integerindices = ['[' sprintf('%i ',indices(:,wallIDs)) ']'];
        wall.shape.pointp = ['[' sprintf('%f ',P') ']'];
        
        underwater.assets = underwater.assets.addnode(wallsID,wall);
        
        data = [wave(:), zeros(numel(wave),1)]';
        wallMaterial = piMaterialCreate('WallXY_material',...
                        'type','matte','kd',data(:)');
                    
        underwater.materials.list = cat(1, underwater.materials.list, wallMaterial);
    
    end
    
    if inputs.wallYZ
        wallIDs = [3, 4, 7, 8]; 
        
        wall = piAssetCreate('type','object');
        wall.name = 'WallYZ';
        wall.material.namedmaterial = 'WallYZ_material';
        wall.shape.meshshape = 'trianglemesh';
        wall.shape.integerindices = ['[' sprintf('%i ',indices(:,wallIDs)) ']'];
        wall.shape.pointp = ['[' sprintf('%f ',P') ']'];
        
        underwater.assets = underwater.assets.addnode(wallsID,wall);
        
        data = [wave(:), zeros(numel(wave),1)]';
        wallMaterial = piMaterialCreate('WallYZ_material',...
                        'type','matte','kd',data(:)');
                    
        underwater.materials.list = cat(1, underwater.materials.list, wallMaterial);
    
    end
    
    if inputs.wallXZ
        wallIDs = [9, 10, 11, 12];
    
        wall = piAssetCreate('type','object');
        wall.name = 'WallXZ';
        wall.material.namedmaterial = 'WallXZ_material';
        wall.shape.meshshape = 'trianglemesh';
        wall.shape.integerindices = ['[' sprintf('%i ',indices(:,wallIDs)) ']'];
        wall.shape.pointp =['[' sprintf('%f ',P') ']'];
        
        underwater.assets = underwater.assets.addnode(wallsID,wall);
        
        data = [wave(:), zeros(numel(wave),1)]';
        wallMaterial = piMaterialCreate('WallXZ_material',...
                        'type','matte','kd',data(:)');
                    
        underwater.materials.list = cat(1, underwater.materials.list, wallMaterial);
        
    end
 
end

end