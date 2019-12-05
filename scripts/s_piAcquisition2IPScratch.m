%% Draft script
%
% Find a session and acquisition in Flywheel with rendered images
%
% Download the rendered data (from PBRT) and assemble them into an ISETCam
% IP with the metadata
%

%%
st = scitran('stanfordlabs');

%% Set a session and acquisition

subjectName = 'camera array';

lu = sprintf('wandell/Graphics camera array/%s', subjectName);
subject = st.lookup(lu);

% Scene sessions.  There are matching render sessions
sessions = subject.sessions();   
fprintf('Found %d sessions in the render subject area\n',numel(sessions));

%%
for ss=1:numel(sessions)
    chdir(fullfile(piRootPath,'local'));

    sessionName = sessions{ss}.label;

    % sessionName  = 'city3_15:08_v12.1_f162.26front_o270.00_2019626181638'
    lu = sprintf('wandell/Graphics camera array/image alignment/%s',sessionName);

    thisSession = st.lookup(lu);
    
    % These are acquisitions from different positions
    acquisitions = thisSession.acquisitions();
    fprintf('Found %d acquisitions for session %s\n',numel(acquisitions),sessionName);
    
    ee = 0;   % Error counter
    for aa = 1:numel(acquisitions)

        chdir(fullfile(piRootPath,'local'));

        delete('city*');  % Remove any old dat files

        %%  Download and build up the OI
        acquisitionName = acquisitions{aa}.label;
        
        lu = sprintf('wandell/Graphics camera array/%s/%s/%s',renderSubject,sessionName,acquisitionName);
        acquisition = st.lookup(lu);

        try
            oi = piAcquisition2ISET(acquisition,st);  % Note:  Remove dat files when done.
            oi = piFireFliesRemove(oi);
            % oiWindow(oi);
            
            %% Convert the oi into an IP
            ip = piOI2IP(oi,'pixel size',3);
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
            chdir(thisDir);   % Proper sub-directory
            
            rgb = ipGet(ip,'srgb');
            this = strrep(strrep(datestr(now),' ','-'),':','');
            
            imwrite(rgb,[this,'-radiance.png'])
            imwrite(ieScale(ip.metadata.depthMap,0,1),[this,'-depth.png'])
            imwrite(ieScale(ip.metadata.meshImage),[this,'-mesh.png'])
            
            % Now save the metadata
            depthMap   = ip.metadata.depthMap;
            meshNumber = ip.metadata.meshImage;
            meshLabel  = ip.metadata.meshtxt;
            save([this,'-metadata']','depthMap','meshNumber','meshLabel');
            fprintf('++++ Succeeded with session %s acq %s\n',sessionName,acquisitionName);

        catch
            % Something went wrong
            ee = ee + 1;
            eList{ee} = sprintf('**** Error session %s acq %s\n',sessionName,acquisitionName); %#ok<SAGROW>
            disp(eList{ee});
        end
        
    end
end


%%