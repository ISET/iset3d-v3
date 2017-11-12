function [fnameZIP, artifact] = piFetchPBRT(aName,varargin)
% FETCH a PBRT file from the RDT archive to a local directory.
%
% Syntax
%  piFetchPBRT(artifactName,varargin)
%
% Required input
%   artifactName - The base name of the artifact that can be found by a search
%   
% Optional inputs
%   destinationFolder - default is piRootPath/local
%   unzip     - perform the unzip operation (default true)
%   deletezip - delete after unzipping (default false; only done if unzip 
%               is true
%
% Return
%   fnameZIP - full path to the zip file
%   artifact - artifact that was found on the remote site during the search
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
aName = 'whiteScene';
[fnameZIP, artifact] = piFetchPBRT(aName);
[p,n,e] = fileparts(fnameZIP); 
pbrtFile = fullfile(p,n,[n,'.pbrt']);
thisR = piRead(pbrtFile);
thisR.outputFile = pbrtFile;
scene = piRender(thisR);
vcAddObject(scene); sceneWindow;
%}
%{
% Sanmiguel scene
aName = 'sanmiguel';
[fnameZIP, artifact] = piFetchPBRT(aName);
%}

%% Parse inputs
p = inputParser;
p.addRequired('aName',@ischar);
p.addParameter('destinationFolder',fullfile(piRootPath,'local'),@ischar);
p.addParameter('unzip',true,@islogical);
p.addParameter('deletezip',false,@islogical);

p.parse(aName,varargin{:});
destinationFolder = p.Results.destinationFolder;
zipFlag = p.Results.unzip;
deleteFlag = p.Results.deletezip;

%% Get the file from the RDT

rdt = RdtClient('isetbio');
rdt.crp('/resources/scenes/pbrt');
a = rdt.searchArtifacts(aName);
[fnameZIP, artifact] =rdt.readArtifact(a(1),'destinationFolder',destinationFolder);

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
