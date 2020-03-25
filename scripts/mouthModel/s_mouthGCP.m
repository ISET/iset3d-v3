%% Create and upload PBRT files to flywheel
%
%   s_mouthUpload.m
%
% Description
%
%
% Author:
%
% See also
%
%
%

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
if ~mcGcloudExists, mcGcloudConfig; end

%% Open the Flywheel site
st = scitran('stanfordlabs');

%% initialize GCP cluster
tic
gcp = gCloud('configuration','cloudRendering-pbrtv3-central-standard-32cpu-120m-flywheel');
toc

% Print out the gcp parameters for the user
str = gcp.configList;

%% Connect to the asset
% st.lookup follows the syntax of:
% groupID/projectLabel/subjectLabel/sessionLabel/acquisitionLabel

% Here an acquisition that contains a scene on Flywheel
group   = 'oraleye';
project = 'Dental simulations';
subject = 'assets';
session = 'mouth';
acq     = 'mouth_001'; 

subjectStr = sprintf('%s/%s/%s',group, project, subject);
acqString  = sprintf('%s/%s/%s/%s/%s',group, project, subject, session, acq);



subject = st.lookup(subjectStr);
sessions = subject.sessions();
thisAcq = st.lookup(acqString);

%% Download the assets
nassets = 1;

assetRecipe = piAssetDownload(sessions{1}, nassets,'acquisitionlabel', acq);
%% Read out the render recipe
thisR = piJson2Recipe(assetRecipe{1}.name);

%% Create the fwInfo list
assets.fwList = assetRecipe{1}.fwInfo;

%% upload the pbrt files 

newSubject = 'mouth001';
newSession = 'scene_mouth001';
newAcq     = 'test001';
gcp.fwUploadPBRT(thisR,'scitran',st,...
    'road',assets, ...
    'render project lookup', fullfile(group, project), ...
    'session label',newSession, ...
    'subject label',newSubject, ...
    'acquisition label',newAcq);
%% Check the list

%% Render the scene

%% Download files from Flywheel

%% Show the scene

%% Remove jobs

%% Close the cluster



