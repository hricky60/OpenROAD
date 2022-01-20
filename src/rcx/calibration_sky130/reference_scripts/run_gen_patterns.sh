# Clean up directory
rm -rf work
mkdir -p data
mkdir -p work 
cd work

# Create a soft link to openroad executable
ln -s ../../../../build/src/openroad

# Step A: Generate Patterns Layout that models
#         various capacitance and resistance
#         models.
./openroad ../script/generate_patterns.tcl

cp EXT/* ../data/sky90/
