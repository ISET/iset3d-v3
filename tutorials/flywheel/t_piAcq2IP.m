%% Convert rendered data to an IP
%
% Description
%   Find a Flywheel session and acquisition with PBRT rendered images.
%   Download the rendered data and assemble them into an ISETCam IP with
%   the metadata.
%
%   We can save these locally for zipping and handing out to students.
%   For example we created AlignmentData.zip file on the Canvas site.
%
% See also
%   s_piAlignmentAcquisition2IP
%
% Wandell, 12/2019

%%
st = scitran('stanfordlabs');

% One of the 10 sessions
ss = 2;

% One of the acquisitions in that session
aa = 2;

%% Set a session and acquisition

% The rendered data are stored as this subject
renderSubject = 'image alignment render';
lu = sprintf('wandell/Graphics camera array/%s',renderSubject);
subject = st.lookup(lu);

% The sessions for this subject are the rendered data.
sessions = subject.sessions();
fprintf('Found %d sessions in the render subject.\n',numel(sessions));

%% For each session
chdir(fullfile(piRootPath,'local'));

sessionName = sessions{ss}.label;
lu = sprintf('wandell/Graphics camera array/%s/%s',renderSubject,sessionName);
thisSession = st.lookup(lu);

% Find the acquisitions.  These are rendereding from different
% camera positions
acquisitions = thisSession.acquisitions();
fprintf('Found %d acquisitions for session %s\n',numel(acquisitions),sessionName);
stPrint(acquisitions,'label');

% Remove old downloaded dat-files.
chdir(fullfile(piRootPath,'local'));
delete('city*');

%%  Download and build up the OI
acquisitionName = acquisitions{aa}.label;

lu = sprintf('wandell/Graphics camera array/%s/%s/%s',renderSubject,sessionName,acquisitionName);
thisAcquisition = st.lookup(lu);

%% Download and read the files 

% Go to Flywheel to download into the local directory
oi = piAcquisition2ISET(thisAcquisition,st);  % Note:  Remove dat files when done.

% The returned oi can have some rendering artifacts.  We clean them
% here.
oi = piFireFliesRemove(oi);
% oiWindow(oi);

%% Convert the oi into an IP
pixelSize = 3;           % Microns
ip = piOI2IP(oi,'pixel size',pixelSize);

%%
ipWindow(ip); ipSet(ip,'gamma',0.7);truesize;  

ieNewGraphWin; imagesc(ip.metadata.depthMap); axis image; colorbar;
ieNewGraphWin; imagesc(ip.metadata.meshImage); axis image; colorbar;

%% END