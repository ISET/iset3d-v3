function newMat = parseMaterial(currentLine)
% Not sure what we use this for.  Could be deprecated after Jan 1 2022.
%
%
% See also
%
thisLine = strsplit(currentLine, {' "', '" ', '"'});
thisLine = thisLine(~cellfun('isempty',thisLine));

% Create a new material
matName = ''; % Material name
matType = thisLine{2}; % Material type
newMat = piMaterialCreate(matName, 'type', matType);


% For strings 3 to the end, parse
for ss = 3:2:numel(thisLine)
    % Get parameter type and name
    keyTypeName = strsplit(thisLine{ss}, ' ');
    keyType = ieParamFormat(keyTypeName{1});
    keyName = ieParamFormat(keyTypeName{2});
    
    % Some corner cases
    % "index" should be replaced with "eta"
    switch keyName
        case 'index'
            keyName = 'eta';
    end
    
    switch keyType
        case {'string', 'texture'}
            thisVal = thisLine{ss + 1};
        case {'float', 'rgb', 'color', 'photolumi'}
            % Parse a float number from string
            % str2num can convert string to vector. str2double can't.
            thisVal = str2num(thisLine{ss + 1});
        case {'spectrum'}
            [~, ~, e] = fileparts(thisLine{ss + 1});
            if isequal(e, '.spd')
                % Is a file
                thisVal = thisLine{ss + 1};
            else
                % Is vector
                thisVal = str2num(thisLine{ss + 1});
            end
        case 'bool'
            if isequal(thisLine{ss + 1}, 'true')
                thisVal = true;
            elseif isequal(thisLine{ss + 1}, 'false')
                thisVal = false;
            end
        otherwise
            warning('Could not resolve the parameter type: %s', keyType);
            continue;
    end
    
    newMat = piMaterialSet(newMat, sprintf('%s value', keyName),...
        thisVal);
end

end