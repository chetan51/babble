# Models
Messages = new Meteor.Collection("messages")

# Client
if (Meteor.is_client)
  window.Messages = Messages
  
  create_new_message = ->
    Messages.insert({
      name: Session.get("my_name"),
      incomplete: true, time: Date.now()
    })
  
  Template.name_prompt.class_visible = ->
    if Session.get("my_name") then "hidden" else "visible"
   
  Template.name_prompt.events = {
    'keydown input': (event) ->
      code = if event.keyCode then event.keyCode else event.which
      if (code == 13) # Enter was pressed
        input = $(event.target)
        Session.set("my_name", input.val())
        if not Messages.find({name: Session.get("my_name"), incomplete: true}).count()
          create_new_message()
  }
  
  Template.chat.class_visible = ->
    if Session.get("my_name") then "visible" else "hidden"
  
  Template.chat.messages = ->
    Messages.find({}, {sort: {time:1}})
  
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
  
  focus_editable()

# Server
if (Meteor.is_server)
  Meteor.startup ->
    if (Messages.find().count() == 0)
      Messages.insert({
        name: "concurrent",
        text: "hey! welcome to real-time chat. share the link to this page to a friend, and when they join, you'll be able to see each other typing. have fun!",
        incomplete: false, time: Date.now() - 10
      })
 
# Helpers
delay = (time, fn) ->
  setTimeout fn, time

uniqueID = (length=8) ->
  id = ""
  id += Math.random().toString(36).substr(2) while id.length < length
  id.substr 0, length
 