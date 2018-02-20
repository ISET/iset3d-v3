function [materiallib]=piMateriallib
materiallib.carpaintmix ={'MakeNamedMaterial "paint_mirror" "string type" "mirror" "rgb Kr" [.1 .1 .1]';
                       'MakeNamedMaterial "paint_base" "string type" "substrate" "color Kd" [.7 .125 .125] "color Ks" [.1 .1 .1] "float uroughness" .01 "float vroughness" .01'; 
                       'MakeNamedMaterial "carpaint" "string type" "mix" "string namedmaterial1" [ "paint-mirror" ] "string namedmaterial2" [ "paint-base" ]';};
materiallib.carpaint   ={'MakeNamedMaterial "CarPaint" "float uroughness" [ 0.0005 ] "float vroughness" [ 0.00051 ] "string type" [ "substrate" ] "rgb Kd" [ 0.4 0.03 0.03 ] "rgb Ks" [ 0.3 0.3 0.3 ]'};
materiallib.chrome_spd ={'MakeNamedMaterial "Metal_Chrome" "float roughness" [ 0.01 ] "string type" [ "metal" ] "spectrum k" "spds/Al.k.spd""spectrum eta" "spds/Al.eta.spd"'};
materiallib.chrome     ={''};
materiallib.blackrubber={'MakeNamedMaterial "Mat" "float roughness" [ 0.5 ] "string type" [ "uber" ] "rgb Kd" [ .01 .01 .01 ] "rgb Ks" [ 0.2 .2 .2 ]'};
materiallib.glass      ={'glass'};
materiallib.plastic    ={'plastic'};
materiallib.mirror     ={'mirror'};
materiallib.matte      ={'matte'};

% materiallib.wood       ={''};
% materiallib.leather    ={''};

end


