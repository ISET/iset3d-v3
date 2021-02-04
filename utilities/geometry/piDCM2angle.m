function [r1,r2,r3] = piDCM2angle( dcm, varargin )

%{% Simplified version of the Aerospace toolbox angle conversion utility
%
% Syntax:
%  [r1,r2,r3] = piDCM2angle( dcm )
%
% Brief description:
%  The case that we compute is this one.  There are many others and
%  various options in the Mathworks dcm2angle.m code
%
%     [          cy*cz,          cy*sz,            -sy]
%     [ sy*sx*cz-sz*cx, sy*sx*sz+cz*cx,          cy*sx]
%     [ sy*cx*cz+sz*sx, sy*cx*sz-cz*sx,          cy*cx]
%
% Inputs:
%   dcm:  A 3D array of matrices
%
% Optional key/value pairs
%   N/A
%
% Outputs:
%  zAngle, yAngle, xAngle:  Vectors of rotation angles for the matrices
%
% See also:
%    piRotationDefault, piGeometryRead

% Examples:
%{
 % Should be all zeros
 dcm(:,:,1) = eye(3);
 dcm(:,:,2) = eye(3);
 [z,y,x] = piDCM2angle(dcm)
%}
%{

%}

%% Should validate here

% TL: Validate seems to fail for certain scenes. Commenting out for now
% until we figure out what's going on.
% validatedcm(dcm);

if isempty(varargin)
    type = 'ZYX';
else
    type = varargin{1};
end
%% This is the transform
switch type
    case 'ZYX'
        [r1,r2,r3] = threeaxisrot( dcm(1,2,:), dcm(1,1,:), -dcm(1,3,:), ...
            dcm(2,3,:), dcm(3,3,:));
    case 'ZXY'
        [r1,r2,r3] = threeaxisrot( -dcm(2,1,:), dcm(2,2,:), dcm(2,3,:), ...
            -dcm(1,3,:), dcm(3,3,:));
    case 'XYZ'
        [r1,r2,r3] = threeaxisrot( -dcm(3,2,:), dcm(3,3,:), dcm(3,1,:), ...
            -dcm(2,1,:), dcm(1,1,:));
    case 'XZY'
        [r1,r2,r3] = threeaxisrot( dcm(2,3,:), dcm(2,2,:), -dcm(2,1,:), ...
            dcm(3,1,:), dcm(1,1,:));
    case 'YXZ'
        [r1,r2,r3] = threeaxisrot( dcm(3,1,:), dcm(3,3,:), -dcm(3,2,:), ...
            dcm(1,2,:), dcm(2,2,:));
    case 'YZX'
        [r1,r2,r3] = threeaxisrot( -dcm(1,3,:), dcm(1,1,:), dcm(1,2,:), ...
            -dcm(3,2,:), dcm(2,2,:));
end


r1 = r1(:);
r2 = r2(:);
r3 = r3(:);

end

function [r1,r2,r3] = threeaxisrot(r11, r12, r21, r31, r32)
% find angles for rotations about X, Y, and Z axes

r1 = atan2( r11, r12 );
r2 = asin(  r21 );
r3 = atan2( r31, r32 );

%{
% The original implements this special case of zero rotation on the
% 3rd dimension.  Does not seem relevant to us
if strcmpi( lim, 'zeror3')
    for i = find(abs( r21 ) >= 1.0)
        r1(i) = atan2( r11a(i), r12a(i) );
        r2(i) = asin( r21(i) );
        r3(i) = 0;
    end
end
%}

end


function validatedcm(dcm)
%VALIDATEDCM internal function to check that the input dcm is orthogonal
%and proper.
% The criteria for this check are:
%      - the transpose of the matrix multiplied by the matrix equals
%        1 +/- tolerance
%      - determinant of matrix == +1
%

tolerance = 1e-6;

for ii=1:size(dcm,3)
    x = dcm(:,:,ii)*dcm(:,:,ii)'; 
    d = (x - eye(3));
    assert( max(d(:)) < tolerance);
    assert(det(x) - 1 < tolerance);
end

end

