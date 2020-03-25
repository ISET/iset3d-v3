%% ieGCPInit
%
% Initialize the local environment for running on the GCP platform
%
% Checks that Docker, gCloud and scitran are on your path.
% Initializes.
%
% Zheng, Brian 2019
%
% See also

% Programming TODO
%   Check if the cluster is already running, or being deleted, and
%   handle those cases.  It could be the already running case is fine.
%   But if it is being deleted, we can tell because the status value
%   of 'STOPPING' is returned.
%
%   We might turn this into a function and take the dockerimage name
%   as an argument to allow for 'latest' or 'flywheel-dev' or
%   something else in the future.
%

%%  Initialize ISETcam
ieInit;

% We need Docker
if ~piDockerExists, piDockerConfig; end

% The isetcloud toolbox must be on your path
if ~mcGcloudExists, mcGcloudConfig; end

%% Open a connection to the Flywheel scitran site

% The scitran toolbox must be on your path
st = scitran('stanfordlabs');

%% Initialize the GCP cluster

tic
gcp = gCloud('configuration','cloudRendering-pbrtv3-west1-custom-50-56320-flywheel',...
        'dockerimage', 'gcr.io/primal-surfer-140120/pbrt-v3-spectral-flywheel-dev-zhenyi');

toc
gcp.renderDepth = 1;  % Create the depth map
gcp.renderMesh  = 1;  % Create the object mesh for subsequent use
gcp.targets     = []; % clear job list

%% Print out the gcp parameters for the user if they want it.

% We could check that this has the string status: 'RUNNING'
str = gcp.configList;

%% END