# Models
Chats    = new Meteor.Collection("chats")
Messages = new Meteor.Collection("messages")

# Client
if (Meteor.is_client)
  window.Chats    = Chats
  window.Messages = Messages
  
  $(window).bind "popstate", (event) ->
    chat_name = location.pathname.substr(1) # get rid of leading /
    update_current_chat(chat_name)
    delay 50, ->
      focus_name_prompt()
  
  focus_name_prompt = ->
    $("#name-prompt input").focus()

  Meteor.startup ->
    focus_name_prompt()
  
  ensure_instructional_message = ->
    if (Messages.find({chat: Session.get("current_chat_name")}).count() == 0)
      Messages.insert({
        name: "babble",
        text: "hey! welcome to real-time chat. share the link to this page to a friend, and when they join, you'll be able to see each other typing. have fun!",
        incomplete: false, time: Date.now() - 10, chat: Session.get("current_chat_name")
      })

  create_new_message = ->
    Messages.insert({
      name: Session.get("my_name"),
      incomplete: true, time: Date.now(), chat: Session.get("current_chat_name")
    })
  
  Template.name_prompt.class_visible = ->
    if Session.get("my_name") then "hidden" else "visible"
    
  Template.name_prompt.class_buttons_visible = ->
    if Session.get("current_chat_name") then "hidden" else "visible"
   
  update_name = ->
    my_name = $("#name-prompt input[type='text']").val()
    if my_name.length
      Session.set("my_name", my_name)
   
  update_current_chat = (chat_name) ->
    if chat_name.length
      Session.set("current_chat_name", chat_name)

  update_url = (chat_name) ->
    window.history.pushState(null, null, "/" + chat_name);
    
  ensure_editable_message = ->
    if Session.get("current_chat_name") and Session.get("my_name")
      if not Messages.find({
        name: Session.get("my_name"),
        incomplete: true,
        chat: Session.get("current_chat_name")
      }).count()
        create_new_message()
       
      #Focus on editable message after it has been rendered
      delay 50, ->
        focus_editable()

  join_chat = (chat_name) ->
    update_name()
    update_current_chat(chat_name)
    update_url(chat_name)
    ensure_instructional_message()
    ensure_editable_message()

  Template.name_prompt.events = {
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
        ensure_instructional_message()
        ensure_editable_message()
  }
  
  Template.chat.class_visible = ->
    if Session.get("my_name") then "visible" else "hidden"
  
  Template.chat.messages = ->
    Messages.find({chat: Session.get("current_chat_name")}, {sort: {time:1}})
  
  is_mine = (message) ->
    message.name == Session.get("my_name")
    
  is_editable = (message) ->
    is_mine(message) and message.incomplete
   
  focus_editable = ->
    $("#editable textarea").focus()

  Template.message.editable = ->
    is_editable(this)
  
  Template.message.id_editable = ->
    if is_editable(this) then "editable" else ''
  
  Template.message.class_incomplete = ->
    if this.incomplete then "incomplete" else ''
  
  Template.message.class_side = ->
    if is_mine(this) then "right" else "left"
    
  Template.message.class_color = ->
    if is_mine(this) then "grey" else "blue"
    
  Template.message.timestamp = ->
    d = new Date(this.time)
    d.toTimeString()
   
  Template.message.events = {
    'keydown textarea': (event) ->
      input = $(event.target)
      code = if event.keyCode then event.keyCode else event.which
      updated = false
      
      if (code == 13) # Enter was pressed
        # Mark message as complete
        Messages.update(this._id, {$set: {incomplete: false, time: Date.now() - 1}})
        
        # Create new incomplete message
        create_new_message()
        
        updated = true
      else if input.val().length == 0
          # This is the first character, so update the timestamp
          Messages.update(this._id, {$set: {time: Date.now()}})
          updated = true
      
      if updated
        # Focus on new message after it has been rendered
        delay 50, ->
          focus_editable()
      
    'keyup textarea': (event) ->
      input = $(event.target)
      Messages.update(this._id, {$set: {text: input.val()}})
  }

# Server
if (Meteor.is_server)
  Meteor.startup ->
    if (Chats.find().count() == 0)
      Chats.insert({name: "public", created: Date.now()})
 
# Helpers
delay = (time, fn) ->
  setTimeout fn, time

uniqueID = (length=8) ->
  id = ""
  id += Math.random().toString(36).substr(2) while id.length < length
  id.substr 0, length
 