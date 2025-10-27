# p-THYROSIM

---

## **1. Install Xcode**

- **macOS:** Ventura 13 or Sonoma 14+ (Apple Silicon or Intel)
- **Xcode:** 15.x or newer (includes iOS 17 SDK)
- **Disk space:** ~20–30 GB free (Xcode + Simulators)
- **Command Line Tools:** Installed with Xcode

**Steps**
1. Install **Xcode** from the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835/).
2. Open Xcode once and allow **additional components** to install.
3. (Optional) Install extra simulators: **Xcode → Settings → Platforms → +**.
4. Verify CLI tools in Terminal:
   ```bash
    xcode-select -p
    # If this errors, point to your Xcode app:
    sudo xcode-select --switch /Applications/Xcode.app
  `

## Step 2: Clone GitHub Repository

1. In Terminal, choose a working folder and clone:
   ```bash
   mkdir -p ~/dev && cd ~/dev
   git clone https://github.com/rchen724/pthyrosim.git
   cd pthyrosim
   ```
     
## Step 3: Run the Project

1. (Recommended) Update your local copy at the start of each session:
   ```bash
   git pull
   
   ```
  
  2. Open you Xcode application and open the tile 'iosapp.xcodeproj' that is in your project folder.

## Saving Changes to the Remote Repository
  The following commands will save your changes onto the repository for everyone to see.
  1. git add .
  2. git commit -m "Insert Commit Message"
  3. git push
