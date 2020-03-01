function thisR = piLightRotate(thisR, idx,varargin)
% Rotate the direction of a light source
%
% Synopsis
%   thisR = piLightRotate(thisR, idx,varargin)
%
% Inputs:
%   thisR:   recipe
%   idx:     Index to a light
%
% Optional key/value pairs
%   
% Returns
%   thisR:  the modified recipe
%
% Description
%   
%   Spot lights can be 


% Examples
%{
    ieInit;
    thisR = piRecipeDefault;
    thisR = piLightDelete(thisR, 'all');
    thisR = piLightAdd(thisR, 'type', 'spot', 'cameracoordinate', true);
    
    piLightGet(thisR);
    lightNumber = 1;
    piLightSet(thisR, lightNumber, 'light spectrum', 'D50')
    piLightSet(thisR, lightNumber, 'coneAngle', 5);
    [~, lightNumber] = piLightRotate(thisR, lightNumber, 'x rot', 5);

    piWrite(thisR, 'overwritematerials', true);

    % Render
    [scene, result] = piRender(thisR, 'render type','radiance');
    sceneWindow(scene);
%}
%% parse

% Remove spaces, force lower case
varargin = ieParamFormat(varargin);
p = inputParser;

p.addRequired('thisR', @(x)isequal(class(x), 'recipe'));

p.addParameter('xrot', 0, @isscalar);
p.addParameter('yrot', 0, @isscalar);
p.addParameter('zrot', 0, @isscalar);
p.addParameter('order',['x', 'y', 'z'], @isvector);

p.parse(thisR, varargin{:});

thisR  = p.Results.thisR;
xrot   = p.Results.xrot;
yrot   = p.Results.yrot;
zrot   = p.Results.zrot;
order  = p.Results.order;

%% Rotate the light

if ~isfield(thisR.lights{idx}, 'to')
    warning('This light does not have to! Doing nothing.');
else
    for ii = 1:numel(order)
        thisAxis = order(ii);

        to = thisR.lights{idx}.to - thisR.lights{idx}.from;
        switch thisAxis
            case 'x'
                rotationMatrix = rotationMatrix3d([deg2rad(xrot),0,0]);
            case 'y'
                rotationMatrix = rotationMatrix3d([0,deg2rad(yrot),0]);
            case 'z'
                rotationMatrix = rotationMatrix3d([0,0,deg2rad(zrot)]);
            otherwise
                error('Unknown axis: %s.\n', thisAxis);
        end

        newto = reshape(reshape(to, [1, 3]) * rotationMatrix, size(thisR.lights{idx}.from));

        if ii ~= 1
            idx = numel(thisR.lights);
        end
        piLightSet(thisR, idx, 'to', thisR.lights{idx}.from + newto);
    end
end

% lightSource = thisR.lights{end};
end