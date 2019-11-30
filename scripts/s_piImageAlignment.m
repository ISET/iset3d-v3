%% Make a sensor image from the image alignment cases

%%
st = scitran('stanfordlabs');

%% Make the download path
fwDownloadPath = fullfile(piRootPath, 'local', date,'fwDownload');
if ~exist(fwDownloadPath,'dir'), mkdir(fwDownloadPath); end

%% Find the project and sessions

project = st.lookup('wandell/Graphics camera array');
sessions = project.sessions();

% 
labels = stCarraySlot(sessions,'subject','label');
lst = cellfun(@(x) isequal(x, 'image alignment'),labels,'uniform',false);
idx = find(cell2mat(lst))
thisSession = sessions{idx};
theseSessions = stSelect(sessions, 'label',thisSession.label);

tmp = st.search('sessions',...
    'project label exact','Graphics camera array',...
    'session label exact',thisSession.label, ...
    'subject code','renderings',...
    'fw',true);
renderedSession = tmp{1};

tmp = st.search('sessions',...
    'project label exact','Graphics camera array',...
    'session label exact',thisSession.label, ...
    'subject code','image alignment',...
    'fw',true);
pbrtSession = tmp{1};
pbrtSessionAcq = pbrtSession.acquisitions()
pbrtFiles = pbrtSessionAcq{1}.files
pbrtJSON = stSelect(pbrtFiles,'name','.json')
pbrtJSON{1}.download(fullfile(fwDownloadPath,...
                ['radiance', '.json']));

acquisitions = renderedSession.acquisitions();
for ii=1:numel(acquisitions)
    files = acquisitions{ii}.files();
    radFile = stSelect(files, 'name',...
        [pbrtSession.label, '_',acquisitions{ii}.label ,'.dat']);
    radFile{1}.download(fullfile(fwDownloadPath,...
                ['radiance_', acquisitions{ii}.label, '.dat']));
end

%% An example of how to process the first image

thisR = piJson2Recipe(fullfile(fwDownloadPath,...
                ['radiance','.json']));


oi = piDat2ISET(fullfile(fwDownloadPath,...
                ['radiance_', acquisitions{1}.label, '.dat']),'recipe',thisR);
oi = piFireFliesRemove(oi);

img = piSensorImage(oi,'file name','radiance.png','exp time',0.002);
imagescRGB(img)

%{
% oiWindow(oi);
sensor = sensorCreate;
sensor = sensorSetSizeToFOV(sensor,50);
sensor = sensorSet(sensor,'exp time',0.001);

sensor = sensorCompute(sensor,oi);
% sensorWindow(sensor);
ip = ipCreate;
ip = ipCompute(ip,sensor);
ipWindow(ip);
%}

%{
for ii=1:numel(labels)
    if isequal(labels{ii},'image alignment')
        disp(ii)
    end
end
%}

%% More modern approach

%% Get the oi down from Flywheel
st = scitran('stanfordlabs');

sessionName = 'city3_10:42_v0.0_f66.66front_o270.00_2019712204934';
acquisitionName = 'pos_0_0_0';
lu = sprintf('wandell/Graphics camera array/renderings/%s/%s',sessionName,acquisitionName);
acquisition = st.lookup(lu);
oi = piAcquisition2ISET(acquisition,st);
oi = piFireFliesRemove(oi);
oiWindow(oi);

sessionName = 'city3_10:42_v0.0_f66.66front_o270.00_2019712204934';
acquisitionName = 'pos_750_0_0';
lu = sprintf('wandell/Graphics camera array/renderings/%s/%s',sessionName,acquisitionName);
acquisition = st.lookup(lu);
oi = piAcquisition2ISET(acquisition,st);
oi = piFireFliesRemove(oi);
oiWindow(oi);

ip = piOI2IP(oi);
ipWindow(ip);
ieNewGraphWin; imagesc(ip.metadata.depthMap); axis image
ieNewGraphWin; imagesc(ip.metadata.meshImage); axis image
