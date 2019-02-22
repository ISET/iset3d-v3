function asset = piAssetCreate(varargin)
% Create a struct of Flywheel assets 
%
% Description
%  The assets are found on Flywheel.  Each asset is stored with a
%  generic recipe that defines how to render it. The information about
%  all of the assets in the scene are placed in the returned asset
%  struct. This has slots like asset.bicycle()
%
% Inputs
%   N/A
%
% Optional key/value parameters
%   ncars
%   ntrucks
%   nped
%   nbuses
%   ncyclist
%   scitran
%
% Returns
%   assets - Struct with the asset geometries and materials
%
% Zhenyi, Vistasoft Team, 2018

%% Parse input parameters
p = inputParser;
if length(varargin) > 1
    for i = 1:length(varargin)
        if ~(isnumeric(varargin{i}) | islogical(varargin{i}))
            varargin{i} = ieParamFormat(varargin{i});
        end
    end
else
    varargin =ieParamFormat(varargin);
end

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

hierarchy = st.projectHierarchy('Graphics assets');

projects     = hierarchy.project;
sessions     = hierarchy.sessions;
acquisitions = hierarchy.acquisitions;

asset = [];

%% Find the cars in the database
if p.Results.ncars > 0
    for ii=1:length(sessions)
        if isequal(lower(sessions{ii}.label),'car')
            carSession = sessions{ii};
            break;
        end
    end
    
    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(carSession,inputs.ncars,'resources',resources,'scitran',st);
    
    % Analyze the downloaded scenes in fname and create the returned asset
    asset.car = piAssetAssign(assetRecipe,'label','car');
end
%% Find the buses in the database
if p.Results.nbuses > 0
    for ii=1:length(sessions)
        if isequal(lower(sessions{ii}.label),'bus')
            busSession = sessions{ii};
            break;
        end
    end
    
    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(busSession,inputs.nbuses,'resources',resources,'scitran',st);
    
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
    assetRecipe = piAssetDownload(truckSession,inputs.ntrucks,'resources',resources,'scitran',st);
    
    % Analyze the downloaded scenes in fname and create the returned asset
    asset.truck = piAssetAssign(assetRecipe,'label','truck');
end

%% Get the people from the database
if p.Results.nped > 0
    % Find the session with the label car
    for ii=1:length(sessions)
        if isequal(lower(sessions{ii}.label),'pedestrian')
            pedestrianSession = sessions{ii};
            break;
        end
    end
    
    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(pedestrianSession,inputs.nped,'resources',resources,'scitran',st);
    
    % Analyze the downloaded scenes in fname and create the returned asset
    asset.pedestrian = piAssetAssign(assetRecipe,'label','pedestrian');
end
%% Get the bikes from the database
if p.Results.nbikes > 0
    % Find the session with the label car
    for ii=1:length(sessions)
        if isequal(lower(sessions{ii}.label),'bike')
            bikeSession = sessions{ii};
            break;
        end
    end
    
    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(bikeSession,inputs.nbikes,'resources',resources,'scitran',st);
    
    % Analyze the downloaded scenes in fname and create the returned asset
    asset.bicycle = piAssetAssign(assetRecipe,'label','bike');
end


%%
disp('Assets are assembled!')

end
