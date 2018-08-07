function asset = piAssetCreate(varargin)
% Create and combine assets using base information from a recipe
%
% Inputs
%  thisR - A rendering recipe
%
% Optional key/value parameters
%   nCars
%   nTrucks
%   nPed
%   nBuses
%   nCyclist
%   scitran
%
% Returns
%   assets - Struct with the asset geometries and materials
%
% Zhenyi, Vistasoft Team, 2018

%% Parse input parameters
p = inputParser;
varargin = ieParamFormat(varargin);

p.addParameter('ncars',0);
p.addParameter('ntrucks',0);
p.addParameter('nPed',0);
p.addParameter('nbuses',0);
p.addParameter('nbuilding',0);
p.addParameter('ncyclist',0); % Cyclist contains two class: rider and bike.
p.addParameter('scitran','',@(x)(isa(x,'scitran')));

p.parse(varargin{:});

inputs = p.Results;
st     = p.Results.scitran;
if isempty(st), st = scitran('stanfordlabs'); end

%%  Store up the asset information

hierarchy = st.projectHierarchy('Graphics assets');

projects     = hierarchy.project;
sessions     = hierarchy.sessions;
acquisitions = hierarchy.acquisitions;

asset = [];

%% Find the cars in the database
if p.Results.ncars > 0
    % Find the session with the label car
    for ii=1:length(sessions)
        if isequal(lower(sessions{ii}.label),'car')
            carSession = sessions{ii};
            break;
        end
    end
    
    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(carSession,'car',inputs.ncars,'scitran',st);
    
    % Analyze the downloaded scenes in fname and create the returned asset
    asset.car = piAssetAssign(assetRecipe,'label','car');
end
%% Find the buses in the database
if p.Results.nbuses > 0
    % Find the session with the label car
    for ii=1:length(sessions)
        if isequal(lower(sessions{ii}.label),'bus')
            busSession = sessions{ii};
            break;
        end
    end
    
    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(busSession,'bus',inputs.nbuses,'scitran',st);
    
    % Analyze the downloaded scenes in fname and create the returned asset
    asset.bus = piAssetAssign(assetRecipe,'label','bus');
end

%% Find the buses in the database
if p.Results.ntrucks > 0
    % Find the session with the label car
    for ii=1:length(sessions)
        if isequal(lower(sessions{ii}.label),'truck')
            truckSession = sessions{ii};
            break;
        end
    end
    
    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(truckSession,'truck',inputs.ntrucks,'scitran',st);
    
    % Analyze the downloaded scenes in fname and create the returned asset
    asset.truck = piAssetAssign(assetRecipe,'label','truck');
end

%% Get the people from the database
if p.Results.nPed > 0
    % Find the session with the label car
    for ii=1:length(sessions)
        if isequal(lower(sessions{ii}.label),'pedestrian')
            pedestrianSession = sessions{ii};
            break;
        end
    end
    
    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(pedestrianSession,'pedestrian',inputs.nPed,'scitran',st);
    
    % Analyze the downloaded scenes in fname and create the returned asset
    asset.pedestrian = piAssetAssign(assetRecipe,'label','pedestrian');
end

%% Get building from the database
if p.Results.nbuilding > 0
    % Find the session with the label car
    for ii=1:length(sessions)
        if isequal(lower(sessions{ii}.label),'building')
            pedestrianSession = sessions{ii};
            break;
        end
    end
    
    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(pedestrianSession,'building',inputs.nbuilding,'scitran',st);
    
    % Analyze the downloaded scenes in fname and create the returned asset
    asset.building = piAssetAssign(assetRecipe,'label','building');
end
%%
disp('All done!')

end
