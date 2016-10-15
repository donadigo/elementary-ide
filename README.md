# elementary IDE
An _unofficial_ elementary OS (Vala) oriented IDE.

![Alt text](http://i.imgur.com/A4gkLmw.png "Screenshot")

## Planned features
1. Complete Vala support (highlighting, symbol previewing, live error reporting)
2. Build system (CMake, Make)
3. Editor Split View
4. Debbuging
5. Symbol tree
6. Auto-fetching build system options
7. elementary OS specific features (debian packaging, publishing to AppCenter)

## Compiling
At this moment there is no repository for easy installation, you will need to compile this project on your own.
Here 3 steps which will guide you through the compiling process:

### 1. Installing dependencies:
  These are the required dependencies in order to build elementary IDE:
  * `libgranite-dev`
  * `libgtksourceview-3.0-dev`
  * `libvala-0.34-dev`
  * `libvte-2.91-dev`
  * `libgee-0.8-dev`
  * `libvaladoc-dev`
  
  
  #### If you are on elementary OS (Loki) you can install them all with this command:
  ```shell
sudo apt install libgranite-dev libgtksourceview-3.0-dev libvala-0.34-dev libvte-2.91-dev libgee-0.8-dev libvaladoc-dev
```


  #### If you are on Ubuntu-based (only >= 16.04) system you will need additional repositories to install all needed dependenices (untested):
  ```shell
sudo add-apt-repository ppa:elementary-os/stable
sudo add-apt-repository ppa:elementary-os/os-patches
sudo apt update
```

  And then install the dependencies:
  ```shell
sudo apt install libgranite-dev libgtksourceview-3.0-dev libvala-0.34-dev libvte-2.91-dev libgee-0.8-dev libvaladoc-dev
```

### 2. The actual compiling:
  1. Clone this repository or download and unpack it.
  2. Open a terminal and `cd` into the root of this project.
  3. Execute these commands in the following order:
  
  ```shell
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make
```

### 3. Installing & running the project:
  1. Once you've done step 2, without closing the terminal, install elementary IDE by executing this command:
  ```shell
  sudo make install
  ```
  
  2. There is currently no .desktop launcher for the IDE, but you can run it with this command:
  ```shell
  elementary-ide
  ```
  
  3. The end!
