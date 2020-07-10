function [lrgb, mWgts2lrgb] = wgts2lrgbDep(wgts, basis, wave)
%% Planning to deprecate
%% Convert wgts to lrgb space use a matrix tranasformation
% We can later inverse the matrix so we can put linear RGB values in the texture
% map
% The euqation should be:
% tmp = ((xyz2lrgb)' * xyz' * basisFunction * wgts);
% maxRGB = max(tmp(:));
% lrgb = tmp / maxRGB;
% 
% So let M = (xyz2lrgb)' * xyz' * basisFunction / maxRGB; then
% lrgb = M * wgts

%% Parse Input
p = inputParser;
p.addRequired('wgts', @isnumeric);
p.addRequired('basis', @isnumeric);
p.addRequired('wave', @isnumeric);
p.parse(wgts, basis, wave);

%% Read XYZ matrix
xyz = ieReadSpectra('XYZ', wave, 'extrap');

matrix = colorTransformMatrix('xyz2lrgb');
tmp = matrix' * xyz' * basis * wgts;
maxRGB = max(tmp(:));

% Tansformation matrix
mWgts2lrgb = matrix' * xyz' * basis / maxRGB;

% The direct transformation is:
lrgb = mWgts2lrgb * wgts;

% Clip the rgb values so they are in (0, 1) range (this can cost some error).
lrgb = ieClip(lrgb, 0, 1);

%{
% Validate the reflectance from basis * wgts vs basis * M^-1 * lrgb
refTrue = mouthBasis * wgts;
refLrgb = mouthBasis * inv(M) * lrgb;

max(abs(refTrue - refLrgb))
thisRefl = 1;
ieNewGraphWin;
plot(wave, refTrue(:,thisRefl), 'r', wave, refLrgb(:,thisRefl), 'b');
legend('Basis with wgts', 'Basis with lrgb')
%}

end