function [coords,lookat,hdl] = piAssetGeometry(thisR)
% Find and plot the object coords in the world
%
% TODO:  Turn off plotting
%    Understand why macbethChecker does not work.
%
% Synopsis
%  [coords,lookat,hdl] = piAssetGeometry(thisR)
% Input
%
% Outputs
%    coords
%    lookat
%    hdl
%
% See also
%  thisR.get('objects')
%

% Examples:
%{
   thisR = piRecipeDefault('scene name','simplescene');
   coords = piAssetGeometry(thisR);
%}
%{
   thisR = piRecipeDefault('scene name','chessset');
   coords = piAssetGeometry(thisR);
%}
%{
   thisR = piRecipeDefault('scene name','macbethchecker');
   coords = piAssetGeometry(thisR);
%}

%%  Check that we have assets
if isempty(thisR.assets)
    warning('No assets stored in the recipe');
    coords = [];
    return;
end

%% Find the coordinates of the leafs of the tree (the objects)

coords = thisR.get('object coordinates');   % World coordinates, meters
names  = thisR.get('object simple names');  % We might do a better job with this.

%% Open a figure to plot

% We should have no plot switch
hdl = ieNewGraphWin;

% Shift is a few percent of the range.  This should become a parameter
sx = (max(coords(:,1)) - min(coords(:,1)))*0.04;
sy = (max(coords(:,2)) - min(coords(:,2)))*0.04;
sz = (max(coords(:,3)) - min(coords(:,3)))*0.04;

% The object coords
for ii=1:numel(names)
    plot3(coords(ii,1),coords(ii,2),coords(ii,3),'ko','MarkerSize',10,'MarkerFaceColor','k');
    text(coords(ii,1)+sx,coords(ii,2)+sy,coords(ii,3)+sz,names{ii},'FontSize',14)
    hold on;
end

% The camera position (red) and where it is looking (green)
lookat = thisR.get('lookat');
plot3(lookat.from(1),lookat.from(2),lookat.from(3),'ro',...
    'Markersize',12,...
    'MarkerFaceColor','r');
text(lookat.from(1)+sx,lookat.from(2)+sy,lookat.from(3),'from');

plot3(lookat.to(1),lookat.to(2),lookat.to(3),'go',...
    'Markersize',12,...
    'MarkerFaceColor','g');
text(lookat.to(1)+sx,lookat.to(2)+sy,lookat.to(3),'to');

line([lookat.from(1),lookat.to(1)],...
    [lookat.from(2),lookat.to(2)],...
    [lookat.from(3),lookat.to(3)],'Color','b',...
    'Linewidth',3);

%% Label the graph

xlabel('x coord (m)'); ylabel('y coord (m)'); zlabel('z coord (m)');
grid on

bName = thisR.get('input basename');
oType = thisR.get('optics type');
title(sprintf('%s (%s)',bName,oType));
legend({'objects','camera','to'})
end


