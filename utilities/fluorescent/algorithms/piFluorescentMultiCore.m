function thisR = piFluorescentMultiCore(thisR, assetInfo, varargin)
%% Generate multiple uniformly spreaded pattern on target location
%
%   piFluorescentMultiUniform
%
% Description:
%   Generate several patterns on target location
%
% Inputs:
%   thisR               - scene recipe
%   TR                  - triangulation object
%   childGeometryPath   - path to the child pbrt geometry files
%   txtLines            - geometry file text lines
%   matIdx              - material index
% Optional:
%   type                - add/reduce
%   fluoName            - name of fluorophore
%   maxConcentration    - max concentration of new fluorophore
%   maxSz               - max size of pattern
%   coreNum             - number of patterns
%
% Outputs:
%   None.
%
% Authors: 
%   ZLY, BW, 2020

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
piFluorescentPattern(thisR, thisIdx, 'algorithm', 'multi core',...
                    'fluoName','protoporphyrin','maxSz', 10,...
                    'maxConcentration', 1, 'coreNum', 10);
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
p.addParameter('fluoname', 'protoporphyrin', @ischar);
p.addParameter('maxconcentration', 1, @isnumeric);
p.addParameter('minconcentration', 1, @isnumeric);
p.addParameter('maxsize', 1, @isnumeric);
p.addParameter('minsize', 1, @isnumeric);
p.addParameter('corenum', 3, @isnumeric);
p.addParameter('type', 'add', @ischar);

p.parse(thisR, assetInfo, varargin{:});
thisR = p.Results.thisR;
assetInfo = p.Results.assetInfo;
fluoName = p.Results.fluoname;
maxConcentration = p.Results.maxconcentration;
minConcentration = p.Results.minconcentration;
maxSize = p.Results.maxsize;
minSize = p.Results.minsize;
coreNum = p.Results.corenum;
tp = p.Results.type;

%%
sfConHigh = 1; sfConLow = 0.5;
sfSzHigh = 0.3; sfSzLow = 0.1;
for ii=1:coreNum
    thisConcentration = (maxConcentration - minConcentration) * ((sfConHigh - sfConLow) * rand(1) + sfConLow)...
                            + minConcentration;
    thisSz = uint64((maxSize - minSize) * ((sfSzHigh - sfSzLow) * rand(1) + sfSzLow) + minSize);
    
    thisR = piFluorescentUniformSpread(thisR, assetInfo,...
                                      'concentration', thisConcentration,...
                                      'fluoname', fluoName,...
                                      'sz', thisSz,...
                                      'type', tp,...
                                      'number', ii);
    % Gradually decrease max concentration
    if ii > 0.1 * coreNum
        sfConHigh = 0.5; sfConLow = 0.25;
        sfSzHigh = 0.5; sfSzLow = 0.3;
    elseif ii > 0.5 * coreNum
        sfConHigh = 0.25; sfConLow = 0.125;
        sfSzHigh = 0.7; sfSzLow = 0.5;
    elseif ii > 0.8 * coreNum
        sfConHigh = 0.125; sfConLow = 0.0626;
        sfSzHigh = 1; sfSzLow = 0.7;
    end
end


%% Old version
%{
%% Parse input
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x), 'recipe'));
p.addRequired('TR');
p.addRequired('childGeometryPath', @ischar);
p.addRequired('txtLines', @iscell);
p.addRequired('matIdx', @(x)(ischar(x) || isnumeric(x)));
p.addParameter('type', 'add',@ischar);
p.addParameter('fluoName', 'protoporphyrin', @ischar);

p.addParameter('maxConcentration', -1, @isscalar);
p.addParameter('minConcentration', 0, @isscalar);
p.addParameter('maxSz', -1, @isscalar);
p.addParameter('minSz', 0, @isscalar);
p.addParameter('coreNum', 1, @isscalar);

p.parse(thisR, TR, childGeometryPath, txtLines, matIdx, varargin{:});

thisR = p.Results.thisR;
TR    = p.Results.TR;
childGeometryPath = p.Results.childGeometryPath;
txtLines = p.Results.txtLines;
matIdx = p.Results.matIdx;
type = p.Results.type;
fluoName = p.Results.fluoName;

maxConcentration = p.Results.maxConcentration;
minConcentration = p.Results.minConcentration;
maxSz = p.Results.maxSz;
minSz = p.Results.minSz;
coreNum     = p.Results.coreNum;

%% Initialize parameters
if maxSz == -1, maxSz = randi([1, uint64((max(TR.Points(:))))]); end
if maxConcentration == -1, maxConcentration = 1; end
    
%% generate a list of cores and depths

% tip: randi(indexRange, dimention)
szList = (maxSz - minSz) * randi(maxSz, 1, coreNum) + minSz;
concentrationList = (maxConcentration - minConcentration) * rand(1, coreNum) + minConcentration;
curTR = TR;
verticeHis = cell(1, coreNum);
for ii = 1:coreNum
    curCore = randi(size(curTR.ConnectivityList, 1));
    curVertice = piFluorescentCoreSpread(thisR, curTR, childGeometryPath,...
                                    txtLines, matIdx,... 
                                    'type', type,...
                                    'concentration', concentrationList(ii),...
                                    'fluoName', fluoName,...
                                    'sz', szList(ii),...
                                    'coreTRIndex', curCore);
    if ~isempty(curVertice)
        curTR = triangulation(curVertice, TR.Points);
        verticeHis{ii} = curVertice;
    else
        warning('Generated fewer cores. Returning...')
        break;
    end
    %{
    verticesPlot(curVertice, TR);
    %}
end

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