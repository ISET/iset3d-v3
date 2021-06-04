function thisR = piFluorescentUniformSpread(thisR, assetInfo, varargin)
%% Generate a pattern from single triangle
%
%   piFluorescentUniformSpread
%
% Description:
%   Generate an unifrom oriented pattern from a random single triangle
%
% Inputs:
%   thisR               - scene recipe
%   TR                  - triangulation object
%   childGeometryPath   - path to the child pbrt geometry files
%   indices             - triangle meshes in the scene
%   txtLines            - geometry file text lines
%   base                - reference material
%   location            - target locaiton for pattern
%   depth               - steps from center of the pattern
%   sTriangleIndex      - vertex index number(seed for the pattern) 
% 
% Ouputs:
%   None
%

% Examples:
%{
ieInit;
if ~piDockerExists, piDockerConfig; end
thisR = piRecipeDefault('scene name', 'sphere');
piMaterialPrint(thisR);
piLightDelete(thisR, 'all');
thisR = piLightAdd(thisR,...
    'type','distant',...
    'light spectrum','OralEye_385',...
    'spectrumscale', 1,...
    'cameracoordinate', true); 
piWrite(thisR);
%{
scene = piRender(thisR);
sceneWindow(scene);
%}
thisIdx = 1;
piFluorescentPattern(thisR, thisIdx, 'algorithm', 'core spread',...
                    'fluoName','protoporphyrin','sz', 10,...
                    'concentration', 1);
wave = 365:5:705;
thisDocker = 'vistalab/pbrt-v3-spectral:basisfunction';
[scene, result] = piRender(thisR, 'dockerimagename', thisDocker,'wave', wave, 'render type', 'radiance');
sceneWindow(scene)
%}
%%
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x), 'recipe'));
p.addRequired('assetInfo', @(x)(ischar(x) || isnumeric(x)));
p.addParameter('concentration', rand(1), @isnumeric);
p.addParameter('fluoname', 'protoporphyrin', @ischar);
p.addParameter('sz', 1, @isnumeric);
p.addParameter('coretrindex', -1, @isnumeric);
p.addParameter('type', 'add', @ischar);
p.addParameter('number', 2, @isnumeric);

p.parse(thisR, assetInfo, varargin{:});
thisR = p.Results.thisR;
assetInfo = p.Results.assetInfo;
concentration = p.Results.concentration;
fluoname = p.Results.fluoname;
tp = p.Results.type;
number = p.Results.number;
sz = p.Results.sz;
coreTRIndex = p.Results.coretrindex;
%% Get material info
matName = thisR.get('asset',assetInfo, 'material name');

%% Create a new material
matPattern = thisR.get('material', matName);
matPattern = piMaterialSet(matPattern,...
                           'name', sprintf('%s_%s_#%d', matName, fluoname, number));
matPattern = piMaterialApplyFluorescence(matPattern,...
                                        'type', tp,...
                                        'fluoname', fluoname,...
                                        'concentration', concentration);
thisR.set('material', 'add', matPattern);

%% Get verticies and points
asset = thisR.get('assets', assetInfo);

%% Generate new asset with pattern
[asset, assetPattern] = piAssetGeneratePattern(asset,...
                                            'algorithm', 'uniform spread',...
                                            'sz', sz,...
                                            'coretrindex', coreTRIndex);
% Update name
assetPattern.name = sprintf('%s_%s_#%d_O',...
                    asset.name, fluoname, number);
% Update material name
assetPattern.material.namedmaterial = matPattern.name;

% Add new asset
parentAsset = thisR.get('asset parent', asset.name);
thisR.set('asset', parentAsset.name, 'add', assetPattern);
thisR.set('asset', asset.name, 'shape', asset.shape);





%% Old version
%{
%% Parse the input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x), 'recipe'));
p.addRequired('TR');
p.addRequired('childGeometryPath', @ischar);
p.addRequired('txtLines', @iscell);
p.addRequired('matIdx', @(x)(ischar(x) || isnumeric(x)));

p.addParameter('type', 'add',@ischar);
p.addParameter('concentration', -1, @isnumeric);
p.addParameter('fluoName', 'protoporphyrin', @ischar);

p.addParameter('sz', -1, @isscalar)
p.addParameter('coreTRIndex', -1, @isscalar)
p.parse(thisR, TR, childGeometryPath, txtLines,...
        matIdx, varargin{:});

thisR = p.Results.thisR;
TR    = p.Results.TR;
childGeometryPath = p.Results.childGeometryPath;
txtLines = p.Results.txtLines;
matIdx = p.Results.matIdx;
tp = p.Results.type;
fluoName = p.Results.fluoName;
concentration = p.Results.concentration;

sz = p.Results.sz;
coreTRIndex = p.Results.coreTRIndex;

%% Parameter initialize

if concentration == -1, concentration = rand(1); end

if sz == -1, sz = randi([1, uint64((max(TR.Points(:))))]); end

edgesNum = size(TR.ConnectivityList, 1);
% Randomly pick one triangle as start if sTriangleIndex is not defined (-1)
if coreTRIndex == -1, coreTRIndex = randi(edgesNum); end

%% Initialize the algorithm structure

nCollection = neighbors(TR);
%{
    
    index = 1891;
    verticePlot(TR.ConnectivityList(index, :), TR)

%}

indexList = [coreTRIndex];
qTriangleIndex = [coreTRIndex];
qDepthList = [0];
verticesTwo = [TR.ConnectivityList(coreTRIndex, :)];

visited = zeros(1, edgesNum);
%% 
while(~isempty(qTriangleIndex))
    thisIndex = qTriangleIndex(1);
    thisDepth = qDepthList(1);
    
    curDepth = thisDepth + 1;
    if curDepth <= sz
        % Find the neighbor triangles, push them in queue
        thisNeighbors = nCollection(thisIndex, :);
        for ii = 1:numel(thisNeighbors)
            if ~isnan(thisNeighbors(ii))
                newIndex = thisNeighbors(ii);

            else
                % Although it's neighbor is NaN, it can still means it has
                % a hidden neighbor as the tricky points naming issue from
                % c4d PBRT exporter - a same point can be assigned with two
                % point labels!
                % Here is what we propose to do - based on thisIndex, we
                % know the points of that triangle (A, B and C). Get the
                % xyz value for the three points, check the combination and
                % see which other points have the same xyz value. Then
                % check which triangle also have that xyz combination as
                % well.
                thisVertice = TR.ConnectivityList(thisIndex, :);
                xyzVertice = TR.Points(thisVertice,:);
                extraPoints = setdiff(find(ismember(TR.Points, xyzVertice, 'rows')), thisVertice);
                newIndex = find(sum(ismember(TR.ConnectivityList, extraPoints), 2)...
                                == numel(extraPoints) & numel(extraPoints) ~= 0);
            end
            
            if ~isempty(newIndex)
                if visited(newIndex) == 0
                    qTriangleIndex = [qTriangleIndex newIndex'];
                    qDepthList = [qDepthList curDepth * ones(1, numel(newIndex))];
                    indexList = [indexList newIndex'];
                    verticesTwo = [verticesTwo; TR.ConnectivityList(newIndex, :)];
                    visited(newIndex) = 1;
                end
            end
        end

    end
    
    % Finished researching, pop the current element
    qTriangleIndex(1) = [];
    qDepthList(1) = [];
end

%{
    verticesPlot(verticesTwo, TR);
    verticesReset(TR);
%}

%% Write verticeOne

indexListOne = setdiff(1:edgesNum, indexList);
verticesOne = zeros(numel(indexListOne), size(TR.ConnectivityList, 2));
for ii = 1:numel(indexListOne)
    verticesOne(ii, :) = TR.ConnectivityList(indexListOne(ii), :);
end

%% Go edit PBRT files
piFluorescentPBRTEdit(thisR, childGeometryPath, txtLines,...
                                matIdx, verticesOne, verticesTwo, tp,...
                                fluoName, concentration);


end

%% Some useful functions for mesh visualization
function verticesPlot(vertice, TR)
close all
trimesh(TR)
tmpTR = triangulation(vertice, TR.Points);
hold all
trisurf(tmpTR);
end

function verticesReset(TR)
hold off
trimesh(TR)
end
%}