Messages = new Meteor.Collection("messages")

if (Meteor.is_client)
  window.Messages = Messages
  
  Template.chat.messages = ->
    return Messages.find()
  
  Template.message.complete = ->
    return this.complete ? " complete" : ''
  
  Template.message.editing = ->
    return true

if (Meteor.is_server)
  Meteor.startup ->
    if (Messages.find().count() == 0)
      Messages.insert({name: "concurrent", text: "welcome!", complete: true})