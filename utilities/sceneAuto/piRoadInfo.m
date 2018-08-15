%% cross: 5 types
roadinfo.crossroad.roadtype='crossroad';
roadinfo.crossroad.scenetype='city';
roadinfo.crossroad.nlanes  =4;
roadinfo.crossroad.sidewalk_list(1).length = 58;
roadinfo.crossroad.sidewalk_list(1).direction = 0;
roadinfo.crossroad.sidewalk_list(1).coordinate = [-14.92/2, 1.278/2];
roadinfo.crossroad.sidewalk_list(1).height = 0.452/2;
roadinfo.crossroad.sidewalk_list(1).width = 5;

roadinfo.crossroad.sidewalk_list(2).length = 58;
roadinfo.crossroad.sidewalk_list(2).direction = 180;
roadinfo.crossroad.sidewalk_list(2).coordinate = [15.616/2, 118.959/2];
roadinfo.crossroad.sidewalk_list(2).height = 0.452/2;
roadinfo.crossroad.sidewalk_list(2).width = 5;

roadinfo.crossroad.sidewalk_list(3).length = 229/2;
roadinfo.crossroad.sidewalk_list(3).direction = 0;
roadinfo.crossroad.sidewalk_list(3).coordinate = [-14.92/2, 170.937/2];
roadinfo.crossroad.sidewalk_list(3).height = 0.452/2;
roadinfo.crossroad.sidewalk_list(3).width = 5;

roadinfo.crossroad.sidewalk_list(4).length = 229/2;
roadinfo.crossroad.sidewalk_list(4).direction = 180;
roadinfo.crossroad.sidewalk_list(4).coordinate = [14.503/2, 400.257/2];
roadinfo.crossroad.sidewalk_list(4).height = 0.452/2;
roadinfo.crossroad.sidewalk_list(4).width = 5;


roadinfo.crossroad.sidewalk_list(5).length = 97.669/2;
roadinfo.crossroad.sidewalk_list(5).direction = 90;
roadinfo.crossroad.sidewalk_list(5).coordinate = [-123.108/2, 159.61/2];
roadinfo.crossroad.sidewalk_list(5).height = 0.452/2;
roadinfo.crossroad.sidewalk_list(5).width = 5;

roadinfo.crossroad.sidewalk_list(6).length = 97.669/2;
roadinfo.crossroad.sidewalk_list(6).direction = 270;
roadinfo.crossroad.sidewalk_list(6).coordinate = [-26.13/2, 130.436/2];
roadinfo.crossroad.sidewalk_list(6).height = 0.452/2;
roadinfo.crossroad.sidewalk_list(6).width = 5;

roadinfo.crossroad.sidewalk_list(7).length = 90.472/2;
roadinfo.crossroad.sidewalk_list(7).direction = 90;
roadinfo.crossroad.sidewalk_list(7).coordinate = [25.761/2, 159.887/2];
roadinfo.crossroad.sidewalk_list(7).height = 0.452/2;
roadinfo.crossroad.sidewalk_list(7).width = 5;

roadinfo.crossroad.sidewalk_list(8).length = 90.472/2;
roadinfo.crossroad.sidewalk_list(8).direction = 270;
roadinfo.crossroad.sidewalk_list(8).coordinate = [123.352/2, 129.991/2];
roadinfo.crossroad.sidewalk_list(8).height = 0.452/2;
roadinfo.crossroad.sidewalk_list(8).width = 5;
%% straight
currdir = pwd;
filepath = fullfile(piRootPath,'configuration');
cd(filepath);
save('roadInfo.mat','roadinfo');cd(currdir)
filefullpath = fullfile(filepath, 'roadInfo.mat');
