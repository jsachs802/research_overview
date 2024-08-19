### Create "manipulated" Synthetic News Transcripts
library(httr)
library(jsonlite)
library(tidyverse)
library(randomNames)

# GPT Model
model_3.5 = "gpt-3.5-turbo"

# Api key
apiKey <- "#############################################"


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
  
  # Return content with host character name, ":" and the introduction to a new topic.
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
#     edges - edge_type
#
# OUTPUTS: returns dialogue from host introducing new topic. 
#

create_talkshow_views <- function(intro_text, topic, n = 3, available, statuses, current, edges){
  
  previous_text <- c()
  previous_text[[1]] <- paste(intro_text, "\n")
  
  for(i in 1:(n*3)){
    
    #Prompt
    word_counts <- c(10:30, 50, 100)
    # Length of responses are sampled between 20 and 150 words - GPT said this was typical
    word_length = sample(word_counts, 1)
    # print(word_length) # for testing
    print(word_length)
    
    # For the first iteration
    if(i == 1){
      # For generating realistic commentary
      # current speaker become previous speaker
      previous = current
      # next speaker cannot be host
      current = sample(available[available %in% attributes(statuses[statuses != "Host"])$names], 1)
      
      if(edges == "high"){
        # For high similarity conversation
        prompt <- list(
          list(role = "user", content = paste0("Pretend you are a guest named, ", current," on a Fox News talk show current and respond to the previous viewpoint. Limit your response to less than ", word_length, " words. Add to the conversation with an extremely similar viewpoint...")),
          list(role = "assistant", content = paste0("The previous viewpoint on the talk show was from ", previous, " a ", statuses[attributes(statuses)$names == current], ": ", previous_text[[i]], " on the topic of: ", topic, "..."))
        )
        
      }else if(edges == "real"){
        # For generating real commentary
        prompt <- list(
          list(role = "user", content = paste0("Pretend you are a guest named, ", current," on a Fox News talk show current and respond to the previous viewpoint. Limit your response to less than ", word_length, " words. Add to the conversation with a new viewpoint but one that aligns with conservative viewpoints often found on Fox News...")),
          list(role = "assistant", content = paste0("The previous viewpoint on the talk show was from ", previous, " a ", statuses[attributes(statuses)$names == current], ": ", previous_text[[i]], " on the topic of: ", topic, "..."))
        )
        
      }else if(edges == "low"){
        # For low simlilarity conversation
        prompt <- list(
          list(role = "user", content = paste0("Pretend you are a guest named, ", current," on a Fox News talk show current and respond to the previous viewpoint. Limit your response to less than ", word_length, " words. Add to the conversation with an extremely different viewpoint...")),
          list(role = "assistant", content = paste0("The previous viewpoint on the talk show was from ", previous, " a ", statuses[attributes(statuses)$names == current], ": ", previous_text[[i]], " on the topic of: ", topic, "..."))
        )
        
      }
      
    }else{
      
      # Set previous to last current
      previous = current
      
      # If available names run out, replenish it, remove the current, and sample randomly
      if(length(available) == 1){
        available = available[!(available %in% previous)]
        current = sample(available, 1)
      }else{
        available = available[!(available %in% previous)]
        current = sample(available, 1)
        
      }
      
      # Prompts for iterations i > 1
      if(edges == "high"){
        # For high similarity conversation
        prompt <- list(
          list(role = "user", content = paste0("Pretend you are a guest named, ", current," on a Fox News talk show current and respond to the previous viewpoint. Limit your response to less than ", word_length, " words. Add to the conversation with an extremely similar viewpoint...")),
          list(role = "assistant", content = paste0("The previous viewpoint on the talk show was from ", previous, " a ", statuses[attributes(statuses)$names == current], ": ", previous_text[[i]], " on the topic of: ", topic, "..."))
        )
        
      }else if(edges == "real"){
        # For generating real commentary
        prompt <- list(
          list(role = "user", content = paste0("Pretend you are a guest named, ", current," on a Fox News talk show current and respond to the previous viewpoint. Limit your response to less than ", word_length, " words. Add to the conversation with a new viewpoint but one that aligns with conservative viewpoints often found on Fox News...")),
          list(role = "assistant", content = paste0("The previous viewpoint on the talk show was from ", previous, " a ", statuses[attributes(statuses)$names == current], ": ", previous_text[[i]], " on the topic of: ", topic, "..."))
        )
        
      }else if(edges == "low"){
        # For low simlilarity conversation
        prompt <- list(
          list(role = "user", content = paste0("Pretend you are a guest named, ", current," on a Fox News talk show current and respond to the previous viewpoint. Limit your response to less than ", word_length, " words. Add to the conversation with an extremely different viewpoint...")),
          list(role = "assistant", content = paste0("The previous viewpoint on the talk show was from ", previous, " a ", statuses[attributes(statuses)$names == current], ": ", previous_text[[i]], " on the topic of: ", topic, "..."))
        )
        
      }
    }
    
    # Make request to chatgpt, given prompt, to act as specified participant in conversation
    similar_response <-  POST(
      url = "https://api.openai.com/v1/chat/completions", 
      add_headers(Authorization = paste("Bearer", apiKey)),
      content_type_json(),
      encode = "json",
      body = list(
        model = model_3.5,
        max_tokens = 300,
        temperature = 0.2,
        messages = prompt
      )
    )
    
    # Select content of result
    result <- sub(".*?:", "", content(similar_response)$choices[[1]]$message$content)
    
    # assign newly created text for next response
    previous_text[[i+1]] <- paste0(current, ": ", result, "\n")
    
    # Sleep to avoid rate limits
    Sys.sleep(10)
    
  }
  
  return(previous_text)
}



### CREATING THE NEWS TRANSCRIPT PROCEDURE

# 1. Initialize talk show

# 1a. Create nodes variable
# Number of participants in talkshow
nodes

# 1b. Generate edge_type variable
# Degree of similarity between participants and their talking points
# "high" = high similarity 
# "low" = low similarity 
# "real" = realistic amount of similarity
edge_type

# 2. Ask GPT to generate topics for show
topics <- get_topics(nodes) 

# 3. Create participants for talk show

# 3a. randomly generate some participant names using randomNames() function
available_speakers <- randomNames(n = nodes, ethnicity = c(5), which.names = "first")

# 3b. Assign statuses ("Host" or "Guest") to participant names
statuses = c("Host", rep("Guest", (nodes-1)))
names(statuses) = available_speakers

# Dialogue 
dialogue <- vector(mode = "list", length = length(topics))

# 4. START OF TRANSCRIPT
  # First iteration (initialization of show is completed outside of for loop)

# 4a. Start the show - host introduces topic
topic_start = create_intro_topic(new_topic = topics[1], i = 1, tops = topics, 
                                 character = attributes(statuses[statuses == "Host"])$names)

## 4b. Set current speaker to host
current_speaker = attributes(statuses[statuses == "Host"])$names

# 4c. Get participant viewpoints for first topic
dialogue[[1]] <- create_talkshow_views(topic_start, topics[1], n = nodes, 
                                       available = available_speakers, 
                                       statuses = statuses, 
                                       current = current_speaker, edges = edge_type)

# 5. CONTINUE TRANSCRIPT 

# 5a. Iterate over rest of topics
for(i in 2:length(topics)){
  
  # Continue show:(i = 1 gpt starts the talk show; i > 1 gpt changes subject as if returning from commercial)
  topic_start = create_intro_topic(new_topic = topics[i], old_topic = topics[i-1], i = i, tops = topics,
                                   character = attributes(statuses[statuses == "Host"])$names)
  
  # Get participant viewpoints
  dialogue[[i]] <- create_talkshow_views(topic_start, topics[i], n = nodes, 
                                         available = available_speakers, 
                                         statuses = statuses, 
                                         current = current_speaker, edges = edge_type)
  
  print(i)
}


# 6. END TRANSCRIPT 
# 6a. Sign off from talk show 
topic_start = create_intro_topic(old_topic = topics[-1], i = "end", tops = topics, 
                                 character = attributes(statuses[statuses == "Host"])$names)


# 7. POST PROCESSING OF TRANSCRIPT 

# 7a. Concat the list of participant dialogue, add sign-off
text_list <- c(unlist(dialogue), topic_start) 
transcript <- paste(text_list, collapse = " ")
