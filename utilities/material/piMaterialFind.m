function idxList = piMaterialFind(thisR, field, val)
%% Find indecies of materials in the list that satisfy conditions.
% Currently only supports searching for string type data, not for arrays
%
% ZLY, 2020
%% Format 
field = ieParamFormat(field);

%%
idxList = [];
for ii = 1:numel(thisR.materials.list)
    if isfield(thisR.materials.list{ii}, field)
        if strcmp(thisR.materials.list{ii}.(field), val)
            idxList = [idxList, ii];
        end
    end
end

end