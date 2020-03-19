function piFluorescentPBRTEdit(thisR, childGeometryPath, txtLines, ...
                                base, location, verticesOne, verticesTwo,...
                                type, varargin)
%% 
%
%   piFluorescentPBRTEdit
%
% Description:
%   Split child geometry files and edit root geometry and material files
%
% Inputs:
%   thisR               - scene recipe
%   TR                  - triangulation object
%   childGeometryPath   - path to the child pbrt geometry files
%   indices             - triangle meshes in the scene
%   txtLines            - geometry file text lines
%   base                - reference material
%   location            - target locaiton for pattern
%   verticeOne          - Being written back to the original child geometry
%                         file
%   verticeTwo          - Being written into a new child geometry file
%
% Outputs:
%   None.
%
% Authors:
%   ZLY, BW, 2020

%% Change the root geometry files

[childGeoPath, childGeoName] = fileparts(childGeometryPath);

[Filepath,sceneFileName] = fileparts(thisR.outputFile);

rootGeometryFile = fullfile(Filepath, sprintf('%s_geometry.pbrt',sceneFileName));
fid_rtGeo = fopen(rootGeometryFile,'r');
tmp = textscan(fid_rtGeo,'%s','Delimiter','\n');
rtTxtLines = tmp{1};

indexList = find(contains(rtTxtLines, childGeoName));
index = indexList(end);
fid_rtGeo = fopen(rootGeometryFile,'w');

% Print the same text for lines before index
for ii = 1 : index
    fprintf(fid_rtGeo, '%s\n', rtTxtLines{ii});
end

% Switch the type 
switch type
    case 'darker'
        % set the scale factor to be 0.000001 for demonstration (for now)
        scaleFactor = 0.000001;

        materialName = strcat(location, '_Division_', num2str(numel(indexList)),...
                            '_scaleFactor_',...
                            strrep(num2str(scaleFactor, '%.10f'),'.',''));
        newFileName = strcat(childGeoName, '_Division#_', num2str(numel(indexList)),...
            '_scaleFactor_',...
            strrep(num2str(scaleFactor, '%.10f'),'.',''), '.pbrt');
        
    case 'bacteria'
        materialName = strcat(location, '_Division_', num2str(numel(indexList)),...
                            '_bacteria');
                        
        newFileName = strcat(childGeoName, '_Division#_', num2str(numel(indexList)),...
            '_bacteria', '.pbrt');        
end



% Print the new lines here
fprintf(fid_rtGeo, '%s%s\n', "NamedMaterial ", strcat('"',materialName, '"'));
fprintf(fid_rtGeo, 'Include "scene/PBRT/pbrt-geometry/%s" \n', newFileName);

for ii = index+1 : numel(rtTxtLines)
    fprintf(fid_rtGeo, '%s\n', rtTxtLines{ii});
end

%% Minus one so the numbers of vertice agree with the rule in PBRT

verticesOne = verticesOne - 1;
verticesTwo = verticesTwo - 1;
%% Write verticeOne back to child geometry file

% Should develop an algorithm 
newVerticeOneLine = strcat("  ", '"integer indices"', ' [ ');
for ii = 1:size(verticesOne, 1)
    thisIndice = verticesOne(ii,:);
    newVerticeOneLine = strcat(newVerticeOneLine, num2str(thisIndice, '% d'), " ");
end
newVerticeOneLine = strcat(newVerticeOneLine, ' ]');

txtLines{3} = char(newVerticeOneLine);

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

newFilePath = fullfile(childGeoPath, newFileName);

fid_newGeoFile = fopen(newFilePath, 'w');

switch type
    case 'darker'
        % Line 1
        fprintf(fid_newGeoFile, strcat("# ", childGeoName, '_scaleFactor_',...
                                strrep(num2str(scaleFactor),'.',''), '\n'));
    case 'bacteria'
        % Line 1
        fprintf(fid_newGeoFile, strcat("# ", childGeoName, '_bacteria', '\n'));        
end

% Line 2
fprintf(fid_newGeoFile, strcat(txtLines{2}, '\n'));

% Line 3
newVerticeTwoLine = strcat("  ", '"integer indices"', ' [ ');
for ii = 1:size(verticesTwo, 1)
    thisIndice = verticesTwo(ii, :);
    newVerticeTwoLine = strcat(newVerticeTwoLine, num2str(thisIndice, '% d'), " ");
end
newVerticeTwoLine = strcat(newVerticeTwoLine, ' ]');

fprintf(fid_newGeoFile, '%s\n', newVerticeTwoLine);

for ii = 4:numel(txtLines)
    fprintf(fid_newGeoFile, '%s\n', txtLines{ii});
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
switch type

    case 'darker'
        thisR.set('concentration', {materialName, scaleFactor});
    case 'bacteria'
        % We have a constant concentration of bacteria for now
        scaleB = 0.001;
        
        % If not empty, it should follow the format of 
        fluorescentInfo = thisR.get('eem', 'material', {base});
        
        % Hard coded in edited PBRT
        wave = 365:5:705;
        if isempty(fluorescentInfo)
            curEEM = zeros(wave);
        else
            
            curEEM = fluorescentInfo{1}(4:end);
        end
        
        % Add porphyrins in EEM
        porphyrins = fluorophoreRead('Porphyrins', 'wave', wave);
        porphyrinsEEM = fluorophoreGet(porphyrins, 'eem');
        flatEEM = (porphyrinsEEM * scaleB)';
        eem = flatEEM(:)'+curEEM;
        vec = [wave(1) wave(2)-wave(1) wave(end) eem];
        thisR.materials.list.(materialName).photolumifluorescence = vec;
end

piMaterialWrite(thisR);
end