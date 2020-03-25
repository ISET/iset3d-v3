%% Multiple resolutions: 
%
%  Convert rendered data from the image alignment render subject in camera
%  array to an IP using different pixel sizes.
%
% Description
%   Find a Flywheel session and acquisition with PBRT rendered images.
%   Download the rendered data and assemble them into an ISETCam OI.
%   Convert the OI into a set of IP rgb images, using sensors with
%   different pixel sizes.
%
% Wandell, 12/2019

%%
st = scitran('stanfordlabs');

%% Use these sensor resolutions

resolutions = [1.5, 2.0, 2.5, 3.0, 3.5, 4.0];   % Microns

%% Set a session and acquisition

% There are plenty of rendered data stored as this subject
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
    fprintf('Using first acquisition for session %s\n',sessionName);
    
    ee = 0; % Error counter
    aa = 1; % Only do this for the first acquisition
    
    % Remove old downloaded dat-files.
    chdir(fullfile(piRootPath,'local'));
    delete('city*');
    
    %%  Download and build up the OI
    acquisitionName = acquisitions{aa}.label;
    
    lu = sprintf('wandell/Graphics camera array/%s/%s/%s',renderSubject,sessionName,acquisitionName);
    acquisition = st.lookup(lu);
    
    try
        oi = piAcquisition2ISET(acquisition,st);  % Note:  Remove dat files when done (above)
        oi = piFireFliesRemove(oi);
        % oiWindow(oi);
    catch
        % Something went wrong
        ee = ee + 1;  %Increment the error count.
        eList{ee} = sprintf('**** Error session %s acq %s\n',sessionName,acquisitionName); %#ok<SAGROW>
        disp(eList{ee});
        oi = [];
    end
    if ~isempty(oi)
        for rr = 1:numel(resolutions)
            %% Convert the oi into an IP
            ip = piOI2IP(oi,'pixel size',resolutions(rr));
            %{
             ipWindow(ip);
             ieNewGraphWin; imagesc(ip.metadata.depthMap); axis image
             ieNewGraphWin; imagesc(ip.metadata.meshImage); axis image
            %}
            
            %% Save out the images as PNG files in the alignment subdirectory
            
            % Inside the alignment directory
            chdir(fullfile(piRootPath,'local','resolution'));
            
            % Look for a directory with the session name.  If it doesn't
            % exist, make it
            thisDir = sprintf('%s',sessionName);
            if ~exist(thisDir,'dir'), mkdir(thisDir); end
            chdir(thisDir);   % Proper sub-directory
            
            % Get the rgb image
            rgb = ipGet(ip,'srgb');
            
            % Make a base name.  Last string is 10*microns, so 1.5 is 15,
            % 3.0 is 30, and 6.0 is 60.
            filename = sprintf('%s-%02.0f',datestr(now),resolutions(rr)*10);
            filename = strrep(strrep(strrep(filename,' ','-'),':',''),'.','');
            filename = sprintf('%s.png',filename);
            imwrite(rgb,filename)
            % imwrite(ieScale(ip.metadata.depthMap,0,1),[this,'-depth.png'])
            % imwrite(ieScale(ip.metadata.meshImage),[this,'-mesh.png'])
            
            fprintf('++++ Succeeded with session %s acq %s\n',sessionName,acquisitionName);
            
        end
    end
end

%% END