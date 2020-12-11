function obj = piAssetCreate(varargin)

%{
n = piAssetCreate('type', 'node');

%}
%%
p = inputParser;
p.addParameter('type', 'node', @ischar);
p.parse(varargin{:});

type = p.Results.type;

%% Initialize the asset
obj.type = type;

switch type
    case 'branch'
        obj.name = 'node';
        obj.size.l = 0;
        obj.size.w = 0;
        obj.size.h = 0;
        obj.size.pmin = [0 0];
        obj.size.pmax = [0 0];
        obj.scale = [1 1 1];
        obj.position = [0 0 0];
        obj.rotate = [0 0 0;
              0 0 1;
              0 1 0;
              1 0 0];
        obj.motion = [];
    case 'object'
        obj.name = 'object';
        obj.mediumInterface = [];
        obj.material = [];
        obj.shape = [];
        obj.output = [];
    case 'light'
        obj.name = 'light';
        obj.lght = [];
end


end