function mList = piMaterialFind(thisR, field, val)
%% Find materials in the list that satisfy the field is equal to the value.
% Ine the case of recipe version 2, this is an index, and it is a field
% name for older version.
%
% Currently only supports searching for string type data, not for arrays
%
% ZLY, 2020
%% Format 
field = ieParamFormat(field);

%%
mList = {};
if ~isfield(thisR, 'recipeVer')
    fNames = fieldnames(thisR.materials.list);
    for ii = 1:numel(fNames)
        if ischar(val)
            if strcmp(thisR.materials.list.(fNames{ii}).(field), val)
                mList{end+1} = fNames{ii};
            end
        elseif isnumeric(val)
            if isequal(thisR.materials.list{ii}.(field), val)
                mList{end+1} = fNames{ii};
            end
        end
        
    end
elseif thisR.recipeVer == 2

for ii = 1:numel(thisR.materials.list)
    if isfield(thisR.materials.list{ii}, field)
        if ischar(val)
            if strcmp(thisR.materials.list{ii}.(field), val)
                mList{end+1} = ii;
            end
        elseif isnumeric(val)
            if isequal(thisR.materials.list{ii}.(field), val)
                mList{end+1} = ii;
            end
        end
    end
end

end

end