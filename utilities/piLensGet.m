function val = piLensGet(param,varargin)
% piLensGet - Get information about the lenses data/lens
%
%  val = piLensGet(param,varargin)
%
% Examples
%   lensList = piLensGet('list','lenstype','dgauss*');
%   focalDistances = piLensGet('focal distance','lensname','dgauss.22deg.50.0mm');
% 
% BW  Scitran Team 2017

%%
p = inputParser;
p.addRequired('param',@ischar);
p.addParameter('lenstype','*',@ischar);
p.addParameter('lensname','dgauss.22deg.50.0mm',@ischar);

p.parse(param,varargin{:});
val = [];

%%
param = ieParamFormat(param);
switch param
    case 'list'
        lenstype = p.Results.lenstype;
        lensDir = fullfile(piRootPath,'data','lens');
        val = dir(fullfile(lensDir,sprintf('%s.dat',lenstype)));
    case 'focaldistance'
        lensName = p.Results.lensname;
        val = load([lensName,'.FL.mat']);
    otherwise
end

end
