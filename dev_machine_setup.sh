#!/bin/bash
. _shared.sh
# This bash script will set up (or update) your development environment for Ubuntu (v=>9.10)

scripts=""
apt_packages=""  # Installs all packages in a single transaction

if [[ $EUID -eq 0 ]]; then
  echo -e "\e[01;31mPlease do not use sudo to run this script!\e[00m" 2>&1
  exit 1
fi

echo -e "
---------------------------------
| Ubuntu Developer Setup Script |
---------------------------------\n"

# Prerequisites
# -------------------------------------
# Requires root permissions
sudo true

# '--all' flag installs everything
if [ "$1" = "--all" ]; then
  echo "== Setting up default environment..."
  scripts="packages dropbox skype keepass2 netrc rc git_config ruby_dotfiles
           gimp gedit vim gnome conky startup tomate apt-install rvm "
  prompt_for_git
  prompt_for_netrc

# '--update' flag updates everything that doesn't require user input
elif [ "$1" = "--update" ]; then
  echo "== Running default update..."
  scripts="packages rc ruby_dotfiles gedit vim gnome conky startup tomate apt-install "

# If no flag given, ask user which scripts they would like to run.
else
  confirm_by_default "Git config" 'git_config'
  if [[ "$scripts" =~ "git_config" ]]; then prompt_for_git; fi # prompt for git user details
  confirm_by_default "~/.netrc"   'netrc'
  if [[ "$scripts" =~ "netrc" ]]; then prompt_for_netrc; fi # prompt for git user details

  confirm_by_default "apt packages"                 'packages'
  confirm_by_default "Dropbox"                      'dropbox'
  confirm_by_default "Skype"                        'skype'
  confirm_by_default "Keepass 2"                    'keepass2'
  confirm_by_default "bashrc, irbrc, ackrc, etc."   'rc'
  confirm_by_default "ruby config (dotfiles)"       'ruby_dotfiles'
  confirm_by_default "Gimp (latest ppa version)"    'gimp'
  confirm_by_default "Tomate (widget)"              'tomate'
  confirm_by_default "gedit customizations"         'gedit'
  confirm_by_default "vim customizations"           'vim'
  confirm_by_default "gnome themes and fonts"       'gnome'
  confirm_by_default "conky (system stats)"         'conky'
  confirm_by_default "FF, term & gedit on startup"  'startup'
  # Defines the point where script should install packages
  scripts+="apt-install "
  confirm_by_default "RVM (Ruby Version Manager)"   'rvm'

  echo -e "\n===== Thanks. Now executing 'rm -rf /'...       No, not really."
fi

scripts=`echo $scripts`  # Remove line-breaks
echo -e "\n===== Now executing the following scripts:"
echo -e   "      [ $scripts ]\n"


# Include each configured script
# --------------------------------------------------------------
for script in $scripts; do
  if [[ "$script" =~ "apt-install" ]]; then
    # Update sources and install apt packages
    # --------------------------------------------------------------
    echo "== Updating apt sources..."
    sudo apt-get update -qq
    echo "== Installing apt packages..."
    sudo apt-get install -ym $apt_packages | grep -v "is already the newest version"
    sudo apt-get autoremove -ym
  else
    . $script\_setup.sh
  fi
done

# Restarting nautilus for dropbox and image resizer
nautilus -q


echo -e "\n===== Ubuntu development machine has been set up!\n"
echo -e "Further manual configuration may be needed:\n"
echo "    Synergy - Copy your synergy conf to '/etc/synergy.conf' & add to startup:"
echo "              synergys --config '/etc/synergy.conf'"
echo "    Dropbox Symlinks - Run 'dropbox_links_setup.sh' after you have set up your Dropbox account."
echo

