function [rotM, transM] = piTransformWorld2Obj(thisR, nodeToRoot)
%%
% World axis with homogeneous coordinates.
% Represented in matrix (4 x 4), with each row
% represents one dimension.
rotM = eye(4);
transM = eye(4);

for ii=numel(nodeToRoot):-1:1
    % Get asset and its rotation and translation
    thisAsset = thisR.get('asset', nodeToRoot(ii));
    if isequal(thisAsset.type, 'branch')
        thisRot = fliplr(piAssetGet(thisAsset, 'rotate')); % PBRT uses wired order of ZYX
        thisTrans = piAssetGet(thisAsset, 'translate');
        
        % Calculate this translation matrix
        curTransM =  piTransformTranslation(rotM(:, 1),...
            rotM(:, 2),...
            rotM(:, 3), thisTrans);
        transM(1:3, 4) = transM(1:3, 4) + curTransM(1:3, 4);
        
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