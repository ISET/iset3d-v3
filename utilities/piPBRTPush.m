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

% varargin = ieParamFormat(varargin);
p.addRequired('fnameZIP',@ischar);
p.addParameter('artifactName','',@ischar);
p.addParameter('pbrtVersion',@isscalar);

p.parse(fnameZIP,varargin{:});

pbrtVersion  = p.Results.pbrtVersion;
artifactName = p.Results.artifactName;

% Check zip file existence
if(~exist(fnameZIP,'file'))
    error('Given file does not exist.');
end

% Check that it is a zip file using the extension
% Is there a better way to do this?
[~,~,ext] = fileparts(fnameZIP);
if(~strcmp(ext,'.zip'))
    error('Given file does not seem to be a zip file.')
end

%% Get the file from the RDT
% To upload requires that you have a password on the Remote Data site.
% Login here. 
rd = RdtClient('isetbio');
rd.credentialsDialog();

%% Upload to RDT archive

rd.crp('/resources/scenes/pbrt')
% if isequal(pbrtVersion,3), rd.crp('/resources/scenes/pbrt/V3');
% else,                      rd.crp('/resources/scenes/pbrt/V2');
% end

fprintf('Uploading... \n');
version = '1';   % Archiva version
if(isempty(artifactName))
    [~,n,~] = fileparts(fnameZIP);
    rd.publishArtifact(fnameZIP,'version',version);
%     rd.publishArtifact(fnameZIP,...
%         'version',version,...
%         'description','pbrt scene',...
%         'name',n);
    
else
    %rd.publishArtifact(fnameZIP,'artifactId',artifactName);
end
 
%% Update status
fprintf('Upload complete. \n');

end
