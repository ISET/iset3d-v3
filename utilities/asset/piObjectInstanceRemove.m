function thisR = piObjectInstanceRemove(thisR,assetname)

[assetIdx,~] = piAssetFind(thisR, 'name', assetname);

% find instance index
index = strfind(assetname,'_I_');
instanceIndex = str2double(assetname(index+3:end));
% find reference branch
referenceBranchName = thisR.assets.Node{assetIdx}.referencebranch;
[idx_ref,referenceBranch] = piAssetFind(thisR, 'name', referenceBranchName);

% remove the instance index for this asset
referenceBranch{1}.instanceCount(referenceBranch{1}.instanceCount==instanceIndex)=[];
thisR.assets = thisR.assets.set(idx_ref, referenceBranch{1});

% remove the asset from tree
thisR.assets=thisR.assets.chop(assetIdx);
end