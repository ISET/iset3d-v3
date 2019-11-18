%% ieGCPInit
%
% Initialize the local environment for running on the GCP platform
%
% Checks that Docker, gCloud and scitran are on your path.
% Initializes.
%
% Zheng, Brian 2019

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
        'dockerimage', 'gcr.io/primal-surfer-140120/pbrt-v3-spectral-flywheel-dev');

toc
gcp.renderDepth = 1;  % Create the depth map
gcp.renderMesh  = 1;  % Create the object mesh for subsequent use
gcp.targets     = []; % clear job list

%% Print out the gcp parameters for the user if they want it.

str = gcp.configList;

%% END