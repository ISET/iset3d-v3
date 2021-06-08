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

%% Open a figure to plot

% We should have no plot switch
hdl = ieNewGraphWin;

% The object coords
plot3(coords(:,1),coords(:,2),coords(:,3),'ko','MarkerSize',10,'MarkerFaceColor','k');
hold on;

% The camera position (red) and where it is looking (green)
lookat = thisR.get('lookat');
plot3(lookat.from(1),lookat.from(2),lookat.from(3),'ro',...
    'Markersize',12,...
    'MarkerFaceColor','r');
plot3(lookat.to(1),lookat.to(2),lookat.to(3),'go',...
    'Markersize',12,...
    'MarkerFaceColor','g');
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


