# Models
Messages = new Meteor.Collection("messages")

# Shared Methods
create_editable_message = (chat_name, my_name) ->
  Messages.insert({
    name: my_name
    incomplete: true, time: Date.now(), chat: chat_name
  })

# Client
if (Meteor.is_client)
  # For debugging
  window.Messages = Messages
  
  # Methods
  focus_login = ->
    $("#login input[type='text']").focus()
  
  update_name = ->
    my_name = $("#login input[type='text']").val()
    if my_name.length
      Session.set("my_name", my_name)
   
  update_current_chat = (chat_name) ->
    if chat_name.length
      Session.set("current_chat_name", chat_name)

  update_url = (chat_name) ->
    window.history.pushState(null, null, "/" + chat_name);
  
  join_chat = (chat_name) ->
    update_name()
    update_current_chat(chat_name)
    update_url(chat_name)
    join_current_chat()

  join_current_chat = ->
    if Session.get("current_chat_name") and Session.get("my_name")
      Meteor.call "join_chat", Session.get("current_chat_name"), Session.get("my_name"), (error, result) ->
        # Wait until render is complete
        delay 500, ->
          $("#editable textarea").focus()
          
  is_mine = (message) ->
    message.name == Session.get("my_name")
    
  is_editable = (message) ->
    is_mine(message) and message.incomplete
   
  focus_editable = ->
    $("#editable textarea").focus()

  # Events
  $(window).bind "popstate", (event) ->
    chat_name = location.pathname.substr(1) # get rid of leading /
    update_current_chat(chat_name)
    delay 50, ->
      focus_login()
  
  Meteor.startup ->
    focus_login()
  
  # Login
  Template.login.class_visible = ->
    if Session.get("current_chat_name") and Session.get("my_name") then "hidden" else "visible"
    
  Template.login.class_buttons_visible = ->
    if Session.get("current_chat_name") then "hidden" else "visible"
   
  Template.login.events = {
    'click .public': (event) ->
      chat_name = "public"
      join_chat(chat_name)
     
    'click .private': (event) ->
      chat_name = uniqueID()
      join_chat(chat_name)
     
    'keydown input[type="text"]': (event) ->
      input = $(event.target)
      code = if event.keyCode then event.keyCode else event.which
      
      if (code == 13) # Enter was pressed
        update_name()
        join_current_chat()
  }
  
  # Chat
  Template.chat.class_visible = ->
    if Session.get("current_chat_name") and Session.get("my_name") then "visible" else "hidden"
  
  Template.chat.messages = ->
    Messages.find({chat: Session.get("current_chat_name")}, {sort: {time:1}})
  
  # Messages
  Template.message.editable = ->
    is_editable(this)
  
  Template.message.id_editable = ->
    if is_editable(this) then "id=editable" else ''
  
  Template.message.class_incomplete = ->
    if this.incomplete then "incomplete" else ''
  
  Template.message.class_empty = ->
    if (not is_editable(this) and (not this.text or not this.text.length)) then "empty" else ''
  
  Template.message.class_side = ->
    if is_mine(this) then "right" else "left"
    
  Template.message.class_color = ->
    if is_mine(this) then "grey" else "blue"
    
  Template.message.events = {
    'keydown textarea': (event) ->
      code = if event.keyCode then event.keyCode else event.which
      if (code == 13) # Enter was pressed
        event.preventDefault()

    'keyup textarea': (event) ->
      input = $(event.target)
      code = if event.keyCode then event.keyCode else event.which
      updated = false
      
      if (code == 13) # Enter was pressed
        # Mark message as complete
        Messages.update(this._id, {$set: {incomplete: false, time: Date.now() - 1}})
        
        create_editable_message Session.get("current_chat_name"), Session.get("my_name")
        
        updated = true
      else if input.val().length == 0
          # This is the first character, so update the timestamp
          Messages.update(this._id, {$set: {time: Date.now()}})
          updated = true
      else
        # New character typed
        Meteor.flush() # Keep the DOM updating even while the user is typing
        input = $(event.target)
        Messages.update(this._id, {$set: {text: input.val()}})
      
      if updated
        # Focus on new message after it has been rendered
        delay 50, ->
          focus_editable()
  }

# Server
if (Meteor.is_server)
  Meteor.methods({
    join_chat: (chat_name, my_name) ->
      # Add instructional message if necessary
      if (Messages.find({chat: chat_name}).count() == 0)
        Messages.insert({
          name: "babble",
          text: "hey! welcome to real-time chat. share the link to this page to a friend, and when they join, you'll be able to see each other typing. have fun!",
          incomplete: false, time: Date.now() - 10, chat: chat_name
        })
        
      # Make sure the user has an editable message
      if not Messages.find({
        name: my_name,
        incomplete: true,
        chat: chat_name
      }).count()
        create_editable_message chat_name, my_name
  })


# Helpers
delay = (time, fn) ->
  setTimeout fn, time

uniqueID = (length=8) ->
  id = ""
  id += Math.random().toString(36).substr(2) while id.length < length
  id.substr 0, length

# For differently-colored messages
String.prototype.hashCode = ->
  hash = 0
  if (this.length == 0)
    return hash
  for i in [0..this.length - 1]
    char = this.charCodeAt(i)
    hash = ((hash<<5)-hash) + char
    hash = hash & hash # Convert to 32-bit integer
  return hash