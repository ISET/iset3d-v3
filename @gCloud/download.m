function [ obj ] = download( obj )

for t=1:length(obj.targets)
    
    [targetFolder] = fileparts(obj.targets(t).local);
    [remoteFolder, remoteFile] = fileparts(obj.targets(t).remote);
    
    cmd = sprintf('gsutil cp %s/%s.dat %/%s.dat',remoteFolder,remoteFile,targetFolder,remoteFile);
    [status, result] = system(cmd);
    
end


end

