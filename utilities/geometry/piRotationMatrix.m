function r = piRotationMatrix(varargin)
% The default rotation matrix used to specify assets and camera rotations
%
% Syntax:
%   r = piRotationDefault([varargin])
%
% Description:
%    This function returns the default rotation matrix used to specify
%    assets and camera rotations.
%
% Inputs:
%    None.
%
% Outputs:
%    r     - Matrix. The default 4x4 matrix that includes the rotation
%            terms and an affine term.
%
% Optional key/value pairs:
%    xaxis - Numeric. The rotation in degrees along the X axis. Default 0.
%    yaxis - Numeric. The rotation in degrees along the Y axis. Default 0.
%    zaxis - Numeric. The rotation in degrees along the Z axis. Default 0.
%
% See Also:
%   piDCM2angle, and piGeometryRead
%

% History:
%    XX/XX/XX  XXX  Created
%    04/29/19  JNM  Documentation pass

% Examples:
%{
    r = piRotationMatrix;
%}
%{
    r = piRotationMatrix('zrot', 10);
%}
%{
    r = piRotationMatrix('zrot', 10, 'yrot', 2, 'xrot', 1);
%}

%%
varargin = ieParamFormat(varargin);

p = inputParser;
p.addParameter('xrot', 0, @isscalar);
p.addParameter('yrot', 0, @isscalar);
p.addParameter('zrot', 0, @isscalar);
p.parse(varargin{:});

xRot = p.Results.xrot;
yRot = p.Results.yrot;
zRot = p.Results.zrot;

%% Initial default rotation angle (0, 0, 0)
r = [0     0     0
     0     0     1
     0     1     0
     1     0     0];

%% Set the correct entries
r(1, 1) = zRot;
r(1, 2) = yRot;
r(1, 3) = xRot;

end
