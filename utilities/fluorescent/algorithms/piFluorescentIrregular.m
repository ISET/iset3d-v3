function piFluorescentIrregular(thisR, TR, childGeometryPath, txtLines, base,...
                            location,varargin)
%% In progress

%% Create pattern
m = 100;

s = fbm(m);
s = (s - min(min(s))) / (max(max(s)) - min(min(s)));
s(s>0.5 & s <= 1) = 1;
s(s>0.1 & s <= 0.5) = 0;
s(s>=0 & s <=0.1) =0;

%{
figure;
imshow(s);
%}

%%

cc = bwconncomp(s, 4);
thisCells = cc.PixelIdxList;
maxPixel = thisCells{cellfun('length', thisCells) == max(cellfun('length', thisCells))};

demoImg = zeros(m);
demoImg(maxPixel) = 1;

%{
figure;
imshow(demoImg)
%}
%% Add the toolbox
addpath(fullfile(piRootPath, 'local', 'im2mesh','mesh2d-master'));

%% Core part
%%
im = demoImg;
% parameters
dx = 1; dy = 1;     % for scaling in im2Bounds
                    % dx - column direction, dy - row direction
                    % e.g. scale of your imgage is 0.11 mm/pixel, try
                    %      dx = 0.11; and dy = 0.11;

tf_avoid_sharp_corner = false;  % for getCtrlPnts
                                % true or false, depend on your image
                                % Add two extra control points around 
                                % one original control point to avoid 
                                % sharp corner when simplifying
                                % polygon. Sharp corner in some cases
                                % will make poly2mesh not able to
                                % converge.

tolerance = 1.;    % for dpsimplify in simplifyBounds
                    % check Douglas-Peucker algorithm
                    % If u don't need to simplify, try tolerance = eps
                    % If value of tolerance is too large, some polygons
                    % will become line segment after simplification,
                    % these polygons will be deleted by delZeroAreaPoly

hmax = size(TR, 1) / 2;         % for poly2mesh, affact maximum mesh-size

% main
bounds1 = im2Bounds( im, dx, dy );
bounds2 = getCtrlPnts( bounds1, tf_avoid_sharp_corner );
% plotBounds( bounds2 );

bounds3 = simplifyBounds( bounds2, tolerance );
bounds3 = delZeroAreaPoly( bounds3 );
% plotBounds( bounds3 );

% clear up redundant vertices
% only control points and knick-points will remain
bounds4 = getCtrlPnts( bounds3, false );
bounds4 = simplifyBounds( bounds4, eps );
% you can insert control points into bounds4 manually, in order to
% define boundary condition, e.g., middle point at the bottom of image

[ node_cell, edge_cell ] = genNodeEdge( bounds4 );
[ vert,tria,tnum ] = poly2mesh( node_cell, edge_cell, hmax );
% plotMeshes( vert, tria, tnum );

%{
% show result
imshow( im,'InitialMagnification','fit' );
plotBounds( bounds2 );
plotBounds( bounds4 );
plotMeshes( vert, tria, tnum );
drawnow;
set(figure(1),'units','normalized', ...
    'position',[.05,.50,.30,.35]);
set(figure(2),'units','normalized', ...
    'position',[.35,.50,.30,.35]);
set(figure(3),'units','normalized', ...
    'position',[.05,.05,.30,.35]);
set(figure(4),'units','normalized', ...
    'position',[.35,.05,.30,.35]);
%}

%% Create triangulation mesh
trPattern = triangulation(tria, vert);

TR1 = triangulation(tria(tnum == 1,:),vert);
TR2 = triangulation(tria(tnum == 2,:),vert);

triplot(TR2);


end