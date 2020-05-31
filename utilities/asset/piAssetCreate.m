function obj = piAssetCreate(varargin)
% Create a struct defining a graphics object in recipe
%
% Synopsis
%  asset = piAssetCreate(varargin)
%
% Brief description
%  The objects form a tree within the thisR.assets.  They define the
%  rotations, translations and material properties of the object either at
%  the node level or at the individual leafs of the tree.  The material
%  properties are usually in the leafs, and the transformations apply from
%  the nodes on down and are concatenated.
%
%  The original form of this function downloaded assets from flywheel and
%  assembled them into an asset structure.  That has been renamed to
%  piFWAssetCreate();
%
% ZLY, BW
%
% See also
%   piFWAssetCreate;

% Examples:
%{
  % Small tree of graphics objects
  obj(1) = piAssetCreate;
  obj(2) = piAssetCreate;
  obj(1).obj = piAssetCreate;
%}

%%
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
obj.index = [];
obj.mediumInterface = [];
obj.material = [];
obj.light = [];
obj.areaLight = [];
obj.shape = {};
obj.output = {};

%{
% Set the parameters requested by the user
if ~isempty(varargin)
    for ii=1:2:numel(varargin)
       obj = piAssetSet(obj,varargin{ii},varargin{ii+1});
    end
%}

end
%
%{
%% Parse input parameters
varargin =ieParamFormat(varargin);

p = inputParser;

p.addParameter('ncars',0);
p.addParameter('ntrucks',0);
p.addParameter('nped',0);
p.addParameter('nbuses',0);
p.addParameter('nbikes',0); % Cyclist contains two class: rider and bike.
p.addParameter('resources',true)
p.addParameter('scitran','',@(x)(isa(x,'scitran')));

p.parse(varargin{:});

inputs = p.Results;
st     = p.Results.scitran;

resources = p.Results.resources;
if resources== 0
    resources = false;
else
    resources = true;
end
if isempty(st), st = scitran('stanfordlabs'); end

%%  Store up the asset information

project = st.lookup('wandell/Graphics auto');
asset = [];

%% Find the cars in the database
if p.Results.ncars > 0
    session = project.sessions.findOne('label=car');
    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(session,inputs.ncars,'resources',resources);
    
    % Analyze the downloaded scenes in fname and create the returned asset
    asset.car = piAssetAssign(assetRecipe,'label','car');
end
%% Find the buses in the database
if p.Results.nbuses > 0
    session = project.sessions.findOne('label=bus');
    
    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(session,inputs.nbuses,'resources',resources);
    
    % Analyze the downloaded scenes in fname and create the returned asset
    asset.bus = piAssetAssign(assetRecipe,'label','bus');
end

%% Find the buses in the database
if p.Results.ntrucks > 0
    % Find the session with the label car
    session = project.sessions.findOne('label=bus');
    
    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(session,inputs.ntrucks,'resources',resources);
    
    % Analyze the downloaded scenes in fname and create the returned asset
    asset.truck = piAssetAssign(assetRecipe,'label','truck');
end

%% Get the people from the database
if p.Results.nped > 0
    % Find the session with the label car
    session = project.sessions.findOne('label=pedestrian');
    
    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(session,inputs.nped,'resources',resources);
    
    % Analyze the downloaded scenes in fname and create the returned asset
    asset.pedestrian = piAssetAssign(assetRecipe,'label','pedestrian');
end
%% Get the bikes from the database
if p.Results.nbikes > 0
    % Find the session with the label car
    session = project.sessions.findOne('label=bike');
    
    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(session,inputs.nbikes,'resources',resources);
    
    % Analyze the downloaded scenes in fname and create the returned asset
    asset.bicycle = piAssetAssign(assetRecipe,'label','bike');
end


%%
disp('Assets are assembled!')

end
%}
