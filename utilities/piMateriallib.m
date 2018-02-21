function [materiallib]=piMateriallib
% construct material into struct fields

%% carpaintmix
materiallib.carpaintmix.paint_mirror.string = 'mirror';
materiallib.carpaintmix.paint_mirror.rgbkr = [.1 .1 .1];
materiallib.carpaintmix.paint_base.string='substrate';
materiallib.carpaintmix.paint_base.colorkd = [.7 .125 .125];
materiallib.carpaintmix.paint_base.colorks =[.1 .1 .1];
materiallib.carpaintmix.paint_base.floaturoughness=0.01;
materiallib.carpaintmix.paint_base.floatvroughness=0.01;
materiallib.carpaintmix.carpaint.string = 'mix';
materiallib.carpaintmix.carpaint.stringnamedmaterial1 = 'paint_mirror';
materiallib.carpaintmix.carpaint.stringnamedmaterial2='paint_base';

%% carpaint
materiallib.carpaint.floaturoughness =0.0005;
materiallib.carpaint.floatvroughness=0.00051;
materiallib.carpaint.string='substrate';


%% chrome_spd
materiallib.chrome_spd.floatroughness=0.01;
materiallib.chrome_spd.string='metal';
materiallib.chrome_spd.spectrumkd='spds/Al.k.spd';
materiallib.chrome_spd.spectrumks='spds/Al.eta.spd';

%% blackrubber
materiallib.blackrubber.floatroughness = 0.5;
materiallib.blackrubber.string = 'uber';
materiallib.blackrubber.rgbkd = [ .01 .01 .01 ];
materiallib.blackrubber.rgbks = [ 0.2 .2 .2 ];
%% mirror
materiallib.mirror.string='mirror';
%% matte
materiallib.matte.string = 'matte';
%% plastic
materiallib.matte.string = 'plastic';
%% glass
materiallib.matte.string = 'glass';
end




