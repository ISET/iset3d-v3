function outFile = piWrite(renderRecipe,outFile,varargin)
% Given a recipe write a PBRT scene file.
%
% Input
%   renderRecipe:  a recipe object
%   outFile:       path to the output pbrt scene file
%
%   outFile = piWrite(recipe,fullOutfile,varargin)
%
% TL Scienstanford 2017

% TODO: Write out a depth map pbrt
%%
p = inputParser;
p.addRequired('renderRecipe',@(x)isequal(class(x),'recipe'));
p.addRequired('outFile',@ischar);
p.addParameter('overwrite',false,@islogical);
p.addParameter('copyDir','',@isdir);
p.parse(renderRecipe,outFile,varargin{:});
overwrite = p.Results.overwrite;
copyDir = p.Results.copyDir;

%% Copy given directory contents over

[outpath,~,~] = fileparts(outFile);
if(~isempty(copyDir))
    status = copyfile(copyDir,outpath);
    if(~status)
        error('Could not copy scene directory contents to output path.');
    else
        fprintf('Copied contents from:\n');
        fprintf('%s \n',copyDir);
        fprintf('to \n');
        fprintf('%s \n \n',outpath);
    end
end


%% Set up a text files to write into.

% Check if it exists. If it does, ask the user if we can overwrite.
if(exist(outFile,'file')) && ~overwrite
    fprintf('Writing out to %s \n',outFile);
    prompt = 'The PBRT file we are writing the recipe to already exists. Overwrite? (Y/N)';
    userInput = input(prompt,'s');
    if(strcmp(userInput,'N'))
        error('PBRT file already exists.');
    else
        warning('Overwriting out file.')
        delete(outFile);
    end
end

fileID = fopen(outFile,'w');

%% Write header

fprintf(fileID,'# PBRT file created with piWrite on %i/%i/%i %i:%i:%0.2f \n',clock);
fprintf(fileID,'\n');

%% Write LookAt command first

fprintf(fileID,'LookAt %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f \n', ...
    [renderRecipe.lookAt.from renderRecipe.lookAt.to renderRecipe.lookAt.up]);

%% Write all other blocks using a for loop

outerFields = fieldnames(renderRecipe);

for ofns = outerFields'
    ofn = ofns{1};
    
    if(strcmp(ofn,'world') || ...
            strcmp(ofn,'lookAt') || ...
            strcmp(ofn,'inputFile') || ...
            strcmp(ofn,'outputFile'))
        % Skip, we don't want to write these out here.
        continue;
    end
    
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
            % Skip these since we've written these out earlier already
            if(strcmp(ifn,'type') || strcmp(ifn,'subtype'))
                continue;
            end
            
            currValue = renderRecipe.(ofn).(ifn).value;
            currType = renderRecipe.(ofn).(ifn).type;
            
            if(strcmp(currType,'string') || ischar(currValue))
                % Either a string type, or a spectrum type with a value
                % of 'xxx.spd'
                lineFormat = '  "%s %s" "%s" \n';
                
                % If the string has an extension like .spd or .dat, we are
                % going to copy it over to the working folder and then
                % rename it as a relative path in the recipe.
                [path,name,ext] = fileparts(currValue);
                if(~isempty(ext))
                    
                    % Error check
                    if(isempty(path))
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
                        [success,~,~] = copyfile(currValue,outpath);
                        if(success)
                            fprintf('Copied %s to: \n',currValue);
                            fprintf('%s \n',fullfile(outpath,relativeValue));
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
                lineFormat = '  "%s %s" [%f] \n';
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
