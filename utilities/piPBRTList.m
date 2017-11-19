function artifacts = piPBRTList(varargin)
% List names of the remote pbrt scene files
%
% Syntax
%    artifacts = piPBRTList;
%
% Required Inputs
%   None
%
% Optional Inputs
%   'print'    Logical, default true
%   'remote'   String defining the remote directory.
%              /resources/scenes/pbrt is the default
%
% Prints out a list of the pbrt scene files (V2) stored on the Remote Data
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


%%
p = inputParser;
for ii=1:2:length(varargin)
    varargin{ii} = ieParamFormat(varargin{ii});
end
p.addParameter('print',true,@islogical);
p.addParameter('remotedirectory','/resources/scenes/pbrt',@ischar);

p.parse(varargin{:});

%%
rdt = RdtClient('isetbio');
rdt.crp(p.Results.remotedirectory);
artifacts = rdt.listArtifacts('print',p.Results.print);

end