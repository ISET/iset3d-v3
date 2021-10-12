function thisRotM = piTransformDegs2RotM(rotDegs, rotM, varargin)
%% 
% TBD
%
% Examples
%{
rotDegs = [90 0 0];
rotM = piTransformDegs2RotM(rotDegs);
%} 

%% Parse input
p = inputParser;
p.addRequired('rotDegs', @isvector);
p.addRequired('rotM', @ismatrix);
p.parse(rotDegs, rotM, varargin{:});

%%
thisRot = fliplr(rotDegs); % PBRT uses wired order of ZYX
% Calculate rotation transform
thisRotM = eye(4);
for jj=1:size(thisRot, 2)
    if thisRot(1, jj) ~= 0
        % rotation matrix from basis axis
        curRotM = piTransformRotation(rotM(:, jj), thisRot(1, jj));
        thisRotM = curRotM * thisRotM;
    end
end
end