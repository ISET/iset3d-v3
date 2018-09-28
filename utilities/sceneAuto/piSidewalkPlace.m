function assetsPlaced = piSidewalkPlace(assetsList,AssetsPosList)
%% For sidewalk assets, place the assets exactly by names
%
%
%
%
%%
for ii = 1: length(AssetsPosList)
    PosList{ii} = AssetsPosList(ii).name;
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
%asset = buildingList.building;
asset = assetsList;
for ii = 1: length(assetPosList_tmp)
%     gg=1;
    % if ~isequal(buildingPosList_tmp(ii).count,1)
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
                rotation=cell(n,1);
                gg=1;
                for jj = 1:length(AssetsPosList)
                    if isequal(assetPosList_tmp(ii).name{1},AssetsPosList(jj).name)
                        position{gg} = AssetsPosList(jj).position;
                        rotation{gg} = AssetsPosList(jj).rotate;
                        gg = gg+1;
                    end
                end
                assets_updated(ii).geometry = piAssetTranslate(asset(dd).geometry,position,'Pos_demention',n);
                assets_updated(ii).geometry = piAssetRotate(assets_updated(ii).geometry,rotation,'Pos_demention',n);
                assets_updated(ii).fwInfo   = asset(dd).fwInfo;
            end
        end
    end
    % end
end
assetsPlaced = assets_updated;
end