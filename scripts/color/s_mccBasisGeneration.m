% s_mccBasisGeneration
%
% Generate basis functions for measured reflectances of MCC
% Warning: this doesn't work well
% 
% Zheng Lyu, 2020
%% Init
ieInit;

%% Read measured MCC reflectances
wave = 365:5:705;
% Allow extrapolation
% extrapVal = 'extrap';
extrapVal = 0;
mccRefl = ieReadSpectra('macbethChart', wave, extrapVal);
nSamples = size(mccRefl, 2);

%{
% Plot 4x6
rows = 6; cols = 4;
ieNewGraphWin;
for ii = 1:size(mccRefl, 2)
subplot(rows, cols, ii)
plot(wave, mccRefl(:,ii))
title(sprintf('Number %d', ii))
end
%}

%% Basis function analysis
[mccBasis, wgts] = basisAnalysis(mccRefl, wave, 'vis', true, 'nBasis', 3);

%% Generate a matrix tranasformation for wgts to lrgb conversion
mWgts2lrgb = wgts2lrgb(mccBasis, wave, 'disp name', 'LCD-Apple',...
                        'light source', 'D65');

%% Save basis functions, wgts, and wgts2lrgb matrix
comment = 'MCC reflection basis functions';
commentStruct = struct('comment', comment, 'mWgts2lrgb', mWgts2lrgb);
fname = fullfile(piRootPath,'data','basisFunctions','mccReflectance');
ieSaveMultiSpectralImage(fname, wgts, mccBasis, commentStruct,[], wave, 0);


