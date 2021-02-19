function texture = piTextureCreateFullTemplate
% Old script to be deprecated
% Template for the texture structure.
%
%
%
%% Create the texture

texture.name = '';
texture.format = '';
texture.type = '';
texture.linenumber = [];

%% 2-D textures parameters
texture.stringmapping = ''; % Default uv
texture.floatuscale = [];
texture.floatvscale = [];
texture.floatudelta = [];
texture.floatvdelta = [];
texture.vectorv1    = [];
texture.vectorv2    = [];

%% 3-D textures parameters
% Constant texture
texture.spectrumvalue = '';
texture.floatvalue = [];

% Scale texture
texture.spectrumtex1 = '';
texture.floattex1 = [];
texture.spectrumtex2 = '';
texture.floattex2 = [];

% Mix texture
texture.floatamount = [];

% Bilinear interpolation
texture.spectrumv00 = '';
texture.spectrumv01 = '';
texture.spectrumv10 = '';
texture.spectrumv11 = '';
texture.floatv00 = [];
texture.floatv01 = [];
texture.floatv10 = [];
texture.floatv11 = [];

% Image map
texture.stringfilename = '';
texture.stringwrap = '';
texture.floatmaxanisotropy = [];
texture.booltrilinear = '';
texture.floatscale = [];
texture.boolgamma = '';

% Checkerboard
texture.integerdimension = [];
texture.stringaamode = '';

% Dots
texture.spectruminside = '';
texture.floatinside = [];
texture.spectrumoutside = '';
texture.floatoutside = [];

% Fbm and Wrinkled
texture.integeroctaves = [];
texture.floatroughness = [];

% Marble
texture.floatvariation = [];

% Basis function
texture.spectrumbasisone = '';
texture.spectrumbasistwo = '';
texture.spectrumbasisthree = '';

end