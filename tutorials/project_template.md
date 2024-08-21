Back to [Main Page](https://github.com/jsachs802/research_overview/blob/main/README.md)

I often have to work on a lot of projects at once, and it becomes time consuming to setup each new project with a file directory for R scripts, Python scripts, and data, setup a virtual environment, install some standard libraries, and intialize git. 

An easy way to streamline this process is to setup a bash script that you can run from the terminal to setup new projects. The bash script I use looks like this: 

```bash

#!/usr/local/bin/bash


# Check if a project name was provided 
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <ProjectName>"
  exit 1
fi


PROJECT_NAME=$1


# Create project directory structure
echo "Creating project directories..."
mkdir -p ${PROJECT_NAME}/{data,python,r}
touch ${PROJECT_NAME}/python/{main.py,notebook.ipynb}
touch ${PROJECT_NAME}/r/main.R


# Set up Python virtual environment and install modules
echo "Setting up Python environment..."
conda create -y -p ${PROJECT_NAME}/python/venv python=3.9
source activate ${PROJECT_NAME}/python/venv
conda install -y  numpy pandas matplotlib seaborn scipy scikit-learn jupyter


# Create a blank Jupyter notebook
echo "Creating a blank Jupyter notebook..."
echo '{
 "cells": [],
 "metadata": {},
 "nbformat": 4,
 "nbformat_minor": 2
}' > ${PROJECT_NAME}/python/notebook.ipynb


# Set up R environment and install packages 
echo "Setting up R environment..." 
Rscript -e "install.packages(c('tidyverse', 'data.table', 'caret', 'ggplot2'), repos='http://cran.us.r-project.org')" >/dev/null 2>&1


# Initialize Git and create a .gitignore file
echo "Initializing Git and creating .gitignore..." 
git init ${PROJECT_NAME}
echo "python/venv/" > ${PROJECT_NAME}/.gitignore
echo "*.ipynb_checkpoints" >> ${PROJECT_NAME}/.gitignore
echo ".Rhistory" >> ${PROJECT_NAME}/.gitignore
echo ".RData" >> ${PROJECT_NAME}/.gitignore
echo "data/" >> ${PROJECT_NAME}/.gitignore

conda  deactivate


echo "Project setup is complete!"


```

The script automates the project setup. It first, checks if a project name was provided. It then creates the directory for the project, with folders for R scripts, Python scripts, and data. It also creates blank scripts in these folders, and a jupyter notebook in the python folder. An environment is created for the project, and Python libraries that I frequently use like pandas, numpy, jupyter, etc. are installed. It also installs R packages I frequently use. It finally initializes git and creates a standard .gitignore script that I would typically use. This makes setting up new projects very simple: I simply run ./project_setup.sh <new_project_name> in the terminal. I keep this bash script in a folder for projects, so whenever I create a new project I change my directory to the project folder and run the script.  
