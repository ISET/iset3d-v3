function [mIdx, mCollection] = piMaterialFind(mList, param, val, varargin)
%% Find materials in the list such that the parameter matches a value
%
% Synopsis
%   [mIdx, mCollection] = piMaterialFind(mList, param, val, varargin)
%
% Inputs
%   mList   - material list cell array
%   param   - parameter name
%   val     - value to match
%
% Return
%   mList  - List of materials that have a field with a specific name and
%   value
%
%
% The new recipe version (2) we return the material as an index into the
% materials.list(). 
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
    mlist = piMaterialFind(thisR.materials.list, 'name', 'Mat');
%}

%% parse input
p = inputParser;
p.addRequired('mList', @iscell);
p.addRequired('param', @ischar)
p.parse(mList, param, varargin{:});

%% Format 
param = ieParamFormat(param);

%%

mIdx = [];
mCollection = {};
cnt = 0;
for ii = 1:numel(mList)
    if isfield(mList{ii}, param)
        if isequal(param, 'name') || isequal(param, 'type')
            curVal = mList{ii}.(param);
        else
            curVal = mList{ii}.(param).value;
        end
        
        if isequal(curVal, val)
            cnt = cnt + 1;
            mIdx(cnt) = ii;
            mCollection{cnt} = mList{ii};
        end
    end
end

if cnt == 1
    mCollection = mCollection{1};
end
end