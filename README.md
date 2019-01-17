# tuxmark

tuxmark is a set of benchmarks for headless linux systems.

## tuxmark-cats

![Cat](var/testing_data/cats/cat.4061.jpg)

tuxmark-cats uses a convolutional neural network to classify a set of over 1000 cat pictures and calculates a score based on the time needed to classify all images.
To start the benchmark run the tuxmark-cats.sh bash script. On first run, a python virtual environment will be created and the python dependencies installed. 
Make sure you install the system dependencies before running tuxmark-cats
`apt install python3-pip bc libxrender-dev libsm6 libxext6`

## tuxmark-kernel
tuxmark-kernel compiles the linux kernel using all available cores and calculates the score based on the time needed.
To start the benchmark run the tuxmark-kernel.sh bash script. On first run, a copy of the 4.20 Kernel source code will be downloaded from kernel.org.
Make sure you install all build dependencies first
`apt install build-essential libncurses5 bison flex libssl-dev libelf-dev`
