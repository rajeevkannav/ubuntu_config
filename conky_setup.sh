#!/bin/bash
. _shared.sh
echo "== Setting up conky..."

# Queue or install apt packages
apt_queue_or_install "conky-all verse"

# Install conky-colors from source
if (which conky-colors | grep -q conky-colors); then
  echo "==== conky-colors is already installed."
else
  echo "==== Installing conky-colors from source..."
  wget http://gnome-look.org/CONTENT/content-files/92328-conky_colors-5.0.tar.gz -O /tmp/conky_colors.tar.gz
  pushd /tmp
  tar zxvf conky_colors.tar.gz
  cd conky_colors
  make
  sudo make install
  rm -rf /tmp/conky_colors /tmp/conky_colors.tar.gz
  popd
fi

# Copy conky config files.
sudo rm -rf ~/.conkycolors
cp -rf assets/conkycolors ~/.conkycolors

# Set home directory placeholder
sed "s%@HOME@%$HOME%g" -i ~/.conkycolors/conkyrc

# Find out how many CPUs this computer has, and set the @CPU@ placeholder to the correct template.
cpus=`grep ^processor -i /proc/cpuinfo | wc -l`
if [ $cpus -eq 1 ]; then
  awk '/@CPU@/{system("cat ~/.conkycolors/1cpu");next}1' ~/.conkycolors/conkyrc > /tmp/conkyrc
elif [ $cpus -eq 2 ]; then
  awk '/@CPU@/{system("cat ~/.conkycolors/2cpu");next}1' ~/.conkycolors/conkyrc > /tmp/conkyrc
else
  awk '/@CPU@/{system("cat ~/.conkycolors/4cpu");next}1' ~/.conkycolors/conkyrc > /tmp/conkyrc
fi
mv /tmp/conkyrc ~/.conkycolors/conkyrc

# Run final user-specific sed script. (Each of my machines need a slightly different layout.)
if [ -e ~/.conkycolors.sed ]; then
  sed -i -f ~/.conkycolors.sed ~/.conkycolors/conkyrc
else
  cat > ~/.conkycolors.sed <<EOF
s%gap_x [0-9]*%gap_x 50%g
s%gap_y [0-9]*%gap_y 50%g
EOF

fi

# Create conky start script.
cat > ~/.start_conky <<EOF
#!/bin/sh
sleep 10 && conky -c $HOME/.conkycolors/conkyrc
EOF
chmod +x ~/.start_conky


echo "==== Configuring conky to run on startup..."
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/conky.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=$HOME/.start_conky
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Conky
Comment=System monitor for X
EOF


echo -e "==== If you have any specific customizations (e.g. layout),\n     add them to the ~/.conkycolors.sed file and run this setup script again."

