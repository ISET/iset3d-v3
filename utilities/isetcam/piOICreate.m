function oi = piOICreate(photons,varargin)
% Create an oi from radiance data
%
%     oi = piOICreate(photons,varargin)
%
% Required
%    photons - row x col x nwave data, computed by PBRT usually
%
% Key/values
%    focalLength - meters
%    fNumber     - dimensionless
%    filmDiag    - meters
%    fov         - horizontal field of view (deg)
%    mean illuminance
%
% Return
%  An ISET oi structure
%
% Note:  If fov and filmdiag are not set, we use fov = 40;
%        If fov is set, we use it
%        If fov is not set, we use filmdiag.
%  
% Example
%{
  oi = piOICreate(abs(randi(128,128,31)));
  oi = piOICreate(abs(randi(128,128,31)),'mean illuminance',10);
%}
% BW, SCIENTSTANFORD, 2017

%%
p = inputParser;
p.KeepUnmatched = true;
p.addRequired('photons',@isnumeric);
p.addParameter('focalLength',0.004,@isscalar);   % Meters
p.addParameter('fNumber',4,@isscalar);           % Dimensionless
p.addParameter('filmDiag',[],@isscalar);         % Meters
p.addParameter('fov',[],@isscalar)               % Horizontal fov, degrees
p.addParameter('wavelength',400:10:700,@isvector); % Spectral samples

% Format arguments so that p.parse will run.
for ii=1:2:length(varargin)
    varargin{ii} = ieParamFormat(varargin{ii});
end

p.parse(photons,varargin{:});

%%  In this case, we don't always have ISET properly initialized.  
%
% So we handle the main issue here
global vcSESSION
if ~isfield(vcSESSION,'SCENE')
    vcSESSION.SCENE = {};
end

%% Create a shift invariant optical image

% There are some problems here.  What do we do about the OTF which
% does not really apply to this calculation?
oi = oiCreate('shift invariant');

% Also, we now adjust the wavelength to allow things to work with
% fluorescence case.
oi = initDefaultSpectrum(oi,'custom',p.Results.wavelength);

oi = oiSet(oi,'photons',photons);
oi = oiSet(oi,'optics focal length', p.Results.focalLength);
oi = oiSet(oi,'optics fnumber',p.Results.fNumber);

[r,c] = size(photons(:,:,1)); depthMap = ones(r,c);
oi = oiSet(oi,'depth map',depthMap);

% Deal with the field of view, which apparently needs to be set for oi to
% work correctly.  The logic is set to 40 if the person tells you nothing.
% If they tell you the fov, use it.  If they don't tell you the fov but
% they do tell you the filmdiag, compute the fov.
if isempty(p.Results.fov) && isempty(p.Results.filmDiag)
    fov = 40;
elseif isempty(p.Results.fov)
    % We must the filmdiag
    photons = oiGet(oi, 'photons');
    x = size(photons, 2);
    y = size(photons, 1);
    d = sqrt(x^2 + y^2);  % Number of samples along the diagonal
    fwidth= (p.Results.filmDiag / d) * x;    % Diagonal size by d gives us mm per step
    
    % multiplying by x gives us the horizontal mm
    % Calculate angle in degrees
    fov = 2 * atan2d(fwidth / 2, p.Results.focalLength);
else
    % We have the fov
    fov = p.Results.fov;
end
oi = oiSet(oi,'fov',fov);

% By default we set the mean illuminance to (pupilArea) lux.  So a 1 mm2
% pupil produces a 1 lux illuminance.
% Suggested new code is here
%{
meanIlluminance = oiGet(oi,'optics aperture area','mm');
oi = oiSet(oi,'mean illuminance',meanIlluminance);
%}

% Set additional parameters the user may have sent in. For example, 'mean
% illuminance' might over-ride the mean illuminance setting above.
if ~isempty(varargin) 
    for ii=1:2:length(varargin) 
        param = ieParamFormat(varargin{ii});
        val = varargin{ii+1};
        try
            % See if this is a valid oiSet
            oi = oiSet(oi,param,val);
        catch
            % Do nothing if it is not.  renderType, for example.
        end
        
    end
end

end