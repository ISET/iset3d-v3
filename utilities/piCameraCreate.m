function camera = piCameraCreate(cameraType)
%PICAMERACREATE Return a default camera structure to be placed in a
%   recipe.The type of camera returns depends on what the user requests.

%   TODO: Perhaps this should be a function of the recipe class?

%% Check input
if(~ischar(cameraType))
    error('Camera type must be a string.')
end

%% Return default camera given the type
switch cameraType
    case {'realistic','realisticDiffraction'}
        
        camera.type = 'Camera';
        camera.subtype = 'realisticDiffraction';
        camera.specfile.type = 'string';
        camera.specfile.value = fullfile(piRootPath,'data','lens','2ElLens.dat');
        camera.filmdistance.type = 'float';
        camera.filmdistance.value = 50;    % mm
        camera.aperture_diameter.type = 'float';
        camera.aperture_diameter.value = 2; % mm
        camera.filmdiag.type = 'float';
        camera.filmdiag.value = 7;
        camera.diffractionEnabled.type = 'bool';
        camera.diffractionEnabled.value = 'false';
        camera.chromaticAberrationEnabled.type = 'bool';
        camera.chromaticAberrationEnabled.value = 'false';

    case {'microlens','lightfield','plenoptic'}
        
        % General parameters
        camera.type = 'Camera';
        camera.subtype = 'realisticDiffraction';
        camera.specfile.type = 'string';
        camera.specfile.value = fullfile(piRootPath,'data','lens','2ElLens.dat');
        camera.filmdistance.type = 'float';
        camera.filmdistance.value = 50;    % mm
        camera.aperture_diameter.type = 'float';
        camera.aperture_diameter.value = 2; % mm
        camera.filmdiag.type = 'float';
        camera.filmdiag.value = 7;
        camera.diffractionEnabled.type = 'bool';
        camera.diffractionEnabled.value = 'false';
        camera.chromaticAberrationEnabled.type = 'bool';
        camera.chromaticAberrationEnabled.value = 'false';
        
        % Microlens parameters
        camera.microlens_enabled.type = 'float';
        camera.microlens_enabled.value = 1;
        camera.num_pinholes_w.type = 'float';
        camera.num_pinholes_w.value = 8;
        camera.num_pinholes_h.type = 'float';
        camera.num_pinholes_h.value = 8;
        
    case {'eye','realisticEye','humanEye','human'}
        
        % TODO:
        % When we render, we need to make sure pbrt2ISET automatically
        % copies over all the correct files into a the working folder. This
        % is taken care of in the eye modeling code repo, but not here.
        % TODO: 
        % Move some default accomodated eye and dispersion curves for the
        % eye into the data folder in pbrt2ISET. Fill them into the missing
        % parameters here.
        camera.type = 'Camera';
        camera.subtype = 'realisticEye';
        camera.specfile.type = 'string';
        camera.specfile.value = ''; % FILL IN
        camera.retinaDistance.type = 'float';
        camera.retinaDistance.value = 16.32;
        camera.retinaRadius.type = 'float';
        camera.retinaRadius.value = 12;
        camera.pupilDiameter.type = 'float';
        camera.pupilDiameter.value = 4;
        camera.retinaSemiDiam.type = 'float';
        camera.retinaSemiDiam.value = 6;
        camera.ior1.type = 'spectrum';
        camera.ior1.value = ''; % FILL IN
        camera.ior2.type = 'spectrum';
        camera.ior2.value = ''; % FILL IN
        camera.ior3.type = 'spectrum';
        camera.ior3.value = ''; % FILL IN
        camera.ior4.type = 'spectrum';
        camera.ior4.value = ''; % FILL IN

        
    otherwise
        error('Cannot recognize camera type.');
end

end

