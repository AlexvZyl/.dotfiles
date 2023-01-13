# Update system.
sudo pacman -Syyu

# Get the rust things.
sudo pacman -S rustup

# Now install rust.
rustup install nightly

# Get dem dependancies.
sudo pacman -S cairo gtk3 pango gdk-pixbuf2 glib2 gcc-libs glibc

# Build from source.
mkdir github
sudo rm -rdf github/ # Make sure it is empty.
git clone https://github.com/elkowar/eww github/
cd github/
cargo build --release
cd target/release/
chmod +x eww
sudo cp -f eww /usr/bin

# Set permissions.
cd $HOME/.config/eww/
chmod +x run.sh
