function ieObject = piAcquisition2ISET(acquisition, st)
% Collects the PBRT files from a single acquisition (PBRT rendering)
% and creates scene or oi object
%
% Syntax
%
% Description
%
% Inputs
%   acquisition - Flywheel acquisition containing rendered data
%   st - scitran object
%
% Key/value options
%
% Return
%  ieObject - scene or oi depending on lens status
%
% Henryk Blasinski, 2019
%
% See also (update these as we simplify)
%   gCloud.fwBatchProcessPBRT, fwBatchProcessPBRT, scitran

%{
  st = scitran('stanfordlabs')
  sessionName = 'city3_10:42_v0.0_f66.66front_o270.00_2019712204934';
  acquisitionName = 'pos_0_0_0';
  lu = sprintf('wandell/Graphics camera array/renderings/%s/%s',sessionName,acquisitionName);
  acquisition = st.lookup(lu);
  oi = piAcquisition2ISET(acquisition,st);
  oi = piFireFliesRemove(oi);
  oiWindow(oi);
%}

%% Parameters
wave = 400:10:700; % Hard coded in pbrt
nWave = length(wave);

if notDefined('st'), st = scitran('stanfordlabs'); end

files = acquisition.files();

%% Get each of the files and
for f=1:length(files)
    
    localName = fullfile(piRootPath,'local',files{f}.name);
    st.fileDownload(files{f},'destination',localName);
    
    % files{f}.download(localName);

    if contains(localName,'depth')
        depthMap = piDat2ISET(localName, 'label', 'depth');
        %         tmp = piReadDAT(localName, 'maxPlanes', nWave);
        %         depthMap = tmp(:,:,1); clear tmp;
       
    elseif contains(localName,'mesh.dat')
        meshImage = piDat2ISET(localName, 'label', 'mesh');
        meshImage = uint16(meshImage);
        %         meshData = piReadDAT(localName, 'maxPlanes', 31);
        %         meshImage = meshData(:,:,1);
        
    elseif contains(localName,'mesh_mesh.txt')
        % These are the labels of each of the meshes
        data = importdata(localName);
        meshLabel = regexp(data, '\s+', 'split');
    else
        % Irradiance data.  Should contain (ir)radiance in a good world.
        [~, pbrtFile, ~] = fileparts(localName);
        recipeName = sprintf('%s.json',pbrtFile);
        
        energy = piReadDAT(localName, 'maxPlanes', nWave);
        photons = Energy2Quanta(wave,energy);
    end
     
end

% scene_label = piSceneAnnotation(meshImage, meshTextFile, st);
    
%% Get the recipe used to create the acquisition

% This depends on some assumption about how the recipe is named in
% Flywheel.  The assumption needs to be made explicit.
recipeFile  = st.search('file','file name',recipeName);
localRecipe = fullfile(piRootPath,'local',recipeName);

if numel(recipeFile) > 1
    warning('Multiple recipe files found');
    
elseif isempty(recipeFile)
    warning('No recipe. Assuming pinhole and scene data.');
    opticsType = 'pinhole';
    thisR = [];
    
else
    % This is the normal, OI case.
    st.fileDownload(recipeFile{1},'destination',localRecipe);
    recipeFile{1}.file.download(localRecipe);
    
    thisR = piJson2Recipe(localRecipe);
    opticsType = thisR.get('optics type');
end

%% Decide on oi or scene

switch opticsType
    case 'lens'
        % If we used a lens, the ieObject is an optical image (irradiance).
        
        % We specify the mean illuminance of the OI mean illuminance
        % with respect to a 1mm^2 aperture. That way, if we change the
        % aperture, but nothing else, the level will scale correctly.

        % Try to find the optics parameters from the PBRT recipe
        % [focalLength, fNumber, filmDiag, ~, success] = ...
        [focalLength, fNumber] = piRecipeFindOpticsParams(thisR);
        filmDiag = thisR.get('film diagonal');  % mm
        
        %{
        if metadata
            lensfile = recipe.get('lensfile');
        end
        %}
        
        try
            ieObject = piOICreate(photons,...
                'focalLength',focalLength,...
                'fNumber',fNumber,...
                'filmDiag',filmDiag*1e-3);
        catch
            % We could not find the optics parameters. Using default.
            ieObject = piOICreate(photons);
        end
        
        ieObject = oiSet(ieObject,'name',pbrtFile);

        ieObject = oiSet(ieObject,'optics model','iset3d');
        if ~isempty(thisR)
            lensfile = thisR.get('lens file');
            ieObject = oiSet(ieObject,'optics name',lensfile);
        else
            warning('Render recipe is not specified.');
        end
        
        ieObject = oiSet(ieObject,'depth map',depthMap);
        
    case {'pinhole','environment'}
        % A scene radiance, not an oi
        ieObject = piSceneCreate(photons,'meanLuminance',meanLuminance);
        ieObject = sceneSet(ieObject,'name',ieObjName);
        ieObject = sceneSet(ieObject,'depth map',depthMap);
        
        if ~isempty(thisR)
            % PBRT may have assigned a field of view
            ieObject = sceneSet(ieObject,'fov',thisR.get('fov'));
        end
        
    otherwise
        errror('Unknown optics type %s\n',opticsType);       
end

% Add mesh label information
ieObject.metadata.meshImage  = meshImage;
ieObject.metadata.meshtxt    = meshLabel;

% Extra imaging information
ieObject.metadata.daytime    = thisR.metadata.daytime;
ieObject.metadata.objects    = thisR.assets;
ieObject.metadata.camera     = thisR.camera;
ieObject.metadata.film       = thisR.film;

end



