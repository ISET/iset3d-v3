%% Convert rendered data from the image alignment to an IP
%
% Description
%
%   Find a Flywheel session and acquisition with PBRT rendered images.
%   Download the rendered data and assemble them into an ISETCam IP with
%   the metadata.  Save these locally for zipping and handing out to
%   students.  These are in the AlignmentData.zip file on the Canvas site.
%
% Wandell, 12/2019

%%
st = scitran('stanfordlabs');

%% Set a session and acquisition

% The rendered data are stored as this subject
renderSubject = 'image alignment render';
lu = sprintf('wandell/Graphics camera array/%s',renderSubject);
subject = st.lookup(lu);

% The sessions for this subject are the rendered data. 
sessions = subject.sessions();   
fprintf('Found %d sessions in the render subject.\n',numel(sessions));

%% For each session
for ss=1:numel(sessions)
    chdir(fullfile(piRootPath,'local'));

    sessionName = sessions{ss}.label;
    lu = sprintf('wandell/Graphics camera array/%s/%s',renderSubject,sessionName);
    thisSession = st.lookup(lu);
    
    % Find the acquisitions.  These are rendereding from different
    % camera positions 
    acquisitions = thisSession.acquisitions();
    fprintf('Found %d acquisitions for session %s\n',numel(acquisitions),sessionName);
    
    ee = 0;   % Error counter
    for aa = 1:numel(acquisitions)

        % Remove old downloaded dat-files.
        chdir(fullfile(piRootPath,'local'));
        delete('city*');

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
            
            %% Save out the images as PNG files in the alignment subdirectory
            
            % Inside the alignment directory
            chdir(fullfile(piRootPath,'local','alignment'));

            % Look for a directory with the session name.  If it doesn't
            % exist, make it
            thisDir = sprintf('%s',sessionName);
            if ~exist(thisDir,'dir'), mkdir(thisDir); end
            chdir(thisDir);   % Proper sub-directory
            
            % Get the rgb image 
            rgb = ipGet(ip,'srgb');
            
            % Make a base name
            this = strrep(strrep(datestr(now),' ','-'),':','');
            
            imwrite(rgb,[this,'-radiance.png'])
            imwrite(ieScale(ip.metadata.depthMap,0,1),[this,'-depth.png'])
            imwrite(ieScale(ip.metadata.meshImage),[this,'-mesh.png'])
            
            % Now save the metadata numerically in a mat-file
            depthMap   = ip.metadata.depthMap;
            meshNumber = ip.metadata.meshImage;
            meshLabel  = ip.metadata.meshtxt;
            save([this,'-metadata']','depthMap','meshNumber','meshLabel');
            fprintf('++++ Succeeded with session %s acq %s\n',sessionName,acquisitionName);

        catch
            % Something went wrong
            ee = ee + 1;  %Increment the error count.
            eList{ee} = sprintf('**** Error session %s acq %s\n',sessionName,acquisitionName); %#ok<SAGROW>
            disp(eList{ee});
        end
        
    end
end


%% END