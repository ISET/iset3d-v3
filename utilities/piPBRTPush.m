function [] = piPBRTPush(fnameZIP,varargin)
% TL Note (1/5/17):
% Publish artifact seems to be hanging on me when I test this function. I'm
% not sure if it's the internet connection or something else...
%
% Push a zipped PBRT scene from a local directory to the RDT archive. You
% must have permission/access to the server in order to do this. 
%
% Syntax
%  piPBRTPush(fnameZIP,varargin)
%
% Required input
%   fnameZIP - filename of ZIP file to push onto the server 
%   
% Optional inputs
%   artifactName - The base name of the artifact that can be found by a search
%
% Return
%   None at the moment
%
% Description
%   The PBRT data are stored as zip file that include the pbrt scene file
%   along with all of the necessary additional files. This function pushes
%   an already-zipped PBRT data folder onto the remote server
%   (RemoteDataToolbox) so it can be pulled down at a later period using
%   piPBRTFetch.m
% 
% TL, SCIEN Stanford, 2017

%% Parse inputs
p = inputParser;
p.addRequired('fnameZIP',@ischar);
p.addParameter('artifactName','',@ischar);
p.addParameter('pbrtVersion',2,@isscalar);

p.parse(fnameZIP,varargin{:});
artifactName = p.Results.artifactName;
pbrtVersion = p.Results.pbrtVersion;

%% Check given file

[p,n,e] = fileparts(fnameZIP);

% Check zip file existence
if(~exist(fnameZIP,'file'))
    error('Given file does not exist.');
end

% Check that fnameZIP is an absolute path
if(isempty(p))
    error('Given file must be an absolute path.');
end

% Check that it is a zip file using the extension
% Is there a better way to do this?
if(~strcmp(e,'.zip'))
    error('Given file does not seem to be a zip file.')
end

%% Get the file from the RDT
% To upload requires that you have a password on the Remote Data site.
% Login here. 
rd = RdtClient('isetbio');
rd.credentialsDialog();

%% Upload to RDT archive
if(pbrtVersion == 2)
    rd.crp('/resources/scenes/pbrt');
elseif(pbrtVersion == 3)
    rd.crp('/resources/scenes/pbrt/v3');
end
version = '1';

fprintf('Uploading... \n');
if(isempty(artifactName))
    rd.publishArtifact(fnameZIP,...
        'version',version,...
        'name',n);
else
    %rd.publishArtifact(fnameZIP,'artifactId',artifactName);
end
 
%% Update status
fprintf('Upload complete. \n');

end
