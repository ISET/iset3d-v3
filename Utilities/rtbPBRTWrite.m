function outFile = rtbPBRTWrite(renderRecipe,outFile,varargin)
% Given a renderRecipe structure, write everything back out into a PBRT
% file.
%
% TL Scienstanford 2017

%%
p = inputParser;
p.addRequired('renderRecipe',@(x)isstruct(x));
p.parse(renderRecipe,varargin{:});

%% Set up a text file to write into.

% Check if it exists. If it does, ask the user if we can overwrite.
if(exist(outFile,'file'))
    prompt = 'Out file already exists. Overwrite? (Y/N)';
    userInput = input(prompt,'s');
    if(strcmp(userInput,'N'))
        error('Out file already exists.');
    else
        warning('Overwriting out file.')
        delete(outFile);
    end
end

[path,name,~] = fileparts(outFile);
fileID = fopen(fullfile(path,sprintf('%s.pbrt',name)),'w');

%% Write header

fprintf(fileID,'# PBRT file created with rtbPBRTWrite on %i/%i/%i %i:%i:%0.2f \n',clock);
fprintf(fileID,'\n');

%% Write LookAt command first

fprintf(fileID,'LookAt %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f \n', ...
    [renderRecipe.lookAt.from renderRecipe.lookAt.to renderRecipe.lookAt.up]);

%% Write all other blocks using a for loop

outerFields = fieldnames(renderRecipe);

for ofns = outerFields'
    ofn = ofns{1};
    
    if(strcmp(ofn,'world') || strcmp(ofn,'lookAt') ...
            || strcmp(ofn,'filename'))
        % Skip, we don't want to write these out here.
        continue;
    end
    
    % Write header for block
    fprintf(fileID,'# %s \n',ofn);
    
    % Write main type and subtype
    fprintf(fileID,'%s "%s" \n',renderRecipe.( ...
        ofn).type,renderRecipe.(ofn).subtype);
    
    % Loop through inner field names
    innerFields = fieldnames(renderRecipe.(ofn));
    if(~isempty(innerFields))
        for ifns = innerFields'
            ifn = ifns{1};
            % Skip these since we've written these out earlier already
            if(strcmp(ifn,'type') || strcmp(ifn,'subtype'))
                continue;
            end
            
            % We need to output the value type as well. Since at the moment
            % we haven't saved it in the renderRecipe (will that change in
            % the future?) we make an educated guess. This list is probably
            % lacking...
            currValue = renderRecipe.(ofn).(ifn).value;
            currType = renderRecipe.(ofn).(ifn).type;
            
            if(strcmp(currType,'string') || ischar(currValue))
                % Either a string type, or a spectrum type with a value
                % of 'xxx.spd'
                lineFormat = '  "%s %s" "%s" \n';
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
