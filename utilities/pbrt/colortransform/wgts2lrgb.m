function mwgts2lrgb = wgts2lrgb(basis, wave, varargin)
% Matrix converts basis weights to lrgb values of the texture map
%
% Synopsis
%   mwgts2lrgb = wgts2lrgb(basis, wave, varargin)
%
% Summary
%  Calculate a 3x3 conversion matrix from basis weights to lrgb. Assuming
%  the material is illuminated under certain light spectrum and displayed
%  on a certain display.
%
% Input:
%   basis -  Reflectance basis
%   wave  -  wavelength samples
%
% Optional:
%   dispName    -  Which display (default is 'LCD-Apple')
%   lightSource -  Illuminant (default is D65)
%
% Output:
%   mwgts2lrgb
%
% Description:
%
%  The XYZ value for a lrgb image shown on a display should be:
%
%     L = XYZ' * displayPrimaries * lrgb
%
%  Let
%
%      M = XYZ' * displayPrimaries
%
%  The material observed under certain light:
%
%     R = XYZ' * diag(lightSource) * refBasis * wgts
%
%  Let
%
%     D = XYZ' * diag(lightSource) * refBasis
%
%  In the ideal case, L = R. So the equation should be:
%
%     M * lrgb = D * wgts
%
% The conversion matrix then would be:
%
%   M^-1 * D
%
% See also
%

% Example:
%{
 basisFunctionsFileName = 'mouthReflectance.mat';
 load(basisFunctionsFileName);
 wave = illuminant.wave;
 w = wgts2lrgb(basis, wave);
%}

%% Parse
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('basis', @isnumeric);
p.addRequired('wave', @isnumeric);
p.addParameter('dispname', 'LCD-Apple', @ischar);
p.addParameter('lightsource', 'D65', @ischar);

p.parse(basis, wave, varargin{:});
lightSource = p.Results.lightsource;
dispName    = p.Results.dispname;

%% Get XYZ matrix
xyz = ieReadSpectra('XYZ', wave, 'extrap');

%% Get Light SPD
spd = ieReadSpectra(lightSource, wave);

%{
% There was a conflict we merged.  These seem pretty much the same, but we
% kept these comments here just in case we are overlooking some difference.

%% Calculate matrix D
D = xyz' * diag(spd) * basis;

%% Create dispaly
d = displayCreate(dispName, wave);

% Get display primaries
primaries = displayGet(d, 'spd primaries');

% Eliminate Nans
primaries(isnan(primaries)) = 0;

%% Calculate matrix M
M = xyz' * primaries;

%% Calculate transformation matrix
mwgts2lrgb = inv(M) * D;

%{
%% Calculate scaling factor
% Given max rgb = [1;1;1], the max reflectance shouldn't be larger than 1
rgb = [1;1;1];
wgts = inv(mwgts2lrgb) * rgb;
ref = basis * wgts;
scf = max(ref);
%}

%{
s = [0.1:0.1:1];
[R,G,B] = meshgrid(s, s, s);
RGB = [R(:),G(:),B(:)]';
wgtsAll = inv(mwgts2lrgb) * RGB;
refAll = basis * wgtsAll;
ieNewGraphWin;
plot(wave, refAll);
hold on
plot(wave, ref, 'bo');
ieNewGraphWin;
plot(wave, basis);
%}

%{
%% Calculate the scaling factor
% When reflectance is ones(), the max of RGB should no bigger than one.
curRGB = inv(M) * xyz' * diag(spd) * ones(numel(wave), 1);
scf = max(curRGB);
%}
%% scale
mwgts2lrgb = mwgts2lrgb * scf;
%}
%}

%% Calculate matrix D
D = xyz' * diag(spd) * basis;

%% Create dispaly
d = displayCreate(dispName, wave);

% Get display primaries
primaries = displayGet(d, 'spd primaries');

% Eliminate Nans
primaries(isnan(primaries)) = 0;

%% Calculate matrix M
M = xyz' * primaries;

%% Calculate transformation matrix
mwgts2lrgb = inv(M) * D;

%{
%% Calculate scaling factor
% Given max rgb = [1;1;1], the max reflectance shouldn't be larger than 1
rgb = [1;1;1];
wgts = inv(mwgts2lrgb) * rgb;
ref = basis * wgts;
scf = max(ref);

%{
s = [0.1:0.1:1];
[R,G,B] = meshgrid(s, s, s);
RGB = [R(:),G(:),B(:)]';
wgtsAll = inv(mwgts2lrgb) * RGB;
refAll = basis * wgtsAll;

ieNewGraphWin;
plot(wave, refAll);
hold on
plot(wave, ref, 'bo');

ieNewGraphWin;
plot(wave, basis);
%}

%{
%% Calculate the scaling factor
% When reflectance is ones(), the max of RGB should no bigger than one.
curRGB = inv(M) * xyz' * diag(spd) * ones(numel(wave), 1);
scf = max(curRGB);
%}
%% scale
mwgts2lrgb = mwgts2lrgb * scf;
%}

end