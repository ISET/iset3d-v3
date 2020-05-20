%% Scratch space for working out some Flywheel search and download interactions
%
% These will be for 
%


st = scitran('stanfordlabs');
status  = st.verify;

project = st.lookup('wandell/Graphics auto renderings');
sessions = project.sessions();

stPrint(sessions,'label')


% scene_pbrt contains the recipes

%% The renderings
thisSession = project.sessions.findOne('label=city1');
acq = thisSession.acquisitions();
numel(acq)

%%
% These are all the scenes that are rendered.  To find the
% correspondence between the scene here and a rendering, we use the
% label of the acquisition.
thisSession = project.sessions.findOne('label=scenes_pbrt');
acq = thisSession.acquisitions();

numel(acq)

%% This one might be deprecated
thisSession = project.sessions.findOne('label=scene_pbrt');
acq = thisSession.acquisitions();
numel(acq)

%%
thisSession.acquisiti

thisSession = project.sessions.findOne('label="20150627_2219"');

theseSessions = project.sessions.find('label="20150627_2219"');

acquisitions = thisSession.acquisitions();

theseFiles = acquisitions{1}.files;



