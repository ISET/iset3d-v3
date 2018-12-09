## Get Sumo source code
`git clone --recursive https://github.com/eclipse/sumo`

## Sumo installation
Go to this [site](http://sumo.dlr.de/wiki/Installing/MacOS_Build_w_Homebrew), and follow the instructions.

### Note:
To  enable the direct linking of python, change

`./configure CXX=clang++ CXXFLAGS="-stdlib=libc++ -std=gnu++11" --with-xerces=/usr/local --with-proj-gdal=/usr/local` 

with

`./configure CXX=clang++ CXXFLAGS="-stdlib=libc++ -std=gnu++11" --with-xerces=/usr/local --with-proj-gdal=/usr/local --with-python`

### Check your installation:
Type: `sumo-gui` in your terminal, a xQuartz based GUI will show up.

## Configuring Path Settings

Temporary Solution
To set an environment variable temporarily, you can use the following command in your terminal:

`export SUMO_HOME="/your/path/to/sumo/"`

This sets the environment variable to be used by any program or script you start in your current shell session. This does not affect any other shell session and only works until you end the session.

Note:
Replace /your/path/to/sumo/ with your sumo directory.
Permanent Solution
To set an environment variable permanently, follow these steps:

Open a file explorer of your choice and go to /home/YOUR_NAME/.
Open the file named .bashrc with a text editor of your choice. (You may have to enable showing hidden files in your file explorer)
Place this code export SUMO_HOME="/your/path/to/sumo/" somewhere in the file and save. (Don't delete any existing content!)
Reboot your computer. (Alternatively, log out of your account and log in again.)
The environment variable will now be used by any program you start from the command line with your current user account.

class label color map


          
             name                     id    trainId   category            catId     hasInstances   ignoreInEval   color'
    
    Label(  'unlabeled'            ,  0 ,      255 , 'void'            , 0       , False        , True         , (  0,  0,  0) ),  
    Label(  'ego vehicle'          ,  1 ,      255 , 'void'            , 0       , False        , True         , (  0,  0,  0) ),    
    Label(  'rectification border' ,  2 ,      255 , 'void'            , 0       , False        , True         , (  0,  0,  0) ),
    Label(  'out of roi'           ,  3 ,      255 , 'void'            , 0       , False        , True         , (  0,  0,  0) ),
    Label(  'static'               ,  4 ,      255 , 'void'            , 0       , False        , True         , (  0,  0,  0) ),
    Label(  'dynamic'              ,  5 ,      255 , 'void'            , 0       , False        , True         , (111, 74,  0) ),
    Label(  'ground'               ,  6 ,      255 , 'void'            , 0       , False        , True         , ( 81,  0, 81) ),
    Label(  'road'                 ,  7 ,        0 , 'ground'          , 1       , False        , False        , (128, 64,128) ),
    Label(  'sidewalk'             ,  8 ,        1 , 'ground'          , 1       , False        , False        , (244, 35,232) ),
    Label(  'parking'              ,  9 ,      255 , 'ground'          , 1       , False        , True         , (250,170,160) ),
    Label(  'rail track'           , 10 ,      255 , 'ground'          , 1       , False        , True         , (230,150,140) ),
    Label(  'building'             , 11 ,        2 , 'construction'    , 2       , False        , False        , ( 70, 70, 70) ),
    Label(  'wall'                 , 12 ,        3 , 'construction'    , 2       , False        , False        , (102,102,156) ),
    Label(  'fence'                , 13 ,        4 , 'construction'    , 2       , False        , False        , (190,153,153) ),
    Label(  'guard rail'           , 14 ,      255 , 'construction'    , 2       , False        , True         , (180,165,180) ),
    Label(  'bridge'               , 15 ,      255 , 'construction'    , 2       , False        , True         , (150,100,100) ),
    Label(  'tunnel'               , 16 ,      255 , 'construction'    , 2       , False        , True         , (150,120, 90) ),
    Label(  'pole'                 , 17 ,        5 , 'object'          , 3       , False        , False        , (153,153,153) ),
    Label(  'polegroup'            , 18 ,      255 , 'object'          , 3       , False        , True         , (153,153,153) ),
    Label(  'traffic light'        , 19 ,        6 , 'object'          , 3       , False        , False        , (250,170, 30) ),
    Label(  'traffic sign'         , 20 ,        7 , 'object'          , 3       , False        , False        , (220,220,  0) ),
    Label(  'vegetation'           , 21 ,        8 , 'nature'          , 4       , False        , False        , (107,142, 35) ),
    Label(  'terrain'              , 22 ,        9 , 'nature'          , 4       , False        , False        , (152,251,152) ),
    Label(  'sky'                  , 23 ,       10 , 'sky'             , 5       , False        , False        , ( 70,130,180) ),
    Label(  'person'               , 24 ,       11 , 'human'           , 6       , True         , False        , (220, 20, 60) ),
    Label(  'rider'                , 25 ,       12 , 'human'           , 6       , True         , False        , (255,  0,  0) ),
    Label(  'car'                  , 26 ,       13 , 'vehicle'         , 7       , True         , False        , (  0,  0,142) ),
    Label(  'truck'                , 27 ,       14 , 'vehicle'         , 7       , True         , False        , (  0,  0, 70) ),
    Label(  'bus'                  , 28 ,       15 , 'vehicle'         , 7       , True         , False        , (  0, 60,100) ),
    Label(  'caravan'              , 29 ,      255 , 'vehicle'         , 7       , True         , True         , (  0,  0, 90) ),
    Label(  'trailer'              , 30 ,      255 , 'vehicle'         , 7       , True         , True         , (  0,  0,110) ),
    Label(  'train'                , 31 ,       16 , 'vehicle'         , 7       , True         , False        , (  0, 80,100) ),
    Label(  'motorcycle'           , 32 ,       17 , 'vehicle'         , 7       , True         , False        , (  0,  0,230) ),
    Label(  'bicycle'              , 33 ,       18 , 'vehicle'         , 7       , True         , False        , (119, 11, 32) ),
    Label(  'license plate'        , -1 ,       -1 , 'vehicle'         , 7       , False        , True         , (  0,  0,142) )
For instances label, we randomize the color for each class,like car, pedestrian, truck and bus, we do not have instances label for static object like builidngs.
## sumo vehicle type parameters
Vehicle type are choosen by the [sumo vehicle type default parameter](http://sumo.dlr.de/wiki/Vehicle_Type_Parameter_Defaults).
## Note to myself
When we import a model from other 3d vendors to C4D, somehow, some materials are converted to transparency(unfortunately, for the most of the time, the shading for preview does not show us that effect distinctly), and the transparent property(especially for uber material) will cause lots of fireflies in the pbrt rendered image, so it would be a good habit to always check the material property before we convert the 3d model into pbrt format.
