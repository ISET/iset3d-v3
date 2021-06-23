function [rotM, transM, scaleM] = piTransformWorld2Obj(thisR, nodeToRoot)
% Find rotation and translation from world axis to object axis
%
% Synopsis
%   [rotM, transM, scaleM] = piTransformWorld2Obj(thisR, nodeToRoot)
%
% The translation and rotations are represented with respect to homogeneous
% coordinates. Represented in matrix (4 x 4), with each row represents one
% dimension.
%
% I am not sure the scale is calculated correctly.  But maybe.  We multiply
% any scale branches together.  This is OK as long as the scale is always
% expressed in the object coordinate frame.
%
% Zheng should add in some more comments about how he is handling rotation
% and translation matrices here.
%
% Input
%    thisR
%    nodeToRoot
%
% Key/val
%    N/A
%
% Output
%    rotM   - 4x4 matrix representing rotation 
%    transM - 4x4 matrix representing translation
%    scaleM - vector of object size scale factors
%
% See also
%    recipeGet

%%
rotM   = eye(4);
transM = eye(4);
scaleM = ones(1,3);   % Scale factors

for ii=numel(nodeToRoot):-1:1
    % Get asset and its rotation and translation
    thisAsset = thisR.get('asset', nodeToRoot(ii));
    if isequal(thisAsset.type, 'branch')
        thisRot = fliplr(piAssetGet(thisAsset, 'rotate')); % PBRT uses wired order of ZYX
        thisTrans = piAssetGet(thisAsset, 'translate');
        thisScale = piAssetGet(thisAsset, 'scale');
        
        % Calculate this translation matrix
        curTransM =  piTransformTranslation(rotM(:, 1),...
            rotM(:, 2),...
            rotM(:, 3), thisTrans);
        transM(1:3, 4) = transM(1:3, 4) + curTransM(1:3, 4);
        scaleM = scaleM * diag(thisScale);
        
        % Calculate rotation transform
        thisRotM = eye(4);
        for jj=1:size(thisRot, 2)
            if thisRot(1, jj) ~= 0
                % rotation matrix from basis axis
                curRotM = piTransformRotation(rotM(:, jj), thisRot(1, jj));
                thisRotM = curRotM * thisRotM;
            end
        end
        % Update x y z axis
        [~, ~, ~, rotM] = piTransformAxis(rotM(:,1), rotM(:,2),rotM(:,3),thisRotM);
    end
end

end