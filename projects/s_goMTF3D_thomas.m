%%  s_goMTF3D
%
% Questions:
%   * I am unsure whether the focal distance is in z or in distance from
%   the camera.  So if the camera is at 0, these are the same.  But if the
%   camera is at -0.5, these are not the same.
%
%  * There is trouble scaling the object size.  When the number gets small,
%  the object disappears.  This may be some numerical issue reading the
%  scale factor in the pbrt geometry file?
%

%%
ieInit
if ~piDockerExists, piDockerConfig; end

%% The chess set with pieces

% This just loads the scene.
load('ChessSetPieces-recipe','thisR');
chessR = thisR;

% The EIA chart
sbar = piAssetLoad('slantedbar');


% Adjust the input slot in the recipe for the local user
[~,n,e] = fileparts(chessR.get('input file'));
inFile = which([n,e]);
if isempty(inFile), error('Cannot find the PBRT input file %s\n',chessR.inputFile); end
chessR.set('input file',inFile);

% Adjust the input slot in the recipe for the local user
[p,n,e] = fileparts(chessR.get('output file'));
temp=split(p,'/');
outFile=fullfile(piRootPath,'local',temp{end});
chessR.set('output file',outFile);



% Merge them
piRecipeMerge(chessR,sbar.thisR,'node name',sbar.mergeNode);

% Position and scale the chart
%piAssetSet(chessR,sbar.mergeNode,'translate',[0 0.5 2]);
piAssetSet(chessR,sbar.mergeNode,'translate',[0 0.2 0.2]);
thisScale = chessR.get('asset',sbar.mergeNode,'scale');

piAssetSet(chessR,sbar.mergeNode,'scale',thisScale.*[0.2 0.2 0.01]);  % scale should always do this
initialScale = chessR.get('asset',sbar.mergeNode,'scale');


% Render the scene
thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-spectral';


%%

%% Add a lens and render.
%camera = piCameraCreate('omni','lensfile','dgauss.22deg.12.5mm.json');
cameraOmni = piCameraCreate('omni','lensfile','dgauss.22deg.3.0mm_aperture0.6_spectral.json')
cameraOmni.filmdistance.type='float'
cameraOmni.filmdistance.value=0.002167;
cameraOmni = rmfield(cameraOmni,'focusdistance')
cameraOmni.aperturediameter.value=0.6


cameraRTF = piCameraCreate('raytransfer','lensfile','dgauss.22deg.3.0mm.json-raytransfer-spectral.json')
cameraRTF.aperturediameter.value=0.6
cameraRTF.aperturediameter.type='float'

chessR.set('pixel samples',50)


thisR.set('film diagonal',2,'mm');


chessR.integrator.subtype='spectralpath'

chessR.integrator.numCABands.type = 'integer';
chessR.integrator.numCABands.value =3


%% Change the focal distance

% This series sets the focal distance and leaves the slanted bar in place
% at 2.3m from the camera
chessR.set('focal distance',0.2);   % Original distance z value of the slanted bar

% Omni
chessR.set('camera',cameraOmni);
oiOmni = piWRS(chessR,'render type','radiance','dockerimagename',thisDocker);

% RTF
chessR.set('camera',cameraRTF);
oiRTF = piWRS(chessR,'render type','radiance','dockerimagename',thisDocker);


oiList = {oiOmni,oiRTF};


%save('simulation_2000samples.mat')
return
%%
clear mtf;
for o=1:numel(oiList)
    oiWindow(oi);
    
    oi=oiList{o};
    % The pixel size is not the limit!
    sensor = sensorCreate;
    %sensor = sensorSet(sensor,'pixel size same fill factor',1.2e-6);
    % How to set correct pixel size given PBRT recipe?
    sensor = sensorSet(sensor,'size',[320 320]);
    sensor = sensorSet(sensor,'size',[418 418]);
    %sensor = sensorSet(sensor,'fov',22,oi); % what FOV should I use?
    
    ip = ipCreate;
    
    sensor = sensorCompute(sensor,oi);
    ip = ipCompute(ip,sensor);
    
    % MTF Lens
    ipWindow(ip)
    
    %[locs,rect] = ieROISelect(ip);
    %positions = round(rect.Position);
    positions= [203    29    79   126];
    mtf{o}= ieISO12233(ip,sensor,'all',positions);
    saveas(gcf,['./fig/MTF-' oi.name '.png'])
end

%% MTF Compare RTF met Omni
color{1}='r'
color{2}='g'
color{3}='b'
color{4}='k'
linestyle{1}='-'
linestyle{2}='--'
marker{1}='none'
marker{2}='none'
% Compare visually MTF's

fig=figure;clf;
fig.Position= [498 419 1101 245];
for o=1:numel(mtf)
    for k =1:4
        subplot(1,4,k); hold on;
        h(o)=plot(mtf{o}.freq,mtf{o}.mtf(:,k),'color',color{k},'linestyle',linestyle{o},'marker',marker{o}); hold on;
        ylim([0 1])
        xlim([0 200])
        title('MTF')
        xlabel('Freq. (cy/mm)')
        
    end
    
end
legend(h,'Omni','RTF')

%saveas(gcf,'./fig/MTF-comparison.png')
