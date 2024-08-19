# STEP ONE - FORMULATE ORTHOGONAL HASHTAGS ------------------------------------

### --------------------------Load and Format Embedding Space ------------------
# INPUTS: 
# open_path - file path to open pre-trained embedding space
#
# OUTPUTS: 
# pre-processed embedding space (matrix)

embed_process_fn <- function(open_path = embed_path){
  
  twit_embed <- data.table::fread(open_path) # Load pre-trained embedding space
  twit_mat <- as.matrix(twit_embed[, 2:201]) ## convert to matrix from dataframe, the first column contains the words
  dimnames(twit_mat) <- list(twit_embed$V1, 1:200) ## apply rownames # Uses the first column (words) as rownames 
  
  selected_rows <- stringr::str_extract(rownames(twit_mat), pattern = "[A-Z|a-z|0-9]+") ### keep only english alphabet letters and numbers
  selected_rows <- selected_rows[!is.na(selected_rows)] ## remove NAs
  twit_mat2 <- twit_mat[rownames(twit_mat) %in% selected_rows, ] ## subset embedding space to subset of words
  
  return(twit_mat2)
  
}


### -------------------- Load and Format English Dictionary ---------------------
# INPUTS: 
# open_path = file path to slang dictionary
#
# OUTPUTS: 
# dictionary (character vector) of english and slang terms for language subsetting


dic_fn <- function(open_path = dictionary_path){
  
  load(open_path) ### Load slang dictionary
  dic <- c(lexicon::grady_augmented, slang_dictionary)
  
  return(dic)
}


### --------------------- Create Orthogonal Hashtag List -----------------------
# INPUTS: 
# hashtag - (character) - hashtag of interest
# embed - (matrix) embedding space matrix 
# rounding - (integer) specification for rounding 
# dic - (character vector) - dictionary for subsetting language
#
# OUTPUTS:
# orthogonal hashtag object - (named list) - names: hashtags, values: cosine similarity


orthog_fn <- function(hashtag, embed, rounding = 2, dic){
  
  hash_mat <- embed[rownames(embed) == hashtag, ] ## create cue matrix
  hasht <- t(hash_mat) # transpose cue matrix 
  dimnames(hasht) <- list(hashtag, 1:ncol(embed)) # add dimension names to cue matrix
  
  cue_sims <- text2vec::sim2(hasht, embed, method = "cosine") ## finds cosine similarity 
  
  round_zeros <- which(round(cue_sims, digits = rounding) == 0, arr.ind = T, useNames = T) ## finds words that have close to zero similarity
  ## With rounding = 2, counts anything below 0.005 and above -0.005 as close enough to zero 
  
  orthogs <- cue_sims[1, c(round_zeros[, 2])]  ## creates vector of orthogonal words
  
  grady_orthogs <- orthogs[names(orthogs) %in% dic] ## subsets those words to English words in Grady's Augmented Dictionary 
  
  return(grady_orthogs)
  
}


### ------------- Function for All Steps (Orthogonal Hashtags) -----------------
# INPUTS:
# hash - (character) - hashtag of interest
# path - (character) - file path to save object
# rounding - (integer) specification for rounding 
#
# OUTPUTS: 
# orthogonal hashtag object - (named list) - names: hashtags, values: cosine similarity


orthog_hash_fn <- function(paths, hash, rounding){
  
  twit_mat <- embed_process_fn(paths[1]) # Load and format embedding space <paths[1]>
  
  dict <- dic_fn(paths[2]) # Load and format dictionary <paths[2]>
  
  # Create orthogonal hashtag list
  orthogonal_hashtags <- orthog_fn(hashtag = hash, embed = twit_mat, rounding = 2, dic = dict)
  
  save(orthogonal_hashtags, file = paths[3]) # Save orthogonal hashtags list <paths[3]>
  
}