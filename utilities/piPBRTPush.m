function rd = piPBRTPush(fnameZIP,varargin)
% Push a file to the RDT web site.
%
% Syntax:
%   rd = piPBRTPush(fnameZIP,varargin)
%
% Description:
%   piPBRTPush uploads a zipped PBRT data folder containing a scene
%   file and all of its necessary resources onto the remote server
%   (RemoteDataToolbox).  The zip file can be fetched later using
%   piPBRTFetch.m
% 
%   You must have permission/access to the server in order to push. 
%
% Required input
%   fnameZIP - filename of ZIP file to push onto the server 
%   
% Optional inputs
%   artifactName - The base name of the artifact that can be found by
%   a search 
%   pbrtVersion  - Can specify a v3 file, so the data are put inside
%                  the v3 folder
%   rd           - If you have an open RdtClient you can pass it here
%                  so you are not asked for a password again.
%
% Return
%   rd:   The remote data client object
%
% TL, SCIEN Stanford, 2017
%
% See also:  piPBRTFetch, piPBRTList

% Examples
%{

%}
%% Parse inputs
p = inputParser;

% varargin = ieParamFormat(varargin);
p.addRequired('fnameZIP',@ischar);
p.addParameter('artifactName','',@ischar);
p.addParameter('pbrtVersion','v2',@ischar);
p.addParameter('rd',[],@(x)(isa(x,'RdtClient')));

p.parse(fnameZIP,varargin{:});

artifactName = p.Results.artifactName;
pbrtVersion  = p.Results.pbrtVersion;
rd           = p.Results.rd;

%% Check given file

[p,n,e] = fileparts(fnameZIP);

% Check zip file existence
if(~exist(fnameZIP,'file'))
    error('Given file does not exist.');
end

% Check that fnameZIP is an absolute path
if(isempty(p))
    fnameZIP = which(fnameZIP);
end

% Check that it is a zip file using the extension
% Is there a better way to do this?
if(~strcmp(e,'.zip'))
    error('Given file does not seem to be a zip file.')
end

%% Get the file from the RDT
% To upload requires that you have a password on the Remote Data site.
% Login here, if rd is not yet passed in.
if isempty(rd)
    rd = RdtClient('isetbio');
    rd.credentialsDialog();
end

%% Set the RDT archive upload destination

% Note the asymmetry.  V2 are in the directory and V3 are in the
% sub-directory remote/V3.
switch lower(pbrtVersion)
    case 'v2'
        rd.crp('/resources/scenes/pbrt');
    case 'v3'
        rd.crp('/resources/scenes/pbrt/v3');
    otherwise
        error('Unknown pbrt version %s\n',pbrtVersion);
end

%% Do the upload (publish)

fprintf('Uploading... \n');
archivaVersion = '1';   
if(isempty(artifactName))
    % Use the file name as the artifact name
    rd.publishArtifact(fnameZIP,...
        'version',archivaVersion,...
        'name',n);
else
    % The user seems to want another name for the artifact
    rd.publishArtifact(fnameZIP,'artifactId',artifactName);
end
 
%% Update status
fprintf('Upload complete. \n');

end
