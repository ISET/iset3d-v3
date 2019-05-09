function asset = piAssetMotionAdd(asset, varargin)
% Add motion to the provided asset.
%
% Syntax:
%   asset = piAssetMotionAdd(asset, [varargin]);
%
% Description:
%    Add motion to the provided asset and return the asset.
%
% Inputs:
%    asset         - Object. One or more objects you wish to add motion to.
%
% Outputs:
%    asset         - Object. The modified object(s).
%
% Optional key/value pairs:
%    translation   - Cell. Cell data about object translation. Default [].
%    Y             - Cell. Cell data about motion along the Y dimension.
%                    Default [].
%    Z             - Cell. Cell data about motion along the Z dimension.
%                    Default [].
%    Pos_demention - Numeric. The position demention? (Dimension???)
%

% History:
%    XX/XX/XX  XXX  Created
%    04/12/19  JNM  Documentation pass
%    05/09/19  JNM  Merge Master in again

p = inputParser;
p.addParameter('translation', [], @iscell)
p.addParameter('Y', [], @iscell);
p.addParameter('Z', [], @iscell);
p.addParameter('instancesNum', 1)
p.parse(varargin{:})
translation = p.Results.translation;
instN = p.Results.instancesNum;
Y = p.Results.Y;
Z = p.Results.Z;

%%
for dd = 1:instN
    for ii = 1:length(asset)
        % Add the translation
        if ~isempty(translation{dd})
            translation{dd} = reshape(translation{dd}, 3, 1);
        else
            translation{dd} = [0; 0; 0];
        end
        asset(ii).motion.position(:, dd) = translation{dd};
        % Update the position of the x-z 2d box of the asset that we use
        % for machine learning identification.
        %     asset(ii).size.pmin = ...
        %           asset(ii).size.pmin + [translation(1) translation(3)];
        %     asset(ii).size.pmax = ...
        %           asset(ii).size.pmax + [translation(1) translation(3)];
        if isfield(asset(ii), 'children')
            if length(asset(ii).children) >= 1
                if isempty(asset(ii).rotate)
                    asset(ii).rotate(:, 1) = [0; 0; 1; 0];
                    asset(ii).rotate(:, 2) = [0; 0; 0; 1];
                    asset(ii).rotate(:, 3) = [0; 1; 0; 0];
                end
                if ~isempty(Y)
                    asset(ii).motion.rotate(:, dd * 3 - 2) = ...
                        [Y{dd}; 0; 1; 0];
                else
                    asset(ii).motion.rotate(:, dd * 3 - 2) = [0; 0; 1; 0];
                end %Y
                if ~isempty(Z)
                    asset(ii).motion.rotate(:, dd * 3) = [Z{dd}; 0; 0; 1];
                else
                    asset(ii).motion.rotate(:, dd * 3) = [0; 0; 0; 1];
                end %Z
                asset(ii).motion.rotate(:, dd * 3 - 1) = [0; 1; 0; 0]; % X
                % find car position
                %         object_position = [object(ii).position(1), ...
                %             object(ii).position(3)];
                % rotate object's pmin and pmax for bounding box checking
                %         object(ii).size.pmin = piPointRotate( ...
                %             object(ii).size.pmin,  ...
                %             object_position, -degree);
                %         object(ii).size.pmax = piPointRotate( ...
                %             object(ii).size.pmax,  ...
                %             object_position, -degree);
            end
        end
    end
end

end