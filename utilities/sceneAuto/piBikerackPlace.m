function StreetPlaced = piBikerackPlace(assetlib,assetPosList)
%% Place the assets by given position list, exact names do not need to be matched.
for ii = 1: length(assetPosList)
    PosList{ii} = assetPosList(ii).name;
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
asset = assetlib;

for ii = 1: length(assetPosList_tmp)
    
    % if ~isequal(buildingPosList_tmp(ii).count,1)
    n = assetPosList_tmp(ii).count;
    assets_updated(ii) = asset(ii);
%     for dd = 1: length(asset)
        
        for hh = 1: length(asset(ii).geometry)% change from ii to dd
            gg=1;
            position=cell(n,1);
            rotationY=cell(n,1); 
            pos = asset(ii).geometry(hh).position;
            rot = asset(ii).geometry(hh).rotate;
            asset(ii).geometry(hh).position = repmat(pos,1,uint8(assetPosList_tmp(ii).count));
            if isempty(rot)
                rot(:,1) = [0;1;0;0];
                rot(:,2) = [0;0;1;0];
                rot(:,3)   = [0;0;0;1];
            end
            asset(ii).geometry(hh).rotate = repmat(rot,1,uint8(assetPosList_tmp(ii).count));
            
            for jj = 1:length(assetPosList)
                position{gg} = assetPosList(jj).position;
                rotationY{gg} = assetPosList(jj).rotate;
                gg = gg+1;
            end
            assets_updated(ii).geometry(hh) = piAssetTranslate(asset(ii).geometry(hh),position,'instancesNum',n);
            assets_updated(ii).geometry(hh) = piAssetRotate(assets_updated(ii).geometry(hh),'Y',rotationY,'instancesNum',n);
            assets_updated(ii).fwInfo       = asset(ii).fwInfo;
        end
%     end
end
StreetPlaced = assets_updated;
end