function thisR = piRecipeTranslate(thisR,origin)
%  Deprecated.  Use piRecipeRectify.
% Move the camera and objects so that the camera is at origin
%
%
% See also
%

% Examples
%{
 thisR = piRecipeDefault('scene name','simple scene');
 piAssetGeometry(thisR);
 origin = [0 0 0];
 thisR = piRecipeTranslate(thisR,origin);
 piAssetGeometry(thisR);
 thisR.show('objects');
%}

%% Find the camera position
from = thisR.get('from');

%% Move the camera to the specified origin

d = origin - from;
piCameraTranslate(thisR,'xshift',d(1), ...
    'yshift',d(2), ...
    'zshift',d(3));

% Try replacing with the rectify method, where we insert the rectify node.
objects = thisR.get('objects');
for ii=1:numel(objects)
    thisR.set('asset',objects(ii),'translate',d);
end

end
