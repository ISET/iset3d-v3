function downloadList = piObjectInstanceCount(assetList)
% Return a struct of asset specifications
%
% Syntax
%   downloadList = piObjectInstanceCount(assetList)
%
% Description:
%  Assets are stored in acquisitions within a session.  We sometimes
%  use the same asset multiple times in a scene.  The assetList is a
%  full listing of each time an asset is used in a scene.  We don't
%  want to download assets that are unused, or the same asset
%  repeatly.  
%
%  This routine finds the unique assets in the assetList.  It then
%  builds the downloadList, that includes indices into the list of
%  acquisitions that should be downloaded.  This downloadList contains
%  indices into the acquisitions that should be downloaded (index).
%  It also contains the number of times that asset is used (count).
%
% Input
%   assetList:
% Key/value
%   N/A
% Outputs
%  downloadList:  A struct with index and count.  
%       index is into the list of acquisitions
%       count is the number of times this particular acquisition is in
%             the assetList
%
% ZL
%
% See also
%  

%%
ListCheck = unique(assetList);
for kk = 1:length(ListCheck)
    count = 1;
    for jj = 1: length(assetList)
        if isequal(ListCheck(kk),assetList(jj))
            downloadList(kk).index = ListCheck(kk);
            downloadList(kk).count = count;
            count = count+1;
        end
    end
end
end