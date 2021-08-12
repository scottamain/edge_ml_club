#!/bin/bash
set -e

export REPO_PROJECT="scottamain"
export REPO_NAME="aiy-coral-kit"

function get_repo () {
    # Check if repo exists
    if [ -d "${REPO_NAME}" ]; then
      echo "${REPO_NAME} directory exists. Skipping git clone."
      return
    fi
    
    # Check if git is installed
    git=`dpkg -l | grep "ii  git " | wc -l`
    if [ $git -eq 0 ]; then
        echo "Installing git..."
        sudo apt-get update
        apt-get install git -y
    fi

    git clone https://github.com/${REPO_PROJECT}/${REPO_NAME}
}

function enable_camera () {
    CAM=$(sudo raspi-config nonint get_camera)
    if [ $CAM -eq 1 ]; then
        sudo raspi-config nonint do_camera 0
        echo "Camera is now enabled, but you must reboot for it to take effect."
        echo "After reboot, run setup.sh again to finish the setup."
      
        while true; do
          echo
          read -p "Reboot now? (y/n) " yn
          case $yn in
            [Yy]* )
              echo "Rebooting..."
              sudo reboot now; break;;
            [Nn]* )
              echo "Setup cancelled. You must reboot to continue setup."; exit;;
            * )
              echo "Please answer yes or no.";;
          esac
        done
    else
      echo "Camera is already enabled."
    fi
}

echo
echo "Checking the camera..."
enable_camera

echo
echo "Installing required packages for Coral..."
echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | sudo tee /etc/apt/sources.list.d/coral-edgetpu.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

sudo apt-get update && sudo apt-get -y install \
  libedgetpu1-max \
  python3-pycoral \
  python3-tflite-runtime \
  python3-numpy \
  python3-pyaudio \
  python3-opencv
echo "Done."

echo
echo "Downloading AIY Coral Kit repo..."
get_repo
echo "Done."

echo
echo "Downloading model files..."
(cd "${REPO_NAME}" && bash install_requirements.sh)
echo "Done."

echo
echo "Setup is done."


# TODO: First check if display is available
while true; do
  echo
  read -p "Run a quick hardware test? (y/n) " yn
  case $yn in
    [Yy]* )
      echo
      (cd "${REPO_NAME}" && python3 test.py); break;;
    [Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
  esac
done

while true; do
  echo
  read -p "Try the face detection demo? (y/n) " yn
  case $yn in
    [Yy]* )
      echo "Press Q to quit the demo."
      (cd "${REPO_NAME}" && python3 detect_faces.py); break;;
    [Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
  esac
done

echo
echo "All done! See more demos in ${REPO_NAME}/."