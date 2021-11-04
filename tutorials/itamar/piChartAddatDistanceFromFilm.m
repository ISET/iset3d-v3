function thisR = piChartAddatDistanceFromFilm(thisR,distanceFromFilm,positionXY,scalefactor)
  % Position XY: on the object plane
  % If not given choose one
    if nargin < 4
    scalefactor=  1;
  end
 
  
% FIlm position might not be at origin,
% We assume optical axis on z axis
    
    % Set camera and camera position and direction. Pointing along z axis.
thisR.lookAt.from= [0 0 0];
thisR.lookAt.to = thisR.lookAt.from+[0 0 1];
filmZPosition=thisR.lookAt.from(3); 

% Load slantedbar asset
sbar = piAssetLoad('slantedbar');


% Merge with given recipe
thisR=piRecipeMerge(thisR,sbar.thisR,'node name',sbar.mergeNode);


% Set scale to same as world coordinate system
initialScale=sbar.thisR.assets.Node{3}.scale{1};

% PATCH: Adding the same asset multiple times makes mergenode na,me
% nonunique. Although when adding a prefix is added, we do not have that
% prefix
%To implement ( from zhemg) [~, newName] = piObjectInstanceCreate(thisR, 'colorChecker_B');


findIDWithPostfix=piAssetFind(thisR,'name','slantedbar-6680_G');
lastID=findIDWithPostfix(end); % latest is the one we added
newName=thisR.assets.Node{lastID}.name;


thisR.set('node', newName, 'scale', 1./initialScale);  % Undo initial scaling


thisR.set('node', newName, 'world position', [positionXY distanceFromFilm+filmZPosition]);  %  Translate to desired position

newScale=[0.2*initialScale(1:3)]*scalefactor  *distanceFromFilm/(2-filmZPosition); % This makes sure the size of the image remains approx identical whenplaced at different depths .
% Normally the further away the smaller
thisR.set('node', newName, 'scale', newScale);  % Rescale as desired

end