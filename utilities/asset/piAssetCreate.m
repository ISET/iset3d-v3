function obj = piAssetCreate(varargin)

%{
n = piAssetCreate('type', 'branch');

%}
%%
p = inputParser;
p.addParameter('type', 'branch', @ischar);
p.parse(varargin{:});

type = p.Results.type;

%% Initialize the asset
obj.type = type;

switch type
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
    case 'light'
        obj.name = 'light';
        obj.lght = [];
end


end