function camera = piCameraCreate(cameraType,lensFile,varargin)
%PICAMERACREATE Return a camera structure to be placed in a recipe. 
%
%   camera = piCameraCreate(cameraType, lensFile, ..)
%
% Input parameters
%  The type of cameras are
%
%    'pinhole'     - Default
%    'realistic'   - allows chromatic aberration and diffraction and a lens file
%    'light field' - microlens array in front of the sensor 
%    'human eye'   - T. Lian human eye model parameters
%
% Optional parameter/values
%     We will set it up to pass in varargin pairs.  Not implemented yet. 
%
% TL, SCIEN STANFORD 2017 

% PROGRAMMING
%   TODO: Perhaps this should be a function of the recipe class?
%
%   TODO:   implement things like this for the camera type values
%
%           piCameraCreate('pinhole','fov',val);
%

%% Check input

if notDefined('cameraType'), cameraType = 'pinhole'; end
cameraType = ieParamFormat(cameraType);

% Default lens file.  We should probably flip this all to inputParser mode.
if notDefined('lensFile'), lensFile = 'dgauss.22deg.12.5mm.dat'; end

%% Initialize the default camera type
switch cameraType
    case {'pinhole'}
        camera.type      = 'Camera';
        camera.subtype   = 'perspective';
        camera.fov.type  = 'float';
        camera.fov.value = 45;  % deg of angle
        
    case {'realistic','realisticdiffraction','lens'}
        
        camera.type = 'Camera';
        camera.subtype = 'realisticDiffraction';
        camera.specfile.type = 'string';
        camera.specfile.value = fullfile(piRootPath,'data','lens',lensFile);
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
        camera.specfile.value = fullfile(piRootPath,'data','lens',lensFile);
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
        
    case {'eye','realisticeye','humaneye','human'}
        
        % TODO:
        % When we render, we need to make sure pbrt2ISET automatically
        % copies over all the correct files into a the working folder. This
        % is taken care of in ISETBIO, but not here.
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

