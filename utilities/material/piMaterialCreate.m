function [material, idx] = piMaterialCreate(thisR, varargin)
% Template for the material structure.
% We have noticed these as possible additions
%    spectrum Kd
%    xyz Kd
%
% V2 had a specifier 'texture bumpmap' that we don't think is V3.
%

%% Parse inputs
varargin = ieParamFormat(varargin);
p = inputParser;
p.KeepUnmatched = true;
p.parse(varargin{:});

%% Get how many materials exist already
val = numel(piMaterialGet(thisR, 'print', false));
idx = val + 1;

%% Construct material structure
material.name = strcat('Default material ', num2str(idx));
thisR.materials.list{idx} = material;

if isempty(varargin)
    material.stringtype = 'matte';
    thisR.materials.list{idx} = material;
else
    for ii=1:2:length(varargin)
        material.(varargin{ii}) = varargin{ii+1};
        piMaterialSet(thisR, idx, varargin{ii}, varargin{ii+1});
    end
end


%{
m.name = '';
m.linenumber = [];

m.string = '';
m.floatindex = [];

m.texturekd = '';
m.texturekr = '';
m.textureks = '';

m.rgbkr =[];
m.rgbks =[];
m.rgbkd =[];
m.rgbkt =[];

m.colorkd = [];
m.colorks = [];
m.colorreflect = [];
m.colortransmit = [];
m.colormfp = [];

m.floaturoughness = [];
m.floatvroughness = [];
m.floatroughness =[];
m.floateta = [];

m.spectrumkd = '';
m.spectrumks ='';
m.spectrumkr = '';
m.spectrumkt ='';
m.spectrumk = '';
m.spectrumeta ='';
m.stringnamedmaterial1 = '';
m.stringnamedmaterial2 = '';
m.texturebumpmap = '';
m.bsdffile = '';
m.boolremaproughness = '';

% Added photolumi for fluorescence materials
m.photolumifluorescence = '';
m.floatconcentration = [];
%}
end
