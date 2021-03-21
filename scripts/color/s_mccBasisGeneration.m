% s_mccBasisGeneration
%
% Generate basis functions for measured reflectances of MCC
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
% The plots are rotated from the usual image, with the gray series on the
% right column.

rows = 6; cols = 4;
ieNewGraphWin;
cnt = 1;
for jj = 1:cols
 for ii = 1:rows
  subplot(rows, cols, cnt)
  plot(wave, mccRefl(:,cnt))
  title(sprintf('Number %d', cnt))
  cnt = cnt + 1;
  set(gca,'ylim',[0 1]);
 end
end

%}

%% Basis function analysis
nBasis = 3;
[mccBasis, wgts] = basisAnalysis(mccRefl, wave, 'vis', true, 'nBasis', nBasis);

%% Generate a matrix tranasformation for wgts to lrgb conversion

% We should create a test of the method.
mwgts2lrgb = wgts2lrgb(mccBasis, wave, 'disp name', 'LCD-Apple',...
    'light source', 'D65');

%% Save basis functions, wgts, and wgts2lrgb matrix

comment = 'MCC reflection basis functions';
commentStruct = struct('comment', comment, 'mWgts2lrgb', mwgts2lrgb);
fname = fullfile(piRootPath,'data','basisFunctions','mccReflectance');
ieSaveMultiSpectralImage(fname, wgts, mccBasis, commentStruct,[], wave, 0);

%% END
