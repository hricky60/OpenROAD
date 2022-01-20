cd work

# Step C: Generate OpenRCX tech file 
#         (OpenRCX RC table) by converting
#         the parasitics extracted from the
#         reference extractor to a RC table.
./openroad ../script/generate_rules.tcl

# Step D: Perform parasitic extraction on the 
#         pattern geometries, and compare the 
#         parasitic result with the golden parasitics 
#         calculated by reference extractor to evaluate 
#         the accuracy of the OpenRCX using the generated
#         RC table (Extraction Rule file).
./openroad ../script/ext_patterns.tcl
