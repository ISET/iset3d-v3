[r1,r2,r3] = pidcm2angle( dcm, varargin )      


%VALIDATEDCM internal function to check that the input dcm is orthogonal
%and proper.
% The criteria for this check are:
%      - the transpose of the matrix multiplied by the matrix equals 
%        1 +/- tolerance
%      - determinant of matrix == +1


%     [          cy*cz,          cy*sz,            -sy]
        %     [ sy*sx*cz-sz*cx, sy*sx*sz+cz*cx,          cy*sx]
        %     [ sy*cx*cz+sz*sx, sy*cx*sz-cz*sx,          cy*cx]

        [r1,r2,r3] = threeaxisrot( dcm(1,2,:), dcm(1,1,:), -dcm(1,3,:), ...
                                   dcm(2,3,:), dcm(3,3,:), ...
                                  -dcm(2,1,:), dcm(2,2,:));   

r1 = r1(:);
r2 = r2(:);
r3 = r3(:);

function [r1,r2,r3] = threeaxisrot(r11, r12, r21, r31, r32, r11a, r12a)
        % find angles for rotations about X, Y, and Z axes
        r1 = atan2( r11, r12 );
        r2 = asin( r21 );
        r3 = atan2( r31, r32 );
        if strcmpi( lim, 'zeror3')
            for i = find(abs( r21 ) >= 1.0)
                r1(i) = atan2( r11a(i), r12a(i) );
                r2(i) = asin( r21(i) );
                r3(i) = 0;
            end
        end
    end