%% Ideas about how to convert the RGB texture to reflectance weights
%
%

%% Suppose we have the texture maps

imgTexture;   % The texture map (RGB)

refBasis;     % The basis functions for the tongue reflectances (3D)

lightSource;  % Assume a light source (D65 in this case)

displayPrimaries  % Let's work the Apple-LCD display

%% Find a 3x3 transform from the texture map rgb to the basis weights

% 1.  Put the imgTexture RGB into a linear representation of the display
% imgTexture (sRGB) -> (textureLRGB) values

%% Principle 
%
% Choose the surface reflectance weights so that when we render the surface
% under the light on the display the rendered surface has the same lRGB
% values as the ones in the texture map that we like.

textureLRGB = 

% This is what we see for the tonguelRGB
%
%   (XYZ'*displayPrimaries) * tongueLRGB
%
% We want the tongueLRGB to match what we would see given the weights
% This is what we would see given the weights
%
%    XYZ' * diag(lightSource) * refBasis * wgts
%
%  
%  Call (XYZ' * diag(lightSource) * refBasis) the matrix R.  It is 3x3
%  Call (XYZ'*displayPrimaries) the matrix D.  It is also 3x3
%
%  So we want
%
%     D*tongueLRGB  = R*wgts
%
% Which means to solve for wgts given the texture tongueLRGB
%
%   wgts = R^-1 * D * tongueLRGB
%
%
tongueLRGB = (XYZ'*displayPrimaries)^-1 * XYZ' * diag(lightSource) * refBasis * wgts

r1 r2 r3            w11 w21 w31
g1 g2 g3  =  [ A ]  w12 w22 w32
b1 b2 b3            w13 w23 w33
