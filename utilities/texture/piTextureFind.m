function [tKeys, tCollection] = piTextureFind(tList, param, val, varargin)
%% Find textures in the list such that the field equals a value
%
% Synopsis
%   mList = piTextureFind(thisR, field, val)
%
% Inputs
%   thisR
%   field  - Name of the field
%   val    - Value of the field
%
% Return
%   tList  - List of textures that have a field with a specific name and
%
%
% Description
%   The new recipe version (2) returns the texture as an index into the
%   textures.list().
%
% Author: ZLY, 2020
%
% See also
%  piTexture*

% Examples:
%{
   thisR = piRecipeDefault('scene name', 'flatSurfaceRandomTexture');

   % This will be the second texture in thisR.textures.list
   piTextureCreate(thisR, 'name', 'checks',...
                       'format', 'spectrum',...
                       'type', 'checkerboard',...
                       'float uscale', 8,...
                       'float vscale', 8,...
                       'spectrum tex1', [.01 .01 .01],...
                       'spectrum tex2', [.99 .99 .99]);

    idx = piTextureFind(thisR,'name','checks')
    idx = piTextureFind(thisR,'name','reflectanceChart_color')
%}
%% parse input
p = inputParser;
p.addRequired('tList', @(x)isa(tList, 'containers.Map'));
p.addRequired('param', @ischar)
p.parse(tList, param, varargin{:});

%% Format
param = ieParamFormat(param);

%%

tKeys = [];
tCollection = {};
cnt = 0;
if strcmp(param, 'name')
    tKeys{1} = val;
    tCollection = tList(val);
    return
else
    for ii = 1:numel(tList)
        if isfield(tList{ii}, param)
            if isequal(param, 'type')
                curVal = tList{ii}.(param);
            else
                curVal = tList{ii}.(param).value;
            end
            
            if isequal(curVal, val)
                cnt = cnt + 1;
                tKeys(cnt) = ii; %#ok<AGROW>
                tCollection{cnt} = tList{ii}; %#ok<AGROW>
            end
        end
    end
    
    if cnt == 1
        tCollection = tCollection{1};
    end
end
%%
%{
%% Format
field = ieParamFormat(field);

%%
if isstruct(thisR.textures.list)
    % The returned material list is a cell array of field names
    tList = {};
    fNames = fieldnames(thisR.textures.list);
    for ii = 1:numel(fNames)
        if ischar(val)
            if strcmp(thisR.textures.list.(fNames{ii}).(field), val)
                tList{end+1} = fNames{ii};
            end
        elseif isnumeric(val)
            if isequal(thisR.textures.list{ii}.(field), val)
                tList{end+1} = fNames{ii};
            end
        end
        
    end
elseif iscell(thisR.textures.list)
    % The return material list is a vector
    tList = [];
    for ii = 1:numel(thisR.textures.list)
        if isfield(thisR.textures.list{ii}, field)
            if ischar(val)
                if strcmp(thisR.textures.list{ii}.(field), val)
                    tList(end+1) = ii;
                end
            elseif isnumeric(val)
                if isequal(thisR.textures.list{ii}.(field), val)
                    tList(end+1) = ii;
                end
            end
        end
    end
else
    error('Bad recipe textures list.');
end
%}
end