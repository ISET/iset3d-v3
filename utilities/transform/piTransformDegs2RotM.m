function rotM = piTransformDegs2RotM(rotDegs, varargin)
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
p.parse(rotDegs, varargin{:});

%%
rotDegs = fliplr(rotDegs); % PBRT uses wired order of ZYX
% Calculate rotation transform
rotM = eye(4);
for jj=1:size(rotDegs, 2)
    if rotDegs(1, jj) ~= 0
        % rotation matrix from basis axis
        curRotM = piTransformRotation(rotM(:, jj), rotDegs(1, jj));
        rotM = curRotM * rotM;
    end
end
end