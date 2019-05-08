function asset = piAssetTranslate(asset, translation,varargin)
% Translation for assets, also updates a bounding box.
%
% When an asset (say a car) comes from the database, the positive x is
% the heading direction.  The default center of the car is 0 0 0.  If
% the position slot of the asset is not present, we assume the value
% is [0,0,0]. 
%
% ZL, Vistasoft Team, 2018
%% 
p = inputParser;
p.addParameter('instancesNum',1)
p.parse(varargin{:})
pos_d = p.Results.instancesNum;
%%
for dd = 1:pos_d
    for ii=1:length(asset)
        % Add the translation
        if ~isempty(translation{dd})
        translation{dd} = reshape(translation{dd},3,1);
        else
            translation{dd} = [0;0;0];
        end
        asset(ii).position(:,dd) = asset(ii).position(:,dd) + translation{dd};
        % Update the position of the x-z 2d box of the asset that we use
        % for machine learning identification.
        %     asset(ii).size.pmin = asset(ii).size.pmin + [translation(1) translation(3)];
        %     asset(ii).size.pmax = asset(ii).size.pmax + [translation(1) translation(3)];
    end
end
end
