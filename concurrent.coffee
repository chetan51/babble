Messages = new Meteor.Collection("messages")

if (Meteor.is_client)
  window.Messages = Messages
  
  Template.chat.messages = ->
    Messages.find()
  
  Template.message.incomplete = ->
    if this.incomplete then " incomplete" else ''
  
  Template.message.editing = ->
    true
  
  is_mine = (message) ->
    message.name == "john"
    
  Template.message.which_side = ->
    if is_mine(this) then " right" else " left"
    
  Template.message.color = ->
    if is_mine(this) then " grey" else " blue"

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