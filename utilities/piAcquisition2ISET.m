function ieObject = piAcquisition2ISET(acquisition, st, varargin)
% Collects PBRT files from an acquisition and creates a scene or oi
%
% Syntax
%  ieObject = piAcquisition2ISET(acquisition, st, varargin)
%
% Description
%   A PBRT render places the radiance, depth, mesh and meshLabel files
%   in an acquisition.  This routine downloads the four files, along
%   with the corresponding recipe, and creates an ISETCam scene or oi.
%
%   The assumption is that the recipe exists in the same Flywheel
%   project as the PBRT radiance file and it has the same name as the
%   pbrt.dat file.  The recipe has a json extension (not .dat).
%
% Inputs
%   acquisition - Flywheel acquisition containing rendered data
%   st - scitran object
%
% Key/value options
%   recipe file - a flywheel.model.FileEntry object to the recipe.
%                 Used to download the recipe.
%
% Return
%  ieObject - scene or oi depending on lens status
%
% Henryk Blasinski, 2019
%
% See also (update these as we simplify)
%   t_piAcq2IP.m, gCloud.fwBatchProcessPBRT, fwBatchProcessPBRT, scitran

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
%{
  sessName = 'suburb';
  acqName = 'suburb_09:39_v7.1_f147.15left_o270.00_2019626192129';
  lu = sprintf('wandell/CameraEval20190626/renderings/%s/%s',sessName,acqName);
  acquisition = st.lookup(lu);
  oi = piAcquisition2ISET(acquisition,st);
  oi = piFireFliesRemove(oi);
  oiWindow(oi);
%}

%% Parameters
wave = 400:10:700; % Hard coded in pbrt
nWave = length(wave);

varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('acquisition',@(x)(piContains(class(x),'Acquisition')));
p.addRequired('st',@(x)(isequal(class(x),'scitran')));
p.addParameter('recipefile',[],@(x)(piContains(class(x),'FileEntry')));

p.parse(acquisition,st,varargin{:});

recipeFile = p.Results.recipefile;
files = acquisition.files();

%% Get each of the files and
for f=1:length(files)
    
    localName = fullfile(piRootPath,'local',files{f}.name);
    st.fileDownload(files{f},'destination',localName);
    
    % files{f}.download(localName);

    if contains(localName,'depth')
        disp('Downloading depth')
        depthMap = piDat2ISET(localName, 'label', 'depth');
        %         tmp = piReadDAT(localName, 'maxPlanes', nWave);
        %         depthMap = tmp(:,:,1); clear tmp;
       
    elseif contains(localName,'mesh.dat')
        disp('Downloading mesh')

        meshImage = piDat2ISET(localName, 'label', 'mesh');
        meshImage = uint16(meshImage);
        %         meshData = piReadDAT(localName, 'maxPlanes', 31);
        %         meshImage = meshData(:,:,1);
        
    elseif contains(localName,'mesh_mesh.txt')
        disp('Downloading labels')
        % These are the labels of each of the meshes
        data = importdata(localName);
        meshLabel = regexp(data, '\s+', 'split');
    else
        disp('Downloading radiance/irradiance')
        % Irradiance data.  Should contain (ir)radiance in a good world.
        [~, pbrtFile, ~] = fileparts(localName);
        recipeName = sprintf('%s.json',pbrtFile);
        
        energy = piReadDAT(localName);
        photons = Energy2Quanta(wave,energy);
    end
     
end

% scene_label = piSceneAnnotation(meshImage, meshTextFile, st);
    
%% Get the recipe used to create the acquisition

% We assume that the recipe has the same name as the pbrt file, the
% recipe is in the same project, and the recipe is unique.  It would
% be better - and I think we will do this - to allow recipeName to be
% a flywheel.model.FileEntry and then to download it.
if isempty(recipeFile)
    % User did not send the recipe in.  So we guess
    recipeFile  = st.search('file',...
        'file name',recipeName, ...
        'project id',acquisition.parents.project);
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
else
    % User sent a Flywheel File.Entry
    localRecipe = fullfile(piRootPath,'local',recipeFile.name);
    recipeFile.download(localRecipe);
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

%% Add mesh label information
ieObject.metadata.meshImage  = meshImage;
ieObject.metadata.meshtxt    = meshLabel;

% Extra imaging information
ieObject.metadata.daytime    = thisR.metadata.daytime;
ieObject.metadata.objects    = thisR.assets;
ieObject.metadata.camera     = thisR.camera;
ieObject.metadata.film       = thisR.film;

end



