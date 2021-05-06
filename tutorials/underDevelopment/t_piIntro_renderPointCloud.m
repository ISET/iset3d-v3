
% This was in t_piIntro_assetmotion, and didn't really below there.
% Sticking here in case someone wants to develop a tutorial about rendering
% point clouds, whatever they are.  DHB.


%{
% Just showing off that we can do some stuff with point clouds.
% Not sure why this is here!

 coordMap = piRender(thisR,'renderType','coordinates');
 coordMap((coordMap(:,:,1)==0) & (coordMap(:,:,2)==0) & (coordMap(:,:,3)==0)) = NaN;
 x  = coordMap(:,:,1) - thisR.lookAt.from(1);
 y  = coordMap(:,:,2) - thisR.lookAt.from(2);
 z  = coordMap(:,:,3) - thisR.lookAt.from(3);

 player = pcplayer([min(x(:)), nanmax(x(:))],...
                   [min(z(:)), nanmax(z(:))],...
                   [min(y(:)), nanmax(y(:))]);
ptCloud = pointCloud([x(:),z(:),y(:)]);
view(player,ptCloud);

%}