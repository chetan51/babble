Messages = new Meteor.Collection("messages")

if (Meteor.is_client)
  window.Messages = Messages
  
  Template.chat.messages = ->
    Messages.find()
  
  is_mine = (message) ->
    message.name == Session.get("my_name")
    
  is_editable = (message) ->
    is_mine(message) and message.incomplete
   
  focus_editable = ->
    console.log $("#editable textarea")
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
    
  Template.message.events = {
    'keydown textarea': (event) ->
      code = if event.keyCode then event.keyCode else event.which
      if (code == 13) # enter was pressed
        # Mark message as complete
        Messages.update(this._id, {$set: {incomplete: false}})
        
        # Create new incomplete message
        Messages.insert({
          name: Session.get("my_name"),
          incomplete: true
        })
        
        # Focus on new message after it has been rendered
        delay 50, ->
          focus_editable()
      else
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
        incomplete: false, time: "3:13p"
      })
      Messages.insert({
        name: "lisa",
        text: "how's it going?",
        incomplete: false, time: "3:13p"
      })
      Messages.insert({
        name: "john",
        text: "it's good, yo",
        incomplete: true, time: "3:14p"
      })
      Messages.insert({
        name: "lisa",
        text: "i heard you got into th",
        incomplete: true, time: "3:14p"
      })

# Helpers
delay = (time, fn) ->
  setTimeout fn, time