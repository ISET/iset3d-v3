function camera = piCameraCreate(cameraType, varargin)
% Return a camera structure to be placed in a recipe.
%
% Syntax:
%   camera = piCameraCreate(cameraType, lensFile, [varargin])
%
% Description:
%    Return a camera structure to be placed in a recipe.
%
% Inputs:
%    cameraType - String. A string representing the type of camera. The
%                 camera type options are:
%       'pinhole'     - Default. A pinhole camera.
%       'realistic'   - Realistic allows for chromatic aberration and
%                       diffraction and a lens file.
%       'light field' - A microlens array in front of the sensor.
%       'human eye'   - T. Lian human eye model parameters
%       'omni'        - M. Mara implementation
%
% Outputs:
%    camera     - Struct. The structure representing the camera.
%
% Optional key/value pairs:
%    lensFile   - String. The filename for the lens file. Default is
%                 'dgauss.22deg.12.5mm.dat'
%
% Notes:
%    * PROGRAMMING TODOS:
%       + Perhaps this should be a function of the recipe class?
%       + Implement things like this for the camera type values
%

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
    c = piCameraCreate('omni', 'lens file', lensname);
%}

% History:
%    XX/XX/17  TL   SCIEN STANFORD 2017
%    04/02/19  JNM  Documentation pass
%    04/18/19  JNM  Merge Master in (resolve conflicts)
%    05/09/19  JNM  Merge Master in again
%    07/30/19  JNM  Rebase from Master

%% Check input
p = inputParser;
if length(varargin) > 1
    for i = 1:length(varargin)
        if ~(isnumeric(varargin{i}) | islogical(varargin{i}) ...
                | isobject(varargin{i}))
            varargin{i} = ieParamFormat(varargin{i});
        end
    end
else
    varargin = ieParamFormat(varargin);
end

validCameraTypes = ...
    {'pinhole', 'realistic', 'omni', 'humaneye', 'lightfield'};
p.addRequired('cameraType', @(x)(ismember(x, validCameraTypes)));

% This will work for realistic, but not omni.  Perhaps we should make the
% default depend on the camera type.
switch cameraType
    case 'omni'
        lensDefault = 'dgauss.22deg.12.5mm.json';
    case 'realistic'
        lensDefault = 'dgauss.22deg.12.5mm.dat';
    otherwise
        lensDefault = '';
end
p.addParameter('lensfile', lensDefault, @(x)(exist(x, 'file')));
p.parse(cameraType, varargin{:});
lensFile = p.Results.lensfile;

%% Initialize the default camera type
switch cameraType
    case {'pinhole'}
        camera.type = 'Camera';
        camera.subtype = 'perspective';
        camera.fov.type = 'float';
        camera.fov.value = 45;  % deg of angle
    case {'realistic'}
        % Check for lens .dat file
        [~, ~, e] = fileparts(lensFile);
        if ~strcmp(e, '.dat')
            % Sometimes we are sent in the json file
            warning('Realistic camera needs *.dat lens file. Checking.');
            [p, n, ~] = fileparts(lensFile);
            lensFile = fullfile(p, [n '.dat']);
            if ~exist(fullfile(p, [n '.dat']), 'file')
                error('No corresponding dat file found');
            else
                fprintf('Found %s\n', lensFile);
            end
        end
        camera.type = 'Camera';
        camera.subtype = 'realistic';
        camera.lensfile.type = 'string';
        camera.lensfile.value = which(lensFile);
        % camera.lensfile.value = fullfile(piRootPath, 'data', ...
        %    'lens', lensFile);
        camera.aperturediameter.type = 'float';
        camera.aperturediameter.value = 5;  % mm
        camera.focusdistance.type = 'float';
        camera.focusdistance.value = 10;    % mm
    case {'omni'}
        [~, ~, e] = fileparts(lensFile);
        if(~strcmp(e, '.json'))
            error('Omni camera needs *.json lens file.');
        end
        camera.type = 'Camera';
        camera.subtype = 'omni';
        camera.lensfile.type = 'string';
        camera.lensfile.value = which(lensFile);
        % camera.lensfile.value = fullfile(piRootPath, 'data', ...
        %     'lens', lensFile);
        camera.aperturediameter.type = 'float';
        camera.aperturediameter.value = 5;  % mm
        camera.focusdistance.type = 'float';
        camera.focusdistance.value = 10;    % mm
    case {'lightfield'}
        % We used to allow 'microlens' and 'plenoptic'
        camera.type = 'Camera';
        camera.subtype = 'realisticDiffraction';
        camera.specfile.type = 'string';
        camera.specfile.value = which(lensFile);
        % camera.specfile.value = ...
        %     fullfile(piRootPath, 'data', 'lens', lensFile);
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
        % We used to allow 'eye', 'realisticeye', 'humaneye', and 'human'
        %
        % TODO: When we render, we need to make sure pbrt2ISET
        % automatically copies over all the correct files into a the
        % working folder. This is taken care of in ISETBIO, but not here.
        %
        % TODO: Move some default accomodated eye and dispersion curves for
        % the eye into the data folder in pbrt2ISET. Fill them into the
        % missing parameters here.
        camera.type = 'Camera';
        camera.subtype = 'realisticEye';
        camera.lensfile.type = 'string';
        camera.lensfile.value = ''; % FILL IN
        camera.retinaDistance.type = 'float';
        camera.retinaDistance.value = 16.32;
        camera.retinaRadius.type = 'float';
        camera.retinaRadius.value = 12;
        camera.pupilDiameter.type = 'float';
        camera.pupilDiameter.value = 4;
        camera.retinaSemiDiam.type = 'float';
        camera.retinaSemiDiam.value = 6;
        camera.ior1.type = 'spectrum';
        camera.ior1.value = '';      % FILL IN
        camera.ior2.type = 'spectrum';
        camera.ior2.value = '';      % FILL IN
        camera.ior3.type = 'spectrum';
        camera.ior3.value = '';      % FILL IN
        camera.ior4.type = 'spectrum';
        camera.ior4.value = '';      % FILL IN
    otherwise
        error('Cannot recognize camera type, %s\n.', cameraType);
end

end
