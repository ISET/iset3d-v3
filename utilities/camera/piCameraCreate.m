function camera = piCameraCreate(cameraType,varargin)
% Create a camera structure to be placed in a ISET3d recipe 
%
% Synopsis
%   camera = piCameraCreate(cameraType, lensFile, ..)
%
% Input parameters
%  
%   cameraType:
%
%    'pinhole'     - Default is pinhole camera, also called 'perspective'
%    'omni'        - Standard lens, including potential microlens array
%
%    'human eye'   - T. Lian human eye model that works with ISETBio and
%                    sceneEye.  It includes specification of the index of
%                    refraction for the cornea, lens and such (ior1-4).
%  Deprecated
%    'light field' - microlens array in front of the sensor for a light
%                    field camera
%    'realisticDiffraction' - Not sure what that sub type is doing in
%                                  light field
%    'realistic'   - This seems to be superseded completely by omni, except
%                    for some old car scene generation cases that have not
%                    been updated. 
%
% Optional parameter/values
%
% Output
%   camera - Camera structure for placement in a recipe
%
% TL,BW SCIEN STANFORD 2017 
%
% See also
%    recipe

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
c = piCameraCreate('human eye','lens file',lensname);
%}
%{
lensname = 'legrand.dat';
c = piCameraCreate('human eye','lens file',lensname);
%}

% PROGRAMMING
%   TODO: Perhaps this should be a method in the recipe class?
%
%   TODO: Implement things key/val options for the camera type values
%
%           piCameraCreate('pinhole','fov',val);
%

%% Check input
varargin = ieParamFormat(varargin);

p = inputParser;
% pinhole and perspective are synonyms
% omni is the most general type in current use
% realistic should be replaced by omni in the future.  Not sure what we are
% waiting for, but there is some feature ... (BW)
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

p.addParameter('lensfile',lensDefault, @ischar);

p.parse(cameraType,varargin{:});

% Use pinhole instead of perspective, for clarity.
if isequal(cameraType,'perspective'), cameraType = 'pinhole'; end

lensFile      = p.Results.lensfile;
if ~exist(lensFile,'file') && (strcmp(cameraType,'omni') || strcmp(cameraType,'realistic'))
    % This warning could be eliminated after some time.  It arises when we
    % first create one of the human eye models but the output lens
    % directory has not yet had the file written out.
    warning('Lens file not found %s\n',lensFile); 
end

%% Initialize the default camera type
switch ieParamFormat(cameraType)
    case {'pinhole'}
        % A pinhole camera is also called 'perspective'.  I am trying to
        % get rid of that terminology in the code (BW).
        camera.type      = 'Camera';
        camera.subtype   = 'perspective';
        camera.fov.type  = 'float';
        camera.fov.value = 45;         % angle in deg
        camera.lensradius.type = 'float';
        camera.lensradius.value = 0;   % Radius in mm???

    case {'realistic'}
        % Check for lens .dat file
        warning('realistic will be deprecated for omni');
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
        [~,name,e] = fileparts(lensFile);
        if(~strcmp(e,'.json'))
            error('Omni camera needs *.json lens file.');
        end
        
        camera.type = 'Camera';
        camera.subtype = 'omni';
        camera.lensfile.type = 'string';
        % check if lensFile exist
        if isempty(which(lensFile))
            % The lensFile is not included in iset3d lens folder.
            % So we move the file into the lens folder.
            copyfile(lensFile, fullfile(piRootPath,'data/lens'));
            camera.lensfile.value = [name, '.json'];
        else
            % lensFile in matlab path
            camera.lensfile.value = which(lensFile);
        end
        camera.aperturediameter.type = 'float';
        camera.aperturediameter.value = 5;    % mm
        camera.focusdistance.type = 'float';
        camera.focusdistance.value = 10; % mm
        
    case {'lightfield'}
        % This may no longer be used.  The 'omni' type incorporates the
        % light field microlens method and is more modern.
        error('Use ''omni'' and add a microlens array');
        %{
        camera.type = 'Camera';
        camera.subtype = 'omni'; 
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
        %}
    case {'humaneye'}
        % Human eye model used with sceneEye calculations in ISETBio.
        % The subtype 'realisticEye' is historical and sent to PBRT. It is
        % intended to refer to the human eye model.
        if piCamBio
            warning('human eye camera type is for use with ISETBio')
        end
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
        
        % Status of the chromatic aberration during rendering.  This slows
        % the calculation, so we start with it off.
        camera.chromaticAberrationEnabled.value = 'false';
        camera.chromaticAberrationEnabled.type  = 'bool';
        
        % These are index of refraction files for the navarro model
        [~,n,~] = fileparts(lensFile);
        if isequal(lower(n),'navarro') || ...
                isequal(lower(n),'legrand')
            camera.ior1.value = 'ior1.spd';
            camera.ior2.value = 'ior2.spd';
            camera.ior3.value = 'ior3.spd';
            camera.ior4.value = 'ior4.spd';
        else
            % Arizona does not have any entries here.  How can that be?
            % Asking TL.
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

