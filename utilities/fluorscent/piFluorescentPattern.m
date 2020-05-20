function piFluorescentPattern(thisR, varargin)
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

%% Parse parameters

p = inputParser;

p.KeepUnmatched = true;
vFunc = @(x)(isequal(class(x),'recipe'));
p.addRequired('thisR',vFunc);
p.addParameter('location','',@ischar);
p.addParameter('base','',@ischar);
p.addParameter('algorithm','half split',@ischar);
p.addParameter('type', 'darker', @ischar);

p.parse(thisR, varargin{:});

thisR  = p.Results.thisR;
location = p.Results.location;
base   = p.Results.base;
type = p.Results.type;

algorithm = ieParamFormat(p.Results.algorithm);

if isempty(location), error('Location must be specified.\n'); end
if isempty(base), base = location; end 

%% TODO: make a copy of all the current files to the current folder?


%% Read child geometry files from the written pbrt files

[Filepath,sceneFileName] = fileparts(thisR.outputFile);

% Find the corresponding child geometry files based on the region name
rootGeometryFile = fullfile(Filepath, sprintf('%s_geometry.pbrt',sceneFileName));
fid_rtGeo = fopen(rootGeometryFile,'r');
tmp = textscan(fid_rtGeo,'%s','Delimiter','\n');
rtGeomTxtLines = tmp{1};

% We change the last object if selected material is used more than once.
index = find(contains(rtGeomTxtLines, location),1,'last') + 1; % Need to see next line

tmp = strsplit(rtGeomTxtLines{index}, '"');

% Complete the child Geometry Path 
childGeometryPath = fullfile(Filepath, tmp{2});

% Edit the "unhealthy" region

fid_obj = fopen(childGeometryPath,'r');
tmp = textscan(fid_obj,'%s','Delimiter','\n');

txtLines = tmp{1};

indicesLine = txtLines{3};
pointPosLine = txtLines{4};

% Process the indices (edges)
indicesSplit = strsplit(indicesLine, {'[',']'}); 
indicesStr = indicesSplit{2};

vertices = threeDCreate(indicesStr);
vertices = vertices + 1;

% Process the points (seems won't be used)
pointsSplit = strsplit(pointPosLine, {'[', ']'});
pointsStr = pointsSplit{2};
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
                                  txtLines, base, location, type);
    case 'uniformspread'

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
        
    case 'multiuniform'
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
