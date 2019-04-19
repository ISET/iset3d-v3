function oi = piOICreate(photons, varargin)
% Create an oi from radiance data
%
% Syntax:
%   oi = piOICreate(photons, [varargin])
%
% Inputs:
%    photons         - Matrix. A matrix of size [row col nwave], computed
%                      by PBRT usually, containing the radiance data.
%
% Outputs:
%    oi              - Struct. An ISET oi structure.
%
% Optional key/value pairs:
%    focalLength     - Numeric. The focal length, in meters. Default is [].
%    fNumber         - Numeric. The dimensionless f number. Default is 4.
%    filmDiag        - The film diagonal, in meters. Default is []. Has a
%                      higher precedence than FoV.
%    fov             - Numeric. The horizontal field of view, in degrees.
%                      Default is []. If both filmDiag and fov are not set,
%                      use a default FoV of 40. If filmDiag set and not
%                      FoV, then use filmDiag.
%    meanIlluminance - Numeric. The mean illuminance. No default provided.
%

% History:
%    XX/XX/17  BW   SCIENTSTANFORD, 2017
%    03/28/19  JNM  Documentation pass
%    04/18/19  JNM  Merge Master in (resolve conflicts)

% Examples:
%{
    oi = piOICreate(abs(randi(128, 128, 31)));
    oi = piOICreate(abs(randi(128, 128, 31)), 'mean illuminance', 10);
%}

%%
p = inputParser;
p.KeepUnmatched = true;
p.addRequired('photons', @isnumeric);
p.addParameter('focalLength', 0.004, @isscalar); % Meters
p.addParameter('fNumber', 4, @isscalar);         % Dimensionless
p.addParameter('filmDiag', [], @isscalar);       % Meters
p.addParameter('fov', [], @isscalar);            % Horizontal fov, degrees

% Format arguments so that p.parse will run.
for ii = 1:2:length(varargin)
    varargin{ii} = ieParamFormat(varargin{ii});
end

p.parse(photons, varargin{:});

%%  In this case, we don't always have ISET properly initialized.
% So we handle the main issue here
global vcSESSION
if ~isfield(vcSESSION, 'SCENE'), vcSESSION.SCENE = {}; end

%% Create a shift invariant optical image
% There are some problems here. What do we do about the OTF, in
% particular, which does not really apply to this calculation?
oi = oiCreate('shift invariant');
oi = initDefaultSpectrum(oi);
oi = oiSet(oi, 'photons', photons);
oi = oiSet(oi, 'optics focal length', p.Results.focalLength);
oi = oiSet(oi, 'optics fnumber', p.Results.fNumber);

[r, c] = size(photons(:, :, 1));
depthMap = ones(r, c);
oi = oiSet(oi, 'depth map', depthMap);

% Determine field of view, which needs to be set for the oi to work
% correctly. The logic is set to 40 if neither filmDiag or fov are
% provided. If the fov is provided, use it. If filmdiag is provided,
% compute the fov.
if isempty(p.Results.fov) && isempty(p.Results.filmDiag)
    fov = 40;
elseif isempty(p.Results.fov)
    % Use the filmdiag to calculate the field of view.
    photons = oiGet(oi, 'photons');
    x = size(photons, 2);
    y = size(photons, 1);
    d = sqrt(x ^ 2 + y ^ 2); % Number of samples along the diagonal
    % Diagonal size by d gives us mm per step
    fwidth = (p.Results.filmDiag / d) * x;

    % multiplying by x gives us the horizontal mm
    % Calculate angle in degrees
    fov = 2 * atan2d(fwidth / 2, p.Results.focalLength);
else % We have the fov
    fov = p.Results.fov;
end

oi = oiSet(oi, 'fov', fov);

% By default we set the mean illuminance to (pupilArea) lux. So a 1 mm2
% pupil produces a 1 lux illuminance. Suggested new code is here:
%{
    meanIlluminance = oiGet(oi, 'optics aperture area', 'mm');
    oi = oiSet(oi, 'mean illuminance', meanIlluminance);
%}

% Set additional parameters the user may have sent in. For example, 'mean
% illuminance' might over-ride the mean illuminance setting above.
if ~isempty(varargin)
    for ii = 1:2:length(varargin)
        param = ieParamFormat(varargin{ii});
        val = varargin{ii + 1};
        try % See if this is a valid oiSet
            oi = oiSet(oi, param, val);
        catch
            % Do nothing if it is not. renderType, for example.
        end
    end
end

end