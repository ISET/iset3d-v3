function val = piLensGet(param, varargin)
% Get information about the lenses data/lens
%
% Syntax:
%   val = piLensGet(param, [varargin])
%
% Description:
%    Get information abou the lens/lenses data
%
% Inputs:
%    param    - String. A string desribing which parameter of the lens data
%               to return information on. Options are:
%       list:          A structure list of all of the lenses
%       focalDistance: A strucutre containing the distance and focal
%                      distance information
%
% Outputs:
%    val      - Struct. A structure containing the information in the
%               format described above based in the value of param.
%
% Optional key/value pairs:
%    lensName - String. The lens's name. Default 'dgauss.22deg.50.0mm'.
%    lensType - String. The lens type. Default '*'.
%

% History:
%    XX/XX/17  BW   Scitran Team 2017
%    03/28/19  JNM  Documentation pass


% Examples:
%{
    lensList = piLensGet('list', 'lenstype', 'dgauss*');
	focalDistances = piLensGet('focal distance', ...
        'lensname', 'dgauss.22deg.50.0mm');
%}

%% Warn that this is a deprecated function (use at own risk)
warning('deprecated');

%%
p = inputParser;
p.addRequired('param', @ischar);
p.addParameter('lenstype', '*', @ischar);
p.addParameter('lensname', 'dgauss.22deg.50.0mm', @ischar);

p.parse(param, varargin{:});
val = [];

%%
param = ieParamFormat(param);
switch param
    case 'list'
        lenstype = p.Results.lenstype;
        lensDir = fullfile(piRootPath, 'data', 'lens');
        val = dir(fullfile(lensDir, sprintf('%s.dat', lenstype)));
    case 'focaldistance'
        lensName = p.Results.lensname;
        val = load([lensName, '.FL.mat']);
    otherwise
end

end
