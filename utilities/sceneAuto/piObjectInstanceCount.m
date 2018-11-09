function downloadList = piObjectInstanceCount(assetList)
%% 
% assetList is namelist which might contains the required asseets to be
% place in a scene, however, one asset is used multiple times, in this
% case, we say, object instances are created, however, to avoid 
% downloading the same data multiple times, we count the number of
% appearance for each unique asset, ideally, we only need to download the
% unique assets, which is downloadList in this function.
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