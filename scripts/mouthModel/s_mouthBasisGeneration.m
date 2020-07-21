% s_mouthBasisGeneration
%
% Generate basis functions for measured reflectances of mouth 
%
% Zheng Lyu, 2020
%% Init
ieInit;

%% Read measured mouth reflectances
wave = 365:5:705;
% Allow extrapolation
% extrapVal = 'extrap';
extrapVal = 0;
mouthRefl = ieReadSpectra('reflectances', wave, extrapVal);
nSamples = size(mouthRefl, 2);

%% Basis function analysis
[mouthBasis, wgts] = basisAnalysis(mouthRefl, wave, 'vis', true);

%% Generate a matrix tranasformation for wgts to lrgb conversion
mWgts2lrgb = wgts2lrgb(mouthBasis, wave, 'disp name', 'LCD-Apple',...
                                         'light source', 'D65');

%% Save basis functions, wgts, and wgts2lrgb matrix
comment = 'Mouth reflection basis functions';
commentStruct = struct('comment', comment, 'mWgts2lrgb', mWgts2lrgb);
illuminant.wave = wave;
illuminant.data = [];
fname = fullfile(piRootPath,'data','basisFunctions','mouthReflectance');
ieSaveMultiSpectralImage(fname, wgts, mouthBasis, commentStruct, [], illuminant, 0);