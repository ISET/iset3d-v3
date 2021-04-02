function thisR = piRecipeUpdateAssets(thisRV1)
% Rearrange the assets in V1 format into V2 format
%
% Description:
%   Rearrange the assets with the new structure to make the old recipe
%   compatible. 
%
%%
p = inputParser;
p.addRequired('thisRV1', @(x)isequal(class(x), 'recipe'));
p.parse(thisRV1);

%% Make sure the modern fields exist in all assets in the old format recipe
fieldList = {"name", "index", "mediumInterface", "material",...
                "light", "areaLight", "shape", "output", "motion", "scale"};
for ii = 1:numel(thisR.assets)
    thisR.assets(ii).groupobjs = [];
    thisR.assets(ii).scale = [1, 1, 1];
    if isempty(thisR.assets(ii).rotate)
        thisR.assets(ii).rotate = [0 0 0;
                                   0 0 1;
                                   0 1 0;
                                   1 0 0];
    end
    for jj = 1:numel(thisR.assets(ii).children)
        for kk = 1:numel(fieldList)
            if strcmp(fieldList{kk}, "scale")
                thisR.assets(ii).children(jj).(fieldList{kk}) = [1, 1, 1];
            end
            if ~isfield(thisR.assets(ii).children(jj), fieldList{kk})
                thisR.assets(ii).children(jj).(fieldList{kk}) = [];
            end
        end
    end
end


%% The old assets are flat structure. 
% We created a root node and put all the old assets into the groupobj. So
% when new assets are created from the old ones, they will always be flat.
% You'll have to rearrange if you want them to be hierarcichal.

newAssets = createGroupObject();
newAssets.name = 'root';
newAssets.groupobjs = thisR.assets; % All the assets in the first and only level
thisR.assets = newAssets;

end

function obj = createGroupObject()

% Initialize a structure representing a group object.

obj.name = [];
obj.size.l = 0;
obj.size.w = 0;
obj.size.h = 0;
obj.size.pmin = [0 0];
obj.size.pmax = [0 0];
obj.scale = [1 1 1];
obj.position = [0 0 0];
obj.rotate = [0 0 0;
              0 0 1;
              0 1 0;
              1 0 0];

obj.children = [];
obj.groupobjs = [];
          

end