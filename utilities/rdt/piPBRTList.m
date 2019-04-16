function artifacts = piPBRTList(varargin)
% List names of the remote pbrt scene files
%
% Syntax
%    artifacts = piPBRTList(...);
%
% Required Inputs
%   None
%
% Optional Inputs
%   'print'    Logical, default true
%   'remote'   String defining the remote directory.
%              /resources/scenes/pbrt is the default
%   'version'  String that defines 'v2' or 'v3' PBRT files.
%
% Prints out a list of the pbrt scene files (v2) stored on the Remote Data
% site in /resources/scenes/pbrt.  This is the Archiva server, managed by
% the Penn team for the isetbio project.
%
% See also:  piPBRTFetch
%
% Examples:
%    piPBRTList;                     % Prints out the list
%    a = piPBRTList('print',false);  % Returns pointers to the artifacts
%
% BW, SCIEN Stanford team, 2017
%
% See also: piPBRTPush, piPBRTFetch

% Examples:
%{
piPBRTList;                     % Prints out the list
a = piPBRTList('print',false);  % Returns pointers to the artifacts
a = piPBRTList('version','v3');
a = piPBRTList('version','v2');
%}

%%
p = inputParser;
for ii=1:2:length(varargin)
    varargin{ii} = ieParamFormat(varargin{ii});
end
p.addParameter('print',true,@islogical);
% p.addParameter('pbrtversion',2,@(x)(x == 2 || x == 3));
p.addParameter('remotedirectory','/resources/scenes/pbrt',@ischar);
p.addParameter('version','V3',@ischar);

p.parse(varargin{:});
remotedirectory = p.Results.remotedirectory;

% We may end up adding a V2 sub-directory.  For now it is files and V3
% files inside of remote/V3
switch lower(p.Results.version)
    case{'v3'}
        remotedirectory = fullfile(remotedirectory,'v3');
    case{'v2'}
        remotedirectory = fullfile(remotedirectory,'v2');
    otherwise
        error('Unknown version %s\n',p.Results.version);
end

% remotedirectory = sprintf('%s/v%d',p.Results.remotedirectory,p.Results.pbrtversion');

%%
rdt = RdtClient('isetbio');
rdt.crp(remotedirectory);
artifacts = rdt.listArtifacts('print',p.Results.print);

end