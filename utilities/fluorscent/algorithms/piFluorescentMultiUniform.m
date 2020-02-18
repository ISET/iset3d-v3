function piFluorescentMultiUniform(thisR, TR, childGeometryPath,...
                                    txtLines, base, location, varargin)
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
%   indices             - triangle meshes in the scene
%   txtLines            - geometry file text lines
%   base                - reference material
%   location            - target locaiton for pattern
%   maxDepth            - max steps from center of the pattern
%   coreNumber          - pattern number
%
% Outputs:
%   None.
%
% Authors:
%   ZLY, BW, 2020

%% Parse input
p = inputParser;

p.addParameter('maxDepth', 10, @isscalar);
p.addParameter('coreNumber', 5, @isscalar);

p.parse(varargin{:});

maxDepth    = p.Results.maxDepth;
coreNum     = p.Results.coreNumber;

%% generate a list of cores and depths

% tip: randi(indexRange, dimention)
depthList = randi(maxDepth, 1, coreNum);

curTR = TR;
for ii = 1:coreNum
    curCore = randi(size(curTR.ConnectivityList, 1));
    curVertice = piFluorescentUniformSpread(thisR, curTR, childGeometryPath,...
                                    txtLines, base, location,...
                                'depth', depthList(ii),...
                                'sTriangleIndex', curCore);
    curTR = triangulation(curVertice, TR.Points);
end

end