function asset = piAssetTranslate(asset,translation)
% Translation for assets, also updates a bounding box.
%
% When an asset (say a car) comes from the database, the positive x is
% the heading direction.  The default center of the car is 0 0 0.  If
% the position slot of the asset is not present, we assume the value
% is [0,0,0]. 
%
% ZL, Vistasoft Team, 2018

for ii=1:length(asset)

    if isempty(asset(ii).position)
        % Assume position is 0,0,0
        asset(ii).position(1) = translation(1);
        asset(ii).position(2) = translation(2);
        asset(ii).position(3) = translation(3);
    else
        % Add the translation
        asset(ii).position(1) = asset(ii).position(1) + translation(1);
        asset(ii).position(2) = asset(ii).position(2) + translation(2);
        asset(ii).position(3) = asset(ii).position(3) + translation(3);
    end
    
    % Update the position of the x-z 2d box of the asset that we use
    % for machine learning identification.
    asset(ii).size.pmin = asset(ii).size.pmin + [translation(1) translation(3)];
    asset(ii).size.pmax = asset(ii).size.pmax + [translation(1) translation(3)];
end

end
