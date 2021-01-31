function rotDeg = piTransformRotM2Degs(rotM, varargin)
%%
% TBD
% http://nghiaho.com/?page_id=846
% http://planning.cs.uiuc.edu/node102.html
% http://www.math.utah.edu/~gupta/MATH1060Fall2012/FormulaSheet

%% Parse input
p = inputParser;
p.addRequired('rotM', @ismatrix);
p.parse(rotM, varargin{:});


%%
rotY = atan2d(-rotM(3, 1), sqrt(rotM(3, 2)^2 + rotM(3, 3)^2));


if isequal(rotY, 90) || isequal(rotY, -90)
    % When rotation around Y axis is 90 degree, the
    % rotation of X and Z just need to satisfy:
    % rotX - rot Z = K where K is a constant that can
    % be calculated as:
    K = asind(rotM(1, 2));
    rotX = 0;
    rotZ = -K;
    fprintf('Rotation around Y axis is %f degrees. X and Z can be arbitrary degrees that satisfies: X - Z = %.2f\n', rotY, K);
else
    rotX = atan2d(rotM(3, 2), rotM(3, 3));
    rotZ = atan2d(rotM(2, 1), rotM(1, 1));
end

rotDeg = [rotX rotY rotZ];
end