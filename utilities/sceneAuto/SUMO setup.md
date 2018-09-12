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

export SUMO_HOME="/your/path/to/sumo/"

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
