function textureMap = piTextureImgMap(textureMask, wgts, varargin)
% 
% Description:
%   Generate texture image map based on Mask and wgts.
%
% Synopsis
%   textureMap = piImgTextureMap(mccTextureMask, wgts)
%
% Inputs:
%   textureMask - 2D matrix with indices of wgts in each pixel
%   wgts           - weights of basis functions
%
% Outputs:
%   textureMap     - texture image map (r * c * 3)
%

% Examples
%{
%% Read measured MCC reflectances
wave = 365:5:705;
% Allow extrapolation
extrapVal = 'extrap';
mccRefl = ieReadSpectra('macbethChart-20180324', wave, extrapVal);
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
[bFunctions, wgts] = basisAnalysis(mccRefl, wave, 'vis', true);
% Read image and get RGB values
img = im2double(imread('mcc.png'));
[width, height, h] = size(img);
patchSize = 32;
rows = 1:patchSize:width;
cols = 1:patchSize:height;
[A,B] = meshgrid(rows,cols);
c=cat(2,A',B');
rowcol=reshape(c,[],2);

mccTextureMask = zeros(width,height);
for ii = 1:size(rowcol, 1)
sRow = rowcol(ii, 1); sCol = rowcol(ii, 2);
mccTextureMask(sRow:sRow+patchSize-1, sCol:sCol+patchSize-1) = ii;
end

textureMap = piTextureImgMap(mccTextureMask, wgts);

%}
%% Parse Input
p = inputParser;
p.addRequired('textureMask', @isnumeric)
p.addRequired('wgts', @isnumeric)
p.parse(textureMask, wgts);

textureMask = p.Results.textureMask;
wgts        = p.Results.wgts;
 
%%
[r, c] = size(textureMask);
textureMap = zeros(r, c, 3);

indices = unique(textureMask);

for ii = 1:numel(indices)
    if indices(ii) ~= 0
        tmpMapOneLayer = zeros(r, c);
        tmpMapOneLayer(textureMask == indices(ii)) = 1;
        tmpMap = cat(3, tmpMapOneLayer, tmpMapOneLayer, tmpMapOneLayer);

        tmpMap(:,:,1) = tmpMap(:,:,1) * wgts(1, indices(ii));
        tmpMap(:,:,2) = tmpMap(:,:,2) * wgts(2, indices(ii));
        tmpMap(:,:,3) = tmpMap(:,:,3) * wgts(3, indices(ii));

        textureMap = textureMap + tmpMap;
    end
end
%{
ieNewGraphWin;
imagesc(textureMap);
%}
end