function [fnameZIP, artifact] = piPBRTFetch(aName,varargin)
% FETCH a PBRT file from the RDT archive to a local directory.
%
% Syntax
%  piPBRTFetch(artifactName,varargin)
%
% Required input
%   artifactName - The base name of the artifact that can be found by a search
%   
% Optional inputs
%   'unzip'      - perform the unzip operation (default true)
%   'delete zip' - delete zip after unzipping (default false)
%   'destination folder' - default is piRootPath/data
%   'pbrt version'       - PBRT version.  Default is current v2, but it
%                          may change to v3 before very long
%
% Return
%   fnameZIP - full path to the zip file
%   artifact - artifact found on the remote site
%
% Description
%   The PBRT data are stored as zip files that include the pbrt scene file
%   along with all of the necessary additional files.  These are typically
%   stored inside of folders (geometry, brdfs, spds, textures).  This
%   function pulls down the zip file containing everything and, by default,
%   unzips the file so that the scene and auxiliary files are in a single
%   directory.
% 
% Wandell, SCIEN Stanford, 2017

% Examples
%{
 % Specify the scene name, download it, and render it
 % By default, the download is to piRootPath/data
 [fnameZIP, artifact] = piPBRTFetch('whiteScene');
 [p,n,e] = fileparts(fnameZIP);
 dname = fullfile(p,n); 
 fname = [n,'.pbrt'];

 % Read the recipe from the pbrt scene file, 
 % which is contained inside a directory of the same name
 thisR = piRead(fullfile(dname,fname));

 % Something wrong here in how this is set up ..
 % BW should fix.
 
 % Render the output to the piRootPath/local output directory
 thisR.outputFile = fullfile(piRootPath,'local',n,fname); 
 scene = piRender(thisR);

 % View it
 ieAddObject(scene); sceneWindow;
%}
%{
 [fnameZIP, artifact] = piPBRTFetch('SimpleScene','pbrtversion',3);
%}
%{
 % By default, this places the data in piRootPath/data.  
 % You could set the 'deletezip', true parameter.
 [fnameZIP, artifact] = piPBRTFetch('sanmiguel');

 % Assumes the scene pbrt file is in piRootPath/data
 % And places the output in piRootPath/local
 s_sanmiguel;
%}

%% Parse inputs
p = inputParser;

% Forces optional inputs to lower case
for ii=1:2:length(varargin)
    varargin{ii} = ieParamFormat(varargin{ii});
end

p.addRequired('aName',@ischar);

p.addParameter('destinationfolder',fullfile(piRootPath,'data'),@ischar);
p.addParameter('unzip',true,@islogical);
p.addParameter('deletezip',false,@islogical);

p.addParameter('pbrtversion',2,@(x)(x == 2 || x == 3));
p.addParameter('remotedirectory','/resources/scenes/pbrt',@ischar);

p.parse(aName,varargin{:});

destinationFolder = p.Results.destinationfolder;
zipFlag           = p.Results.unzip;
deleteFlag        = p.Results.deletezip;
if(strcmp(p.Results.remotedirectory,'/resources/scenes/pbrt'))
    remotedirectory   = sprintf('%s/v%d',p.Results.remotedirectory,p.Results.pbrtversion');
else
    remotedirectory = p.Results.remotedirectory;
end

%% If destination folder does not exist, create it
if(~exist(destinationFolder,'dir'))
    mkdir(destinationFolder);
end

%% Check for RDT
if(~exist('RdtClient','file'))
    error('Cannot find RdtClient. This scene requires RemoteDataToolbox to be installed. Is it on your path?')
end

%% Get the file from the RDT
rdt = RdtClient('isetbio');
rdt.crp(remotedirectory);

a = rdt.searchArtifacts(aName);
[fnameZIP, artifact] = rdt.readArtifact(a(1),'destinationFolder',destinationFolder);

%% If download succeeded, check if unzip and delete are requested
if exist(fnameZIP,'file')
    if zipFlag
        % unzip into the destionation directory.
        unzip(fnameZIP,destinationFolder);
    end
    
    % Only delete the zip file if the person has unzipped.  This prevents
    % boneheaded mistakes.
    if deleteFlag && zipFlag,  delete(fnameZIP); end
end

end
