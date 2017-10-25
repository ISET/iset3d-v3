function [] = rtbPBRTWrite(renderRecipe,outFile,varargin)
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
            currValue = renderRecipe.(ofn).(ifn);
            if(ischar(currValue))
                if(strcmp(currValue(end-3:end),'.spd'))
                    % Is a spectrum file.
                    currType = 'spectrum';
                    lineFormat = '  "%s %s" "%s" \n';
                else
                    currType = 'string';
                    lineFormat = '  "%s %s" "%s" \n';
                end
            else
                if(size(currValue,2) == 4)
                    % Somtimes spectra are defined like this.
                    currType = 'spectrum';
                    lineFormat = '  "%s %s" [%f %f %f %f] \n';
                elseif(size(currValue,2) == 3)
                    currType = 'rgb';
                    lineFormat = '  "%s %s" [%f %f %f] \n';
                elseif(mod(currValue,1) == 0)
                    currType = 'integer';
                    lineFormat = '  "%s %s" [%i] \n';
                else
                    currType = 'float';
                    lineFormat = '  "%s %s" [%f] \n';
                end
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
