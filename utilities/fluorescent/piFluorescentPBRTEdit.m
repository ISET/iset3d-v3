function piFluorescentPBRTEdit(thisR, childGeometryPath, txtLines, ...
                                matIdx, verticesOne, verticesTwo,...
                                type, fluoName, concentration,varargin)
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

% Examples
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
piFluorescentPattern(thisR, thisIdx, 'algorithm', 'half split', 'fluoName', 'protoporphyrin');
wave = 365:5:705;
thisDocker = 'vistalab/pbrt-v3-spectral:basisfunction';
[scene, result] = piRender(thisR, 'dockerimagename', thisDocker,'wave', wave, 'render type', 'radiance');
sceneWindow(scene)
%}
%% Parse input
p = inputParser;

p.addRequired('thisR', @(x)isequal(class(x), 'recipe'));
p.addRequired('childGeometryPath', @ischar);
p.addRequired('txtLines', @iscell);
p.addRequired('matIdx', @(x)(ischar(x) || isnumeric(x)));
p.addRequired('verticesOne');
p.addRequired('verticesTwo');
p.addRequired('type', @ischar);
p.addRequired('fluoName', @ischar);
p.addRequired('concentration', @isnumeric);

p.parse(thisR, childGeometryPath, txtLines, matIdx,...
        verticesOne, verticesTwo, type, fluoName, concentration);

%% Change the root geometry files

[childGeoPath, childGeoName] = fileparts(childGeometryPath);

[Filepath,sceneFileName] = fileparts(thisR.outputFile);

rootGeometryFile = fullfile(Filepath, sprintf('%s_geometry.pbrt',sceneFileName));
fid_rtGeo = fopen(rootGeometryFile,'r');
tmp = textscan(fid_rtGeo,'%s','Delimiter','\n');
rtTxtLines = tmp{1};

objBegList = find(contains(rtTxtLines, strcat("ObjectBegin ", '"', childGeoName)));
objBegIndex = objBegList(end) + 4;
fid_rtGeo = fopen(rootGeometryFile,'w');

% Print the same text for lines before index
for ii = 1 : objBegIndex
    fprintf(fid_rtGeo, '%s\n', rtTxtLines{ii});
end

%% Get material name
matName = piMaterialGet(thisR, 'idx', matIdx, 'param','name');

% Set new material and object name
newMatName = sprintf('%s_Division_%s_type_%s_fluorophoreName_%s_scale_%s', matName,...
                                    num2str(numel(objBegList)),...
                                    type,...
                                    fluoName,...
                                    strrep(num2str(concentration, '%.10f'),'.',''));

newObjectName = sprintf('%s_Division_%s_type_%s_fluorophoreName_%s_scale_%s.pbrt', childGeoName,...
                                    num2str(numel(objBegList)),...
                                    type,...
                                    fluoName,...
                                    strrep(num2str(concentration, '%.10f'),'.',''));




%% Write the Object definition section

fprintf(fid_rtGeo, strcat("ObjectBegin ", '"', newObjectName, '"\n'));
% Print the new lines here
fprintf(fid_rtGeo, '%s%s\n', "NamedMaterial ", strcat('"',newMatName, '"'));
fprintf(fid_rtGeo, 'Include "scene/PBRT/pbrt-geometry/%s" \n', newObjectName);
fprintf(fid_rtGeo, 'ObjectEnd\n');
fprintf(fid_rtGeo, '\n');


%% Find the Attribute that define the object. 

objInsList = find(contains(rtTxtLines, strcat("ObjectInstance ", '"', childGeoName)));
objInsIndex = objInsList(end);
for ii = objBegIndex+1 : objInsIndex
    fprintf(fid_rtGeo, '%s\n', rtTxtLines{ii});
end

attText = strcat("ObjectInstance ", ' ','"', newObjectName, '"');
fprintf(fid_rtGeo, '%s\n', attText);

for ii = objInsIndex+1:numel(rtTxtLines)
    fprintf(fid_rtGeo, '%s\n', rtTxtLines{ii});
end

% % Get the attribute section above
% if contains(rtTxtLines{objInsIndex-1}, "ObjectInstance")    
%     for ii = objBegIndex+1 : objInsIndex
%         fprintf(fid_rtGeo, '%s\n', rtTxtLines{ii});
%     end
%     
%     attText = strcat("ObjectInstance ", ' ','"', newObjectName, '"');
%     fprintf(fid_rtGeo, '%s\n', attText);
%     
%     % Write the remaining text
%     for ii = objInsIndex+1:numel(rtTxtLines)
%         fprintf(fid_rtGeo, '%s\n', rtTxtLines{ii});
%     end
% 
% else
%     % There are other information 
%     attText = rtTxtLines(objInsIndex-7:objInsIndex+1);
%     
%     for ii = objBegIndex+1 : objInsIndex+1
%         fprintf(fid_rtGeo, '%s\n', rtTxtLines{ii});
%     end
%     
%     % Write this section again wtih the new instance
%     attText{end-1} = strcat("ObjectInstance ", ' ','"', newObjectName, '"');
%     
%     for ii = 1:numel(attText)
%         fprintf(fid_rtGeo, '%s\n', attText{ii});
%     end
%     
%     % Write the remaining text
%     for ii = objInsIndex+2:numel(rtTxtLines)
%         fprintf(fid_rtGeo, '%s\n', rtTxtLines{ii});
%     end
% end

%% Minus one so the numbers of vertice agree with the rule in PBRT

verticesOne = verticesOne - 1;
verticesTwo = verticesTwo - 1;
%% Make a copy of the txtLines
txtLinesCopy = txtLines;

%% Write verticeOne back to child geometry file

% Should develop an algorithm 
newVerticeOneSlot = "";
for ii = 1:size(verticesOne, 1)
    thisIndice = verticesOne(ii,:);
    newVerticeOneSlot = strcat(newVerticeOneSlot, num2str(thisIndice, '% d'), " ");
end

txtLines{2} = char(newVerticeOneSlot);

for ii = 2:2:numel(txtLines)
    txtLines{ii} = strcat(" [ ", txtLines{ii}, " ] ");
end

fid_obj = fopen(childGeometryPath,'w');
for ii = 1:numel(txtLines)
    fprintf(fid_obj, '%s', txtLines{ii});
end
fprintf(fid_obj, '\n');

%% Write the second half of the indices into another pbrt geometry file
newFilePath = fullfile(childGeoPath, newObjectName);


newVerticeTwoSlot = "";
for ii = 1:size(verticesTwo, 1)
    thisIndice = verticesTwo(ii,:);
    newVerticeTwoSlot = strcat(newVerticeTwoSlot, num2str(thisIndice, '% d'), " ");
end

txtLinesCopy{2} = char(newVerticeTwoSlot);

for ii = 2:2:numel(txtLinesCopy)
    txtLinesCopy{ii} = strcat(" [ ", txtLinesCopy{ii}, " ] ");
end

fid_newGeoFile = fopen(newFilePath, 'w');
for ii = 1:numel(txtLinesCopy)
    fprintf(fid_newGeoFile, '%s', txtLinesCopy{ii});
end
fprintf(fid_newGeoFile, '\n');

%{
% OLD Comments:
% The structure of the file should follow this:
%   Line 1: # 1_Mouth_half - give a comment/name to the file
%   Line 2: Shape type
%   Line 3: integer dices : copy the collection of edges here
%   Line 4: points : copy the whole points data here
%   Line 5 and afterwards: copy and paste here
newFilePath = fullfile(childGeoPath, newObjectName);

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
%}


%% Change the matrial files so that we give a new material there
%{
materialFileName = thisR.materials.outputFile_materials;

fid_material = fopen(materialFileName, 'r');
tmp = textscan(fid_material, '%s', 'Delimiter', '\n');
txtLines = tmp{1};

% Create a new material in the material list
thisR.materials.list(1).(newMatName) = thisR.materials.list.(base);
thisR.materials.list(1).(newMatName).name = newMatName;
thisR.materials.list(1).(newMatName).linenumber = numel(txtLines);
switch type

    case 'darker'
        thisR.set('concentration', {newMatName, scaleFactor});
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
        thisR.materials.list.(newMatName).photolumifluorescence = vec;
end
%}

%% Adjust the fluorescence based on type

% Switch the type 
switch type
    %{
    case 'darker'
        % set the scale factor to be 0.000001 for demonstration (for now)
        scaleFactor = 0.000001;

        materialName = strcat(matName, '_Division_', num2str(numel(objBegList)),...
                            '_scaleFactor_',...
                            strrep(num2str(scaleFactor, '%.10f'),'.',''));
        newObjectName = strcat(childGeoName, '_Division#_', num2str(numel(objBegList)),...
            '_scaleFactor_',...
            strrep(num2str(scaleFactor, '%.10f'),'.',''), '.pbrt');
        
    case 'bacteria'
        materialName = strcat(location, '_Division_', num2str(numel(objBegList)),...
                            '_bacteria');
                        
        newObjectName = strcat(childGeoName, '_Division#_', num2str(numel(objBegList)),...
            '_bacteria', '.pbrt');    
    %}
    case 'add'
        flag = 1;

    case 'reduce'
        flag = -1;
end

[~, newIdx] = piMaterialCreate(thisR);
thisR.materials.list{newIdx} = thisR.materials.list{matIdx};
piMaterialSet(thisR, newIdx, 'name', newMatName);
if ~isfield(thisR.materials.list{newIdx}, 'photolumifluorescence')
    % No fluorophore yet
    if  strcmp(type, 'add')
        piMaterialSet(thisR, newIdx, 'fluorophoreeem', fluoName);
        piMaterialSet(thisR, newIdx, 'fluorophoreconcentration', concentration);
    else
        warning('No fluorophore yet. Please add one. Doing nothing');
        return;
    end
else
    % Get the eem and concentration of origin fluorophore
    eemVec = piMaterialGet(thisR, 'idx', matIdx,...
                                  'param', 'photolumifluorescence');
    scale  = piMaterialGet(thisR, 'idx', matIdx,...
                                  'param', 'floatconcentration');
                              
    eem = piVec2EEM(eemVec) * (scale *(1 - 0 * rand(1))); % Give a 10% variance
    
    % Get eem for the adjustment
    wave = 365:5:705; % Hardcoded for PBRT fluorescence branch
    eemNewFluoNorm = fluorophoreGet(fluorophoreRead(fluoName, 'wave', wave),'eem');
    
    eemNewFluo = eemNewFluoNorm * concentration;
    
    eemNewFinal = eem + flag * eemNewFluo;

    piMaterialSet(thisR, newIdx, 'fluorophoreeem', 'custom', eemNewFinal);
    piMaterialSet(thisR, newIdx, 'fluorophoreconcentration', 1);
end

% Write out the changes
piMaterialWrite(thisR);
end