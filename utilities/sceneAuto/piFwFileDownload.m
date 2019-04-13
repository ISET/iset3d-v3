function piFwFileDownload(destination, fileName, AcqID)
    p = inputParser;
    st = scitran('stanfordlabs');    
    acq       = st.fw.get(AcqID); % Get the acquisition using the ID
    thisFile  = acq.getFile(fileName); % Get the FileEntry for this skymap
    thisFile.download(destination); % Download the file
    
    if piContains(destination,'.zip')
        % User said to unzip the file and delete the zip file.
        outputDir = fileparts(destination);
        unzip(destination,outputDir);
        delete(destination);
    end
end