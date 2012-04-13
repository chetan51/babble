Messages = new Meteor.Collection("messages")

if (Meteor.is_client)
  window.Messages = Messages
  
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
    if this.incomplete then " incomplete" else ''
  
  Template.message.class_side = ->
    if is_mine(this) then " right" else " left"
    
  Template.message.class_color = ->
    if is_mine(this) then " grey" else " blue"
    
  Template.message.timestamp = ->
    d = new Date(this.time)
    d.toTimeString()
   
  Template.message.events = {
    'keydown textarea': (event) ->
      code = if event.keyCode then event.keyCode else event.which
      if (code == 13) # Enter was pressed
        # Mark message as complete
        Messages.update(this._id, {$set: {incomplete: false, time: Date.now() - 1}})
        
        # Create new incomplete message
        Messages.insert({
          name: Session.get("my_name"),
          incomplete: true, time: Date.now()
        })
        
        # Focus on new message after it has been rendered
        delay 50, ->
          focus_editable()
      
    'keyup textarea': (event) ->
      input = $(event.target)
      Messages.update(this._id, {$set: {text: input.val()}})
  }
  
  Session.set("my_name", "john") # for debugging
  focus_editable()


if (Meteor.is_server)
  Meteor.startup ->
    if (Messages.find().count() == 0)
      Messages.insert({
        name: "john",
        text: "hey!",
        incomplete: false, time: Date.now() - (5 * 60 * 1000)
      })
      Messages.insert({
        name: "lisa",
        text: "how's it going?",
        incomplete: false, time: Date.now() - (4 * 60 * 1000)
      })
      Messages.insert({
        name: "john",
        text: "it's good, yo",
        incomplete: true, time: Date.now() - (2 * 60 * 1000)
      })
      Messages.insert({
        name: "lisa",
        text: "i heard you got into th",
        incomplete: true, time: Date.now() - (1 * 60 * 1000)
      })

# Helpers
delay = (time, fn) ->
  setTimeout fn, time