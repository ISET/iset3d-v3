function assetsPlaced = piSidewalkPlace(assetsList,assetsPosList)
% Place sidewalk assets exactly by names
%
% Syntax
%
% Description
%
% Inputs
%   assetList
%   AssetsPosList
%
% Key/val pairs
%
% Outputs
%   assetsPlaced
%
%
%
% Zhenyi
%
% See also
%

%%

for ii = 1: length(assetsPosList)
    PosList{ii} = assetsPosList(ii).name;
end

PosListCheck = unique(PosList);
for kk = 1:length(PosListCheck)
    count = 1;
    for jj = 1: length(PosList)
        if isequal(PosListCheck(kk),PosList(jj))
            assetPosList_tmp(kk).name = PosListCheck(kk);
            assetPosList_tmp(kk).count = count;
            count = count+1;
        end
    end
end

%%
asset = assetsList;

for ii = 1: length(assetPosList_tmp)
    n = assetPosList_tmp(ii).count;
    for hh = 1: length(asset(ii).geometry)
        
        for dd = 1: length(asset)
            if isequal(asset(dd).geometry.name,assetPosList_tmp(ii).name{1})
                assets_updated(ii) = asset(dd);
                pos = asset(dd).geometry(hh).position;
                rot = asset(dd).geometry(hh).rotate;
                asset(dd).geometry(hh).position = repmat(pos,1,uint8(assetPosList_tmp(ii).count));
                asset(dd).geometry(hh).rotate = repmat(rot,1,uint8(assetPosList_tmp(ii).count));
                position=cell(n,1);
                rotationY=cell(n,1);
                gg=1;
                for jj = 1:length(assetsPosList)
                    if isequal(assetPosList_tmp(ii).name{1},assetsPosList(jj).name)
                        position{gg} = assetsPosList(jj).position;
                        rotationY{gg} = assetsPosList(jj).rotate;
                        gg = gg+1;
                    end
                end
                assets_updated(ii).geometry = piAssetTranslate(asset(dd).geometry,position,'instancesNum',n);
                assets_updated(ii).geometry = piAssetRotate(assets_updated(ii).geometry,'Y',rotationY,'instancesNum',n);
                assets_updated(ii).fwInfo   = asset(dd).fwInfo;
            end
        end
    end
end

assetsPlaced = assets_updated;

end