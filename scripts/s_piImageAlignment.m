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
pbrtJSON{1}.download('radiance.json');

acquisitions = renderedSession.acquisitions();
for ii=1:numel(acquisitions)
    files = acquisitions{ii}.files();
    files{2}.download(fullfile(fwDownloadPath,...
                ['radiance_', acquisitions{ii}.label, '.dat']));
end

thisR = piJson2Recipe(fullfile(fwDownloadPath,...
                ['radiance_', acquisitions{ii}.label, '.json']));

oi = piDat2ISET('radiance.dat','recipe',thisR);
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

