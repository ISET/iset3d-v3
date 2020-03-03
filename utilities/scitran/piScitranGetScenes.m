function [ieObject, localPaths] = piScitranGetScenes(st, projectDirectory, localDirectory, varargin)


p =inputParser;
p.addParameter('forceDownload',false,@islogical);

p.parse(varargin{:});
inputs = p.Results;

localPaths = {};

% Search for scenes
res = st.search('acquisition',...
          'project label exact',projectDirectory,...
          'subjectcode','scenes','fw',true);

for i=1:length(res)
   
    for f=1:length(res{i}.files)
        dest = fullfile(localDirectory,res{i}.label,res{i}.files{f}.name);
        if ~exist(fileparts(dest),'dir')
            mkdir(fileparts(dest))
        end
        
        if isequal(sprintf('%s.pbrt',res{i}.label),res{i}.files{f}.name)
            localPaths = cat(1,localPaths,dest);
        end
        
        if ~exist(dest,'file') || inputs.forceDownload
            st.fileDownload(res{i}.files{f},...
                        'destination',dest);
        end
    end
    
    renderings = st.search('acquisition',...
                            'project label exact',projectDirectory,...
                            'acquisition label exact',res{i}.label,...
                            'subjectcode','renderings','fw',true);
                        
    if (length(renderings) > 1)
        % issue a warning here
    end
    
    for f=1:length(renderings{1}.files)
        
        dest = fullfile(localDirectory,res{i}.label,'renderings',renderings{1}.files{f}.name);
        
        if ~exist(fileparts(dest),'dir')
            mkdir(fileparts(dest))
        end
        
        if ~exist(dest,'file') || inputs.forceDownload
            st.fileDownload(renderings{1}.files{f},...
                        'destination',dest);
        end
        
    end
    
    
    % Read it and parse it into the local recipe class
    thisR = piJson2Recipe(fullfile(localDirectory,res{i}.label,sprintf('%s.json',res{i}.label)));
    
    %depthMap = piDat2ISET(fullfile(localDirectory,res{i}.label,sprintf('%s_depth.dat',res{i}.label)), 'label', 'depth');
    %coordMap = piDat2ISET(fullfile(localDirectory,res{i}.label,sprintf('%s_coordinates.dat',res{i}.label)),'label','coordinates');
    %meshImage = piDat2ISET(fullfile(localDirectory,res{i}.label,sprintf('%s_mesh.dat',res{i}.label)), 'label', 'mesh');
    
    % Read the PBRT dat file into the iset object
    isetObj = piDat2ISET(fullfile(localDirectory,res{i}.label,'renderings',sprintf('%s.dat',res{i}.label)),...
        'label','radiance','recipe',thisR);
        
    % Removies fire flies (little white spots) from the image
    ieObject(i) = piFireFliesRemove(isetObj);
    
    
    %% Add some metadata to the ISET object

    ieObject(i).metadata.daytime    = thisR.metadata.daytime;
    ieObject(i).metadata.objects    = thisR.assets;
    ieObject(i).metadata.camera     = thisR.camera;
    ieObject(i).metadata.film       = thisR.film;
    
    %{
    if renderMesh==1
        % mesh_txt
        data=importdata(label);
        meshtxt = regexp(data, '\s+', 'split');
        
        meshImage = uint16(meshImage);
        ieObject(tt).metadata.meshImage  = meshImage;
        ieObject(tt).metadata.meshtxt    = meshtxt;
    end
    if renderDepth
        ieObject(tt) = sceneSet(ieObject(tt),'depth map',depthMap); 
    end
    if renderPointCloud
        ieObject(tt).metadata.pointcloud = coordMap;
    end
    %}
    
end

end

