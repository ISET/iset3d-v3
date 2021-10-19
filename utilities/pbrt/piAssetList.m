function gnames = piAssetList(thisR,varargin)
%  DEPRECATED
%
% Print out the group object names or the children names 
%
% Synopsis
%    gnames = piAssetList(thisR,varargin)
%
% Brief description
%   Print out and indexed list of the group objs in the recipe
%
% Input
%   thisR:   recipe
%
% Optional key/val pair
%   asset type {'groupobj','children'}
%
% Outputs:
%   gnames:   Group obj asset names
%
% ieExamplesPrint('piAssetList');
%
% See also
%  piAssetNames


%% Examples:
%{
  thisR = piRecipeDefault('scene name','SimpleScene');
  piAssetList(thisR);
  piAssetList(thisR,'asset type','children');
  piAssetList(thisR,'asset type','both');
%}

%%
warning('deprecated');

varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('thisR',@(x)(isa(x,'recipe')));
p.addParameter('assettype','groupobj',@(x)(ismember(x,{'groupobj','children','both'})));
p.parse(thisR,varargin{:});
assetType = p.Results.assettype;

%%

% Print
switch assetType
    case 'both'
        piAssetList(thisR,'asset type','groupobj');
        piAssetList(thisR,'asset type','children');
        
    case 'groupobj'
        gnames = thisR.get('group names');

        fprintf('\nGroup obj names\n===============\n');
        for ii=1:numel(gnames)
            fprintf('level %d ',ii);
            for jj = 1:numel(gnames{ii})
                fprintf('%s  ',ii,gnames{ii}{jj});
            end
            fprintf('\n');
        end
    case 'children'
        % Print out the children showing level and which group obj they are
        % part of
        cnames = thisR.get('children names');
        fprintf('\nChildren names\n===============\n');
        sz = numel(cnames);
        for ii=1:sz(1)
            fprintf('level %d ',ii);
            for jj = 1:numel(cnames{ii})
                if ~isempty(cnames{ii}{jj})
                    for kk = 1:length(cnames{ii}{jj})
                        fprintf('[%s (%d)]  ',cnames{ii}{jj}{kk},jj);
                    end
                end
            end
            fprintf('\n');
        end
    otherwise
        error('Unknown asset type %s\n',assetType);
end

end
