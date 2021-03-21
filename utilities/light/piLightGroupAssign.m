function thisR = piLightGroupAssign(thisR, varargin)
%
% Description:
%   Assign a group of lights with certain shape and spacing in the scene.
%
% Synopsis:
%   piLightGroupAssign(thisR, varargin)
%
% Inputs:
%   thisR - scene recipe
%
% Optional param/val pairs
%   shape    - put lights with certain shape
%   radius   - radius of a certain shape. For example, it will
%              be radius for a circle shape
%   number   - how many lights are assigned. This will be set equal to the
%              number of edges as default
%   other parameters can be set to lights. See piLightAdd.

%

% Examples
%{
thisR = piRecipeDefault;
piLightDelete(thisR, 'all');
thisR = piLightGroupAssign(thisR, 'shape','circle',...
                                  'radius',0.5,...
                                  'number', 10,...
                                  'type', 'spot',...
                                  'coneangle', 5);
piWrite(thisR);
[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
%}
%{
thisR = piRecipeDefault;
thisR.set('light', 'delete', 'all');
thisR = piLightGroupAssign(thisR, 'shape','circle',...
                                  'radius',0.5,...
                                  'number', 6,...
                                  'type', 'spot',...
                                  'coneangle', 5,...
                                  'spd', 'tungsten');
piWrite(thisR);
[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
%}

%{
thisR = piRecipeDefault;
thisR.set('light', 'delete', 'all');
thisR = piLightGroupAssign(thisR, 'shape','circle',...
                                  'radius',0.5,...
                                  'number', 6,...
                                  'type', 'spot',...
                                  'coneangle', 5,...
                                  'spd', 'D65');
piWrite(thisR);
[scene, ~] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
%}

%% Parse inputs
varargin = ieParamFormat(varargin);

p = inputParser;
p.KeepUnmatched = true;
p.addRequired('thisR', @(x)isequal(class(x), 'recipe'));
p.addParameter('shape', 'circle', @ischar);
p.addParameter('radius', 1, @isnumeric);
p.addParameter('number', 0, @isnumeric); % If number is not specified, we will set default values for different shape
p.addParameter('type', 'point', @ischar);
p.parse(thisR, varargin{:});

thisR = p.Results.thisR;
shape = p.Results.shape;
radius = p.Results.radius;
number = p.Results.number;
type = p.Results.type;

%% Extract light parameters except for shape, radius, number
paramVal = {};

for ii = 1:2:numel(varargin)
    if ~strcmp(varargin{ii}, {'shape', 'radius', 'number', 'type'})
        paramVal{numel(paramVal)+1} = varargin{ii};
        paramVal{end+1} = varargin{ii+1};
    end
    
end

%% Add lights accroding to shape
switch shape
    case 'circle'
        if number == 0
            number = 6;
        end
        
    case 'triangle'
end

%% Add from and to paramVal
from = thisR.get('from');
to = thisR.get('to');
%%
oriTrans = [0, radius, 0];
degrees = 0:360/number:360*(1-1/number);

for ii = 1:numel(degrees)
    curTrans = oriTrans * rotationMatrix3d([0, 0, deg2rad(degrees(ii))]);
    %% Add new light
    lght = piLightCreate(sprintf('GroupLight: %d', ii), 'type', type, paramVal{:});
    if isfield(lght, 'from')
        lght = piLightSet(lght, 'from val', from);
    end
    if isfield(lght, 'to')
        lght = piLightSet(lght, 'to val', to);
    end
    
    %% Translate this light towards direction
    lght = piLightTranslate(lght, 'x shift',...
                                         curTrans(1),...
                                         'y shift',...
                                         curTrans(2),...
                                         'z shift',...
                                         curTrans(3));
    thisR.set('light', 'add', lght);
end
%% older version
%{
%% Extract light parameters except for shape, radius, number
paramVal = {};

for ii = 1:2:numel(varargin)
    if ~strcmp(varargin{ii}, {'shape', 'radius', 'number'})
        paramVal{numel(paramVal)+1} = varargin{ii};
        paramVal{end+1} = varargin{ii+1};
    end
end

%% Add from to to paramVal
paramVal{numel(paramVal)+1} = 'from'; 
paramVal{numel(paramVal)+1} = thisR.get('from');
paramVal{numel(paramVal)+1} = 'to'; 
paramVal{numel(paramVal)+1} = thisR.get('to');

%% Add lights accroding to shape
switch shape
    case 'circle'
        if number == 0
            number = 6;
        end
        
    case 'triangle'
end

%%
oriTrans = [0, radius, 0];
degrees = 0:360/number:360*(1-1/number);

for ii = 1:numel(degrees)
    curTrans = oriTrans * rotationMatrix3d([0, 0, deg2rad(degrees(ii))]);
    %% Add new light
    thisR = piLightAdd(thisR, paramVal{:});
    
    %% Translate this light towards direction
    idx = numel(thisR.lights);
    thisR = piLightTranslate(thisR, idx, 'x shift',...
                                         curTrans(1),...
                                         'y shift',...
                                         curTrans(2),...
                                         'z shift',...
                                         curTrans(3));
end
%}
end