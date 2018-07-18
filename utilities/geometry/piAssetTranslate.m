function asset = piAssetTranslate(asset,translation)
% translte car and lights
% positive x is heading direction
% default center of the car  is 0 0 0, we adjust the y(up) of the car to
% place it in a correct position.


for ii=1:length(asset)
    x = translation(1);
    y = translation(2);
    z = translation(3);
    if isempty(asset(ii).position)
        asset(ii).position = [x y z];
    else
        asset(ii).position = asset(ii).position + [x y z];
    end
    % x-z 2d box of the asset
    asset(ii).size.pmin = asset(ii).size.pmin +[x z];
    asset(ii).size.pmax = asset(ii).size.pmax +[x z];
end
end
