function thisR = piCameraRotate(thisR, varargin)
%
% Syntax:
%   thisR = piCameraRotate(recipe, 'x rot', x,...
%                                  'y rot', y,...
%                                  'z rot', z,...
%                                  'order',[]);
%
% Description:
%   Rotate the camera along three axis
%
% Inputs:
%   recipe  - The recipe of the scene
%
% Optional key/val pairs:
%   x rot   - Rotation along x axis in camera space (degrees)
%   y rot   - Rotation along y axis in camera space (degrees)
%   z rot   - Rotation along z axis in camera space (degrees)
%   order   - The order of the rotation 
%             (default [], meaning rotate all axes at the same time)
%
% Outputs
%   recipe  - Camera lookAt updated for the shift
%
% Description
%   Calculate the direction vector based on lookAt in a recipe, rotate the
%   direction vector according to a certain order.
%
% See also:
%   piCameraTranslate
%
%

% Examples:
%{
    % Create a recipe
    thisR =  piRecipeDefault;
    xrot = 10;
    yrot = 10;
    zrot = 10;

    % Rotate the camera
    thisR = piCameraRotate(thisR, 'x rot', xrot,...
                                  'y rot', yrot,...
                                  'z rot', zrot);

    % Shift the camera
    thisR = piCameraTranslate(thisR, 'x shift', 1,...
                                     'y shift', -0.5,...
                                     'z shift', -0.5);

    piWrite(thisR);
    [scene, result] = piRender(thisR, 'render type','both');
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

%% Rotate the camera 

for ii = 1:numel(order)
    thisAxis = order(ii);
    
    lookAt = thisR.get('lookAt');
    direction = lookAt.to - lookAt.from;
    switch thisAxis
        case 'x'
            % rotationMatrix = rotx(xrot);
            rotationMatrix = rotationMatrix3d([deg2rad(xrot),0,0]);
        case 'y'
            % rotationMatrix = roty(yrot);
            rotationMatrix = rotationMatrix3d([0,deg2rad(yrot),0]);

        case 'z'
            % rotationMatrix = rotz(zrot);
            rotationMatrix = rotationMatrix3d([0,0,deg2rad(zrot)]);
        otherwise
            error('Unknown axis: %s.\n', thisAxis);
    end
    
    newDirection = direction * rotationMatrix;
    lookAt.to = lookAt.from + newDirection;
    thisR.set('lookAt', lookAt);
end

end