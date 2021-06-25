function [coords,lookat,hdl] = piAssetGeometry(thisR,varargin)
% Find and plot the object coords in the world
%
% Synopsis
%  [coords,lookat,hdl] = piAssetGeometry(thisR,vararign)
%
% Input
%
% Optional key/val
%   size - Logical, add size to graph (default false)
%   name - Logical, add name to graph (default true)
%   position - World coordinates (default false)
%
% Outputs
%    coords
%    lookat
%    hdl
%
% To set the xz plane or xy plane views use
%   xz plane view(0,0)
%   xy plane view(0,90) or view(0,270)
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
   coords = piAssetGeometry(thisR,'size',true);
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

%% Parser
p = inputParser;
p.addRequired('thisR',@(x)(isa(x,'recipe')));
p.addParameter('size',false,@islogical);
p.addParameter('name',true,@islogical);
p.addParameter('position',false,@islogical);
p.parse(thisR,varargin{:});

%% Find the coordinates of the leafs of the tree (the objects)

coords = thisR.get('object coordinates');   % World coordinates, meters
names  = thisR.get('object simple names');  % We might do a better job with this.
shapesize = thisR.get('object sizes');
notes = cell(size(names));
for ii=1:numel(notes), notes{ii} = ' '; end   % Start them out empty

%% Include names
if p.Results.name
    for ii=1:numel(names)
        notes{ii} = sprintf('%s',names{ii});
    end
end

%% Add position
if p.Results.position
    for ii=1:numel(names)
        notes{ii} = sprintf('%s (%.1f %.1f %.1f)p ',notes{ii},coords(ii,1),coords(ii,2),coords(ii,3));
    end
    
end

%% Add size
if p.Results.size
    for ii=1:numel(names)
        notes{ii} = sprintf('%s (%.1f %.1f %.1f)s ',notes{ii},shapesize(ii,1),shapesize(ii,2),shapesize(ii,3));
    end
    
end

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
    text(coords(ii,1)+sx,coords(ii,2)+sy,coords(ii,3)+sz,notes{ii},'FontSize',14)
    hold on;
end

% The camera position (red) and where it is looking (green)
lookat = thisR.get('lookat');
plot3(lookat.from(1),lookat.from(2),lookat.from(3),'ro',...
    'Markersize',12,...
    'MarkerFaceColor','r');
text(lookat.from(1)+sx,lookat.from(2)+sy,lookat.from(3),'from','Color','r');

plot3(lookat.to(1),lookat.to(2),lookat.to(3),'go',...
    'Markersize',12,...
    'MarkerFaceColor','g');
text(lookat.to(1)+sx,lookat.to(2)+sy,lookat.to(3),'to','Color','g');

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
% legend({'objects','camera','to'})

%% By default set the xy plane view
view(0,270);

end


