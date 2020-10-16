function piFluorescentHalfDivision(thisR, TR, childGeometryPath,...
                                   txtLines, matIdx, varargin)
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