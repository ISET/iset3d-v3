function [mKeys, mCollection] = piMaterialFind(mList, param, val, n)
% Find materials in the list with a parameter that matches a value
%
% Synopsis
%   [mIdx, mCollection] = piMaterialFind(mList, param, val, n)
%
% Brief
%   Return the index of material(s) whose parameter matches val.
%
% Inputs
%   mList   - material list cell array (thisR.materials.list)
%   param   - parameter name
%   val     - value to match
%   n       - return first n indices
%
% Return
%   mIdx  - Index to the List of materials that have a field with a specific name and
%   mCollection - if requested, return the materials as a cell array.
%
% Description
%   Materials in a recipe are stored as a cell array.  We return the
%   material index into the thisR.materials.list.
%   
%
% In the original version the materials.list was not an
% array.  Instead, it was organized as a set of field names like
% materials.list.fieldname.  So in that case we have to return a cell array
% of fieldnames 
%
% Author: ZLY, 2020
%
% See also
%  piMaterial*

% Examples
%{
    thisR = piRecipeDefault;
    % Index of the materials whose name matches 'Mat'
    idx = piMaterialFind(thisR.materials.list, 'name', 'Mat');
    % Index and the material
    [idx,m] = piMaterialFind(thisR.materials.list, 'name', 'Mat');
    [idx,m] = piMaterialFind(thisR.materials.list, 'name', 'Patch19Material');
    [idx,m] = piMaterialFind(thisR.materials.list, 'type', 'uber');
%}

%% parse input
p = inputParser;
% p.addRequired('mList', @iscell);
p.addRequired('mList', @(x)isequal(class(mList), 'containers.Map'));
p.addRequired('param', @ischar);
% p.parse(mList, param, varargin{:}); % seems varargin is not being used
p.parse(mList, param);

%% Format 
param = ieParamFormat(param);

%%

mKeys = [];
mCollection = {};
cnt = 0;
if strcmp(param, 'name')
    mKeys{1} = val;
    mCollection = mList(val);
    return
else
    matNamesList = keys(mList);
    % if user not specified number of elements, return all
    if ~exist('n', 'var')
        n = numel(matNamesList);
    end
    for ii = 1:numel(matNamesList)
        if cnt<n
            thisMaterial = mList(matNamesList{ii});
            if isfield(thisMaterial, param)
                if isequal(param, 'type')
                    curVal = thisMaterial.(param);
                else
                    % All parameters beside 'name' and 'type'
                    % This is really not great because there are properties within
                    % these properties.  So we need to improve this (BW).
                    curVal = thisMaterial.(param).value;
                end
                
                if isequal(curVal, val)
                    cnt = cnt + 1;
                    mKeys{cnt} = matNamesList{ii}; %#ok<AGROW>
                    mCollection{cnt} = thisMaterial; %#ok<AGROW>
                end
            end
        end
    end
    
    if cnt == 1
        mCollection = mCollection{1};
    end
end
end