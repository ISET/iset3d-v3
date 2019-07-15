function thisR = piGeometryReadBlender(thisR)
% read geometry file exported using obj2pbrt exporter, or blender2pbrt
% currently, the file format follows the file used in this website:
%              https://benedikt-bitterli.me/resources/
% More to be tested.
% thisR: render recipe
% Zhenyi, SCIEN, 2019
%%
MaterialDefineList = find(piContains(thisR.world, 'MakeNamedMaterial'));
mlist = find(piContains(thisR.world, 'NamedMaterial'));
mlist(1:length(MaterialDefineList)) = [];
% for now, only lights using attributebegin/end pairs, will use in the
% future if other cases use this string pairs.
attributeList = find(piContains(thisR.world, 'attribute'));
%% read geometry information
for ii = 1:(length(mlist)-1)
    %List includes all the following transformation and geometry
    %information
    thisMat = thisR.world(mlist(ii):(mlist(ii+1)-1));
    % shape list
    glist = find(piContains(thisMat, 'Shape'));
    % transformlist
    tlist = find(piContains(thisMat, 'Transform'));
    
    for jj = 1:length(glist)
        thisLine = textscan(thisMat{glist(jj)}, '%q');thisLine = thisLine{1};
        thisLine(piContains(thisLine, '['))=[];
        thisLine(piContains(thisLine, ']'))=[];
        assets(ii).name = sprintf('foo_%d', ii);
        assets(ii).rotate = [];
        assets(ii).position = [0;0;0];
        assets(ii).size = [];
        assets(ii).children(jj).index = jj;
        assets(ii).children(jj).name = sprintf('foo_%d', jj);
        assets(ii).children(jj).mediumInterface = [];
        assets(ii).children(jj).material = thisMat{1};
        assets(ii).children(jj).output = thisMat{glist(jj)};
    end
    if tlist
        for kk = 1:3:length(tlist)
            tmp = thisMat{tlist(kk+1)};
            tmp  = textscan(tmp, '%s [%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f]');
            values = cell2mat(tmp(2:end));
            transform = reshape(values,[4,4]);
            dcm = [transform(1:3);transform(5:7);transform(9:11)];
            
            [rotz,roty,rotx]= piDCM2angle(dcm);
            rotx = rotx*180/pi;
            roty = roty*180/pi;
            rotz = rotz*180/pi;
            
            assets(ii).rotate(:,3)   = [rotx;1;0;0];
            assets(ii).rotate(:,2)   = [roty;0;1;0];
            assets(ii).rotate(:,1)   = [rotz;0;0;1];
            assets(ii).position = reshape(transform(13:15),[3,1]);
        end
    end
end
thisR.assets = assets;

end