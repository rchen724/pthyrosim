# p-THYROSIM Readme

## Step 1: Install Xcode
  Install [Xcode]([url](https://apps.apple.com/us/app/xcode/id497799835/)) 
  
  System requirements: 
  *macOS: Ventura 13 or Sonoma 14+ (Apple Silicon or Intel)
  *Xcode: 15.x or newer (includes iOS 17 SDK)
  *Disk space: ~20–30 GB free (Xcode + Simulators)
  *Command Line Tools: Installed with Xcode
  
  Steps:
  *Install XCode from Mac App Store
  *Open Xcode once and allow additional components to install.
  *(Optional) Install extra simulators: Xcode → Settings → Platforms → +.
  *Verify CLI tools in Terminal.
   ###In terminal:
    xcode-select -p
    #If this errors, point to your Xcode app:
    sudo xcode-select --switch /Applications/Xcode.app
  
## Step 2: Clone github Repository:
  1. In Terminal, choose a working folder and clone:
  ###
  mkdir -p ~/dev && cd ~/dev
    git clone https://github.com/rchen724/pthyrosim.git
    cd pthyrosim
     
## Step 3: Running the Project: 
  1. Paste the following commands into your terminal window:
  
  ###
  git pull
  #We recommend that you run this command at the start of every session
  
  2. Open you Xcode application and open the tile 'iosapp.xcodeproj' that is in your project folder.

## Saving Changes to the Remote Repository
  The following commands will save your changes onto the repository for everyone to see.
  1. git add .
  2. git commit -m "Insert Commit Message"
  3. git push
