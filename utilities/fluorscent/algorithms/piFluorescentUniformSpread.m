function verticesOne = piFluorescentUniformSpread(thisR, TR, childGeometryPath,...
                                    txtLines, base, location, varargin)
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
%% Parse the input
p = inputParser;

p.addParameter('depth', 40, @isscalar)
p.addParameter('sTriangleIndex', -1, @isscalar)
p.parse(varargin{:});

depth = p.Results.depth;
sTriangleIndex = p.Results.sTriangleIndex;
%% Initialize the algorithm structure

edgesNum = size(TR.ConnectivityList, 1);

% Randomly pick one triangle as start if sTriangleIndex is not defined (-1)
if sTriangleIndex == -1, sTriangleIndex = randi(edgesNum); end

nCollection = neighbors(TR);
%{
    
    index = 1891;
    verticePlot(TR.ConnectivityList(index, :), TR)

%}

indexList = [sTriangleIndex];
qTriangleIndex = [sTriangleIndex];
qDepthList = [0];
verticesTwo = [TR.ConnectivityList(sTriangleIndex, :)];

visited = zeros(1, edgesNum);
%% 
while(~isempty(qTriangleIndex))
    thisIndex = qTriangleIndex(1);
    thisDepth = qDepthList(1);
    
    curDepth = thisDepth + 1;
    if curDepth <= depth
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
                    qTriangleIndex = [qTriangleIndex newIndex];
                    qDepthList = [qDepthList curDepth];
                    indexList = [indexList newIndex];
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
    verticesPlot(verticeTwo, TR);
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
                                base, location, verticesOne, verticesTwo);


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