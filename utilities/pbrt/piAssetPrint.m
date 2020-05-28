function names = piAssetPrint(thisR)
% Print asset names with index number
%
% Brief description
%   Print out and indexed list of the assets in the recipe
%
% Input
%   thisR:   recipe
%
% Outputs:
%   names:   Asset names
%
% See also
%

fprintf('%s is deprecated.  Use piAssetList\n',mfilename);

names = piAssetList(thisR);

end