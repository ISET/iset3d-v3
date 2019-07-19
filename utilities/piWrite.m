
function workingDir = piWrite(renderRecipe,varargin)
% Write a PBRT scene file based on its renderRecipe
%
% Syntax
%   workingDir = piWrite(recipe,varargin)
%
% The pbrt scene file and all of its resources files are written out
% in a working directory that will be mounted by the docker container.
%
% In some cases, there are multiple PBRT files that use the same
% resources files.  If you know the resources files are already there,
% you can set overwriteresources to false.  Similarly if you do not
% want to overwrite the pbrt scene file, set overwritepbrtfile to
% false.
%
% Input
%   renderRecipe:  a recipe object describing the rendering parameters.  This
%       includes the inputFile and the outputFile, which are used to find the
%       directories containing all of the pbrt scene data.
%
% Optional parameter/values
%   overwritepbrtfile  - If scene PBRT file exists,    overwrite (default true)
%   overwriteresources - If the resources files exist, overwrite (default true) 
%
% Return
%    workingDir - path to the output directory mounted by the Docker containe
%
% TL Scien Stanford 2017
% JNM -- Add Windows support 01/25/2019

%{
piWrite(thisR,'overwrite resources',false,'overwrite pbrt file',true);
piWrite(thisR);
%}
%%
p = inputParser;

% When varargin contains a number, the ieParamFormat() method fails.
% It takes only a string or cell.  We should look into that.
varargin = ieParamFormat(varargin);


p.addRequired('renderRecipe',@(x)isequal(class(x),'recipe'));

% % JNM -- Why format variables twice?
% % Format the parameters by removing spaces and forcing lower case.
% if ~isempty(varargin), varargin = ieParamFormat(varargin); end

% Copy over the whole directory
p.addParameter('overwriteresources', true,@islogical);

% Overwrite the specific scene file
p.addParameter('overwritepbrtfile',true,@islogical);

% Force overwrite of the lens file
p.addParameter('overwritelensfile',true,@islogical);

% Overwrite materials.pbrt
p.addParameter('overwritematerials',true,@islogical);

% Overwrite geometry.pbrt
p.addParameter('overwritegeometry',true,@islogical);

% Create a new materials.pbrt
p.addParameter('creatematerials',false,@islogical);

% control lighting in geomtery.pbrt
p.addParameter('lightsFlag',false,@islogical);

% Read trafficflow variable
p.addParameter('thistrafficflow',[]);
p.parse(renderRecipe,varargin{:});

% workingDir          = p.Results.workingdir;
overwriteresources  = p.Results.overwriteresources;
overwritepbrtfile   = p.Results.overwritepbrtfile;
overwritelensfile   = p.Results.overwritelensfile;
overwritematerials  = p.Results.overwritematerials;
overwritegeometry   = p.Results.overwritegeometry;
creatematerials     = p.Results.creatematerials;
lightsFlag          = p.Results.lightsFlag;
thistrafficflow         = p.Results.thistrafficflow;

%% Check exporter
% TL: We seem to run into a lot of problems of overwriting the wrong files
% when the exporter isn't C4D (i.e. when we don't or can't parse the PBRT
% file). Here we do a pre-check: if the exporter isn't C4D don't touch the
% materials or geometry at all. Just copy files over to the output
% directory. Hopefully that will clean things up a bit.
if isempty(renderRecipe.exporter)
    creatematerials = false;
    overwritegeometry = false;
    overwritematerials = false;
end
if ~isempty(renderRecipe.materials)
    creatematerials = true;
    overwritematerials = true;
end
if ~isempty(renderRecipe.assets)
    overwritegeometry = true;
end
%% Copy the input directory to the Docker working directory

% Input must exist
inputDir   = fileparts(renderRecipe.inputFile);
if ~exist(inputDir,'dir'), error('Could not find %s\n',inputDir); end

% Make working dir if it does not already exist
workingDir = fileparts(renderRecipe.outputFile);
if ~exist(workingDir,'dir'), mkdir(workingDir); end

% This is a full directory copy, so all of the resources in the
% input directory are written to the docker working directory.  In some
% cases we are looping so we can turn off the repeated copies with this
% flag.
if overwriteresources
    status = copyfile(inputDir,workingDir);
    if(~status)
        error('Failed to copy input directory to docker working directory.');
    else
        fprintf('Copied contents from:\n');
        fprintf('%s \n',inputDir);
        fprintf('to \n');
        fprintf('%s \n \n',workingDir);
    end
end


%% Potentially overwrite the scene PBRT file

outFile = renderRecipe.outputFile;

% Check if the outFile exists. If it does, decide what to do.
if(exist(outFile,'file'))
    if overwritepbrtfile
        % This is the pbrt scene file.
        fprintf('Overwriting PBRT file %s\n',outFile)
        delete(outFile);
    else
        % Do not overwrite is set, and yet it exists. We don't like this
        % condition, so we throw an error.
        error('PBRT file %s exists.',outFile);
    end 
end

%% If the optics type is lens, copy the lens file to a lens sub-directory

if isequal(renderRecipe.get('optics type'),'lens')
    % In version 2 the lens file is stored in the specfile field. We didn't
    % like that, and so we are shifting to lensfile field in version 3.
    % This deals with the compatibility.
    
    if isfield(renderRecipe.camera,'lensfile')
        inputLensFile = renderRecipe.camera.lensfile.value;
    elseif isfield(renderRecipe.camera,'specfile')
        if (renderRecipe.version == 3)
            warning('Use lensfile, not specfile, for version 3 and higher');
        end
        inputLensFile = renderRecipe.camera.specfile.value;
    end
    
    % Verify that the input lens is a full path
    if ispc()
        if ~strcmp(inputLensFile(1),'C')
            error('You must specify an absolute path for the lens file.');
        end
    elseif ~strcmp(inputLensFile(1),'/')
        error('You must specify an absolute path for the lens file.');
    end
    
    % Figure out the working lens file directory and name
    [~,name,ext] = fileparts(inputLensFile);
    workingLensDir = fullfile(workingDir,'lens');
    if ~exist(workingLensDir,'dir'), mkdir(workingLensDir); end
    workingLensFile = fullfile(workingLensDir,[name,ext]);
    
    % If the working copy doesn't exist, copy it.  If it exists but there
    % is a force overwrite, delete and copy.
    if ~exist(workingLensFile,'file')
        copyfile(inputLensFile,workingLensFile);
    elseif overwritelensfile
        delete(workingLensFile);
        copyfile(inputLensFile,workingLensFile);
    end
    
    % Figure out the working lens file directory and name
    [~,name,ext] = fileparts(inputLensFile);
    workingLensDir = fullfile(workingDir,'lens');
    if ~exist(workingLensDir,'dir'), mkdir(workingLensDir); end
    workingLensFile = fullfile(workingLensDir,[name,ext]);
    
    % If the working copy doesn't exist, copy it.  If it exists but there
    % is a force overwrite, delete and copy.
    if ~exist(workingLensFile,'file')
        copyfile(inputLensFile,workingLensFile);
    elseif overwritelensfile
        delete(workingLensFile);
        copyfile(inputLensFile,workingLensFile);
    end
end

%% Make sure there is a renderings sub-directory of the working directory

renderingDir = fullfile(workingDir,'renderings');
if ~exist(renderingDir,'dir'), mkdir(renderingDir); end


%% OK, we are good to go. Open up the file.

% fprintf('Opening %s for output\n',outFile);
fileID = fopen(outFile,'w');



%% Write header
fprintf(fileID,'# PBRT file created with piWrite on %i/%i/%i %i:%i:%0.2f \n',clock);
fprintf(fileID,'# PBRT version = %i \n',renderRecipe.version);
fprintf(fileID,'\n');

% If a crop window exists, write out a warning
if(isfield(renderRecipe.film,'cropwindow'))
    fprintf(fileID,'# Warning: Crop window exists! \n');
end

%% Write Scale and LookAt commands first

% Optional Scale
if(~isempty(renderRecipe.scale))   
   fprintf(fileID,'Scale %0.2f %0.2f %0.2f \n', ...
    [renderRecipe.scale(1) renderRecipe.scale(2) renderRecipe.scale(3)]);
    fprintf(fileID,'\n');
end
% Optional Motion Blur
% default StartTime and EndTime is 0 to 1;
if isfield(renderRecipe.camera,'motion') 
    
    motionTranslate =renderRecipe.camera.motion.activeTransformStart.pos-renderRecipe.camera.motion.activeTransformEnd.pos;
    motionStart     =renderRecipe.camera.motion.activeTransformStart.rotate;
    motionEnd      =  renderRecipe.camera.motion.activeTransformEnd.rotate;
    fprintf(fileID,'ActiveTransform StartTime \n');
    fprintf(fileID,'Translate 0 0 0 \n');
    fprintf(fileID,'Rotate %f %f %f %f \n',motionStart(:,1)); % Z
    fprintf(fileID,'Rotate %f %f %f %f \n',motionStart(:,2)); % Y
    fprintf(fileID,'Rotate %f %f %f %f \n',motionStart(:,3));  % X
    fprintf(fileID,'ActiveTransform EndTime \n');
    fprintf(fileID,'Translate %0.2f %0.2f %0.2f \n',...
        [motionTranslate(1),...
        motionTranslate(2),...
        motionTranslate(3)]);
    fprintf(fileID,'Rotate %f %f %f %f \n',motionEnd(:,1)); % Z
    fprintf(fileID,'Rotate %f %f %f %f \n',motionEnd(:,2)); % Y
    fprintf(fileID,'Rotate %f %f %f %f \n',motionEnd(:,3));  % X
    fprintf(fileID,'ActiveTransform All \n');
end
% Required LookAt 
fprintf(fileID,'LookAt %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f \n', ...
    [renderRecipe.lookAt.from(:); renderRecipe.lookAt.to(:); renderRecipe.lookAt.up(:)]);
fprintf(fileID,'\n');

%% Write all other blocks using a for loop

outerFields = fieldnames(renderRecipe);

for ofns = outerFields'
    ofn = ofns{1};
    
    % If empty, we skip this field.
    if(~isfield(renderRecipe.(ofn),'type') || ...
            ~isfield(renderRecipe.(ofn),'subtype'))
        continue;
    end
    
    if(strcmp(ofn,'world') || ...
            strcmp(ofn,'lookAt') || ...
            strcmp(ofn,'inputFile') || ...
            strcmp(ofn,'outputFile')|| ...
            strcmp(ofn,'version')) || ...
            strcmp(ofn,'materials')|| ...
            strcmp(ofn,'world')
        % Skip, we don't want to write these out here.
        continue;
    end
    
    % fprintf('outer field %s\n',ofn);
    
    % Write header for block
    fprintf(fileID,'# %s \n',ofn);
    
    % Write main type and subtype
    fprintf(fileID,'%s "%s" \n',renderRecipe.(ofn).type,...
        renderRecipe.(ofn).subtype);
    
    % Loop through inner field names
    innerFields = fieldnames(renderRecipe.(ofn));
    if(~isempty(innerFields))
        for ifns = innerFields'
            ifn = ifns{1};
            % Skip these since we've written these out earlier, they are
            % localized to pbrt2ISET but not pbrt scene files. We make a
            % second copy of the lens file in the workingDir because some
            % docker containers require it. In the future, we should
            % exclude lens file and specfile. (BW).
            if(strcmp(ifn,'type') || ...
                    strcmp(ifn,'subtype') || ...
                    strcmp(ifn,'subpixels_h') || ...
                    strcmp(ifn,'subpixels_w') || ...
                    strcmp(ifn,'motion') || ...
                    strcmp(ifn,'subpixels_w'))
                continue;
            end
            
            currValue = renderRecipe.(ofn).(ifn).value;
            currType  = renderRecipe.(ofn).(ifn).type;
            
            if(strcmp(currType,'string') || ischar(currValue))
                % We have a string with some value
                lineFormat = '  "%s %s" "%s" \n';
                
                % The currValue might be a full path to a file with an
                % extension. We find the base file name and copy the
                % file to the working directory. Then, we transform
                % the string to be printed in the pbrt scene file to
                % be its new relative path.  There is a minor
                % exception for the lens file.
                % Perhaps we should have a better test here, say an
                % exist() test. (BW).
                [~,name,ext] = fileparts(currValue);

                if(~isempty(ext))
                    % OK, it has an extension.  So we swing into
                    % action.  First, copy the file to the working
                    % directory - unless it is a lens file, in which
                    % case it is already in place (see above)                    
                    fileName = strcat(name,ext);
                    if ~(strcmp(ifn,'specfile') || strcmp(ifn,'lensfile'))
                        [success,~,id]  = copyfile(currValue,workingDir);
                        if ~success && ~strcmp(id,'MATLAB:COPYFILE:SourceAndDestinationSame')
                            warning('Problem copying %s\n',currValue);
                        end
                        % Update the file for the relative path
                        currValue = fileName;
                    else
                        % It is a lens, so just update the name.  It
                        % was already copied
                        if ispc()
                            currValue = strcat('lens/',strcat(name,ext));
                        else
                            currValue = fullfile('lens',strcat(name,ext));
                        end
                    end
                end
                                
            elseif(strcmp(currType,'spectrum') && ~ischar(currValue))
                % A spectrum of type [wave1 wave2 value1 value2]. TODO:
                % There are probably more variations of this...
                lineFormat = '  "%s %s" [%f %f %f %f] \n';
            elseif(strcmp(currType,'rgb'))
                lineFormat = '  "%s %s" [%f %f %f] \n';
            elseif(strcmp(currType,'float'))
                if(length(currValue) > 1)
                    lineFormat = '  "%s %s" [%f %f %f %f] \n';
                else
                    lineFormat = '  "%s %s" [%f] \n';
                end
            elseif(strcmp(currType,'integer'))
                lineFormat = '  "%s %s" [%i] \n';
            end
            
            fprintf(fileID,lineFormat,...
                currType,ifn,currValue);
            
        end
    end
    
    % Blank line.
    fprintf(fileID,'\n');
end


%% Write out WorldBegin/WorldEnd

if creatematerials
    % We may have created new materials.
    % We write the material and geometry files based on the recipe,
    % which defines these new materials.
    for ii = 1:length(renderRecipe.world)
        currLine = renderRecipe.world{ii};
        if piContains(currLine, 'materials.pbrt')
            [~,n] = fileparts(renderRecipe.outputFile);
            currLine = sprintf('Include "%s_materials.pbrt"',n);
        end
        if overwritegeometry
            if piContains(currLine, 'geometry.pbrt')
                [~,n] = fileparts(renderRecipe.outputFile);
                currLine = sprintf('Include "%s_geometry.pbrt"',n);
            end
        end 
        if ii == length(renderRecipe.world)
            if ~piContains(renderRecipe.world, 'materials.pbrt')
        [~,n] = fileparts(renderRecipe.outputFile);
        mLine = sprintf('Include "%s_materials.pbrt"',n);
        fprintf(fileID,'%s \n',mLine);
        [~,n] = fileparts(renderRecipe.outputFile);
        gLine = sprintf('Include "%s_geometry.pbrt"',n);
        fprintf(fileID,'%s \n',gLine);
            end
        end
        fprintf(fileID,'%s \n',currLine);
    end
    
else
    % No materials were created, so we just write out the world data
    % without any changes.
    for ii = 1:length(renderRecipe.world)
        currLine = renderRecipe.world{ii};
        if overwritegeometry
            if piContains(currLine, 'geometry.pbrt')
                [~,n] = fileparts(renderRecipe.outputFile);
                currLine = sprintf('Include "%s_geometry.pbrt"',n);
            end
        end
        fprintf(fileID,'%s \n',currLine);
    end
end
%% Close file

fclose(fileID);

%% Overwrite Materials.pbrt
if piContains(renderRecipe.exporter, 'C4D')|| ~isempty(renderRecipe.materials)
    % If the scene is from Cinema 4D, 
    if ~creatematerials
        % We overwrite from the input directory, but we do not create
        % any new material files beyond what is already in the input
        if overwritematerials
            [~,n] = fileparts(renderRecipe.inputFile);
            fname_materials = sprintf('%s_materials.pbrt',n);
            renderRecipe.materials.outputFile_materials = fullfile(workingDir,fname_materials);
            piMaterialWrite(renderRecipe);
        end
    else
        % Create new material files that could come from somewhere
        % other than the input directory.
        [~,n] = fileparts(renderRecipe.outputFile);
        fname_materials = sprintf('%s_materials.pbrt',n);
        renderRecipe.materials.outputFile_materials = fullfile(workingDir,fname_materials);
        piMaterialWrite(renderRecipe);
    end
end

%% Overwrite geometry.pbrt
if piContains(renderRecipe.exporter, 'C4D')||~isempty(renderRecipe.assets)
    if overwritegeometry
        piGeometryWrite(renderRecipe,'lightsFlag',lightsFlag, ...
            'thistrafficflow',thistrafficflow);
    end
end
%% Overwrite xxx.json
[~,scene_fname,~] = fileparts(renderRecipe.outputFile);
jsonFile = fullfile(workingDir,sprintf('%s.json',scene_fname));
jsonwrite(jsonFile,renderRecipe);
end
