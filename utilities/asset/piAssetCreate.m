function obj = piAssetCreate(varargin)
% Creates the format for different types of assets
%
% Synopsis
%
% Inputs
%
% Optional key/val pairs
%   type - Possible asset node types are 'branch','object' and 'light'.
%
% Return
%
% Description
%
%  A marker is a leaf of the tree.  We have these from Cinema4D and maybe
% other graphics programs
%
%  A light is always a leaf of the tree.  Lights are not always included in
% the assets.  There is a separate 'lights' slot in the recipe
%
%  An object is always a leaf of the tree.  This is an honest to God aset.
%
%  A branch is a branch of the tree.  This includes position, rotation,
% scale and other branch information.  The contents apply to all assets
% below this branch Node
%
% See also
%

% Examples:
%{
n = piAssetCreate('type', 'branch');
%}
%{
n = piAssetCreate('type','marker')
%}

%%
p = inputParser;
p.addParameter('type', 'branch', @(x)(ismember(x,{'branch','object','light','marker'})));
p.parse(varargin{:});

type = p.Results.type;

%% Initialize the asset
obj.type = type;

switch ieParamFormat(type)
    case 'branch'
        obj.name = 'branch';
        obj.size.l = 0;
        obj.size.w = 0;
        obj.size.h = 0;
        obj.size.pmin = [0 0];
        obj.size.pmax = [0 0];
        obj.scale = [1 1 1];
        obj.translation = [0 0 0];
        obj.rotation = [0 0 0;
            0 0 1;
            0 1 0;
            1 0 0];
        obj.concattransform=[];
        obj.motion = [];
    case 'object'
        obj.name = 'object';
        obj.mediumInterface = [];
        obj.material = [];
        obj.shape = [];
        % Different parts can be part of the same object, not clear.
        obj.index = [];
    case 'light'
        obj.name = 'light';
        obj.lght = [];
    case 'marker'
        obj.name = 'marker';
        obj.size.l = 0;
        obj.size.w = 0;
        obj.size.h = 0;
        obj.size.pmin = [0 0];
        obj.size.pmax = [0 0];
        obj.scale = [1 1 1];
        obj.translation = [0 0 0];
        obj.rotation = [0 0 0;
            0 0 1;
            0 1 0;
            1 0 0];
        obj.concattransform=[];
        obj.motion = [];
    otherwise
        error('Unknown asset type %s\n',type);
end

end

