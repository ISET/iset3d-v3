function [gnames,cnames] = piAssetNames(thisR,varargin)
% Retrieve the names of the group objs and children in the asset struct
%
% Synopsis
%    [gnames, cnames] = piAssetNames(thisR,varargin)
%
% Brief description
%   The recipe assets have a root, groupobjs, and children.  These have
%   names. For now we have this rather awkward approach to getting the tree
%   structure of the groupobjs and children names.
%
% Inputs
%   thisR - recipe
%
% Optional key/val pairs
%   group find    - Return the [i,j] values so that gnames{i}{j} matches
%                   the find string
%   children find - Return the [i,j,k] values so that cnames{i}{j}{k}
%                   matches the find string
%
% Outputs
%  Either
%     gnames - groupobj names in a 2D cell array gnames{level}{idx}
%     cnames - children names in a 3D cell array cnames{level}{group}{idx}
%
%  Or, if a 'find' parameter is set to a string then the gnames parameter
%  is a vector such that gnames{i}{j} or cnames{i}{j}{k} is the entry
%  that matches the string.
%
% Longer description
%
%   The assets have a root (level 0).  Within the root there are groups of
%   assets (groupobjs) and these can in turn hyave groupobjs.  As you
%   descend through the struct there are terminal leafs that describe the
%   material properties and the shapes of the assets. These are called
%   'children'. There can be multiple children defining a group because
%   each child has its own
%
%   The basic organization is child stops the leafs of the tree.
%
%                                root
%  Level 1     child01   child02         group11            group12
%  Level 2             group21        group22      group23  child121
%                 child211 child212   child221    child231
%
% ieExamplesPrint('piAssetNames');
%
% See also
%

% Examples:
%{
 thisR = piRecipeDefault('scene name','SimpleScene');
 [gnames,cnames] = piAssetNames(thisR);
%}
%{
 thisR = piRecipeDefault('scene name','SimpleScene');
 thisGroup= piAssetNames(thisR,'group find','figure_3m');
 [gnames,cnames] = piAssetNames(thisR);
 gnames{thisGroup(1)}{thisGroup(2)}
%}
%{
 thisR = piRecipeDefault('scene name','SimpleScene');
 [gnames,cnames] = piAssetNames(thisR);
 thisChild= piAssetNames(thisR,'children find','3_1_Moon Light');
 cnames{thisChild(1)}{thisChild(2)}{thisChild(3)}
%}

%%
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('thisR',@(x)(isa(x,'recipe')));
p.addParameter('groupprint',false,@islogical);
p.addParameter('groupfind','',@ischar);
p.addParameter('childrenprint',false,@islogical);
p.addParameter('childrenfind','',@ischar);
p.parse(thisR,varargin{:});

%% Find gnames and cnames

clear names
level = 0;
thisG = thisR.assets.groupobjs;

while level > -1
    if isempty(thisG)
        level = -1;
    else
        nobjs = numel(thisG);
        level = level + 1;
        for jj=1:nobjs
            gnames{level}{jj} = thisG(jj).name; %#ok<AGROW>
            if ~isempty(thisG(jj).children)
                for kk=1:numel(thisG(jj).children)
                    cnames{level}{jj}{kk} = thisG(jj).children(kk).name; %#ok<AGROW>
                end
            end
        end
        thisG = thisG.groupobjs;
    end
end

%% Find index of a group obj by name
if ~isempty(p.Results.groupfind)
    for ii=1:size(gnames,1)
        idx = find(contains(gnames{ii},p.Results.groupfind));
        if ~isempty(idx)
            gnames = [ii,idx];
            return;
        end
    end
    disp('Group not found');
    gnames = [];
end

%% Find index of a child by name
if ~isempty(p.Results.childrenfind)
    for ii=1:numel(cnames)
        if ~isempty(cnames{ii})
            for jj=1:size(cnames{ii},2)
                if ~isempty(cnames{ii}{jj})
                    idx = find(contains(cnames{ii}{jj},p.Results.childrenfind));
                    if ~isempty(idx)
                        gnames = [ii,jj,idx];
                        return;
                    end
                end
            end
        end
    end
    disp('Child not found');
    gnames = [];
end


end

