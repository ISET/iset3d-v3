function [lIdx, lCollection] = piLightFind(lList, param, val, varargin)
%% Find light in the list such that the field equals a value
%
% Synopsis
%   [lIdx, lCollection] = piLightFind(lList, param, val, varargin)
%
% Inputs
%   thisR
%   field  - Name of the field
%   val    - Value of the field
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
%% parse input
p = inputParser;
p.addRequired('lList', @iscell);
p.addRequired('param', @ischar)
p.parse(lList, param, varargin{:});

%% Format 
param = ieParamFormat(param);

%%
lIdx = [];
lCollection = {};
cnt = 0;
for ii = 1:numel(lList)
    if isfield(lList{ii}, param)
        if isequal(param, 'name') || isequal(param, 'type')
            curVal = lList{ii}.(param);
        else
            curVal = lList{ii}.(param).value;
        end

        if isequal(curVal, val)
            cnt = cnt + 1;
            lIdx(cnt) = ii; %#ok<AGROW>
            lCollection{cnt} = lList{ii}; %#ok<AGROW>
        end
    end
end

if cnt == 1
    lCollection = lCollection{1};
end
%% old version
%{
%% Format 
field = ieParamFormat(field);

%%
if isstruct(thisR.lights)
    % The returned material list is a cell array of field names
    lList = {};
    fNames = fieldnames(thisR.lights);
    for ii = 1:numel(fNames)
        if ischar(val)
            if strcmp(thisR.lights.(fNames{ii}).(field), val)
                lList{end+1} = fNames{ii};
            end
        elseif isnumeric(val)
            if isequal(thisR.lights{ii}.(field), val)
                lList{end+1} = fNames{ii};
            end
        end
        
    end
elseif iscell(thisR.lights)
    % The return material list is a vector
    lList = [];
    for ii = 1:numel(thisR.lights)
        if isfield(thisR.lights{ii}, field)
            if ischar(val)
                if strcmp(thisR.lights{ii}.(field), val)
                    lList(end+1) = ii;
                end
            elseif isnumeric(val)
                if isequal(thisR.lights{ii}.(field), val)
                    lList(end+1) = ii;
                end
            end
        end
    end
else
    error('Bad recipe lights list.');
end
%}
end