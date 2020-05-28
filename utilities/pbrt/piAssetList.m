function gnames = piAssetList(thisR,varargin)
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
%}

%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('thisR',@(x)(isa(x,'recipe')));
p.addParameter('assettype','groupobj',@(x)(ismember(x,{'groupobj','children'})));
p.parse(thisR,varargin{:});
assetType = p.Results.assettype;

%%

% Print
switch assetType
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
        cnames = thisR.get('children names');
        fprintf('\nChildren names\n===============\n');
        sz = numel(cnames);
        for ii=1:sz(1)
            fprintf('level %d ',ii);
            for jj = 1:numel(cnames{ii})
                fprintf('%s ',ii,cnames{ii}{jj});
            end
            fprintf('\n');
        end
    otherwise
        error('Unknown asset type %s\n',assetType);
end

end
