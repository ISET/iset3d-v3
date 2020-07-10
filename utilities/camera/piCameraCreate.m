function camera = piCameraCreate(cameraType,varargin)
%PICAMERACREATE Return a camera structure to be placed in a recipe. 
%
%   camera = piCameraCreate(cameraType, lensFile, ..)
%
% Input parameters
%  
% The camera lens type
%
%    {'pinhole','perspective]  - Default is pinhole camera
%           
%    'realistic'   - allows chromatic aberration and diffraction and a lens file
%    'light field' - microlens array in front of the sensor 
%    'human eye'   - T. Lian human eye model parameters
%    'omni'        - M. Mara implementation
%
% Optional parameter/values
%
% Output
%   camera - Camera structure
%
% TL, SCIEN STANFORD 2017 

% Examples:
%{
c = piCameraCreate('pinhole');
%}
%{
lensname = 'dgauss.22deg.12.5mm.dat';
c = piCameraCreate('realistic');
%}
%{
c = piCameraCreate('lightfield');
%}
%{
lensname = 'dgauss.22deg.12.5mm.json';
c = piCameraCreate('omni','lens file',lensname);
%}
%{
lensname = 'navarro.dat';
c = piCameraCreate('humaneye','lens file',lensname);
%}

% PROGRAMMING
%   TODO: Perhaps this should be a function of the recipe class?
%
%   TODO: Implement things like this for the camera type values
%
%           piCameraCreate('pinhole','fov',val);
%

%% Check input
varargin = ieParamFormat(varargin);

p = inputParser;
validCameraTypes = {'pinhole','perspective','realistic','omni', 'humaneye','lightfield'};
p.addRequired('cameraType',@(x)(ismember(ieParamFormat(x),validCameraTypes)));

% This will work for realistic, but not omni.  Perhaps we should make the
% default depend on the camera type.
switch cameraType
    % Omni and realistic have lenses.  We are using this default lens.
    case 'omni'
        lensDefault = 'dgauss.22deg.12.5mm.json';
    case 'realistic'
        lensDefault = 'dgauss.22deg.12.5mm.dat';
    otherwise
        lensDefault = '';
end
p.addParameter('lensfile',lensDefault,@(x)(exist(x,'file')));

p.parse(cameraType,varargin{:});

lensFile      = p.Results.lensfile;

%% Initialize the default camera type
switch ieParamFormat(cameraType)
    case {'pinhole','perspective'}
        % A perspective camera with zero aperture is a pinhole camera. 
        camera.type      = 'Camera';
        camera.subtype   = 'perspective';
        camera.fov.type  = 'float';
        camera.fov.value = 45;         % angle in deg
        camera.lensradius.type = 'float';
        camera.lensradius.value = 0;   % Radius in mm???

    case {'realistic'}
        % Check for lens .dat file
        [~,~,e] = fileparts(lensFile);
        if(~strcmp(e,'.dat'))
            % Sometimes we are sent in the json file
            warning('Realistic camera needs *.dat lens file. Checking.');
            [p,n,~] = fileparts(lensFile);
            lensFile = fullfile(p,[n '.dat']);
            if ~exist(fullfile(p,[n '.dat']),'file')
                error('No corresponding dat file found');
            else
                fprintf('Found %s\n',lensFile);
            end
            
        end
        
        camera.type          = 'Camera';
        camera.subtype       = 'realistic';
        camera.lensfile.type = 'string';
        camera.lensfile.value = which(lensFile);
        camera.aperturediameter.type  = 'float';
        camera.aperturediameter.value = 5;    % mm
        camera.focusdistance.type     = 'float';
        camera.focusdistance.value    = 10; % mm
        
    case {'omni'}
        [~,~,e] = fileparts(lensFile);
        if(~strcmp(e,'.json'))
            error('Omni camera needs *.json lens file.');
        end
        
        camera.type = 'Camera';
        camera.subtype = 'omni';
        camera.lensfile.type = 'string';
        camera.lensfile.value = which(lensFile);
        camera.aperturediameter.type = 'float';
        camera.aperturediameter.value = 5;    % mm
        camera.focusdistance.type = 'float';
        camera.focusdistance.value = 10; % mm
        
    case {'lightfield'}
        % Use to allow 'microlens' and'plenoptic'
        camera.type = 'Camera';
        camera.subtype = 'realisticDiffraction';
        camera.specfile.type = 'string';
        camera.specfile.value = which(lensFile);
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
        
    case {'humaneye'}
        % Yuman eye camera model used with sceneEye calculations in
        % ISETBio. 
        camera.type           = 'Camera';
        camera.subtype        = 'realisticEye';
        camera.lensfile.type  = 'string';
        camera.lensfile.value = lensFile;
        
        % This is the length of the chord that defines the field of view.
        % There is a PowerPoint in the wiki (iset3d) images that explains
        % the parameters and the eye ball geometry.
        
        % The distance from the back of the lens to the retina is the
        % retinaDistance.
        camera.retinaDistance.type = 'float';
        camera.retinaDistance.value = 16.32;
        % The radius of the whole eyeball is retinaRadius.
        camera.retinaRadius.type    = 'float';
        camera.retinaRadius.value   = 12;  %mm
        % The chord length used to define the effect 'width','height' and
        % field of view of the eyeball model.  See the PowerPoint (above).
        camera.retinaSemiDiam.type  = 'float';
        camera.retinaSemiDiam.value = 6;  %mm
        
        camera.pupilDiameter.type   = 'float';
        camera.pupilDiameter.value  = 4;  % mm
        
        % Default distance to the focal plane in object space.  This
        % differs from the 'object distance' which is the difference
        % between the 'from' and 'to' coordinates.
        camera.focusdistance.value = 0.2;   % Meters.  Accommodation is 5 diopters
        camera.focusdistance.type  = 'float';
        
        % Default is units of meters.  If you have something in
        % millimeters, you should use this flag
        camera.mmUnits.value = 'false';
        camera.mmUnits.type  = 'bool';
        
        % These are index of refraction files for the navarro model
        [~,n,~] = fileparts(lensFile);
        if isequal(lower(n),'navarro')
            camera.ior1.value = 'ior1.spd';
            camera.ior2.value = 'ior2.spd';
            camera.ior3.value = 'ior3.spd';
            camera.ior4.value = 'ior4.spd';
        else
            camera.ior1.value = '';
            camera.ior2.value = '';
            camera.ior3.value = '';
            camera.ior4.value = '';
        end
        camera.ior1.type = 'spectrum';
        camera.ior2.type = 'spectrum';
        camera.ior4.type = 'spectrum';
        camera.ior3.type = 'spectrum';

    otherwise
        error('Cannot recognize camera type, %s\n.', cameraType);
end

end

