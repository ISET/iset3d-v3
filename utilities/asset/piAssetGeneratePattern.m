function [asset, assetPattern] = piAssetGeneratePattern(asset, varargin)
%%
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('asset', @isstruct);
p.addParameter('algorithm', 'halfdivision', @ischar);
% Uniform spread alg
p.addParameter('sz', 1, @isnumeric);
p.addParameter('coretrindex', -1, @isnumeric);

p.parse(asset, varargin{:});
asset = p.Results.asset;
algorithm = ieParamFormat(p.Results.algorithm);
sz = p.Results.sz;
coreTRIndex = p.Results.coretrindex;
%% Generate 
vertices = piThreeDCreate(asset.shape.integerindices);
vertices = vertices + 1;

points = piThreeDCreate(asset.shape.pointp);

TR = triangulation(vertices, points);
%%
switch algorithm
    case 'halfsplit'
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
       
    case 'uniformspread'
        %%
        if sz == -1, sz = randi([1, uint64((max(size(TR.Points(:)))))]); end
        if sz > max(size(TR.Points(:))), sz = max(size(TR.Points(:))); end
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
        visited(coreTRIndex) = 1;
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
end
verticesOne = uint64(verticesOne - 1)';
verticesTwo = uint64(verticesTwo - 1)';
%% Create a new asset with new vertices
assetPattern = asset;

assetPattern.shape.integerindices = verticesTwo(:);
asset.shape.integerindices = verticesOne(:);
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