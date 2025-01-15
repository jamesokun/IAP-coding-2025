# USING TAXES TO INCENTIVIZE VEGETARIANISM:
# EVIDENCE FROM PAELLA RESTAURANTS

# Víctor Quintas-Martínez
# January 2023

# MASTER FILE

# Declare paths:
BUILD_PATH="./0-build" # Important: No spaces around the "="
ANALYSIS_PATH="./1-analysis"
PAPER_PATH="./2-paper"

# STEP 0: Build ---------------------------------------------------------------
## 0.0. Create necessary directories:
INTERMEDIATE_DATA_PATH=$BUILD_PATH"/intermediate"
CLEAN_DATA_PATH=$ANALYSIS_PATH"/input"
mkdir -p $INTERMEDIATE_DATA_PATH # Use "mkdir -p" to create directory if it does not exist
mkdir -p $CLEAN_DATA_PATH

## 0.1. Simulate data:
julia --project=@. $BUILD_PATH"/code/0-1-simulate.jl" $INTERMEDIATE_DATA_PATH
# --project=@. will activate the project in the current directory or parent files

## 0.2. Clean data:
julia --project=@. $BUILD_PATH"/code/0-2-clean.jl" $INTERMEDIATE_DATA_PATH $CLEAN_DATA_PATH

# STEP 1: Analysis ------------------------------------------------------------
## 1.0. Create necessary directories:
RESULTS_PATH=$ANALYSIS_PATH"/output"
mkdir -p $RESULTS_PATH
SIMULATE_FILE=$BUILD_PATH"/code/0-1-simulate.jl"

## 1.1. Reduced Form:
julia --project=@. $ANALYSIS_PATH"/code/1-1-reduced-form.jl" $CLEAN_DATA_PATH $RESULTS_PATH

## 1.2. Counterfactuals:
julia --project=@. $ANALYSIS_PATH"/code/1-2-counterfactuals.jl" $CLEAN_DATA_PATH $RESULTS_PATH $SIMULATE_FILE

# STEP 2: Compile paper -------------------------------------------------------
pdflatex -output-directory 2-paper "\def\outputpath{$RESULTS_PATH} \input{2-paper/paper}"

# Sometimes you need to compile twice for the cross-references to be right:
pdflatex -output-directory 2-paper "\def\outputpath{$RESULTS_PATH} \input{2-paper/paper}"
