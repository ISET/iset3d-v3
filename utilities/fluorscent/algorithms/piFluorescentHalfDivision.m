function piFluorescentHalfDivision(thisR, TR, childGeometryPath,...
                                   txtLines, base, location)
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
%   base                - reference material
%   location            - target locaiton for pattern
%
% Outputs:
%   None.
%
% Authors:
%   ZLY, BW, 2020
%
% See also:
%   t_piFluorescentPattern, piFluorescentPattern.

%% Generate verticeOne and verticeTwo
vertice = TR.ConnectivityList;

numVerticeOne = cast(size(vertice, 1)/2, 'uint32');

% Generate verticeOne
verticeOne = zeros(numVerticeOne, size(vertice, 2));

for ii = 1:size(verticeOne, 1)
    verticeOne(ii, :) = vertice(ii, :);
end
% Generate verticeTwo
verticeTwo = zeros(size(vertice, 1) - numVerticeOne, size(vertice, 2));

for ii = numVerticeOne + 1 : size(vertice, 1)
    verticeTwo(ii - numVerticeOne, :) = vertice(ii, :);
end

%% Go edit PBRT files
piFluorescentPBRTEdit(thisR, childGeometryPath, txtLines,...
                                base, location, verticeOne, verticeTwo);

%%
%{
%% Only write half of the indices back to the pbrt file

% Should develop an algorithm 
newIndicesLine = strcat(indicesSplit{1}, ' [ ');
for ii = 1:numel(indices)/2
    thisIndice = indices(ii,:);
    newIndicesLine = strcat(newIndicesLine, num2str(thisIndice, '% d'), " ");

end
newIndicesLine = strcat(newIndicesLine, ' ]');

txtLines{3} = char(newIndicesLine);

fid_obj = fopen(childGeometryPath,'w');
for ii = 1:numel(txtLines)
    fprintf(fid_obj, '%s\n', txtLines{ii});
end

%% Write the second half of the indices into another pbrt geometry file
% The structure of the file should follow this:
%   Line 1: # 1_Mouth_half - give a comment/name to the file
%   Line 2: Shape type
%   Line 3: integer dices : copy the collection of edges here
%   Line 4: points : copy the whole points data here
%   Line 5 and afterwards: copy and paste here

% set the scale factor to be 1 for demonstration
scaleFactor = 1;

[childGeoPath, childGeoName] = fileparts(childGeometryPath);

newFileName = strcat(childGeoName, '_scaleFactor_', num2str(scaleFactor), '.pbrt');

newFilePath = fullfile(childGeoPath, newFileName);

fid_newGeoFile = fopen(newFilePath, 'w');
% Line 1
fprintf(fid_newGeoFile, strcat("# ", childGeoName, '_scaleFactor_',...
                        num2str(scaleFactor), '\n'));

% Line 2
fprintf(fid_newGeoFile, strcat(txtLines{2}, '\n'));

% Line 3
newIndicesLine = strcat("  ", indicesSplit{1}, ' [ ');
for ii = numel(indices)/2 + 1 : numel(indices)
    thisIndice = indices{ii};
    newIndicesLine = strcat(newIndicesLine, num2str(thisIndice, '% d'), " ");
end
newIndicesLine = strcat(newIndicesLine, ' ]');

fprintf(fid_newGeoFile, '%s\n', newIndicesLine);

for ii = 4:numel(txtLines)
    fprintf(fid_newGeoFile, '%s\n', txtLines{ii});
end

%% Change the root geometry files
[Filepath,sceneFileName] = fileparts(thisR.outputFile);

rootGeometryFile = fullfile(Filepath, sprintf('%s_geometry.pbrt',sceneFileName));
fid_rtGeo = fopen(rootGeometryFile,'r');
tmp = textscan(fid_rtGeo,'%s','Delimiter','\n');
txtLines = tmp{1};

indexList = find(contains(txtLines, childGeoName));
index = indexList(end);
fid_rtGeo = fopen(rootGeometryFile,'w');

% Print the same text for lines before index
for ii = 1 : index
    fprintf(fid_rtGeo, '%s\n', txtLines{ii});
end

materialName = strcat('Unhealthy_scaleFactor_',...
                    strcat(num2str(scaleFactor)));
% Print the new lines here
fprintf(fid_rtGeo, '%s%s\n', "NamedMaterial ", strcat('"',materialName, '"'));
fprintf(fid_rtGeo, 'Include "scene/PBRT/pbrt-geometry/%s" \n', newFileName);

for ii = index+1 : numel(txtLines)
    fprintf(fid_rtGeo, '%s\n', txtLines{ii});
end

%% Change the matrial files so that we give a new material there
materialFileName = thisR.materials.outputFile_materials;

fid_material = fopen(materialFileName, 'r');
tmp = textscan(fid_material, '%s', 'Delimiter', '\n');
txtLines = tmp{1};

% Create a new material in the material list
thisR.materials.list(1).(materialName) = thisR.materials.list.(base);
thisR.materials.list(1).(materialName).name = materialName;
thisR.materials.list(1).(materialName).linenumber = numel(txtLines);

thisR.set('eem', {materialName, 'FAD'});
thisR.set('concentration', {materialName, scaleFactor});
piMaterialWrite(thisR);
%}
end