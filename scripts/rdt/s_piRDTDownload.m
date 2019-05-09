%% Download from the archiva server and create some images
%
%  
%
% 

%% San miguel scene

if ~exist(fullfile(piRootPath,'data','sanmiguel'),'dir')
    piPBRTFetch('sanmiguel');
end

piRead(