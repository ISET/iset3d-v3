%% Draft script
%
% Find a session and acquisition in Flywheel with rendered images
%
% Download the rendered data (from PBRT) and assemble them into an ISETCam
% IP with the metadata
%

%%
st = scitran('stanfordlabs');
chdir(fullfile(piRootPath,'local'));

%% Set a session and acquisition

subjectName = 'camera array';

lu = sprintf('wandell/Graphics camera array/%s', subjectName);
subject = st.lookup(lu);
sessions = subject.sessions();

for ss=1:numel(sessions)
    chdir(fullfile(piRootPath,'local'));

    sessionName = sessions{ss}.label;
    lu = sprintf('wandell/Graphics camera array/%s/%s', subjectName,sessionName);
    thisSession = st.lookup(lu);
    acquisitions = thisSession.acquisitions();
    
    ee = 0;   % Error counter
    for aa = 1:numel(acquisitions)

        delete('city*');

        %%  Download and build up the OI
        acquisitionName = acquisitions{aa}.label;
        lu = sprintf('wandell/Graphics camera array/renderings/%s/%s',sessionName,acquisitionName);
        try
            acquisition = st.lookup(lu);
            oi = piAcquisition2ISET(acquisition,st);  % Note:  Remove dat files when done.
            oi = piFireFliesRemove(oi);
            % oiWindow(oi);
            
            %% Convert the oi into an IP
            
            ip = piOI2IP(oi);
            %{
             ipWindow(ip);
             ieNewGraphWin; imagesc(ip.metadata.depthMap); axis image
             ieNewGraphWin; imagesc(ip.metadata.meshImage); axis image
            %}
            
            %% Save out the corresponding images as PNG files
            
            savePath = fullfile(piRootPath,'local','stereo');
            if ~exist(savePath,'dir'), mkdir(savePath); end
            chdir(savePath);
            thisDir = sprintf('%s',sessionName);
            if ~exist(thisDir,'dir'), mkdir(thisDir); end
            chdir(thisDir);
            
            rgb = ipGet(ip,'srgb');
            this = strrep(strrep(datestr(now),' ','-'),':','');
            
            imwrite(rgb,[this,'-radiance.png'])
            imwrite(ieScale(ip.metadata.depthMap,0,1),[this,'-depth.png'])
            imwrite(ieScale(ip.metadata.meshImage),[this,'-mesh.png'])
            
            depthMap   = ip.metadata.depthMap;
            meshNumber = ip.metadata.meshImage;
            meshLabel  = ip.metadata.meshtxt;
            save([this,'-metadata']','depthMap','meshNumber','meshLabel');
            fprintf('++++ Succeeded with session %s acq %s\n',sessionName,acquisitionName);

        catch
            % Mis-match in the acquisiton and rendering labels
            ee = ee + 1;
            eList{ee} = sprintf('**** Error session %s acq %s\n',sessionName,acquisitionName); %#ok<SAGROW>
            disp(eList{ee});
        end
        
    end
end


%%