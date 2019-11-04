function ieObject = piAcquisition2ISET(acquisition, st)

% This function collects all PBRT files for a single acquisition (i.e.
% scene) and uses them to create an ISET object
%
% Henryk Blasinski, 2019

wave = 400:10:700; % Hard coded in pbrt
nWave = length(wave);

files = acquisition.files();



for f=1:length(files)
    
    localName = fullfile(piRootPath,'local',files{f}.name)
    files{f}.download(localName);

    if contains(localName,'depth')
        tmp = piReadDAT(localName, 'maxPlanes', nWave);
        depthMap = tmp(:,:,1); clear tmp;
    elseif contains(localName,'mesh.txt')
        meshTextFile = localName;
        
    elseif contains(localName,'mesh.dat')
        meshData = piReadDAT(localName, 'maxPlanes', 31);
        meshImage = meshData(:,:,1);
    else
        
        [~, pbrtFile, ~] = fileparts(localName);
        recipeName = sprintf('%s.pbrt',pbrtFile);
        
        energy = piReadDAT(localName, 'maxPlanes', nWave);
        photons = Energy2Quanta(wave,energy);
    end
     
end


scene_label = piSceneAnnotation(meshImage, meshTextFile, st);
    

file = st.search('file','file name',recipeName);
localPbrtFile = fullfile(piRootPath,'local',recipeName);

if length(file) >= 1
    file{1}.file.download(localPbrtFile);

    recipe = piRead(localPbrtFile);
    opticsType = recipe.get('optics type');
else
    opticsType = 'pinhole';
    recipe = [];
end

switch opticsType
    case 'lens'
        % If we used a lens, the ieObject is an optical image (irradiance).
        
        % We specify the mean illuminance of the OI mean illuminance
        % with respect to a 1mm^2 aperture. That way, if we change the
        % aperture, but nothing else, the level will scale correctly.

        % Try to find the optics parameters from the PBRT recipe
        [focalLength, fNumber, filmDiag, ~, success] = ...
            piRecipeFindOpticsParams(recipe);
        
        if(success)
            ieObject = piOICreate(photons,...
                'focalLength',focalLength,...
                'fNumber',fNumber,...
                'filmDiag',filmDiag);
        else
            % We could not find the optics parameters. Using default.
            ieObject = piOICreate(photons);
        end
        
        ieObject = oiSet(ieObject,'name',pbrtFile);

        ieObject = oiSet(ieObject,'optics model','iset3d');
        if ~isempty(recipe)
            lensfile = recipe.get('lens file');
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
        
        if ~isempty(recipe)
            % PBRT may have assigned a field of view
            ieObject = sceneSet(ieObject,'fov',recipe.get('fov'));
        end
        
    otherwise
        errror('Unknown optics type %s\n',opticsType);       
end




end



