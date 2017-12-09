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

%{
piWrite(thisR,'overwriteresources',false);
piWrite(thisR);
%}
%%
p = inputParser;
p.addRequired('renderRecipe',@(x)isequal(class(x),'recipe'));

% Format the parameters by removing spaces and forcing lower case.
if ~isempty(varargin), varargin = ieParamFormat(varargin); end
% p.addParameter('workingdir','',@isdir);

% Copy over the whole directory
p.addParameter('overwriteresources', true,@islogical);

% Overwrite the specific scene file
p.addParameter('overwritepbrtfile',true,@islogical);

% Force overwrite of the lens file
p.addParameter('overwritelensfile',true,@islogical);

p.parse(renderRecipe,varargin{:});

% workingDir          = p.Results.workingdir;
overwriteresources  = p.Results.overwriteresources;
overwritepbrtfile   = p.Results.overwritepbrtfile;
overwritelensfile   = p.Results.overwritelensfile;

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
        fprintf('Overwriting PBRT file %s.\n',outFile)
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
    if ~strcmp(inputLensFile(1),'/')
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

%% Write Scale and LookAt commands first

% Optional Scale
if(~isempty(renderRecipe.scale))   
   fprintf(fileID,'Scale %0.2f %0.2f %0.2f \n', ...
    [renderRecipe.scale(1) renderRecipe.scale(2) renderRecipe.scale(3)]);
    fprintf(fileID,'\n');
end

% Required LookAt 
fprintf(fileID,'LookAt %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f %0.6f \n', ...
    [renderRecipe.lookAt.from renderRecipe.lookAt.to renderRecipe.lookAt.up]);
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
            strcmp(ofn,'version'))
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
                    strcmp(ifn,'subpixels_w'))
                continue;
            end
            
            currValue = renderRecipe.(ofn).(ifn).value;
            currType  = renderRecipe.(ofn).(ifn).type;
            
            if(strcmp(currType,'string') || ischar(currValue))
                % Either a string type, or a spectrum type with a value
                % of 'xxx.spd'
                lineFormat = '  "%s %s" "%s" \n';
                
                % If the string has an extension like .spd or .dat, we are
                % going to copy it over to the working folder and then
                % rename it as a relative path in the recipe.
                [thisPath,name,ext] = fileparts(currValue);
                if(~isempty(ext))
                    
                    % Error check - Needs more comments about the
                    % relative path and absolute path.  BW/TL to do.
                    if(isempty(thisPath))
                        % We don't need a warning for the filename.
                        % TL: Got rid of warning for now, since it gets
                        % annoying. Maybe we should just assume the user
                        % knows what they are doing.
                        %{
                        if(~strcmp(ifn,'filename'))
                            warning('Tried to copy file %s, but filepath does not seem to be absolute.',currValue);
                        end
                        %}
                    else
                        relativeValue = strcat(name,ext);
                        [success,~,~] = copyfile(currValue,workingDir);
                        if(success)
                            % fprintf('Copied %s to: \n',currValue);
                            % fprintf('%s \n',fullfile(workingDir,relativeValue));
                            currValue = relativeValue;
                        else
                            % Warning or error?
                            warning('There was a problem copying file %s.',currValue);
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

for ii = 1:length(renderRecipe.world)
    currLine = renderRecipe.world{ii};
    fprintf(fileID,'%s \n',currLine);
end

%% Close file

fclose(fileID);

end
