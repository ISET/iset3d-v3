function thisR = piFluorescentHalfSplit(thisR, assetInfo, varargin)
%% Split the orignal area into two parts
%
%   piFluorescentHalfDivision
%
% Depscription:
%   Simply split the selected region into two parts, give (by default) FAD
%   as fluophores on one part.
%
% Inputs:
%   thisR               - scene recipe
%   TR                  - triangulation object
%   childGeometryPath   - path to the child pbrt geometry files
%   indices             - triangle meshes in the scene
%   txtLines            - geometry file text lines
%   targetMaterial      - index (preffered) or the name of a material that
%                         will assign fluorescence on
%   fluoName            - 
%   type                - type of change on fluorescent effect
%
% Outputs:
%   None.
%
% Authors:
%   ZLY, BW, 2020
%
% See also:
%   t_piFluorescentPattern, piFluorescentPattern.

% 02/11/2021 UPDATE - ZLY
% Updating pattern generation function with new style

%% Parse input
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x), 'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isnumeric(x)));
p.addParameter('concentration', rand(1), @isnumeric);
p.addParameter('fluoname', 'protoporphyrin', @ischar);
p.addParameter('type', 'add', @ischar);

p.parse(thisR, assetInfo, varargin{:});
thisR = p.Results.thisR;
assetInfo = p.Results.assetInfo;
concentration = p.Results.concentration;
fluoname = p.Results.fluoname;
type = p.Results.type;
%% Get material info
matName = thisR.get('asset',assetInfo, 'material name');

%% Create a new material
matPattern = thisR.get('material', matName);
matPattern = piMaterialSet(matPattern,...
                    'name', sprintf('%s_%s_#2', matName, fluoname));

matPattern = piMaterialApplyFluorescence(matPattern,...
                                        'type', type,...
                                        'fluoname', fluoname,...
                                        'concentration', concentration);

thisR.set('material', 'add', matPattern);


%% Get verticies and points
asset = thisR.get('assets', assetInfo);

%% Generate new asset with pattern
[asset, assetPattern] = piAssetGeneratePattern(asset,...
                                            'algorithm', 'halfsplit');
% Update name
assetPattern.name = sprintf('%s_%s_#2_O',...
                    asset.name, fluoname);
% Update material name
assetPattern.material.namedmaterial = matPattern.name;

% Add new asset
parentAsset = thisR.get('asset parent', asset.name);
thisR.set('asset', parentAsset.name, 'add', assetPattern);
thisR.set('asset', asset.name, 'shape', asset.shape);

%{
vertices = piThreeDCreate(asset.shape.integerindices);
vertices = vertices + 1;

points = piThreeDCreate(asset.shape.pointp);

TR = triangulation(vertices, points);


%% Generate verticeOne and verticeTwo
vertice = TR.ConnectivityList;

numVerticeOne = cast(size(vertice, 1)/2, 'uint32');

% Generate verticeOne
verticesOne = zeros(numVerticeOne, size(vertice, 2));

for ii = 1:size(verticesOne, 1)
    verticesOne(ii, :) = vertice(ii, :);
end
% Generate verticeTwo
verticesTwo = zeros(size(vertice, 1) - numVerticeOne, size(vertice, 2));

for ii = numVerticeOne + 1 : size(vertice, 1)
    verticesTwo(ii - numVerticeOne, :) = vertice(ii, :);
end

verticesOne = uint64(verticesOne - 1)';
verticesTwo = uint64(verticesTwo - 1)';
%% Create a new asset with new vertices
assetPattern = asset;
assetPattern.name = sprintf('%s_%s_#2_O',...
                            asset.name, fluoname);
assetPattern.shape.integerindices = verticesTwo(:);
assetPattern.material.namedmaterial = matPattern.name;
parentAsset = thisR.get('asset parent', asset.name);
thisR.set('asset', parentAsset.name, 'add', assetPattern);

asset.shape.integerindices = verticesOne(:);
thisR.set('asset', asset.name, 'shape', asset.shape);

%}
%
%% old version
%{
%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x), 'recipe'));
p.addRequired('TR');
p.addRequired('childGeometryPath', @ischar);
p.addRequired('txtLines', @iscell);
p.addRequired('matIdx', @(x)(ischar(x) || isnumeric(x)));
p.addParameter('type', 'add',@ischar);
p.addParameter('concentration', -1, @isnumeric);
p.addParameter('fluoName', 'protoporphyrin', @ischar);

p.parse(thisR, TR, childGeometryPath, txtLines,...
        matIdx, varargin{:});
thisR = p.Results.thisR;
TR    = p.Results.TR;
childGeometryPath = p.Results.childGeometryPath;
txtLines = p.Results.txtLines;
matIdx = p.Results.matIdx;
type = p.Results.type;
fluoName = p.Results.fluoName;
concentration = p.Results.concentration;

%% Parameter initialize

if concentration == -1, concentration = rand(1); end
%% Convert baseMaterial and targetMaterial into index if not
if ischar(matIdx)
    matIdx = piMaterialFind(thisR, 'name', matIdx);
end

%% Generate verticeOne and verticeTwo
vertice = TR.ConnectivityList;

numVerticeOne = cast(size(vertice, 1)/2, 'uint32');

% Generate verticeOne
verticesOne = zeros(numVerticeOne, size(vertice, 2));

for ii = 1:size(verticesOne, 1)
    verticesOne(ii, :) = vertice(ii, :);
end
% Generate verticeTwo
verticesTwo = zeros(size(vertice, 1) - numVerticeOne, size(vertice, 2));

for ii = numVerticeOne + 1 : size(vertice, 1)
    verticesTwo(ii - numVerticeOne, :) = vertice(ii, :);
end

%% Go edit PBRT files
piFluorescentPBRTEdit(thisR, childGeometryPath, txtLines,...
                      matIdx, verticesOne, verticesTwo,type, fluoName,...
                      concentration);

end
%}
end