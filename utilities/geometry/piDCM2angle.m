function [r1,r2,r3] = piDCM2angle( dcm )
% Simplified version of the Aerospace toolbox angle conversion utility
%
% Syntax:
%
% Brief description:
%   
% The case that we compute is this one.  There are many others and
% various options in the Mathworks dcm2angle.m code
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
%  zAngle, yAngle, xAngle:  vectors of rotation angles for the matrices
%
% See also:
%

% TODO
%   Zhenyi to make sure that this function returns the same as dcm2angle
%   in the Aerospace toolbox for this case.

% Examples:
%{
dcm(:,:,1) = eye(3);
dcm(:,:,2) = eye(3);
[z,y,x] = piDCM2angle(dcm)
%}

% Should validate here

%% This is the transform
validatedcm(dcm);

[r1,r2,r3] = threeaxisrot( dcm(1,2,:), dcm(1,1,:), -dcm(1,3,:), ...
    dcm(2,3,:), dcm(3,3,:), ...
    -dcm(2,1,:), dcm(2,2,:));

r1 = r1(:);
r2 = r2(:);
r3 = r3(:);

end

function [r1,r2,r3] = threeaxisrot(r11, r12, r21, r31, r32, r11a, r12a)
% find angles for rotations about X, Y, and Z axes
r1 = atan2( r11, r12 );
r2 = asin( r21 );
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


