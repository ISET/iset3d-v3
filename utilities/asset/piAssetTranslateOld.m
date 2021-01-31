function asset = piAssetTranslate(asset, translation,varargin)
% Translation for an array of assets
%
% Synopsis
%   asset = piAssetTranslate(asset, translation,varargin)
%
% Brief description
%   Translate the position of an array of assets
%
% Input
%   asset
%   translation
%
% Optional key/value pair
%   instances num
%
% Return
%   asset - the modified asset
%
% Description
%  When an asset (say a car) comes from the database, the positive x is
%  the heading direction.  The default center of the car is 0 0 0.  If
%  the position slot of the asset is not present, we assume the value
%  is [0,0,0].   (Need better comment here).
%
% ZL, Vistasoft Team, 2018
%
% See also
%   piAsset*
%
% TODO:  
%   Why is translate a cell array instead of a vector?
%   We need piAssetGet, piAssetSet.  And this should be called by
%
%     piAssetSet(thisR,idx,'translate',tVector);
%
%

%%
varargin = ieParamFormat(varargin);

p = inputParser;
p.addParameter('instancesnum',1)
p.parse(varargin{:})

pos_d = p.Results.instancesnum;   % The variable name is confusing (BW)
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
        
        %{
        % Update the position of the x-z 2d box of the asset that we use
        % for machine learning identification.
        %     asset(ii).size.pmin = asset(ii).size.pmin + [translation(1) translation(3)];
        %     asset(ii).size.pmax = asset(ii).size.pmax + [translation(1) translation(3)];
        %}
        
    end
end
end
