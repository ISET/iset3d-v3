function asset = piAssetCreate(varargin)
% Create a struct of Flywheel assets
%
% Syntax:
%   asset = piAssetCreate([varargin])
%
% Description:
%    The assets are found on Flywheel. Each asset is stored with a generic
%    recipe that defines how to render it. The information about all of the
%    assets in the scene are placed in the returned asset struct. This has
%    slots like asset.bicycle()
%
% Inputs
%    None.
%
% Outputs:
%    assets - Struct. A structure with the asset geometries and materials.
%
% Optional key/value pairs:
%   ncars   - Numeric. The number of cars. Default 0.
%   ntrucks - Numeric. The number of trucks. Default 0.
%   nped    - Numeric. The number of pedestrians. Default 0.
%   nbuses  - Numeric. The number of buses. Default 0.
%   nbikes  - Numeric. The number of bikes. Default 0.
%   scitran - Object. A scitran object. Default []. If the default is
%             provided, then initates an instance of 'stanfordlabs'.
%

% History:
%    XX/XX/XX   Z   Zhenyi, Vistasoft Team, 2018
%    04/11/19  JNM  Documentation pass
%    04/18/19  JNM  Merge Master in (resolve conflicts)

%% Parse input parameters
varargin =ieParamFormat(varargin);

p = inputParser;
if length(varargin) > 1
    for i = 1:length(varargin)
        if ~(isnumeric(varargin{i}) | islogical(varargin{i}) | ...
                isobject(varargin{i}))
            varargin{i} = ieParamFormat(varargin{i});
        end
    end
else
    varargin = ieParamFormat(varargin);
end

p.addParameter('ncars', 0);
p.addParameter('ntrucks', 0);
p.addParameter('nped', 0);
p.addParameter('nbuses', 0);
p.addParameter('nbikes', 0); % Cyclist contains two class: rider and bike.
p.addParameter('resources', true)
p.addParameter('scitran', '', @(x)(isa(x, 'scitran')));

p.parse(varargin{:});

inputs = p.Results;
st = p.Results.scitran;

resources = p.Results.resources;
if ~resources, resources = false; else, resources = true; end
if isempty(st), st = scitran('stanfordlabs'); end

%%  Store up the asset information
project = st.lookup('wandell/Graphics assets');
asset = [];

%% Find the cars in the database
if p.Results.ncars > 0
    session = project.sessions.findOne('label=car');

    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(session, inputs.ncars, ...
        'resources', resources);

    % Analyze the downloaded scenes in fname and create the returned asset
    asset.car = piAssetAssign(assetRecipe, 'label', 'car');
end

%% Find the buses in the database
if p.Results.nbuses > 0
    session = project.sessions.findOne('label=bus');

    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(session, inputs.nbuses, ...
        'resources', resources);

    % Analyze the downloaded scenes in fname and create the returned asset
    asset.bus = piAssetAssign(assetRecipe, 'label', 'bus');
end

%% Find the trucks in the database
if p.Results.ntrucks > 0
    % Find the session with the label truck
    session = project.sessions.findOne('label=truck');

    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(session, inputs.ntrucks, ...
        'resources', resources);

    % Analyze the downloaded scenes in fname and create the returned asset
    asset.truck = piAssetAssign(assetRecipe, 'label', 'truck');
end

%% Get the people from the database
if p.Results.nped > 0
    % Find the session with the label pedestrian
    session = project.sessions.findOne('label=pedestrian');

    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(session, inputs.nped, ...
        'resources', resources);

    % Analyze the downloaded scenes in fname and create the returned asset
    asset.pedestrian = piAssetAssign(assetRecipe, 'label', 'pedestrian');
end

%% Get the bikes from the database
if p.Results.nbikes > 0
    % Find the session with the label bike
    session = project.sessions.findOne('label=bike');

    % Create Assets obj struct
    % Download random assets from flywheel
    assetRecipe = piAssetDownload(session, inputs.nbikes, ...
        'resources', resources);

    % Analyze the downloaded scenes in fname and create the returned asset
    asset.bicycle = piAssetAssign(assetRecipe, 'label', 'bike');
end

%%
disp('Assets are assembled!')

end
