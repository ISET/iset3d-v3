function piFwFileDownload(destination, fileName, AcqID)
% Download the specified file from Flywheel.io
%
% Syntax:
%   piFwFileDownload(destination, filename, AcqID)
%
% Description:
%    Using the Acquisition specified by AcqID, retrieve the file from the
%    provided destination.
%
% Inputs:
%    destination - String. The string filename to download.
%    fileName    - String. The name of the FileEntry in the SkyMap.
%    AcqID       - String. The acquisition ID, in string form.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    None.
%

% Examples:
%{
    FilePath = fullfile(piRootPath, 'data', 'V3', 'checkerboard_new');
    fname = fullfile(FilePath, 'checkerboard_new.pbrt');
    if ~exist(fname, 'file'), error('File not found'); end
    thisR = piRead(fname);

    % Grab a car from Flywheel
    st = scitran('stanfordlabs');
    project = st.fw.lookup('wandell/Graphics assets');
    session = project.sessions.findOne('label=car');

    inputs.ncars = 1;
    assetRecipe = piAssetDownload(session, inputs.ncars, ...
        'acquisition label', 'Car_085');
    asset.car = piAssetAssign(assetRecipe, 'label', 'car');

    % add downloaded asset information to Render recipe. Set quality.
    thisR = piAssetAdd(thisR, asset);
    thisR.set('film resolution', [400 300]);  % low res == fast!
    thisR.set('pixel samples', 64);

    if piScitranExists
        [~, skymapInfo] = piSkymapAdd(thisR, thisTime);

        % SkymapInfo is structured according to python rules. Convert to
        % Matlab format here. The first cell is the acquisition ID and the
        % second cell is the file name of the skymap
        s = split(skymapInfo, ' ');

        % The destination of the skymap file
        skyMapFile = fullfile(fileparts(thisR.outputFile), s{2});

        % If it doesn't exist, open Flywheel and download the skypmap file.
        if ~exist(skyMapFile, 'file')
            fprintf('Downloading Skymap from Flywheel ... ');
            % Download from acq using fileName - (dest, FileName, AcqID)
            piFwFileDownload(skyMapFile, s{2}, s{1})
            fprintf('complete\n');
        end
    end
%}

st = scitran('stanfordlabs');
acq = st.fw.get(AcqID); % Get the acquisition using the ID
thisFile = acq.getFile(fileName); % Get the FileEntry for this skymap
thisFile.download(destination); % Download the file

if piContains(destination, '.zip')
    % User said to unzip the file and delete the zip file.
    outputDir = fileparts(destination);
    unzip(destination, outputDir);
    delete(destination);
end

end
