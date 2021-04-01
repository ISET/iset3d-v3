function val = piMaterialGenerateEEM(fluoname, varargin)
%% Return an excitation-emission matrix for a fluorophore
%
% Synopsis
%  val = piMaterialGenerateEEM(fluoname, varargin)
%
% Input
%   fluoname
%
% Optional key/val pairs
%   wave - wavelength samples
%   form - return as a vector or a matrix, as needed.  PBRT takes the data
%          as a vector
% 
% Output
%   eem - Excitation emission matrix
%
% See also
%   isetfluorescence repository is required

varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('fluoname', @ischar);
p.addParameter('wave', 365:5:705, @isnumeric);
p.addParameter('form', 'vec', @ischar);
p.addParameter('normal', true, @islogical);

p.parse(fluoname, varargin{:});
fluoname = p.Results.fluoname;
wave = p.Results.wave;
form = p.Results.form;
normal = p.Results.normal;

%%
val = [];
fluorophore = fluorophoreRead(fluoname, 'wave', wave);
if normal
    eem = fluorophoreGet(fluorophore, 'eem energy normalize');
else
    eem = fluorophoreGet(fluorophore, 'eem energy');
end


if isempty(eem)
    warning('Cannot find fluorophore: %s', fluoname);
    return;
end

switch form
    case {'vec', 'vector'}
        val = piEEM2Vec(wave, eem);
    case {'mat', 'matrix'}
        val = eem;
end
%%
end