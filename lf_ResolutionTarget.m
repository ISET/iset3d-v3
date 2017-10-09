%% Example of creating a target imaged through a microlens array
%
% Light field camera
%
% Trisha Lian
% Rendered three resolution charts placed at different distances from a
% light field camera.
%

%%
ieInit;
curDir = pwd;

%% Choose files to render
parentSceneFile = 'ResolutionTargets.dae';
mappingsFile = 'ResolutionTargetsMappings_LF.txt';
conditionsFile = 'ResolutionTargetsConditions.txt';

%% Choose renderer options.
% hints.imageWidth = 2880;
% hints.imageHeight = 2880;
hints.imageWidth = 408;
hints.imageHeight = 408;
hints.recipeName = 'MakeResolutionTargets_LF';
hints.renderer = 'PBRT'; % We're only using PBRT right now

% Move to working folder (in render-toolbox)
ChangeToWorkingFolder(hints);

%% Use docker?
hints.copyResources = 1;
SetupPBRTDocker(hints);

%% Copy textures over 
[path,~,~] = fileparts(mfilename('fullpath'));
texFiles = fullfile(path,['*' '.exr']);
d = dir(texFiles);
for i = 1:length(d)
    texName = d(i).name;
    texturePath = fullfile(path,texName);
    copyfile(texturePath, GetWorkingFolder('', false, hints));
end

fprintf('Copied textures from %s to %s. \n',path,GetWorkingFolder('', false, hints));

%% Choose struct of OI parameters, which will generate RTB3 conditions.
oiParams = struct( ...
    'lensType', 'realisticDiffraction', ...
    'specFile', 'dgauss.50mm.dat', ...
    'filmDistance', {45}, ...
    'apertureDiameter', {16},... % aperture should be large to efficiently use sensor space
    'filmDiag', {12},...
    'lookAt',{[0 0 0 0 1 0 0 0 1]});

pixelSamples = 256;
% numPinholesW = 320;
% numPinholesH = 320;
numPinholesW = 12;
numPinholesH = 12;

% Use microlens (plenoptic camera)
microlensMode = 1;

%% Generate a conditions file based on OI parameters.

varNames = {'imageName', 'groupName','filmDistance',...
    'apertureDiameter','filmDiag','pixelSamples','lookAt'...
    'numPinholesW','numPinholesH','microlensMode'};

varValues = cell(0, numel(varNames));

for ii = 1:numel(oiParams)
    
    filmDiag = oiParams(ii).filmDiag;
    filmDistance = oiParams(ii).filmDistance;
    apertureDiameter = oiParams(ii).apertureDiameter;
    lookAt = oiParams(ii).lookAt;
    
    % radiance
    imageName = sprintf('%s-radiance-%d', hints.recipeName,ii);
    radianceVals{ii} = {imageName, 'radianceMode',...
        filmDistance,...
        apertureDiameter,...
        filmDiag,...
        pixelSamples,...
        lookAt,...
        numPinholesW,...
        numPinholesH,...
        microlensMode};
    
    % depth
    imageName = sprintf('%s-depth-%d',hints.recipeName, ii);
    depthVals{ii} = {imageName, 'depthMode',...
        filmDistance,...
        apertureDiameter,...
        filmDiag,...
        pixelSamples,...
        lookAt,...
        numPinholesW,...
        numPinholesH,...
        microlensMode};
    
    varValues = cat(1, varValues, radianceVals{ii});
    varValues = cat(1, varValues, depthVals{ii});
end

WriteConditionsFile(conditionsFile, varNames, varValues);

%% Render for radiance and depth.
nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
radianceDataFiles = BatchRender(nativeSceneFiles, hints);

%% Build ISET optical images

dataRoot = GetWorkingFolder('renderings', true, hints);

for ii = 1:numel(oiParams)
    
    % Read and display depth
    imageName = strcat(depthVals{ii}{1},'_depth.exr');
    depthFile = FindFiles(dataRoot, imageName);
    [depthSliceInfo, depthData] = ReadMultichannelEXR(depthFile{1});
    depthMap = depthData(:,:,2);
    figure()
    imagesc(depthMap); colorbar; colormap(flipud(gray));
    axis image;
    title(depthVals{ii}{1});

    % Texture Image
    imageName = strcat(radianceVals{ii}{1},'.mat');
    radianceFile = FindFiles(dataRoot,imageName);
    photonData = load(radianceFile{1});
    oi = BuildOI(photonData.multispectralImage, depthMap, oiParams(ii));
    vcAddAndSelectObject(oi);
    
    % Save all data as a .mat file
    name = sprintf('%s_%i',hints.recipeName,ii);
    parameters = oiParams(ii);
    save(name,'oi','parameters');
    
end

% display optical images
oiWindow();

%%
chdir(curDir);