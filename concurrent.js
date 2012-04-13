Messages = new Meteor.Collection("messages");

if (Meteor.is_client) {
  Template.chat.messages = function() {
    return Messages.find();
  };
  
  Template.message.complete = function() {
    return this.complete ? " complete" : '';
  }
  
  Template.message.editing = function() {
    return true;
  }

  //Template.hello.events = {
    //'click input' : function () {
      //// template data, if any, is available in 'this'
      //if (typeof console !== 'undefined')
        //console.log("You pressed the button");
    //}
  //};
}

if (Meteor.is_server) {
  Meteor.startup(function () {
    if (Messages.find().count() === 0) {
      Messages.insert({name: "concurrent", text: "welcome!", complete: true});
    }
  });
}