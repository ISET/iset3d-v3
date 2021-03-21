function dcm=piAngle2dcm(r1, r2, r3)
% case ZYX
angles = [r1(:) r2(:) r3(:)];

dcm = zeros(3,3,size(angles,1));
cang = cos( angles );
sang = sin( angles );

%     [          cy*cz,          cy*sz,            -sy]
%     [ sy*sx*cz-sz*cx, sy*sx*sz+cz*cx,          cy*sx]
%     [ sy*cx*cz+sz*sx, sy*cx*sz-cz*sx,          cy*cx]

dcm(1,1,:) = cang(:,2).*cang(:,1);
dcm(1,2,:) = cang(:,2).*sang(:,1);
dcm(1,3,:) = -sang(:,2);
dcm(2,1,:) = sang(:,3).*sang(:,2).*cang(:,1) - cang(:,3).*sang(:,1);
dcm(2,2,:) = sang(:,3).*sang(:,2).*sang(:,1) + cang(:,3).*cang(:,1);
dcm(2,3,:) = sang(:,3).*cang(:,2);
dcm(3,1,:) = cang(:,3).*sang(:,2).*cang(:,1) + sang(:,3).*sang(:,1);
dcm(3,2,:) = cang(:,3).*sang(:,2).*sang(:,1) - sang(:,3).*cang(:,1);
dcm(3,3,:) = cang(:,3).*cang(:,2);
end