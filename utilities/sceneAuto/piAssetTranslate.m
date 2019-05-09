function asset = piAssetTranslate(asset, translation, varargin)
% Translation for assets, also updates a bounding box.
%
% Syntax:
%   asset = piAssetTranslate(asset, translation, [varargin])
%
% Description:
%    When an asset (say a car) comes from the database, the positive x is
%    the heading direction. The default center of the car is 0 0 0. If
%    the position slot of the asset is not present, we assume the value
%    is [0, 0, 0].
%
% Inputs:
%    asset         - Struct. A structure containing asset information.
%                    This can have one or more assets within the structure.
%    translation   - Matrix. The translation matrix for how to move the
%                    asset(s) within the scene.
%
% Outputs:
%    asset         - Struct. The modified asset structure.
%
% Optional key/value pairs:
%    pos_dimension - Numeric. The position dimension along which to
%                    translate the asset(s).
%

% History:
%    XX/XX/18  ZL   Vistasoft Team, 2018
%    05/07/19  JNM  Documentation pass
%    05/09/19  JNM  Merge with master

p = inputParser;
p.addParameter('instancesNum', 1)
p.parse(varargin{:})
instN = p.Results.instancesNum;

%%
for dd = 1:instN
    for ii = 1:length(asset)
        % Add the translation
        if ~isempty(translation{dd})
            translation{dd} = reshape(translation{dd}, 3, 1);
        else
            translation{dd} = [0; 0; 0];
        end
        asset(ii).position(:, dd) = asset(ii).position(:, dd) + ...
            translation{dd};
        % Update the position of the x-z 2d box of the asset that we use
        % for machine learning identification.
        % asset(ii).size.pmin = asset(ii).size.pmin + ...
        %     [translation(1) translation(3)];
        % asset(ii).size.pmax = asset(ii).size.pmax + ...
        %     [translation(1) translation(3)];
    end
end

end
