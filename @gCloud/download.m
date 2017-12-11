function [ isetObj ] = download( obj, varargin )

isetObj = cell(1,length(obj.targets));

[targetFolder] = fileparts(obj.targets(1).local);
[remoteFolder, remoteFile] = fileparts(obj.targets(1).remote);

cmd = sprintf('gsutil rsync -r %s %s',remoteFolder,targetFolder);
[status, result] = system(cmd);


for t=1:length(obj.targets)
    
    [targetFolder] = fileparts(obj.targets(t).local);
    [remoteFolder, remoteFile] = fileparts(obj.targets(t).remote);
    
    outFile = sprintf('%s/renderings/%s.dat',targetFolder,remoteFile);
    photons = piReadDAT(outFile, 'maxPlanes', 31);
    
    
    ieObjName = sprintf('%s-%s',remoteFile,datestr(now,'mmm-dd,HH:MM'));
    if strcmp(obj.targets(t).camera.subtype,'perspective')
        opticsType = 'pinhole';
    else
        opticsType = 'lens';
    end
    
    % If radiance, return a scene or optical image
    switch opticsType
        case 'lens'
            % If we used a lens, the ieObject is an optical image (irradiance).
            
            % We should set fov or filmDiag here.  We should also set other ray
            % trace optics parameters here. We are using defaults for now, but we
            % will find those numbers in the future from inside the radiance.dat
            % file and put them in here.
            ieObject = piOICreate(photons,varargin{:});  % Settable parameters passed
            ieObject = oiSet(ieObject,'name',ieObjName);
            % I think this should work (BW)
            if exist('depthMap','var')
            if(~isempty(depthMap))
                ieObject = oiSet(ieObject,'depth map',depthMap);
            end
            end
            
            % This always worked in ISET, but not in ISETBIO.  So I stuck in a
            % hack to ISETBIO to make it work there temporarily and created an
            % issue. (BW).
            ieObject = oiSet(ieObject,'optics model','ray trace');
            
        case 'pinhole'
            % In this case, we the radiance describes the scene, not an oi
            ieObject = piSceneCreate(photons,'meanLuminance',100);
            ieObject = sceneSet(ieObject,'name',ieObjName);
            if(~isempty(depthMap))
                ieObject = sceneSet(ieObject,'depth map',depthMap);
            end
            
            % There may be other parameters here in this future
            if strcmp(thisR.get('optics type'),'pinhole')
                ieObject = sceneSet(ieObject,'fov',thisR.get('fov'));
            end
    end
    
    isetObj{t} = ieObject;
    
end


end

