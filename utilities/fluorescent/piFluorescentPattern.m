function thisR = piFluorescentPattern(thisR, assetInfo, varargin)
%% Apply pattern generation algorithms and change pbrt files for the pattern
% 
%   piFluorescentPattern
%
% Description:
%   Steps to add pattern on certain location area are:
%   (1) Based on the target location, read corresponding child geometry
%       pbrt file(s)
%   (2) Call piFluorescentDivision function to apply algorithm on the
%       geometry pbrt file(s)
%
% Inputs:
%   thisR       - recipe of the scene
%   location    - target region of pattern
%   base        - create the fluorescent based on the base material
%   algorithm   - the algorithm being used for pattern generation. The
%                 default algorithm is 'half split', split the location
%                 area into half and assign pattern on half of the whole
%                 area
%
% Outputs:
%   None
%
% Authors:
%   ZLY, BW, 2020
%
% See also:
%   t_piFluorescentPattern
%
% TODO: In the future, we want to assign the pattern within recipe. This
% will be done when assets get updated.
%
% Algorithm input:
%   Half split:
%   

% 02/11/2021 Update:
% ZLY: Come to this round of updating: (1) creating patterns on assets
% makes more sense since we have the tree assets structure. (2) The pattern
% should be generated within recipe - creating new objects and then write
% them out along with the old assets.

%%

% Examples
%{
thisR = piRecipeDefault('scene name', 'slantedbar');
assetName = 'WhitePlane_O';
piFluorescentPattern(thisR, assetName, 'algorithm', 'half split');
%}

%% Parse parameters

varargin = ieParamFormat(varargin);

p = inputParser;

p.KeepUnmatched = true;
vFunc = @(x)(isequal(class(x),'recipe'));
p.addRequired('thisR',vFunc);
p.addRequired('assetInfo', @(x)(ischar(x) || isnumeric(x)));
p.addParameter('algorithm','halfsplit',@ischar);
p.addParameter('type', 'add', @ischar);
p.addParameter('fluoname', 'protoporphyrin', @ischar);
p.addParameter('concentration', rand(1), @isnumeric);
p.addParameter('coretrindex', -1, @isnumeric);
p.addParameter('sz', 1, @isnumeric);
p.addParameter('maxconcentration', 1, @isnumeric);
p.addParameter('minconcentration', 0, @isnumeric);
p.addParameter('maxsize', 1, @isnumeric);
p.addParameter('minsize', 1, @isnumeric);
p.addParameter('corenum', 1, @isnumeric);

p.parse(thisR, assetInfo, varargin{:});

thisR  = p.Results.thisR;
assetInfo = p.Results.assetInfo;
tp = p.Results.type;
fluoName = p.Results.fluoname;
algorithm = ieParamFormat(p.Results.algorithm);

%% Set parameter values
switch algorithm
    case 'halfsplit'
        concentration = p.Results.concentration;
        thisR = piFluorescentHalfSplit(thisR, assetInfo,...
                                          'concentration', concentration,...
                                          'fluoname', fluoName,...
                                          'type', tp);
    case 'uniformspread'
        concentration = p.Results.concentration;
        coreTRIndex   = p.Results.coretrindex;
        sz          = p.Results.sz;
        thisR = piFluorescentUniformSpread(thisR, assetInfo,...
                                        'concentration', concentration,...
                                        'fluoname', fluoName,...
                                        'sz', sz,...
                                        'coretrindex', coreTRIndex,...
                                        'type', tp);
    case 'multicore'
        maxConcentration = p.Results.maxconcentration;
        minConcentration = p.Results.minconcentration;
        maxSize = p.Results.maxsize;
        minSize = p.Results.minsize;
        coreNum = p.Results.corenum;
        thisR = piFluorescentMultiCore(thisR, assetInfo,...
                                       'max concentration', maxConcentration,...
                                       'min concentration', minConcentration,...
                                       'max size', maxSize,...
                                       'min size', minSize,...
                                       'fluoname', fluoName,...
                                       'core num', coreNum,...
                                       'type', tp);
    otherwise
        error('Unknown algorithm: %s, maybe implement it in the future. \n', algorithm);
end



%%
%{
%% Old version
%% Parse parameters

p = inputParser;

p.KeepUnmatched = true;
vFunc = @(x)(isequal(class(x),'recipe'));
p.addRequired('thisR',vFunc);
p.addRequired('matIdx', @(x)(ischar(x) || isnumeric(x)));
p.addParameter('algorithm','halfsplit',@ischar);
p.addParameter('type', 'add', @ischar);
p.addParameter('fluoName', 'protoporphyrin', @ischar);

p.parse(thisR, varargin{:});

thisR  = p.Results.thisR;
matIdx = p.Results.matIdx;
type = p.Results.type;
fluoName = p.Results.fluoName;
algorithm = ieParamFormat(p.Results.algorithm);

%% Address unmatched parameters

switch algorithm
    case 'halfsplit'
        if isfield(p.Unmatched, 'concentration')
            concentration = p.Unmatched.concentration;
        else
            concentration = 1;
        end
    case 'corespread'
        % Concentration
        if isfield(p.Unmatched, 'concentration')
            concentration = p.Unmatched.concentration;
        else
            concentration = -1;
        end
        
        % coreTRIndex
        if isfield(p.Unmatched, 'coreTRIndex')
            coreTRIndex = p.Unmatched.coreTRIndex;
        else
            coreTRIndex = -1;
        end
        
        % sz
        if isfield(p.Unmatched, 'sz')
            sz = p.Unmatched.sz;
        else
            sz = -1;
        end
        
    case 'multicore'
        % Note: different from corespread where only one pattern will be
        % created:
        %   maxConcentration: the max difference that
        %   will be applied on the base pattern.
        %   maxSz: the max size of the pattern
        
        % max concentration
        if isfield(p.Unmatched, 'maxConcentration')
            maxConcentration = p.Unmatched.maxConcentration;
        else
            maxConcentration = -1;
        end
        
        % min concentration
        if isfield(p.Unmatched, 'minConcentration')
            minConcentration = p.Unmatched.minConcentration;
        else
            minConcentration = 0;
        end
        
        % max size
        if isfield(p.Unmatched, 'maxSz')
            maxSz = p.Unmatched.maxSz;
        else
            maxSz = -1;
        end
        
        % min size
        if isfield(p.Unmatched, 'minSz')
            minSz = p.Unmatched.minSz;
        else
            minSz = 0;
        end
        
        if isfield(p.Unmatched, 'coreNum')
            coreNum = p.Unmatched.coreNum;
        else
            coreNum = -1;
        end
        
        
end


%% Convert baseMaterial and targetMaterial into index if not
if ischar(matIdx)
    matIdx = piMaterialFind(thisR, 'name', matIdx);
end

%% Get material name
matName = piMaterialGet(thisR, 'idx', matIdx, 'param','name');

%% Read child geometry files from the written pbrt files

[Filepath,sceneFileName] = fileparts(thisR.outputFile);

% Find the corresponding child geometry files based on the region name
rootGeometryFile = fullfile(Filepath, sprintf('%s_geometry.pbrt',sceneFileName));
fid_rtGeo = fopen(rootGeometryFile,'r');
tmp = textscan(fid_rtGeo,'%s','Delimiter','\n');
rtGeomTxtLines = tmp{1};

% We change the last object if selected material is used more than once.
% With NamedMaterial line, we can make sure the line below is the child
% geometry path.
index = find(contains(rtGeomTxtLines, strcat("NamedMaterial ", '"', matName)),1,'last') + 1; % Need to see next line

tmp = strsplit(rtGeomTxtLines{index}, '"');

% Complete the child Geometry Path 
childGeometryPath = fullfile(Filepath, tmp{2});

% Edit the "unhealthy" region

fid_obj = fopen(childGeometryPath,'r');
tmp = textscan(fid_obj,'%s','Delimiter','\n');

txtLines = tmp{1};
txtLines = strsplit(txtLines{1}, {'[',']'});
indicesStr = txtLines{2};
pointsStr = txtLines{4};

vertices = threeDCreate(indicesStr);
vertices = vertices + 1;

% Process the points (seems won't be used)
points = threeDCreate(pointsStr);

%% Create triangulation object using MATLAB Computational Geometry toolbox

TR = triangulation(vertices, points);
%{
  % Visualization
    trimesh(TR);   
%}

%% Apply algorithm for mesh split
switch algorithm
    case 'halfsplit'
        piFluorescentHalfDivision(thisR, TR, childGeometryPath,...
                                  txtLines, matIdx,... 
                                  'fluoName', fluoName,...
                                  'concentration', concentration,...
                                  'type', type);
    case 'corespread'
        piFluorescentCoreSpread(thisR, TR, childGeometryPath, txtLines, matIdx,...
                            'type', type,...
                            'concentration', concentration,...
                            'fluoName', fluoName,...
                            'sz', sz,...
                            'coreTRIndex', coreTRIndex);
        %{
        if isfield(p.Unmatched, 'depth')
            if isfield(p.Unmatched, 'sTriangleIndex')
                piFluorescentUniformSpread(thisR, TR, childGeometryPath,...
                                       txtLines, base, location, type,...
                                       'depth', p.Unmatched.depth,...
                                       'sTriangleIndex', p.Unmatched.sTriangleIndex);  
            else
                piFluorescentUniformSpread(thisR, TR, childGeometryPath,...
                           txtLines, base, location, type,...
                           'depth', p.Unmatched.depth); 
            end
        else
            if isfield(p.Unmatched, 'sTriangleIndex')
                piFluorescentUniformSpread(thisR, TR, childGeometryPath,...
                                       txtLines, base, location, type,...
                                       'sTriangleIndex', p.Unmatched.sTriangleIndex);   
            else
                piFluorescentUniformSpread(thisR, TR, childGeometryPath,...
                                           txtLines, base, location, type);                 
            end
        end
        %}
        
    case 'multicore'
        piFluorescentMultiCore(thisR, TR, childGeometryPath, txtLines, matIdx,...
                               'type', type,...
                               'fluoName', fluoName,...
                               'maxConcentration', maxConcentration,...
                               'minConcentration', minConcentration,...
                               'maxSz', maxSz,...
                               'minSz', minSz,...
                               'coreNum', coreNum);
        %{
        if isfield(p.Unmatched, 'maxDepth')
            if isfield(p.Unmatched, 'coreNumber')
                piFluorescentMultiUniform(thisR, TR, childGeometryPath,...
                                           txtLines, base, location, type,...
                                           'maxDepth', p.Unmatched.maxDepth,...
                                           'coreNumber', p.Unmatched.coreNumber);
            else
                piFluorescentMultiUniform(thisR, TR, childGeometryPath,...
                           txtLines, base, location, type,...
                           'maxDepth', p.Unmatched.maxDepth);
            end
        else
            if isfield(p.Unmatched, 'coreNumber')
                piFluorescentMultiUniform(thisR, TR, childGeometryPath,...
                           txtLines, base, location, type,...
                           'coreNumber', p.Unmatched.coreNumber);
            else
                piFluorescentMultiUniform(thisR, TR, childGeometryPath,...
                           txtLines, base, location, type);
            end
        end
        %}
    case 'irregular'
        piFluorescentIrregular(thisR, TR, childGeometryPath, txtLines, base,...
                            location, type);

    otherwise
        error('Unknown algorithm: %s, maybe implement it in the future. \n', algorithm);
    
end
end

%%
function points = threeDCreate(pointsStr)
% Create cell array from a string. Suitable for situations where every
% three numbers are considered as a data point.
    pointsNum = str2num(pointsStr);
    points = []; % xyz position & triangle mesh
    for ii = 1:numel(pointsNum)/3
        pointList = zeros(1, 3);
        for jj = 1:3
            pointList(jj) = pointsNum((ii - 1) * 3 + jj);
        end
        points = [points; pointList];
    end
end
%}
end
