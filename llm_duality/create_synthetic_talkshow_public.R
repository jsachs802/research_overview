### Create "real" Synthetic News Transcripts
library(httr)
library(jsonlite)
library(tidyverse)
library(randomNames)

# GPT Model
model_3.5 = "gpt-3.5-turbo"

# api key
apiKey <- "#####################################################################"

### FUNCTIONS ###


# GET NUMBER OF PARTICIPANTS 
# SUMMARY: Ask gpt for the number of participants for its Fox News talk show
#
# INPUTS: no inputs
#
# OUTPUTS: integer output for number of participants
#
get_number_of_participants <- function(){
  
  # Prompt for getting participants
  participant_prompt = list(
    list(role = "user", content = "Pretend you are creating a typical Fox News talk show, how many different participants should be on the show? Please provide a single numerical result..."))
  
  # Make request with GPT for number of participants
  participant_response = POST(
    url = "https://api.openai.com/v1/chat/completions", 
    add_headers(Authorization = paste("Bearer", apiKey)),
    content_type_json(),
    encode = "json",
    body = list(
      model = model_3.5,
      max_tokens = 100, # Limit response to 100 tokens
      temperature = 1, # Max temperature - max creativity
      messages = participant_prompt
    )
  )
  
  # Select content from GPT response
  result <- content(participant_response, "parsed")
  generated_response <- result$choices[[1]]$message$content
  number_of_participants <- as.numeric(gsub("[^0-9]", "", generated_response))
  
  
  return(number_of_participants)
  
}


# GET TOPICS FOR TALK SHOW
# SUMMARY: Ask gpt for topics for the show 
#
# INPUTS: nodes - number of participants in talkshow
#
# OUTPUTS: cleaned_topics - set of news topics for talkshow
#
get_topics <- function(nodes){
  
  # Prompt for getting participants
  topic_prompt = list(
    list(role = "user", content = paste("Pretend you are creating a typical Fox News talk show with", nodes, "participants. Give a list of topic-headlines that you would cover in a single show. Provide headlines that align with conservative viewpoints often found on Fox News...")))
  
  # Make request with chatgpt
  topics_response = POST(
    url = "https://api.openai.com/v1/chat/completions", # API url
    add_headers(Authorization = paste("Bearer", apiKey)),
    content_type_json(),
    encode = "json",
    body = list(
      model = model_3.5, # Model parameter
      max_tokens = 500,
      temperature = 1, # Temperature (0 - 1): 1 creates diverse and highly creative responses. 
      messages = topic_prompt # Prompt parameter
    )
  )
  
  # Response
  result <- content(topics_response, "parsed") # Retrieve the content of the request
  generated_response <- result$choices[[1]]$message$content # Select the response
  
  # Split the response into a vector of topics
  topics_vector <- unlist(strsplit(generated_response, "\n"))
  
  # Remove any empty elements
  topics_vector <- topics_vector[topics_vector != ""]
  
  # Remove AI notes if present 
  # Check if the first and last elements don't have a number
  if (!grepl("^\\d+\\.\\s*", topics_vector[1]) &&
      !grepl("^\\d+\\.\\s*", topics_vector[length(topics_vector)])) {
    
    # Remove the first and last elements
    topics_vector <- topics_vector[-c(1, length(topics_vector))]
  }
  
  # Catch of any further notes 
  topics_vector <- topics_vector[!grepl("^Note:|Please note", topics_vector)]
  
  # Clean up each topic
  cleaned_topics <- gsub("^\\d+\\.\\s*\"(.*?)\"$", "\\1", topics_vector)
  
  # Return cleaned topics
  return(cleaned_topics)
  
}


# INTRO TOPIC FUNCTION 
# SUMMARY: Use to start the talkcshow with a news topic, also used to change topics
#     NOTE: Meant to be used within for loop
#
# INPUTS: 
#     new_topic - new topic to introduce from the object <topics[i]>
#     old_topic - previous topic, if prior topic exists 
#     i - iterating variable for looping
#     tops - variable that holds list of topics in function
#     character - character from list of talk show participants 
#
# OUTPUTS: returns dialogue from host introducing new topic. 
#

create_intro_topic <- function(new_topic = NA, old_topic = NA, i, tops, character){
  
  # Prompt
  if(i == 1){
    # On the first iteration, start the show
    prompt = list(
      list(role = "user", content = paste0("Pretend you are the host of a Fox News talk show discussing the topic of: ", new_topic, ". Your name is, ", character, ". Provide an introduction in less than 200 words using a perspective that aligns with conservative viewpoints often found on Fox News...")),
      list(role = "assistant", content = "FOX NEWS HOST:...")
    )
    
  }else if(i == "end"){
    # For concluding the show
    prompt = list(
      list(role = "user", content = paste0("Pretend you are the host of a Fox News talk show. Your name is, ", character, ". You and your guests have just finished discussing the following topics: ", paste(tops, collapse = ": "), ". Conclude your talk show in less than 200 words using a perspective that aligns with conservative viewpoints often found on Fox News...")),
      list(role = "assistant", content = "FOX NEWS HOST:...")
    )
    
  }else{
    # On subsequent iterations, change the subject
    prompt = list(
      list(role = "user", content = paste0("Pretend you are the host of a Fox News talk show. Your name is, ", character, ". You and your guests have just finished discussing the topic of: ", old_topic, ". Provide an introduction in less than 200 words to the new topic of: ", new_topic, "using a perspective that aligns with conservative viewpoints often found on Fox News...")),
      list(role = "assistant", content = "FOX NEWS HOST:...")
    )
    
  }
  
  # Generate introduction to new topic by show host
  intro_topic_response = POST(
    url = "https://api.openai.com/v1/chat/completions", 
    add_headers(Authorization = paste("Bearer", apiKey)),
    content_type_json(),
    encode = "json",
    body = list(
      model = model_3.5,
      max_tokens = 1000,
      temperature = 0.2,
      messages = prompt
    )
  )
  
  # Select content of gpt response
  intro_response <- content(intro_topic_response)$choices[[1]]$message$content
  
  # Remove speaker prompt
  intro_response <- sub(".*?:", "", intro_response)
  
  # Sleep in between requests to control for rate limits
  Sys.sleep(10)
  
  
  return(paste0(character, ": ", intro_response))
  
}



# CREATE CONVERSATION AROUND TOPIC 
# SUMMARY: Ask gpt to have participants share their viewpoint on topics
#   NOTE: Randomly selects speaker from a list the list of available speakers to add a conversation point.
#         Once a participant has spoken they will not be selected again until list of participants has been
#         exhausted, at which time the list of characters is replenished. 
#
# INPUTS: 
#     intro_text - introduction to topic produced by create_intro_topic()
#     topic - topic of conversation
#     n - average number of times each participant should speak
#     available - list of available participants
#     statuses - list of statuses ("Host" or "Guest") for each participant
#     current - current participant in talk show 
#
# OUTPUTS: returns dialogue from host introducing new topic. 
#

create_talkshow_views <- function(intro_text, topic, n = 3, available, statuses, current){
  
  previous_text <- c()
  previous_text[[1]] <- paste(intro_text, "\n")
  
  for(i in 1:(n*3)){
    
    # Vector of response lengths to request from GPT
    # NOTE: Length of responses are sampled between 20 and 150 words - GPT said this was typical
    word_counts <- c(10:30, 50, 100)
    word_length = sample(word_counts, 1) # Randomly select response length

    # For first iteration of for loop
    if(i == 1){
      # For generating realistic commentary
      # last speaker is the one currently under current
      previous = current
      # next speaker cannot be host
      current = sample(available[available %in% attributes(statuses[statuses != "Host"])$names], 1)
      
      # Prompt for talking point on i == 1
      similar_edge <- list(
        list(role = "user", content = paste0("Pretend you are a guest named, ", current," on a Fox News talk show and respond to the previous viewpoint. Limit your response to less than ", word_length, " words. Add to the conversation with a new viewpoint but one that aligns with conservative viewpoints often found on Fox News...")),
        list(role = "assistant", content = paste0("The previous viewpoint on the talk show was from ", previous, " a ", statuses[attributes(statuses)$names == current], ": ", previous_text[[i]], " on the topic of: ", topic, "..."))
      )
      
    }else{ # For iterations i > 1
      
      # Set previous to last current
      previous = current
      
      # If available names run out, replenish it, remove the current, and sample 
      if(length(available) == 1){
        available = available[!(available %in% previous)]
        current = sample(available, 1)
      }else{
        available = available[!(available %in% previous)]
        current = sample(available, 1)
        
      }
      
      # Prompt for talking point on i > 1
      similar_edge <- list(
        list(role = "user", content = paste0("Pretend you are a ", statuses[attributes(statuses)$names == current]," named ", current,"on a Fox News talk show and respond to the previous viewpoint. Limit your response to less than ", word_length, " words. Add to the conversation with a new viewpoint but one that aligns with conservative viewpoints often found on Fox News...")),
        list(role = "assistant", content = paste0("The previous viewpoint on the talk show was from ", previous, " a ", statuses[attributes(statuses)$names == previous], ": ", previous_text[[i]], " on the topic of: ", topic, "..."))
      )
    }
    
    # Request participant viewpoint, given prompt, from GPT
    similar_response <-  POST(
      url = "https://api.openai.com/v1/chat/completions", 
      add_headers(Authorization = paste("Bearer", apiKey)),
      content_type_json(),
      encode = "json",
      body = list(
        model = model_3.5,
        max_tokens = 300,
        temperature = 0.2,
        messages = similar_edge
      )
    )
    
    # Select and clean content of response
    result <- sub(".*?:", "", content(similar_response)$choices[[1]]$message$content)
    
    # Assign newly created text to previous_text for next iteration
    previous_text[[i+1]] <- paste0(current, ": ", result, "\n")
    
    Sys.sleep(10)
    
  }
  
  return(previous_text)
}



### CREATING THE NEWS TRANSCRIPT 
# 1. Initialize talk show
# 1a. Get number of participants or nodes
nodes <- get_number_of_participants() 
# 1b. Get topics for show 
topics <- get_topics(nodes) 

# 2. Generate speaker names and statuses
# 2a. Generate random names for participants
available_speakers  <- randomNames(n = nodes, ethnicity = c(5), which.names = "first")
# 2b. Assign statuses ("Host" or "Guest" to speaker names)
statuses = c("Host", rep("Guest", (nodes-1)))
names(statuses) = available_speakers

# 3. START OF NEWS TRANSCRIPT
  # NOTE: First iteration is completed outside of for loop
# 3a. Initialize list object for participant text 
dialogue <- vector(mode = "list", length = length(topics))

# 3b. Start the show - host introduces topic
topic_start = create_intro_topic(new_topic = topics[1], i = 1, tops = topics, 
                                 character = attributes(statuses[statuses == "Host"])$names)

# 3c. Set current speaker to host
current_speaker = attributes(statuses[statuses == "Host"])$names

# 3s. Get participant viewpoints 
dialogue[[1]] <- create_talkshow_views(topic_start, topics[1], n = nodes, 
                                       available = available_speakers, 
                                       statuses = statuses, 
                                       current = current_speaker)

# 4. CONTINUE TRANSCRIPT FOR REST OF TOPICS
# 4a. Iterate over rest of topics
for(i in 2:length(topics)){
  
  # Continue show:(i = 1 gpt starts the talk show; i > 1 gpt changes subject as if returning from commercial)
  topic_start = create_intro_topic(new_topic = topics[i], old_topic = topics[i-1], i = i, tops = topics,
                                   character = attributes(statuses[statuses == "Host"])$names)
  
  # Get participant viewpoints
  dialogue[[i]] <- create_talkshow_views(topic_start, topics[i], n = nodes, 
                                         available = available_speakers, 
                                         statuses = statuses, 
                                         current = current_speaker)
  
  print(i)
}


# 5. END TRANSCRIPT 
# 5a. Sign off from (conclude) talk show 
topic_start = create_intro_topic(old_topic = topics[-1], i = "end", tops = topics, 
                                 character = attributes(statuses[statuses == "Host"])$names)

# 5b. Add sign off to list of dialogue and unlist to the dialogue to generate transcript
text_list <- c(unlist(dialogue), topic_start)
transcript <- paste(text_list, collapse = " ")

